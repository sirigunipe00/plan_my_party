import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plan_my_party/main.dart';
import 'package:plan_my_party/widgets/venue_picker.dart';
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

  testWidgets('guest creates an event in four separate steps', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(PartyApp(store: store));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Explore as a guest →'));
    await tester.tap(find.text('Explore as a guest →'));
    await tester.pumpAndSettle();

    // Step 1: date & time, with the logo and no scrolling.
    expect(find.text('Plan my party'), findsOneWidget);
    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('step-date-time')), findsOneWidget);
    expect(find.text('Starts at'), findsOneWidget);
    expect(
      find.image(const AssetImage('assets/images/celebration.jpg')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('step-date-time')),
        matching: find.byType(Scrollable),
      ),
      findsNothing,
    );
    expect(find.text('Back'), findsNothing);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 2: location is required before moving on.
    expect(find.text('Step 2 of 4'), findsOneWidget);
    expect(find.byType(VenuePicker), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 4'), findsOneWidget);
    expect(find.text('Search and select an event location.'), findsOneWidget);
    tester
        .widget<VenuePicker>(find.byType(VenuePicker))
        .onPicked(const VenuePick('Sunny Hall, Hyderabad', 17.4156, 78.4347));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 4'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 3: decoration is its own scrollable screen and needs one item.
    expect(find.text('Step 3 of 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('step-decoration')), findsOneWidget);
    expect(
      find.text('Fresh flowers for the tables and stage'),
      findsOneWidget,
    );
    final decorationScroll = find.descendant(
      of: find.byKey(const ValueKey('step-decoration')),
      matching: find.byType(Scrollable),
    );
    expect(
      tester
          .state<ScrollableState>(decorationScroll)
          .position
          .maxScrollExtent,
      greaterThan(0),
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Select at least one decoration item.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('add-flowers')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add another Floral arrangement'));
    await tester.tap(find.byTooltip('Add another Floral arrangement'));
    await tester.tap(find.byTooltip('Remove one Floral arrangement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 4: furniture is scrollable and needs one item before create.
    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('step-furniture')), findsOneWidget);
    final furnitureScroll = find.descendant(
      of: find.byKey(const ValueKey('step-furniture')),
      matching: find.byType(Scrollable),
    );
    expect(
      tester.state<ScrollableState>(furnitureScroll).position.maxScrollExtent,
      greaterThan(0),
    );
    await tester.tap(find.text('Create Event'));
    await tester.pumpAndSettle();
    expect(find.text('Select at least one furniture item.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('add-chairs')));
    await tester.pumpAndSettle();
    expect(find.text('3 selected · ₹11,500'), findsOneWidget);
    await tester.tap(find.text('Create Event'));
    await tester.pumpAndSettle();
    expect(store.events.first.location, 'Sunny Hall, Hyderabad');
    expect(store.events.first.latitude, 17.4156);
    expect(store.events.first.longitude, 78.4347);
    expect(store.events.first.lines.map((line) => line.id), [
      'flowers',
      'chairs',
    ]);
    expect(store.events.first.lines.map((line) => line.quantity), [2, 1]);
    expect(store.events.first.budget, 11500);
    expect(find.text('Your event has been created.'), findsOneWidget);
    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await store.persist();
    final restored = await AppStore.load();
    expect(restored.events.first.lines.length, 2);
    restored.dispose();
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
        expect(find.text('Plan my party'), findsOneWidget);
        expect(tester.takeException(), isNull);
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
