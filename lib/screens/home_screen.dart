import 'package:flutter/material.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'planner_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppStore store;
  const HomeScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
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
                          Text(
                            '⌖ ${store.profile.city}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
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
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Hello, ${store.profile.firstName} ✦',
                  style: const TextStyle(fontSize: 13),
                ),
                gap8,
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Your Next Memory\n'),
                      TextSpan(
                        text: 'Starts Here',
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
                    height: 240,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/wedding.jpg',
                          fit: BoxFit.cover,
                        ),
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
                              const Spacer(),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.deep,
                                  minimumSize: const Size(0, 44),
                                ),
                                onPressed: () => openPlanner(context, store),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text(
                                  'Plan an Event',
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
                const SectionTitle('A celebration, beautifully set'),
                gap8,
                SizedBox(
                  height: 168,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _moodTile(
                          context,
                          image: 'decoration.jpg',
                          title: 'Décor that feels personal',
                          subtitle: 'Flowers, lights & finishing touches',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                              child: _moodTile(
                                context,
                                image: 'furniture.jpg',
                                title: 'Furniture',
                                subtitle: 'Seating & tables',
                                compact: true,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: _moodTile(
                                context,
                                image: 'flowers.jpg',
                                title: 'Details',
                                subtitle: 'Props & extras',
                                compact: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                gap24,
                PartyCard(
                  color: const Color(0xffF2EFD8),
                  child: const Row(
                    children: [
                      Expanded(
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
                              'Pick a date, pin a place in India, choose décor and furniture, then book with confidence.',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.card_giftcard_outlined,
                        size: 30,
                        color: Color(0xff9D8C45),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _moodTile(
    BuildContext context, {
    required String image,
    required String title,
    required String subtitle,
    bool compact = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => openPlanner(context, store),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: DecorationImage(
              image: AssetImage('assets/images/$image'),
              fit: BoxFit.cover,
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: compact ? 0.55 : 0.62),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(compact ? 10 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 12 : 15,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: compact ? 9 : 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
