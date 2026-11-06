import 'dart:math' as math;

import '../models/models.dart';

/// Warehouse / fulfillment hub used to estimate delivery distance.
const fulfillmentHubLatitude = 17.3850;
const fulfillmentHubLongitude = 78.4867;

class OrderCharges {
  final double items;
  final double delivery;
  final double pickup;
  final double setup;
  final double distanceKm;
  const OrderCharges({
    required this.items,
    required this.delivery,
    required this.pickup,
    required this.setup,
    required this.distanceKm,
  });

  double get extras => delivery + pickup + setup;
  double get grandTotal => items + extras;
}

double distanceKmBetween(
  double latitude,
  double longitude, {
  double fromLat = fulfillmentHubLatitude,
  double fromLon = fulfillmentHubLongitude,
}) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRadians(latitude - fromLat);
  final dLon = _toRadians(longitude - fromLon);
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(fromLat)) *
          math.cos(_toRadians(latitude)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _toRadians(double degrees) => degrees * math.pi / 180;

/// Calculates delivery, pickup, and setup fees from location and cart size.
OrderCharges calculateOrderCharges({
  required List<ServiceLine> lines,
  required double? latitude,
  required double? longitude,
}) {
  final items = lines.fold<double>(0, (sum, line) => sum + line.total);
  final units = lines.fold<int>(0, (sum, line) => sum + line.quantity);
  final distance = (latitude != null && longitude != null)
      ? distanceKmBetween(latitude, longitude)
      : 8.0;

  final delivery = 250 + (distance * 35) + (units * 20);
  final pickup = 150 + (distance * 20) + (units * 12);
  final setup = 400 + (units * 45) + (items * 0.02);

  return OrderCharges(
    items: items,
    delivery: _round(delivery),
    pickup: _round(pickup),
    setup: _round(setup),
    distanceKm: _round(distance, digits: 1),
  );
}

double _round(double value, {int digits = 0}) {
  final factor = math.pow(10, digits).toDouble();
  return (value * factor).round() / factor;
}
