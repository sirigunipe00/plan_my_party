import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/catalog_widgets.dart';
import 'planner_screen.dart';
import 'vendor_screens.dart';
import 'quote_screens.dart';

class MyEventsScreen extends StatefulWidget {
  final AppStore store;
  const MyEventsScreen({super.key, required this.store});
  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  String status = 'Upcoming';
  @override
  Widget build(BuildContext context) {
    final events = widget.store.events
        .where((e) => e.status == status)
        .toList();
    return RootScroll(
      children: [
        const Eyebrow('LIFE’S HAPPIEST MOMENTS'),
        gap8,
        Row(
          children: [
            Expanded(
              child: Text(
                'Your celebrations.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => openPlanner(context, widget.store),
              tooltip: 'Plan a new event',
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        gap8,
        const Text('The big picture. And every lovely little detail.'),
        gap24,
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            style: const ButtonStyle(
              textStyle: WidgetStatePropertyAll(
                TextStyle(fontSize: 11, fontFamily: 'DMSans'),
              ),
            ),
            segments: const [
              ButtonSegment(value: 'Upcoming', label: Text('Upcoming')),
              ButtonSegment(value: 'Completed', label: Text('Completed')),
              ButtonSegment(value: 'Cancelled', label: Text('Cancelled')),
            ],
            selected: {status},
            onSelectionChanged: (s) => setState(() => status = s.first),
          ),
        ),
        gap24,
        if (events.isEmpty)
          EmptyState(
            'No ${status.toLowerCase()} celebrations.',
            status == 'Upcoming'
                ? 'Your next happy memory starts with a little planning.'
                : 'Events appear here when you update their status.',
            icon: Icons.calendar_month_outlined,
            action: status == 'Upcoming'
                ? PrimaryButton(
                    'Plan something lovely',
                    onPressed: () => openPlanner(context, widget.store),
                  )
                : null,
          ),
        ...events.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 17),
            child: PartyCard(
              padding: EdgeInsets.zero,
              onTap: () => pushPage(
                context,
                EventDetailScreen(store: widget.store, eventId: e.id),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/images/${e.image}',
                        height: 135,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        left: 13,
                        bottom: 12,
                        child: StatusBadge(
                          e.statusLabel,
                          green: e.bookings.isNotEmpty,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        gap8,
                        Text(
                          '${dateLabel(e.date, short: true)} · ${e.location.split(',').first}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        gap16,
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${e.guests} guests · ${e.services.length} services',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            Text(
                              money(e.budget),
                              style: const TextStyle(
                                color: AppColors.purple,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        gap16,
                        PrimaryButton(
                          'See the happy details',
                          outline: true,
                          onPressed: () => pushPage(
                            context,
                            EventDetailScreen(
                              store: widget.store,
                              eventId: e.id,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const DemoNotice(text: 'Your plans are saved on this device.'),
      ],
    );
  }
}

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
                      'This moves ${event.name} to Cancelled. You can restore it from My events. No vendor will be contacted.',
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
        bottom: event.status == 'Upcoming'
            ? PrimaryButton(
                'Find more party people',
                icon: Icons.search,
                onPressed: () => pushPage(
                  context,
                  VendorBrowsePage(store: store, eventId: eventId),
                ),
              )
            : null,
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
            child: Column(
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
                    'A great celebration starts with great people. Find your favorites and try a sample quote.',
                  ),
                  TextButton(
                    onPressed: () => pushPage(
                      context,
                      VendorBrowsePage(store: store, eventId: eventId),
                    ),
                    child: const Text('Explore vendors →'),
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

class UpdatesScreen extends StatelessWidget {
  final AppStore store;
  const UpdatesScreen({super.key, required this.store});
  @override
  Widget build(BuildContext context) {
    final updates =
        <
          ({
            EventPlan event,
            IconData icon,
            String title,
            String text,
            bool quotes,
          })
        >[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final event in store.events) {
      for (final b in event.bookings) {
        updates.add((
          event: event,
          icon: Icons.check_circle_outline,
          title: '${vendorById(b.vendorId).name} added to your plan',
          text: 'Demo booking saved for ${event.name}.',
          quotes: false,
        ));
      }
      if (store.quoteUpdates && event.quotes.isNotEmpty) {
        updates.add((
          event: event,
          icon: Icons.chat_bubble_outline,
          title: '${event.quotes.length} sample quotes to explore',
          text: 'Compare a few lovely options for ${event.name}.',
          quotes: true,
        ));
      }
      final until = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      ).difference(today).inDays;
      if (store.eventReminders &&
          event.status == 'Upcoming' &&
          until >= 0 &&
          until <= 1) {
        updates.add((
          event: event,
          icon: Icons.celebration_outlined,
          title: until == 0
              ? 'Your happy day is here!'
              : 'Your celebration is tomorrow!',
          text: event.name,
          quotes: false,
        ));
      }
    }
    return RootScroll(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your happy\nupdates.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            TextButton(
              onPressed: () {
                store.alertsRead = true;
                store.changed();
                notify(context, 'All caught up.');
              },
              child: const Text('Mark as read', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
        gap8,
        const Text('The little things to keep your plans moving.'),
        const SectionTitle('Your celebrations'),
        if (updates.isEmpty)
          const EmptyState(
            'All quiet, in a good way.',
            'Your event updates will appear here.',
            icon: Icons.notifications_none_rounded,
          ),
        ...updates.map(
          (u) => ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            onTap: () {
              store.alertsRead = true;
              store.changed();
              pushPage(
                context,
                u.quotes
                    ? QuotesScreen(store: store, eventId: u.event.id)
                    : EventDetailScreen(store: store, eventId: u.event.id),
              );
            },
            leading: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: AppColors.lavender,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(u.icon, color: AppColors.purple, size: 22),
            ),
            title: Text(
              u.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            subtitle: Text(
              '${u.text}\nSaved on this device',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: store.alertsRead
                ? null
                : const CircleAvatar(
                    radius: 3,
                    backgroundColor: AppColors.purple,
                  ),
          ),
        ),
        const DemoNotice(
          text: 'In-app demo updates · Push delivery is not connected.',
        ),
      ],
    );
  }
}
