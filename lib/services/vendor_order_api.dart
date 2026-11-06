import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

enum VendorOrderStatus { pending, accepted, rejected }

class VendorOrder {
  final String id;
  final VendorOrderStatus status;
  final String vendorName;
  final String message;
  const VendorOrder({
    required this.id,
    required this.status,
    required this.vendorName,
    required this.message,
  });

  factory VendorOrder.fromJson(Map<String, dynamic> json) {
    final raw = '${json['status'] ?? 'pending'}'.toLowerCase();
    final status = switch (raw) {
      'accepted' || 'approved' => VendorOrderStatus.accepted,
      'rejected' || 'declined' => VendorOrderStatus.rejected,
      _ => VendorOrderStatus.pending,
    };
    return VendorOrder(
      id: '${json['id'] ?? ''}',
      status: status,
      vendorName: '${json['vendorName'] ?? json['vendor_name'] ?? 'Vendor'}',
      message: '${json['message'] ?? ''}',
    );
  }
}

abstract class VendorOrderApi {
  Future<VendorOrder> submit({
    required String eventName,
    required String location,
    required double latitude,
    required double longitude,
    required double amount,
    required List<Map<String, dynamic>> items,
  });

  Future<VendorOrder> status(String orderId);
}

/// Real HTTP vendor approval backend.
///
/// Configure with `--dart-define=VENDOR_ORDER_URL=https://your-api.example`.
/// Expected endpoints:
/// - POST `$base/orders` → `{ id, status, vendorName, message }`
/// - GET `$base/orders/:id` → same shape
class HttpVendorOrderApi implements VendorOrderApi {
  final String baseUrl;
  final http.Client? client;
  HttpVendorOrderApi({required this.baseUrl, this.client});

  Uri _uri(String path) {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$root$path');
  }

  Map<String, String> get _headers => const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'User-Agent': 'PlanMyParty/1.0 (celebration planner)',
  };

  http.Client get _http => client ?? http.Client();

  @override
  Future<VendorOrder> submit({
    required String eventName,
    required String location,
    required double latitude,
    required double longitude,
    required double amount,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _http
        .post(
          _uri('/orders'),
          headers: _headers,
          body: jsonEncode({
            'eventName': eventName,
            'location': location,
            'latitude': latitude,
            'longitude': longitude,
            'amount': amount,
            'items': items,
          }),
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Vendor order could not be created.');
    }
    final body = jsonDecode(response.body);
    if (body is! Map) throw StateError('Invalid vendor order response.');
    return VendorOrder.fromJson(Map<String, dynamic>.from(body));
  }

  @override
  Future<VendorOrder> status(String orderId) async {
    final response = await _http
        .get(_uri('/orders/$orderId'), headers: _headers)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Vendor status is unavailable.');
    }
    final body = jsonDecode(response.body);
    if (body is! Map) throw StateError('Invalid vendor status response.');
    return VendorOrder.fromJson(Map<String, dynamic>.from(body));
  }
}

/// Local backend used when `VENDOR_ORDER_URL` is not configured.
///
/// It still behaves like a remote service: create an order id, then resolve
/// status asynchronously after a short review window based on order details.
class LocalVendorOrderApi implements VendorOrderApi {
  final Map<String, _LocalOrder> _orders = {};
  final math.Random _random;
  final Duration reviewDelay;
  final Duration submitDelay;
  LocalVendorOrderApi({
    math.Random? random,
    this.reviewDelay = const Duration(seconds: 4),
    this.submitDelay = const Duration(milliseconds: 450),
  }) : _random = random ?? math.Random();

  @override
  Future<VendorOrder> submit({
    required String eventName,
    required String location,
    required double latitude,
    required double longitude,
    required double amount,
    required List<Map<String, dynamic>> items,
  }) async {
    await Future<void>.delayed(submitDelay);
    final id =
        'VO-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(999)}';
    final vendorName = _vendorFor(items);
    // Reject clearly incomplete / oversized mock requests so both outcomes work.
    final reject =
        items.isEmpty ||
        amount <= 0 ||
        location.toLowerCase().contains('reject-demo');
    _orders[id] = _LocalOrder(
      id: id,
      vendorName: vendorName,
      decideAt: DateTime.now().add(reviewDelay),
      rejected: reject,
    );
    return VendorOrder(
      id: id,
      status: VendorOrderStatus.pending,
      vendorName: vendorName,
      message: 'Waiting for $vendorName to review your order.',
    );
  }

  @override
  Future<VendorOrder> status(String orderId) async {
    final order = _orders[orderId];
    if (order == null) {
      throw StateError('Vendor order was not found.');
    }
    // Tiny yield so UI can paint the pending state before approval.
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (DateTime.now().isBefore(order.decideAt)) {
      return VendorOrder(
        id: order.id,
        status: VendorOrderStatus.pending,
        vendorName: order.vendorName,
        message: 'Waiting for ${order.vendorName} to accept your order.',
      );
    }
    if (order.rejected) {
      return VendorOrder(
        id: order.id,
        status: VendorOrderStatus.rejected,
        vendorName: order.vendorName,
        message:
            '${order.vendorName} could not take this order. Please adjust your plan and try again.',
      );
    }
    return VendorOrder(
      id: order.id,
      status: VendorOrderStatus.accepted,
      vendorName: order.vendorName,
      message:
          '${order.vendorName} accepted your order. Opening payment…',
    );
  }

  String _vendorFor(List<Map<String, dynamic>> items) {
    final groups = items.map((item) => '${item['group'] ?? ''}').toSet();
    if (groups.contains('Furniture')) return 'Seat Well';
    if (groups.contains('Decoration')) return 'Dream Events';
    if (groups.contains('Party Props')) return 'Beat Box';
    return 'Plan My Party Partners';
  }
}

class _LocalOrder {
  final String id, vendorName;
  final DateTime decideAt;
  final bool rejected;
  _LocalOrder({
    required this.id,
    required this.vendorName,
    required this.decideAt,
    required this.rejected,
  });
}

VendorOrderApi createVendorOrderApi({http.Client? client}) {
  const configured = String.fromEnvironment('VENDOR_ORDER_URL');
  if (configured.trim().isEmpty) {
    return LocalVendorOrderApi();
  }
  return HttpVendorOrderApi(baseUrl: configured.trim(), client: client);
}
