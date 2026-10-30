import 'package:flutter/material.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'profile_screens.dart';

class WelcomeScreen extends StatefulWidget {
  final AppStore store;
  const WelcomeScreen({super.key, required this.store});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int page = 0;
  void enter() {
    widget.store.onboarded = true;
    widget.store.changed();
  }

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Big moments.\nBeautifully planned.',
      'Find your\ndream team.',
      'More memories.\nLess to manage.',
    ];
    const subtitles = [
      'From the first idea to the final confetti. Find everything you need for a celebration that feels like you.',
      'Explore decorators, photographers, music and more. Save your favorites and find your perfect match.',
      'Plan your budget, compare sample quotes and bring the little details together in one happy place.',
    ];
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * .44,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(38),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/${page == 1 ? 'wedding.jpg' : 'celebration.jpg'}',
                        fit: BoxFit.cover,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x55352344),
                              Colors.transparent,
                              Color(0x333D254C),
                            ],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.auto_awesome_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 9),
                              const Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  'plan my party.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: enter,
                                child: const Text(
                                  'Skip →',
                                  style: TextStyle(color: Colors.white),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 29, 28, 24),
                child: Column(
                  children: [
                    const Eyebrow('A LITTLE LESS PLANNING. A LOT MORE JOY.'),
                    gap16,
                    Text(
                      titles[page],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(color: AppColors.purple),
                    ),
                    gap12,
                    Text(subtitles[page], textAlign: TextAlign.center),
                    gap16,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(3),
                          height: 5,
                          width: i == page ? 23 : 5,
                          decoration: BoxDecoration(
                            color: i == page
                                ? AppColors.purple
                                : const Color(0xffDCD2EA),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    gap16,
                    PrimaryButton(
                      page == 2 ? 'Let’s get started' : 'Next',
                      onPressed: () async {
                        if (page < 2) {
                          setState(() => page++);
                        } else {
                          await pushPage(
                            context,
                            PersonalScreen(
                              store: widget.store,
                              onboarding: true,
                            ),
                          );
                        }
                      },
                    ),
                    TextButton(
                      onPressed: enter,
                      child: const Text(
                        'Explore as a guest →',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Text(
                      'Local demo · No password needed',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
