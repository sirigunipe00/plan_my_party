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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher'),
          (call) async => true,
        );
  });
  late AppStore store;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await AppStore.load();
  });
  tearDown(() => store.dispose());

  testWidgets('guest can plan a celebration and open UPI checkout', (
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
    expect(find.text('Wedding'), findsNothing);
    await tester.tap(find.text('Plan an event'));
    await tester.pumpAndSettle();
    store.draft!
      ..latitude = 17.4156
      ..longitude = 78.4347
      ..location = 'Banjara Hills, Hyderabad';
    expect(find.text('Wedding'), findsNothing);
    expect(find.text('Engagement'), findsNothing);
    expect(find.text('Reception'), findsNothing);
    expect(find.text('Anniversary'), findsWidgets);
    await tester.enterText(
      find.byKey(const ValueKey('event-name')),
      'Sunny’s birthday',
    );
    await tester.enterText(find.byKey(const ValueKey('event-guests')), '90');
    await tester.tap(find.text('Choose your services'));
    await tester.pumpAndSettle();
    expect(find.text('Build your\nkind of celebration.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('service-Decoration')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-flowers')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review celebration'));
    await tester.pumpAndSettle();
    expect(find.text('Sunny’s birthday'), findsOneWidget);
    expect(find.text('Floral arrangement × 1'), findsOneWidget);
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();
    expect(find.text('Pay with UPI'), findsOneWidget);
    await tester.tap(find.text('Google Pay'));
    await tester.pumpAndSettle();
    expect(store.events.first.name, 'Sunny’s birthday');
    expect(store.events.first.guests, 90);
    expect(store.events.first.budget, 4500);
    expect(store.draft, isNull);
    expect(
      find.text('It’s a plan.\nAnd it’s going to be lovely.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await store.persist();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a chosen occasion is the only one on the celebration screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.onboarded = true;
    await tester.pumpWidget(PartyApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Birthday'));
    await tester.pumpAndSettle();
    expect(find.text('Birthday'), findsWidgets);
    expect(find.text('Corporate'), findsNothing);
    expect(find.text('Baby Shower'), findsNothing);
    expect(store.draft!.occasionChosen, isTrue);
    expect(tester.takeException(), isNull);
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
