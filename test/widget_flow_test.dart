import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plan_my_party/main.dart';
import 'package:plan_my_party/state/app_store.dart';
import 'package:plan_my_party/screens/planner_screen.dart';
import 'package:plan_my_party/screens/vendor_screens.dart';
import 'package:plan_my_party/screens/quote_screens.dart';
import 'package:plan_my_party/screens/event_screens.dart';
import 'package:plan_my_party/screens/profile_screens.dart';
import 'package:plan_my_party/data/catalog.dart';
import 'package:plan_my_party/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('DMSans')
      ..addFont(rootBundle.load('assets/fonts/dm-sans.ttf'));
    await fonts.load();
  });
  late AppStore store;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await AppStore.load();
  });
  tearDown(() => store.dispose());

  testWidgets('guest can create a celebration through all four steps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(PartyApp(store: store));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Explore as a guest →'));
    await tester.tap(find.text('Explore as a guest →'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Ananya ✦'), findsOneWidget);
    await tester.tap(find.text('Plan an event'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('event-name')),
      'Sunny’s birthday',
    );
    await tester.enterText(find.byKey(const ValueKey('event-guests')), '90');
    await tester.tap(find.text('Choose your services'));
    await tester.pumpAndSettle();
    expect(find.text('Build your\nkind of celebration.'), findsOneWidget);
    await tester.tap(find.text('Let’s talk budget'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('total-budget')),
      '125000',
    );
    await tester.tap(find.text('Review my celebration'));
    await tester.pumpAndSettle();
    expect(find.text('Sunny’s birthday'), findsOneWidget);
    await tester.tap(find.text('Save my celebration'));
    await tester.pumpAndSettle();
    expect(store.events.first.name, 'Sunny’s birthday');
    expect(store.events.first.guests, 90);
    expect(store.events.first.budget, 125000);
    expect(store.draft, isNull);
    expect(
      find.text('It’s a plan.\nAnd it’s going to be lovely.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await store.persist();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('vendor favorites and the selected-vendor quote work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final lens = vendorById('lens');
    await tester.pumpWidget(
      MaterialApp(
        theme: partyTheme(),
        home: VendorDetailScreen(store: store, vendor: lens),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Save vendor'));
    await tester.pumpAndSettle();
    expect(store.favorites, contains('lens'));
    await tester.tap(find.text('Try a quote'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate sample quote'));
    await tester.pumpAndSettle();
    expect(store.events.first.quotes, contains('lens'));
    expect(store.events.first.requests.single.vendorId, 'lens');
    expect(find.text('Your sample quotes'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await store.persist();
    await tester.pumpWidget(const SizedBox());
  });

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets(
      'key screens render at ${width.toInt()}px without layout exceptions',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        store.onboarded = true;
        await tester.pumpWidget(PartyApp(store: store));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final tab in ['Explore', 'My events', 'Updates', 'Profile']) {
          await tester.tap(find.text(tab).last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: tab);
        }
        final event = store.events.first;
        for (final screen in <Widget>[
          VendorDetailScreen(store: store, vendor: vendors.first),
          EventDetailScreen(store: store, eventId: event.id),
          QuotesScreen(store: store, eventId: event.id),
          CompareScreen(store: store, eventId: event.id),
          FavoritesScreen(store: store),
          PersonalScreen(store: store),
          AddressesScreen(store: store),
          PrivacyScreen(store: store),
        ]) {
          await tester.pumpWidget(
            MaterialApp(key: UniqueKey(), theme: partyTheme(), home: screen),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: screen.runtimeType.toString(),
          );
        }
        store.startDraft();
        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            theme: partyTheme(),
            home: PlannerScreen(store: store),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await store.persist();
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
