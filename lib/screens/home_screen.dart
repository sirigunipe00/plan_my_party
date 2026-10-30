import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/catalog_widgets.dart';
import 'planner_screen.dart';
import 'event_screens.dart';
import 'vendor_screens.dart';

class HomeScreen extends StatelessWidget {
  final AppStore store;
  final ValueChanged<int> onTab;
  const HomeScreen({super.key, required this.store, required this.onTab});
  @override
  Widget build(BuildContext context) {
    final upcoming = store.events.where((e) => e.status == 'Upcoming').toList();
    return RootScroll(
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'plan my party.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _location(context),
                    child: Text(
                      '⌖ ${store.profile.city} ⌄',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => onTab(3),
              tooltip: 'Your updates',
              icon: Badge(
                isLabelVisible: !store.alertsRead,
                smallSize: 5,
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ),
            InkWell(
              onTap: () => onTab(4),
              borderRadius: BorderRadius.circular(30),
              child: CircleAvatar(
                backgroundColor: const Color(0xffE8DCCF),
                child: Text(
                  store.profile.initials,
                  style: const TextStyle(
                    color: Color(0xff765640),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 27),
        Text(
          'Hello, ${store.profile.firstName} ✦',
          style: const TextStyle(fontSize: 13),
        ),
        gap8,
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Life’s little moments.\n'),
              const TextSpan(
                text: 'Made unforgettable.',
                style: TextStyle(color: AppColors.purple),
              ),
            ],
          ),
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        gap24,
        ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: SizedBox(
            height: 221,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/celebration.jpg', fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xcc302139), Color(0x11302139)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(21),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow(
                        'LET’S MAKE IT A CELEBRATION',
                        color: Color(0xffF1DCDC),
                      ),
                      gap12,
                      const Text(
                        'Your next happy\nmemory starts here.',
                        style: TextStyle(
                          fontSize: 25,
                          height: 1.15,
                          letterSpacing: -.7,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      gap16,
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.deep,
                          minimumSize: const Size(0, 44),
                        ),
                        onPressed: () => openPlanner(context, store),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text(
                          'Plan an event',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SectionTitle('What’s the occasion?'),
        Row(
          children:
              [
                    ('Birthday', Icons.cake_outlined, const Color(0xffF7E7DE)),
                    (
                      'Anniversary',
                      Icons.celebration_outlined,
                      const Color(0xffF5E5EC),
                    ),
                    ('Corporate', Icons.work_outline, const Color(0xffE6EDE8)),
                    ('More', Icons.grid_view_rounded, const Color(0xffEBE5F6)),
                  ]
                  .map(
                    (c) => Expanded(
                      child: InkWell(
                        onTap: () => c.$1 == 'More'
                            ? _occasions(context)
                            : openPlanner(context, store, type: c.$1),
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              Container(
                                width: 57,
                                height: 57,
                                decoration: BoxDecoration(
                                  color: c.$3,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  c.$2,
                                  size: 27,
                                  color: AppColors.deep.withValues(alpha: .65),
                                ),
                              ),
                              gap8,
                              Text(
                                c.$1,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        SectionTitle(
          'Your next celebration',
          action: 'View all ›',
          onAction: () => onTab(2),
        ),
        if (upcoming.isNotEmpty)
          EventTile(
            upcoming.first,
            onTap: () => pushPage(
              context,
              EventDetailScreen(store: store, eventId: upcoming.first.id),
            ),
          )
        else
          EmptyState(
            'Your next memory is waiting.',
            'Start planning something lovely.',
            action: PrimaryButton(
              'Plan an event',
              onPressed: () => openPlanner(context, store),
            ),
          ),
        SectionTitle(
          'Meet your party people',
          action: 'See all ›',
          onAction: () => onTab(1),
        ),
        VendorGrid(
          vendors: vendors.take(2).toList(),
          store: store,
          onOpen: (v) =>
              pushPage(context, VendorDetailScreen(store: store, vendor: v)),
        ),
        gap12,
        PartyCard(
          color: const Color(0xffF2EFD8),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good times, thoughtfully planned.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    gap8,
                    Text(
                      'Your people. Your budget. Your kind of party.',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.card_giftcard_outlined,
                size: 30,
                color: Color(0xff9D8C45),
              ),
            ],
          ),
        ),
        const DemoNotice(),
      ],
    );
  }

  void _occasions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Every occasion deserves a little joy.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            gap16,
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: eventTypes
                  .map(
                    (t) => ActionChip(
                      label: Text(t),
                      onPressed: () {
                        Navigator.pop(sheet);
                        openPlanner(context, store, type: t);
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _location(BuildContext context) async {
    final controller = TextEditingController(text: store.profile.city);
    final result = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Where’s the happy happening?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLength: 60,
              decoration: const InputDecoration(labelText: 'Your city'),
            ),
            gap12,
            const Text('The sample catalog is based in Hyderabad.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(d, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      store.profile.city = result;
      store.changed();
    }
  }
}
