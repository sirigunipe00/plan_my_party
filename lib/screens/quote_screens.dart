import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'event_screens.dart';
import 'vendor_screens.dart';

Future<void> tryBooking(
  BuildContext context,
  AppStore store,
  EventPlan event,
  Vendor vendor,
) async {
  if (event.status != 'Upcoming') {
    notify(context, 'Choose an upcoming event before booking.');
    return;
  }
  final existing = event.bookings.any((b) => b.vendorId == vendor.id);
  if (!existing) {
    final over = event.bookedTotal + vendor.quote - event.budget;
    final ok = await confirm(
      context,
      title: 'A happy match?',
      message:
          '${vendor.name}\n${event.name}\nSample quote: ${money(vendor.quote)}\n\n${over > 0 ? 'This puts demo bookings ${money(over)} over the planned budget.\n\n' : ''}This saves a demo booking on your device. No reservation, vendor contact or payment takes place.',
      action: 'Save demo booking',
    );
    if (!ok || !context.mounted) return;
    store.bookDemo(event, vendor);
    await store.persist();
  }
  if (!context.mounted) return;
  await pushPage(
    context,
    BookingScreen(store: store, eventId: event.id, vendorId: vendor.id),
  );
}

class QuotesScreen extends StatelessWidget {
  final AppStore store;
  final String eventId;
  const QuotesScreen({super.key, required this.store, required this.eventId});
  @override
  Widget build(BuildContext context) => StoreView(
    store: store,
    builder: (context) {
      final event = store.eventById(eventId);
      final quotes = event.quotes.map(vendorById).toList();
      return AppPage(
        title: 'Your sample quotes',
        bottom: quotes.length > 1
            ? PrimaryButton(
                'Compare sample quotes',
                outline: true,
                icon: Icons.compare_arrows_rounded,
                onPressed: () => pushPage(
                  context,
                  CompareScreen(store: store, eventId: eventId),
                ),
              )
            : null,
        children: [
          PageHeading(
            'A good fit.\nAt a happy price.',
            subtitle: '${quotes.length} sample quotes for ${event.name}.',
          ),
          const DemoNotice(
            text:
                'These are generated examples, not responses from real vendors. No payment is taken.',
          ),
          if (quotes.isEmpty)
            EmptyState(
              'No quotes just yet.',
              'Find your party people and try a sample request.',
              icon: Icons.chat_bubble_outline,
              action: PrimaryButton(
                'Explore vendors',
                onPressed: () => pushPage(
                  context,
                  VendorBrowsePage(store: store, eventId: eventId),
                ),
              ),
            ),
          ...quotes.map((v) {
            final booked = event.bookings.any((b) => b.vendorId == v.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PartyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.asset(
                            'assets/images/${v.image}',
                            height: 48,
                            width: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '★ ${v.rating} (${v.reviews})',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(v.badge),
                      ],
                    ),
                    gap16,
                    Text(
                      money(v.quote),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    gap8,
                    Text(
                      v.services.join(' · '),
                      style: const TextStyle(fontSize: 12),
                    ),
                    gap16,
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${v.setup} setup',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        StatusBadge(
                          booked ? 'Saved to event' : 'Sample quote',
                          green: booked,
                        ),
                      ],
                    ),
                    gap16,
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            'Details',
                            outline: true,
                            icon: null,
                            onPressed: () => _details(context, v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PrimaryButton(
                            booked ? 'View booking' : 'Try booking',
                            icon: Icons.chevron_right,
                            onPressed: () =>
                                tryBooking(context, store, event, v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    },
  );
  void _details(BuildContext context, Vendor vendor) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vendor.name, style: Theme.of(context).textTheme.titleLarge),
              gap16,
              StatusBadge('${vendor.badge} · Sample quote'),
              gap16,
              Text(
                money(vendor.quote),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              gap12,
              Text(vendor.services.join(' · ')),
              gap16,
              InfoPair('Package', vendor.packageName),
              InfoPair('Setup', vendor.setup),
              InfoPair(
                'Sample rating',
                '★ ${vendor.rating} (${vendor.reviews})',
              ),
              const DemoNotice(
                text:
                    'This example does not guarantee a vendor, availability, tax treatment or final price.',
              ),
              PrimaryButton(
                'View vendor profile',
                onPressed: () {
                  Navigator.pop(sheet);
                  pushPage(
                    context,
                    VendorDetailScreen(
                      store: store,
                      vendor: vendor,
                      eventId: eventId,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompareScreen extends StatelessWidget {
  final AppStore store;
  final String eventId;
  const CompareScreen({super.key, required this.store, required this.eventId});
  @override
  Widget build(BuildContext context) {
    final event = store.eventById(eventId),
        quotes = event.quotes.map(vendorById).toList();
    return AppPage(
      title: 'Compare sample quotes',
      children: [
        const PageHeading(
          'The details\nmake the difference.',
          subtitle: 'Compare your options side by side.',
        ),
        const Text(
          'Swipe the table to see every vendor →',
          style: TextStyle(fontSize: 11),
        ),
        gap16,
        PartyCard(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: const WidgetStatePropertyAll(AppColors.lavender),
              dataRowMinHeight: 65,
              dataRowMaxHeight: 110,
              columnSpacing: 21,
              horizontalMargin: 16,
              columns: [
                const DataColumn(
                  label: Text('THE DETAILS', style: TextStyle(fontSize: 10)),
                ),
                ...quotes.map(
                  (v) => DataColumn(
                    label: SizedBox(
                      width: 120,
                      child: Text(
                        v.name,
                        style: const TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              rows: [
                for (final row in <(String, String Function(Vendor))>[
                  ('Price', (v) => money(v.quote)),
                  ('Rating', (v) => '★ ${v.rating} (${v.reviews})'),
                  ('Package', (v) => v.packageName),
                  ('Includes', (v) => v.services.join(', ')),
                  ('Setup time', (v) => v.setup),
                ])
                  DataRow(
                    cells: [
                      DataCell(
                        Text(row.$1, style: const TextStyle(fontSize: 11)),
                      ),
                      ...quotes.map(
                        (v) => DataCell(
                          SizedBox(
                            width: 120,
                            child: Text(
                              row.$2(v),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                DataRow(
                  cells: [
                    const DataCell(
                      Text('Sample booking', style: TextStyle(fontSize: 11)),
                    ),
                    ...quotes.map(
                      (v) => DataCell(
                        TextButton(
                          onPressed: () => tryBooking(context, store, event, v),
                          child: const Text('Select →'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const DemoNotice(
          text:
              'Sample quotes include no real availability or vendor commitment.',
        ),
      ],
    );
  }
}

class BookingScreen extends StatelessWidget {
  final AppStore store;
  final String eventId, vendorId;
  const BookingScreen({
    super.key,
    required this.store,
    required this.eventId,
    required this.vendorId,
  });
  @override
  Widget build(BuildContext context) {
    final event = store.eventById(eventId), vendor = vendorById(vendorId);
    final booking = event.bookings.firstWhere((b) => b.vendorId == vendorId);
    return AppPage(
      title: 'Saved to your celebration',
      children: [
        const SizedBox(height: 30),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.lavender,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.purple,
              size: 52,
            ),
          ),
        ),
        const SizedBox(height: 35),
        const Center(child: Eyebrow('ONE MORE DETAIL, TAKEN CARE OF')),
        gap16,
        Center(
          child: Text(
            'Your demo booking\nis all set.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        gap16,
        Text(
          'You’ve added ${vendor.name} to your celebration. Here’s how your booking summary would look.',
          textAlign: TextAlign.center,
        ),
        gap24,
        PartyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vendor.name, style: Theme.of(context).textTheme.titleLarge),
              gap8,
              const StatusBadge('Demo booking saved', green: true),
              gap16,
              InfoPair('Event', event.name),
              InfoPair('Date', dateLabel(event.date)),
              InfoPair('Services', vendor.services.join(', ')),
              InfoPair('Reference', booking.reference),
              const Divider(),
              InfoPair('Sample total', money(booking.amount)),
            ],
          ),
        ),
        gap24,
        PrimaryButton(
          'View my celebration',
          onPressed: () => pushPage(
            context,
            EventDetailScreen(store: store, eventId: eventId),
          ),
        ),
        gap12,
        PrimaryButton(
          'Contact information',
          outline: true,
          icon: Icons.chat_bubble_outline,
          onPressed: () => showDialog<void>(
            context: context,
            builder: (d) => AlertDialog(
              title: const Text('Your party people'),
              content: const Text(
                'This is a sample vendor. Phone, chat and email are not connected to a real business.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(d),
                  child: const Text('Got it'),
                ),
              ],
            ),
          ),
        ),
        const DemoNotice(
          text: 'Demo only · No vendor contacted · No payment collected.',
        ),
      ],
    );
  }
}
