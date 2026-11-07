import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plan_my_party/main.dart';
import 'package:plan_my_party/models/models.dart';
import 'package:plan_my_party/widgets/venue_picker.dart';
import 'package:plan_my_party/state/app_store.dart';
import 'package:plan_my_party/screens/planner_screen.dart';
import 'package:plan_my_party/screens/vendor_screens.dart';
import 'package:plan_my_party/screens/quote_screens.dart';
import 'package:plan_my_party/screens/event_screens.dart';
import 'package:plan_my_party/screens/profile_screens.dart';
import 'package:plan_my_party/data/catalog.dart';
import 'package:plan_my_party/services/vendor_order_api.dart';
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

  testWidgets('home opens create event with date, location and categories', (
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

    expect(find.textContaining('Your Next Memory'), findsOneWidget);
    await tester.tap(find.text('Plan an Event'));
    await tester.pumpAndSettle();

    expect(find.text('Create Event'), findsOneWidget);
    expect(find.text('Step 1 of 6'), findsOneWidget);
    expect(find.byKey(const ValueKey('step-date-time')), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.byType(VenuePicker), findsOneWidget);
    tester
        .widget<VenuePicker>(find.byType(VenuePicker))
        .onPicked(const VenuePick('Sunny Hall, Hyderabad', 17.4156, 78.4347));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Party Decorations'), findsOneWidget);
    expect(find.text('Furniture'), findsOneWidget);
    expect(find.text('Party Props'), findsOneWidget);
    expect(find.text('Other Party Needs'), findsOneWidget);
    await tester.tap(find.text('Furniture'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-chairs')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add another Guest chairs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 items selected'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('summary charges, vendor approval and payment confirm booking', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    store.draft = EventPlan(date: DateTime.now())
      ..start = '18:00'
      ..end = '23:00'
      ..location = 'Sunny Hall, Hyderabad'
      ..latitude = 17.4156
      ..longitude = 78.4347
      ..lines.addAll([
        ServiceLine(
          id: 'flowers',
          group: 'Decoration',
          name: 'Floral arrangement',
          price: 4500,
          quantity: 1,
        ),
        ServiceLine(
          id: 'chairs',
          group: 'Furniture',
          name: 'Guest chairs',
          price: 2500,
          quantity: 2,
        ),
      ]);

    final api = _ScriptedVendorApi();
    await tester.pumpWidget(
      MaterialApp(
        theme: partyTheme(),
        home: PlannerScreen(store: store, vendorApi: api),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Order summary'), findsOneWidget);
    expect(find.text('Delivery charge'), findsOneWidget);
    expect(find.text('Setup charge'), findsOneWidget);
    expect(find.text('GST (18%)'), findsOneWidget);
    await tester.tap(find.text('Request vendor approval'));
    await tester.pump(); // show vendor pending
    expect(find.byKey(const ValueKey('step-vendor')), findsOneWidget);

    // Poll 1 pending → wait → poll 2 accepted → wait → auto payment.
    await tester.pump(const Duration(milliseconds: 850));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 850));
    expect(find.byKey(const ValueKey('step-payment')), findsOneWidget);
    await tester.tap(find.text('Pay now'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('payment-card-number')),
      '4111111111111111',
    );
    await tester.enterText(
      find.byKey(const ValueKey('payment-expiry')),
      '12/30',
    );
    await tester.enterText(find.byKey(const ValueKey('payment-cvv')), '123');
    await tester.enterText(
      find.byKey(const ValueKey('payment-name')),
      'Ananya Rao',
    );
    await tester.tap(find.text('Pay now').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('payment-otp')),
      '123456',
    );
    await tester.tap(find.text('Confirm payment'));
    await tester.pumpAndSettle();

    expect(find.text('Booking confirmed'), findsOneWidget);
    expect(store.events.first.paid, isTrue);
    expect(store.events.first.deliveryCharge, greaterThan(0));
    expect(store.events.first.gstAmount, greaterThan(0));
    expect(
      store.events.first.orderTotal,
      closeTo(
        store.events.first.taxableAmount + store.events.first.gstAmount,
        0.001,
      ),
    );
    expect(store.events.first.lines.length, 2);
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
        expect(find.text('Plan an Event'), findsOneWidget);
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

class _ScriptedVendorApi implements VendorOrderApi {
  var statusChecks = 0;

  @override
  Future<VendorOrder> submit({
    required String eventName,
    required String location,
    required double latitude,
    required double longitude,
    required double amount,
    required List<Map<String, dynamic>> items,
  }) async => const VendorOrder(
    id: 'VO-test',
    status: VendorOrderStatus.pending,
    vendorName: 'Seat Well',
    message: 'Waiting for Seat Well to accept your order.',
  );

  @override
  Future<VendorOrder> status(String orderId) async {
    statusChecks += 1;
    if (statusChecks < 2) {
      return const VendorOrder(
        id: 'VO-test',
        status: VendorOrderStatus.pending,
        vendorName: 'Seat Well',
        message: 'Waiting for Seat Well to accept your order.',
      );
    }
    return const VendorOrder(
      id: 'VO-test',
      status: VendorOrderStatus.accepted,
      vendorName: 'Seat Well',
      message: 'Seat Well accepted your order. Opening payment…',
    );
  }
}
