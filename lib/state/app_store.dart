import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppStore extends ChangeNotifier {
  static const storageKey = 'plan_my_party.flutter.v1';
  final SharedPreferences preferences;
  AppStore(this.preferences);
  Profile profile = Profile();
  bool onboarded = false,
      alertsRead = false,
      quoteUpdates = true,
      eventReminders = true;
  Set<String> favorites = {};
  List<EventPlan> events = [];
  List<SavedAddress> addresses = [
    SavedAddress('Home', 'Banjara Hills, Hyderabad'),
  ];
  EventPlan? draft;
  String? lastStorageError;
  Timer? _saveTimer;
  Future<void>? _pending;

  static Future<AppStore> load() async {
    final store = AppStore(await SharedPreferences.getInstance());
    store.restore();
    return store;
  }

  void restore() {
    final raw = preferences.getString(storageKey);
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        if (j['version'] != 1) {
          throw const FormatException('Unsupported data version');
        }
        profile = Profile.fromJson(
          Map<String, dynamic>.from(j['profile'] as Map),
        );
        onboarded = j['onboarded'] as bool? ?? false;
        alertsRead = j['alertsRead'] as bool? ?? false;
        quoteUpdates = j['quoteUpdates'] as bool? ?? true;
        eventReminders = j['eventReminders'] as bool? ?? true;
        favorites = Set<String>.from(j['favorites'] ?? []);
        events = (j['events'] as List)
            .map((e) => EventPlan.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        addresses = (j['addresses'] as List? ?? [])
            .map(
              (e) => SavedAddress.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        if (j['draft'] != null) {
          draft = EventPlan.fromJson(
            Map<String, dynamic>.from(j['draft'] as Map),
          );
        }
        return;
      } catch (_) {
        // Keep a copy of unreadable local data for recovery instead of discarding it.
        unawaited(preferences.setString('$storageKey.recovery', raw));
        lastStorageError =
            'Saved data could not be opened. A recovery copy was kept on this device.';
      }
    }
    _sampleState();
  }

  void _sampleState() {
    profile = Profile();
    onboarded = false;
    alertsRead = false;
    quoteUpdates = true;
    eventReminders = true;
    favorites = {};
    draft = null;
    addresses = [SavedAddress('Home', 'Banjara Hills, Hyderabad')];
    events = [
      EventPlan(
        id: 'sample-birthday',
        name: 'Ananya’s Birthday Party',
        description: 'A little pink, a little gold, and a whole lot of joy.',
        sample: true,
        created: DateTime(2026, 10, 29),
        quotes: ['dream', 'petal', 'glow'],
      ),
    ];
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'profile': profile.toJson(),
    'onboarded': onboarded,
    'alertsRead': alertsRead,
    'quoteUpdates': quoteUpdates,
    'eventReminders': eventReminders,
    'favorites': favorites.toList(),
    'events': events.map((e) => e.toJson()).toList(),
    'addresses': addresses.map((a) => a.toJson()).toList(),
    'draft': draft?.toJson(),
  };

  Future<void> persist() {
    _saveTimer?.cancel();
    final snapshot = jsonEncode(toJson());
    Future<void> write() async {
      try {
        final ok = await preferences.setString(storageKey, snapshot);
        if (!ok) throw StateError('Local storage write failed');
        lastStorageError = null;
      } catch (_) {
        lastStorageError =
            'Your latest changes could not be saved. Remove a few photos and try again.';
        notifyListeners();
      }
    }

    final previous = _pending;
    final next = previous == null ? write() : previous.then((_) => write());
    _pending = next;
    return next;
  }

  void changed({bool debounce = false}) {
    notifyListeners();
    if (debounce) {
      _saveTimer?.cancel();
      _saveTimer = Timer(
        const Duration(milliseconds: 250),
        () => unawaited(persist()),
      );
    } else {
      unawaited(persist());
    }
  }

  EventPlan startDraft([String? type]) {
    draft ??= EventPlan();
    if (type != null) draft!.type = type;
    changed();
    return draft!;
  }

  EventPlan saveEvent() {
    final source = draft;
    if (source == null) throw StateError('No event draft');
    final error =
        source.validateBasics() ??
        (source.services.isEmpty
            ? 'Choose at least one service.'
            : source.validateBudget());
    if (error != null) throw StateError(error);
    final event = source.copy()
      ..id = DateTime.now().microsecondsSinceEpoch.toString()
      ..created = DateTime.now()
      ..sample = false;
    events.insert(0, event);
    draft = null;
    alertsRead = false;
    changed();
    return event;
  }

  EventPlan eventById(String id) => events.firstWhere((e) => e.id == id);

  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    changed();
  }

  void requestQuote(
    EventPlan event,
    Vendor vendor,
    double budget,
    String notes,
  ) {
    if (event.status != 'Upcoming') {
      throw StateError('Choose an upcoming event.');
    }
    if (!budget.isFinite || budget <= 0) {
      throw ArgumentError('Enter a valid vendor budget.');
    }
    event.requests.add(
      QuoteRequest(vendorId: vendor.id, notes: notes, budget: budget),
    );
    if (!event.quotes.contains(vendor.id)) event.quotes.add(vendor.id);
    alertsRead = false;
    changed();
  }

  DemoBooking bookDemo(EventPlan event, Vendor vendor) {
    if (event.status != 'Upcoming') {
      throw StateError('Choose an upcoming event.');
    }
    for (final b in event.bookings) {
      if (b.vendorId == vendor.id) return b;
    }
    final b = DemoBooking(
      vendorId: vendor.id,
      amount: vendor.quote,
      reference:
          'DEMO-${DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase()}',
    );
    event.bookings.add(b);
    alertsRead = false;
    changed();
    return b;
  }

  void setEventStatus(EventPlan event, String status) {
    if (!['Upcoming', 'Completed', 'Cancelled'].contains(status)) {
      throw ArgumentError('Invalid event status');
    }
    event.status = status;
    changed();
  }

  Future<void> reset() async {
    _sampleState();
    await persist();
    notifyListeners();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}
