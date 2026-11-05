import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'quote_screens.dart';

class EventDetailScreen extends StatelessWidget {
  final AppStore store;
  final String eventId;
  const EventDetailScreen({
    super.key,
    required this.store,
    required this.eventId,
  });
  @override
  Widget build(BuildContext context) => StoreView(
    store: store,
    builder: (context) {
      final event = store.eventById(eventId);
      return AppPage(
        title: 'The happy details',
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Manage event',
            onSelected: (value) async {
              if (value == 'Cancelled') {
                final ok = await confirm(
                  context,
                  title: 'Cancel your local event?',
                  message:
                      'This moves ${event.name} to Cancelled. You can move it back to Upcoming later. No vendor will be contacted.',
                  action: 'Cancel local event',
                );
                if (!ok) return;
              }
              store.setEventStatus(event, value);
            },
            itemBuilder: (_) => event.status == 'Upcoming'
                ? const [
                    PopupMenuItem(
                      value: 'Completed',
                      child: Text('Mark as completed'),
                    ),
                    PopupMenuItem(
                      value: 'Cancelled',
                      child: Text('Cancel local event'),
                    ),
                  ]
                : const [
                    PopupMenuItem(
                      value: 'Upcoming',
                      child: Text('Move back to upcoming'),
                    ),
                  ],
          ),
        ],
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Image.asset(
              'assets/images/${event.image}',
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          gap16,
          StatusBadge(event.statusLabel, green: event.bookings.isNotEmpty),
          gap12,
          Text(event.name, style: Theme.of(context).textTheme.headlineMedium),
          gap24,
          EventFacts(event),
          if (event.description.isNotEmpty) Text(event.description),
          const SectionTitle('Your party essentials'),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: event.services.map((s) => Chip(label: Text(s))).toList(),
          ),
          if (event.services.contains('Balloons') &&
              (event.balloons.theme.isNotEmpty ||
                  event.balloons.images.isNotEmpty)) ...[
            const SectionTitle('The little details'),
            PartyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoPair('Balloons', '${event.balloons.quantity}'),
                  InfoPair('Colors', event.balloons.colors.join(', ')),
                  if (event.balloons.theme.isNotEmpty)
                    InfoPair('Theme', event.balloons.theme),
                  if (event.balloons.notes.isNotEmpty)
                    InfoPair('Notes', event.balloons.notes),
                  if (event.balloons.images.isNotEmpty) ...[
                    gap12,
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: event.balloons.images
                          .map(
                            (data) => ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.memory(
                                base64Decode(data),
                                width: 75,
                                height: 75,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SectionTitle('A happy budget'),
          PartyCard(
            child: event.lines.isEmpty
                ? Column(
                    children: [
                      InfoPair('Total planned', money(event.budget)),
                      gap12,
                      BudgetBar(event.allocations),
                      gap12,
                      InfoPair('Demo bookings', money(event.bookedTotal)),
                      InfoPair(
                        event.bookedTotal > event.budget
                            ? 'Over planned budget'
                            : 'Still in your plan',
                        money((event.budget - event.bookedTotal).abs()),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      ...event.lines.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InfoPair(
                            '${line.group} · ${line.name}${line.quantity > 1 ? ' × ${line.quantity}' : ''}',
                            money(line.total),
                          ),
                        ),
                      ),
                      InfoPair('Total', money(event.itemsTotal)),
                    ],
                  ),
          ),
          SectionTitle(
            'Your party people',
            action: event.quotes.isEmpty
                ? null
                : '${event.quotes.length} quotes ›',
            onAction: () =>
                pushPage(context, QuotesScreen(store: store, eventId: eventId)),
          ),
          if (event.bookings.isEmpty)
            PartyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your event is saved. Your selected items appear above.',
                  ),
                ],
              ),
            )
          else
            ...event.bookings.map((b) {
              final v = vendorById(b.vendorId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: PartyCard(
                  onTap: () => pushPage(
                    context,
                    BookingScreen(
                      store: store,
                      eventId: eventId,
                      vendorId: v.id,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.asset(
                          'assets/images/${v.image}',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.name,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${v.category} · ${money(b.amount)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            gap8,
                            const StatusBadge(
                              'Demo booking saved',
                              green: true,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            }),
          const SectionTitle('How it’s coming together'),
          _timeline(
            Icons.check_circle_outline,
            'Celebration planned',
            event.sample ? 'Sample event' : dateLabel(event.created),
            true,
          ),
          _timeline(
            Icons.chat_bubble_outline,
            event.quotes.isEmpty
                ? 'Find your party people'
                : '${event.quotes.length} sample quotes ready',
            'Compare the details that matter.',
            event.quotes.isNotEmpty,
          ),
          _timeline(
            Icons.task_alt,
            event.bookings.isEmpty
                ? 'Bring the details together'
                : '${event.bookings.length} demo bookings saved',
            'Your plans stay on this device.',
            event.bookings.isNotEmpty,
          ),
          _timeline(
            Icons.celebration_outlined,
            'The happy day',
            '${dateLabel(event.date)} · ${timeLabel(event.start)}',
            false,
          ),
          const DemoNotice(),
        ],
      );
    },
  );
  Widget _timeline(IconData icon, String title, String subtitle, bool done) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 21),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 21,
              color: done ? AppColors.purple : const Color(0xffC7BCD6),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      );
}
