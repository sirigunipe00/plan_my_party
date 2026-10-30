import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plan_my_party/data/catalog.dart';
import 'package:plan_my_party/models/models.dart';
import 'package:plan_my_party/state/app_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppStore store;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await AppStore.load();
  });
  tearDown(() => store.dispose());

  test('sample state and changed profile survive loading storage', () async {
    expect(store.events.single.quotes, ['dream', 'petal', 'glow']);
    store.profile.name = 'Sunny';
    store.onboarded = true;
    store.toggleFavorite('lens');
    await store.persist();
    final restored = await AppStore.load();
    expect(restored.profile.name, 'Sunny');
    expect(restored.onboarded, isTrue);
    expect(restored.favorites, contains('lens'));
    restored.dispose();
  });

  test('draft edits, balloon inspiration and budget survive reload', () async {
    final draft = store.startDraft('Wedding');
    draft.name = 'A lovely evening';
    draft.guests = 90;
    draft.budget = 125000;
    draft.balloons.theme = 'Lavender & gold';
    draft.balloons.images.add('c2FtcGxl');
    store.changed(debounce: true);
    await store.persist();
    final restored = await AppStore.load();
    expect(restored.draft!.name, 'A lovely evening');
    expect(restored.draft!.type, 'Wedding');
    expect(restored.draft!.balloons.images, ['c2FtcGxl']);
    expect(restored.draft!.budget, 125000);
    restored.dispose();
  });

  test('planner validates total shares, times and guest counts', () {
    final d = EventPlan(name: 'Sunny’s birthday');
    expect(d.validateBasics(), isNull);
    expect(d.validateBudget(), isNull);
    d.allocations[0].percent = 20;
    expect(d.validateBudget(), contains('100%'));
    d.allocations[0].percent = 25;
    d.budget = double.nan;
    expect(d.validateBudget(), isNotNull);
    d.end = '17:00';
    expect(d.validateBasics(), contains('end time'));
    d.end = '23:00';
    d.guests = 0;
    expect(d.validateBasics(), contains('guests'));
  });

  test('saved event preserves details and clears its draft', () async {
    final draft = store.startDraft()
      ..name = 'Sunny’s <great> birthday'
      ..guests = 90
      ..budget = 125000;
    final event = store.saveEvent();
    expect(event.name, draft.name);
    expect(event.guests, 90);
    expect(event.budget, 125000);
    expect(event.id, isNotEmpty);
    expect(event.quotes, isEmpty);
    expect(store.draft, isNull);
    await store.persist();
    final restored = await AppStore.load();
    expect(restored.events.first.name, event.name);
    restored.dispose();
  });

  test(
    'quote and booking belong to the selected vendor and cannot duplicate',
    () async {
      store.startDraft().name = 'A new birthday';
      final event = store.saveEvent();
      final lens = vendorById('lens');
      store.requestQuote(event, lens, 24000, 'Candid photos please.');
      expect(event.quotes, ['lens']);
      expect(event.requests.single.notes, 'Candid photos please.');
      final first = store.bookDemo(event, lens),
          second = store.bookDemo(event, lens);
      expect(first.reference, second.reference);
      expect(event.bookings.length, 1);
      expect(event.bookedTotal, 22000);
      store.setEventStatus(event, 'Cancelled');
      expect(
        () => store.bookDemo(event, vendorById('dream')),
        throwsStateError,
      );
      store.setEventStatus(event, 'Upcoming');
      expect(event.status, 'Upcoming');
      await store.persist();
    },
  );

  test('combined catalog filtering and sorting use actual vendor data', () {
    expect(findVendors(search: 'candid').map((v) => v.id), ['lens']);
    expect(findVendors(area: 'Jubilee Hills', rating: 4.8).map((v) => v.id), [
      'lens',
    ]);
    expect(
      findVendors(category: 'Decoration', maxPrice: 10000).map((v) => v.id),
      ['dream', 'petal'],
    );
    expect(findVendors(sort: 'price').first.id, 'beat');
    expect(findVendors(search: 'missing vendor'), isEmpty);
  });

  test('demo reset clears local changes and restores onboarding', () async {
    store.profile.name = 'Sunny';
    store.onboarded = true;
    store.toggleFavorite('dream');
    await store.reset();
    expect(store.onboarded, isFalse);
    expect(store.favorites, isEmpty);
    expect(store.events.length, 1);
    final restored = await AppStore.load();
    expect(restored.profile.name, 'Ananya Rao');
    restored.dispose();
  });
}
