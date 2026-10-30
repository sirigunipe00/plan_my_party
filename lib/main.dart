import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'state/app_store.dart';
import 'theme/app_theme.dart';
import 'screens/app_shell.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  final store = await AppStore.load();
  runApp(PartyApp(store: store));
}

class PartyApp extends StatefulWidget {
  final AppStore store;
  const PartyApp({super.key, required this.store});
  @override
  State<PartyApp> createState() => _PartyAppState();
}

class _PartyAppState extends State<PartyApp> with WidgetsBindingObserver {
  final messenger = GlobalKey<ScaffoldMessengerState>();
  String? shownError;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.store.addListener(_watchStorage);
  }

  void _watchStorage() {
    final error = widget.store.lastStorageError;
    if (error == null || error == shownError) return;
    shownError = error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      messenger.currentState?.showSnackBar(SnackBar(content: Text(error)));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(widget.store.persist());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.store.removeListener(_watchStorage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) => MaterialApp(
      title: 'Plan My Party',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: messenger,
      theme: partyTheme(),
      home: widget.store.onboarded
          ? AppShell(store: widget.store)
          : WelcomeScreen(store: widget.store),
    ),
  );
}
