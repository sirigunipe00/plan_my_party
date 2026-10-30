import 'dart:convert';

class Profile {
  String name, email, phone, city;
  Profile({
    this.name = 'Ananya Rao',
    this.email = 'ananya@example.com',
    this.phone = '',
    this.city = 'Hyderabad',
  });
  String get firstName => name.trim().split(' ').first;
  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0].toUpperCase())
      .join();
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'city': city,
  };
  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
    name: j['name'] as String? ?? 'Ananya Rao',
    email: j['email'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
    city: j['city'] as String? ?? 'Hyderabad',
  );
}

class Allocation {
  final String name;
  final int color;
  double percent;
  Allocation(this.name, this.percent, this.color);
  Map<String, dynamic> toJson() => {
    'name': name,
    'percent': percent,
    'color': color,
  };
  factory Allocation.fromJson(Map<String, dynamic> j) => Allocation(
    j['name'] as String,
    (j['percent'] as num).toDouble(),
    j['color'] as int,
  );
}

List<Allocation> defaultAllocations() => [
  Allocation('Decoration', 25, 0xffA68ACD),
  Allocation('Photography', 15, 0xffEDBD77),
  Allocation('Music & sound', 10, 0xffDCA4B1),
  Allocation('Food & drinks', 30, 0xff7DAF9C),
  Allocation('Furniture', 10, 0xff84A9C3),
  Allocation('Lighting', 10, 0xffCBC3A1),
];

class BalloonSpec {
  int quantity;
  List<String> colors, images;
  String theme, notes;
  double budget;
  BalloonSpec({
    this.quantity = 200,
    List<String>? colors,
    List<String>? images,
    this.theme = '',
    this.notes = '',
    this.budget = 10000,
  }) : colors = colors ?? ['Pink', 'White', 'Gold'],
       images = images ?? [];
  Map<String, dynamic> toJson() => {
    'quantity': quantity,
    'colors': colors,
    'images': images,
    'theme': theme,
    'notes': notes,
    'budget': budget,
  };
  factory BalloonSpec.fromJson(Map<String, dynamic> j) => BalloonSpec(
    quantity: j['quantity'] as int? ?? 200,
    colors: List<String>.from(j['colors'] ?? []),
    images: List<String>.from(j['images'] ?? []),
    theme: j['theme'] as String? ?? '',
    notes: j['notes'] as String? ?? '',
    budget: (j['budget'] as num? ?? 10000).toDouble(),
  );
}

class DemoBooking {
  final String vendorId, reference;
  final double amount;
  DemoBooking({
    required this.vendorId,
    required this.reference,
    required this.amount,
  });
  Map<String, dynamic> toJson() => {
    'vendorId': vendorId,
    'reference': reference,
    'amount': amount,
  };
  factory DemoBooking.fromJson(Map<String, dynamic> j) => DemoBooking(
    vendorId: j['vendorId'] as String,
    reference: j['reference'] as String,
    amount: (j['amount'] as num).toDouble(),
  );
}

class QuoteRequest {
  final String vendorId, notes;
  final double budget;
  QuoteRequest({
    required this.vendorId,
    required this.notes,
    required this.budget,
  });
  Map<String, dynamic> toJson() => {
    'vendorId': vendorId,
    'notes': notes,
    'budget': budget,
  };
  factory QuoteRequest.fromJson(Map<String, dynamic> j) => QuoteRequest(
    vendorId: j['vendorId'] as String,
    notes: j['notes'] as String? ?? '',
    budget: (j['budget'] as num).toDouble(),
  );
}

