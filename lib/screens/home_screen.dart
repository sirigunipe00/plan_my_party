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
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
              children: [
                const Eyebrow('WELCOME TO PLAN MY PARTY'),
                gap8,
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
                    height: 320,
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
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Eyebrow(
                                'LET’S MAKE IT A CELEBRATION',
                                color: Color(0xffF1DCDC),
                              ),
                              gap12,
                              const Text(
                                'Big day coming up?\nLet’s make it unforgettable.',
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
                                  minimumSize: const Size(double.infinity, 62),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                onPressed: () => openPlanner(context, store),
                                icon: const Icon(Icons.add, size: 22),
                                label: const Text('Plan an Event'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
