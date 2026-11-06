import 'dart:async';

import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../services/order_charges.dart';
import '../services/vendor_order_api.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/venue_picker.dart';
import 'category_items_screen.dart';
import 'payment_gateway.dart';

Future<void> openPlanner(
  BuildContext context,
  AppStore store, {
  String? type,
}) async {
  store.draft = null;
  store.startDraft(type);
  await pushPage(context, PlannerScreen(store: store));
}

class PlannerScreen extends StatefulWidget {
  final AppStore store;
  final VendorOrderApi? vendorApi;
  const PlannerScreen({super.key, required this.store, this.vendorApi});
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  static const _stepNames = [
    'Date & time',
    'Location',
    'Categories',
    'Summary',
    'Vendor',
    'Payment',
  ];

  late EventPlan draft;
  late final VendorOrderApi vendorApi;
  int step = 0;
  bool submitting = false;
  bool pollingVendor = false;
  String? vendorMessage;
  Timer? vendorPoll;

  @override
  void initState() {
    super.initState();
    vendorApi = widget.vendorApi ?? createVendorOrderApi();
    final existing = widget.store.draft;
    if (existing == null) {
      draft = EventPlan(date: DateTime.now());
      widget.store.draft = draft;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.store.changed();
      });
    } else {
      draft = existing;
    }
    draft.normalizeLines();
  }

  @override
  void dispose() {
    vendorPoll?.cancel();
    super.dispose();
  }

  void save() => widget.store.changed(debounce: true);

  void _go(int value) {
    FocusScope.of(context).unfocus();
    setState(() => step = value.clamp(0, _stepNames.length - 1));
  }

  OrderCharges get charges => calculateOrderCharges(
    lines: draft.lines,
    latitude: draft.latitude,
    longitude: draft.longitude,
  );

  void _applyCharges() {
    final next = charges;
    draft
      ..deliveryCharge = next.delivery
      ..pickupCharge = next.pickup
      ..setupCharge = next.setup
      ..distanceKm = next.distanceKm;
  }

  int get selectedUnits =>
      draft.lines.fold<int>(0, (sum, line) => sum + line.quantity);

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: step == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && step > 0) _go(step - 1);
    },
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (step > 0) {
              _go(step - 1);
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Create Event'),
      ),
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _indicator(),
                  gap16,
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: switch (step) {
                        0 => _dateTime(),
                        1 => _location(),
                        2 => _categories(),
                        3 => _summary(),
                        4 => _vendor(),
                        _ => _paymentReady(),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    ),
  );

  Widget _bottomBar() {
    final last = step >= _stepNames.length - 1;
    final vendorPending =
        step == 4 && draft.vendorStatus == VendorOrderStatus.pending.name;
    final vendorRejected =
        step == 4 && draft.vendorStatus == VendorOrderStatus.rejected.name;
    String label;
    if (step == 4 && vendorRejected) {
      label = 'Back to summary';
    } else if (step == 4 && vendorPending) {
      label = 'Checking vendor…';
    } else if (step == 3) {
      label = 'Request vendor approval';
    } else if (step == 4) {
      label = 'Continue to payment';
    } else if (last) {
      label = submitting ? 'Opening payment…' : 'Pay now';
    } else {
      label = 'Next';
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          child: Row(
            children: [
              if (step > 0 && step != 4) ...[
                Expanded(
                  child: PrimaryButton(
                    'Back',
                    outline: true,
                    icon: null,
                    onPressed: submitting ? null : () => _go(step - 1),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label,
                  icon: last || step == 4
                      ? Icons.check
                      : Icons.arrow_forward_rounded,
                  onPressed: submitting || (step == 4 && vendorPending)
                      ? null
                      : _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicator() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Step ${step + 1} of ${_stepNames.length}',
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.purple,
          fontWeight: FontWeight.w700,
        ),
      ),
      gap8,
      Row(
        children: List.generate(
          _stepNames.length,
          (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i < _stepNames.length - 1 ? 5 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 3,
                    decoration: BoxDecoration(
                      color: i <= step ? AppColors.purple : AppColors.line,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _stepNames[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8,
                      color: i <= step ? AppColors.purple : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _heading(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        gap8,
        Text(subtitle),
      ],
    ),
  );

  Widget _dateTime() => Column(
    key: const ValueKey('step-date-time'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('Date & time', 'When is the party?'),
      _picker(
        Icons.calendar_month_outlined,
        'Event date',
        dateLabel(draft.date),
        _chooseDate,
        large: true,
      ),
      gap12,
      Row(
        children: [
          Expanded(
            child: _picker(
              Icons.schedule,
              'Starts at',
              timeLabel(draft.start),
              () => _chooseTime(true),
              large: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _picker(
              Icons.schedule,
              'Ends at',
              timeLabel(draft.end),
              () => _chooseTime(false),
              large: true,
            ),
          ),
        ],
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox.expand(
              child: Image.asset(
                'assets/images/celebration.jpg',
                fit: BoxFit.cover,
                semanticLabel: 'Celebration',
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _picker(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap, {
    bool large = false,
  }) => PartyCard(
    padding: EdgeInsets.all(large ? 18 : 13),
    onTap: onTap,
    child: Row(
      children: [
        Icon(icon, size: large ? 24 : 19, color: AppColors.purple),
        SizedBox(width: large ? 14 : 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: large ? 12 : 10)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: large ? 16 : 12,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.expand_more, size: large ? 24 : 19),
      ],
    ),
  );

  Future<void> _chooseDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.date.isBefore(today) ? today : draft.date,
      firstDate: today,
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => draft.date = picked);
    save();
  }

  Future<void> _chooseTime(bool start) async {
    final parts = (start ? draft.start : draft.end)
        .split(':')
        .map(int.parse)
        .toList();
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: parts[0], minute: parts[1]),
    );
    if (value == null || !mounted) return;
    final text =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (start) {
        draft.start = text;
      } else {
        draft.end = text;
      }
    });
    save();
  }

  Widget _location() => Column(
    key: const ValueKey('step-location'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('Location', 'Search and pin where the party happens.'),
      Expanded(
        child: VenuePicker(
          fill: true,
          location: draft.location,
          latitude: draft.latitude,
          longitude: draft.longitude,
          onQueryChanged: () {
            setState(() {
              draft.latitude = null;
              draft.longitude = null;
              draft.location = '';
            });
            save();
          },
          onPicked: (place) {
            setState(() {
              draft.location = place.label;
              draft.latitude = place.latitude;
              draft.longitude = place.longitude;
            });
            save();
          },
        ),
      ),
    ],
  );

  Widget _categories() => Column(
    key: const ValueKey('step-categories'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        'Party categories',
        'Open a category to choose items and quantities.',
      ),
      Expanded(
        child: ListView(
          children: [
            for (final category in partyCategories)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _categoryCard(category),
              ),
            Text(
              selectedUnits == 0
                  ? 'Select at least one item to continue'
                  : '$selectedUnits items selected · ${money(draft.itemsTotal)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _categoryCard(PartyCategory category) {
    final count = draft.lines
        .where((line) => line.group == category.id)
        .fold<int>(0, (sum, line) => sum + line.quantity);
    return PartyCard(
      padding: EdgeInsets.zero,
      onTap: () async {
        await pushPage(
          context,
          CategoryItemsScreen(
            category: category,
            draft: draft,
            onChanged: () {
              setState(() {});
              save();
            },
          ),
        );
        if (mounted) setState(() {});
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(18),
            ),
            child: Image.asset(
              'assets/images/${category.image}',
              width: 92,
              height: 92,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: category.tint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: AppColors.deep, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          category.blurb,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                        if (count > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$count selected',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.purple,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary() {
    _applyCharges();
    final next = charges;
    return Column(
      key: const ValueKey('step-summary'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Order summary',
          'Review items and location-based service charges.',
        ),
        Expanded(
          child: ListView(
            children: [
              PartyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.location,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    gap8,
                    Text(
                      '${dateLabel(draft.date)} · ${timeLabel(draft.start)} – ${timeLabel(draft.end)}',
                    ),
                    gap8,
                    Text(
                      'Distance from fulfillment hub · ${next.distanceKm} km',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              gap12,
              PartyCard(
                child: Column(
                  children: [
                    for (final line in draft.lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InfoPair(
                          '${line.name} × ${line.quantity}',
                          money(line.total),
                        ),
                      ),
                    const Divider(height: 20),
                    InfoPair('Items subtotal', money(next.items)),
                    InfoPair('Delivery charge', money(next.delivery)),
                    InfoPair('Pickup charge', money(next.pickup)),
                    InfoPair('Setup charge', money(next.setup)),
                    const Divider(height: 20),
                    InfoPair('Grand total', money(next.grandTotal)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vendor() {
    final status = draft.vendorStatus;
    final pending = status == VendorOrderStatus.pending.name || status.isEmpty;
    final accepted = status == VendorOrderStatus.accepted.name;
    return Column(
      key: const ValueKey('step-vendor'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Vendor approval',
          pending
              ? 'Waiting for Vendor to Accept Your Order.'
              : accepted
              ? 'Your vendor accepted the order.'
              : 'Your order was not accepted.',
        ),
        Expanded(
          child: Center(
            child: PartyCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      pending
                          ? Icons.hourglass_top_rounded
                          : accepted
                          ? Icons.verified_rounded
                          : Icons.cancel_outlined,
                      key: ValueKey(status),
                      size: 54,
                      color: pending
                          ? AppColors.purple
                          : accepted
                          ? AppColors.green
                          : const Color(0xffC45B5B),
                    ),
                  ),
                  gap16,
                  Text(
                    pending
                        ? 'Waiting for Vendor to Accept Your Order.'
                        : accepted
                        ? '${draft.vendorName} accepted your order'
                        : '${draft.vendorName.isEmpty ? 'Vendor' : draft.vendorName} declined your order',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  gap12,
                  Text(
                    vendorMessage ??
                        (pending
                            ? 'We’re checking with a nearby partner for your location and items.'
                            : ''),
                    textAlign: TextAlign.center,
                  ),
                  if (pending) ...[
                    gap16,
                    const LinearProgressIndicator(
                      minHeight: 3,
                      color: AppColors.purple,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _paymentReady() => Column(
    key: const ValueKey('step-payment'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        'Payment',
        'Your vendor is ready. Complete payment to confirm the booking.',
      ),
      PartyCard(
        child: Column(
          children: [
            InfoPair('Vendor', draft.vendorName),
            InfoPair('Items', money(draft.itemsTotal)),
            InfoPair('Delivery + pickup + setup', money(draft.extrasTotal)),
            const Divider(height: 20),
            InfoPair('Amount due', money(draft.orderTotal)),
          ],
        ),
      ),
      gap16,
      const Text(
        'You’ll enter card, net banking, or wallet details on the secure payment screen.',
      ),
    ],
  );

  String? _validate() {
    switch (step) {
      case 0:
        if (draft.date.isBefore(DateUtils.dateOnly(DateTime.now()))) {
          return 'Choose today or a future date.';
        }
        if (draft.end.compareTo(draft.start) <= 0) {
          return 'The end time must be after the start time.';
        }
        return null;
      case 1:
        if (draft.latitude == null ||
            draft.longitude == null ||
            draft.location.trim().isEmpty) {
          return 'Search and select an event location.';
        }
        return null;
      case 2:
        if (draft.lines.isEmpty) {
          return 'Choose at least one item from any category.';
        }
        return null;
      case 3:
        return null;
      case 4:
        if (draft.vendorStatus == VendorOrderStatus.rejected.name) {
          return null;
        }
        if (draft.vendorStatus != VendorOrderStatus.accepted.name) {
          return 'Waiting for the vendor to accept your order.';
        }
        return null;
      default:
        return null;
    }
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    if (step == 4 && draft.vendorStatus == VendorOrderStatus.rejected.name) {
      _go(3);
      return;
    }
    final error = _validate();
    if (error != null) {
      notify(context, error);
      return;
    }
    if (step == 3) {
      await _requestVendor();
      return;
    }
    if (step == 5) {
      await _payAndConfirm();
      return;
    }
    if (step < _stepNames.length - 1) {
      _go(step + 1);
    }
  }

  Future<void> _requestVendor() async {
    setState(() {
      submitting = true;
      vendorMessage = null;
      draft.vendorStatus = VendorOrderStatus.pending.name;
      draft.vendorOrderId = '';
      draft.vendorName = '';
    });
    _applyCharges();
    draft.name =
        '${draft.occasionChosen ? draft.type : 'Event'} · ${dateLabel(draft.date, short: true)}';
    try {
      final order = await vendorApi.submit(
        eventName: draft.name,
        location: draft.location,
        latitude: draft.latitude!,
        longitude: draft.longitude!,
        amount: draft.orderTotal,
        items: draft.lines.map((line) => line.toJson()).toList(),
      );
      if (!mounted) return;
      setState(() {
        submitting = false;
        draft.vendorOrderId = order.id;
        draft.vendorName = order.vendorName;
        draft.vendorStatus = order.status.name;
        vendorMessage = order.message;
        step = 4;
      });
      save();
      _startVendorPolling();
    } catch (_) {
      if (!mounted) return;
      setState(() => submitting = false);
      notify(context, 'Could not reach the vendor service. Please try again.');
    }
  }

  void _startVendorPolling() {
    vendorPoll?.cancel();
    if (draft.vendorOrderId.isEmpty) return;
    pollingVendor = true;
    _pollVendorStatus();
  }

  Future<void> _pollVendorStatus() async {
    if (!mounted || !pollingVendor || draft.vendorOrderId.isEmpty) return;
    try {
      final order = await vendorApi.status(draft.vendorOrderId);
      if (!mounted || !pollingVendor) return;
      setState(() {
        draft.vendorStatus = order.status.name;
        draft.vendorName = order.vendorName;
        vendorMessage = order.message;
      });
      save();
      if (order.status == VendorOrderStatus.accepted) {
        pollingVendor = false;
        vendorPoll?.cancel();
        vendorPoll = Timer(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          if (draft.vendorStatus == VendorOrderStatus.accepted.name &&
              step == 4) {
            setState(() => step = 5);
          }
        });
        return;
      }
      if (order.status == VendorOrderStatus.rejected) {
        pollingVendor = false;
        vendorPoll?.cancel();
        return;
      }
    } catch (_) {
      // Keep waiting; the next poll may succeed.
    }
    if (!mounted || !pollingVendor) return;
    vendorPoll?.cancel();
    vendorPoll = Timer(const Duration(milliseconds: 800), () {
      unawaited(_pollVendorStatus());
    });
  }

  Future<void> _payAndConfirm() async {
    setState(() => submitting = true);
    final paid = await pushPage<bool>(
      context,
      PaymentGatewayScreen(
        amount: draft.orderTotal,
        note: draft.name.isEmpty ? 'Plan My Party booking' : draft.name,
      ),
    );
    if (!mounted) return;
    if (paid != true) {
      setState(() => submitting = false);
      notify(context, 'Payment was not completed.');
      return;
    }
    await _confirmBooking();
  }

  Future<void> _confirmBooking() async {
    draft.normalizeLines();
    _applyCharges();
    draft.paid = true;
    draft.name =
        '${draft.occasionChosen ? draft.type : 'Event'} · ${dateLabel(draft.date, short: true)}';
    draft.applyLines();
    try {
      final event = widget.store.saveEvent();
      await widget.store.persist();
      if (!mounted) return;
      setState(() => submitting = false);
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(event: event),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => submitting = false);
      notify(context, 'Could not confirm your booking. Please try again.');
    }
  }
}

class BookingConfirmationScreen extends StatelessWidget {
  final EventPlan event;
  const BookingConfirmationScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Booking confirmed'),
    ),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.celebration_outlined,
                  size: 48,
                  color: AppColors.purple,
                ),
                gap16,
                Text(
                  'You’re all set.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                gap8,
                Text(
                  '${event.name} is booked with ${event.vendorName.isEmpty ? 'your vendor' : event.vendorName}.',
                ),
                gap16,
                PartyCard(
                  child: Column(
                    children: [
                      InfoPair('When', '${dateLabel(event.date)} · ${timeLabel(event.start)}'),
                      InfoPair('Where', event.location),
                      InfoPair('Items', money(event.itemsTotal)),
                      InfoPair('Delivery', money(event.deliveryCharge)),
                      InfoPair('Pickup', money(event.pickupCharge)),
                      InfoPair('Setup', money(event.setupCharge)),
                      const Divider(height: 20),
                      InfoPair('Paid', money(event.orderTotal)),
                    ],
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  'Back to home',
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