class EventPlan {
  String id, name, type, start, end, location, description, status;
  DateTime date, created;
  int guests;
  double budget;
  bool sample;
  List<String> services, quotes;
  List<Allocation> allocations;
  List<DemoBooking> bookings;
  List<QuoteRequest> requests;
  BalloonSpec balloons;
  EventPlan({
    this.id = '',
    this.name = '',
    this.type = 'Birthday',
    DateTime? date,
    this.start = '18:00',
    this.end = '23:00',
    this.location = 'Banjara Hills, Hyderabad',
    this.description = '',
    this.guests = 150,
    this.budget = 100000,
    this.status = 'Upcoming',
    this.sample = false,
    DateTime? created,
    List<String>? services,
    List<Allocation>? allocations,
    List<String>? quotes,
    List<DemoBooking>? bookings,
    List<QuoteRequest>? requests,
    BalloonSpec? balloons,
  }) : date = date ?? DateTime(2026, 12, 20),
       created = created ?? DateTime.now(),
       services =
           services ??
           [
             'Balloons',
             'Flowers',
             'Photographer',
             'DJ',
             'Chairs',
             'LED Lights',
           ],
       allocations = allocations ?? defaultAllocations(),
       quotes = quotes ?? [],
       bookings = bookings ?? [],
       requests = requests ?? [],
       balloons = balloons ?? BalloonSpec();
  double get bookedTotal => bookings.fold(0, (sum, b) => sum + b.amount);
  double get allocatedPercent =>
      allocations.fold(0, (sum, a) => sum + a.percent);
  String get image => ['Wedding', 'Engagement', 'Reception'].contains(type)
      ? 'wedding.jpg'
      : 'celebration.jpg';
  String get statusLabel => status != 'Upcoming'
      ? status
      : bookings.isNotEmpty
      ? 'Demo booking saved'
      : quotes.isNotEmpty
      ? '${quotes.length} sample quotes'
      : 'Planning started';
  String? validateBasics() {
    if (name.trim().isEmpty) return 'Give your celebration a name.';
    if (location.trim().isEmpty) return 'Add a venue or an area.';
    if (guests < 1 || guests > 10000) {
      return 'Choose between 1 and 10,000 guests.';
    }
    if (end.compareTo(start) <= 0) {
      return 'The end time must be after the start time. Overnight events are not supported.';
    }
    return null;
  }

  String? validateBudget() {
    if (!budget.isFinite || budget < 1000 || budget > 100000000) {
      return 'Choose a budget from ₹1,000 to ₹10,00,00,000.';
    }
    if (allocations.any(
          (a) => !a.percent.isFinite || a.percent < 0 || a.percent > 100,
        ) ||
        (allocatedPercent - 100).abs() > 0.001) {
      return 'Your budget shares need to add up to 100%.';
    }
    return null;
  }

  EventPlan copy() => EventPlan.fromJson(
    jsonDecode(jsonEncode(toJson())) as Map<String, dynamic>,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'date': date.toIso8601String(),
    'start': start,
    'end': end,
    'location': location,
    'description': description,
    'guests': guests,
    'budget': budget,
    'status': status,
    'sample': sample,
    'created': created.toIso8601String(),
    'services': services,
    'quotes': quotes,
    'allocations': allocations.map((a) => a.toJson()).toList(),
    'bookings': bookings.map((b) => b.toJson()).toList(),
    'requests': requests.map((r) => r.toJson()).toList(),
    'balloons': balloons.toJson(),
  };
  factory EventPlan.fromJson(Map<String, dynamic> j) => EventPlan(
    id: j['id'] as String? ?? '',
    name: j['name'] as String? ?? '',
    type: j['type'] as String? ?? 'Birthday',
    date: DateTime.parse(j['date'] as String),
    start: j['start'] as String? ?? '18:00',
    end: j['end'] as String? ?? '23:00',
    location: j['location'] as String? ?? '',
    description: j['description'] as String? ?? '',
    guests: j['guests'] as int? ?? 150,
    budget: (j['budget'] as num? ?? 100000).toDouble(),
    status: j['status'] as String? ?? 'Upcoming',
    sample: j['sample'] as bool? ?? false,
    created: DateTime.tryParse(j['created'] as String? ?? '') ?? DateTime.now(),
    services: List<String>.from(j['services'] ?? []),
    quotes: List<String>.from(j['quotes'] ?? []),
    allocations: (j['allocations'] as List? ?? [])
        .map((a) => Allocation.fromJson(Map<String, dynamic>.from(a as Map)))
        .toList(),
    bookings: (j['bookings'] as List? ?? [])
        .map((b) => DemoBooking.fromJson(Map<String, dynamic>.from(b as Map)))
        .toList(),
    requests: (j['requests'] as List? ?? [])
        .map((r) => QuoteRequest.fromJson(Map<String, dynamic>.from(r as Map)))
        .toList(),
    balloons: BalloonSpec.fromJson(
      Map<String, dynamic>.from(j['balloons'] as Map? ?? {}),
    ),
  );
}

class SavedAddress {
  final String label, address;
  SavedAddress(this.label, this.address);
  Map<String, dynamic> toJson() => {'label': label, 'address': address};
  factory SavedAddress.fromJson(Map<String, dynamic> j) =>
      SavedAddress(j['label'] as String, j['address'] as String);
}

class Vendor {
  final String id,
      name,
      category,
      image,
      area,
      tagline,
      packageName,
      badge,
      about,
      setup;
  final double from, rating, packagePrice, quote;
  final int reviews;
  final List<String> services;
  const Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.area,
    required this.from,
    required this.rating,
    required this.reviews,
    required this.tagline,
    required this.packageName,
    required this.packagePrice,
    required this.quote,
    required this.badge,
    required this.about,
    required this.setup,
    required this.services,
  });
}
