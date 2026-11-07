import 'dart:math' as math;

import '../widgets/venue_picker.dart';

/// Curated India venues, apartments, blocks, door numbers, and landmarks for
/// door / building / area search.
/// Used alongside OpenStreetMap Nominatim (countrycodes=in).
const indiaPlaces = <VenuePick>[
  VenuePick('Door No. 12-2-418, Asif Nagar, Hyderabad, Telangana', 17.3850, 78.4562),
  VenuePick('Plot 45, Road No. 12, Banjara Hills, Hyderabad', 17.4126, 78.4482),
  VenuePick('Flat 302, Prestige Towers, Jubilee Hills, Hyderabad', 17.4310, 78.4075),
  VenuePick('H.No. 8-2-293, Road No. 36, Jubilee Hills, Hyderabad', 17.4325, 78.4098),
  VenuePick('Villa 7, Palm Meadows, Kompally, Hyderabad', 17.5449, 78.4890),
  VenuePick('Shop 14, KPHB Colony, Kukatpally, Hyderabad', 17.4942, 78.3996),
  VenuePick('Gachibowli Financial District, Hyderabad, Telangana', 17.4401, 78.3489),
  VenuePick('Hitech City, Madhapur, Hyderabad, Telangana', 17.4435, 78.3772),
  VenuePick('Secunderabad Club Road, Secunderabad, Telangana', 17.4399, 78.4983),
  VenuePick('Necklace Road, Hussain Sagar, Hyderabad', 17.4239, 78.4738),
  VenuePick('Charminar, Old City, Hyderabad, Telangana', 17.3616, 78.4747),
  VenuePick('LB Nagar, Hyderabad, Telangana', 17.3507, 78.5522),
  VenuePick('Miyapur Metro Station Area, Hyderabad', 17.4967, 78.3570),
  VenuePick('Kondapur, Hyderabad, Telangana', 17.4647, 78.3570),
  VenuePick('Begumpet, Hyderabad, Telangana', 17.4441, 78.4663),
  VenuePick('Ameerpet, Hyderabad, Telangana', 17.4375, 78.4483),
  VenuePick('Somajiguda, Hyderabad, Telangana', 17.4240, 78.4572),
  VenuePick('Film Nagar, Hyderabad, Telangana', 17.4139, 78.4195),
  VenuePick('Tolichowki, Hyderabad, Telangana', 17.3960, 78.4212),
  VenuePick('Mehdipatnam, Hyderabad, Telangana', 17.3940, 78.4345),
  VenuePick('Indiranagar 100 Feet Road, Bengaluru, Karnataka', 12.9784, 77.6408),
  VenuePick('Koramangala 5th Block, Bengaluru, Karnataka', 12.9352, 77.6245),
  VenuePick('Whitefield ITPL Road, Bengaluru, Karnataka', 12.9698, 77.7500),
  VenuePick('Jayanagar 4th Block, Bengaluru, Karnataka', 12.9308, 77.5838),
  VenuePick('MG Road, Bengaluru, Karnataka', 12.9750, 77.6063),
  VenuePick('Andheri West, Mumbai, Maharashtra', 19.1364, 72.8277),
  VenuePick('Bandra Linking Road, Mumbai, Maharashtra', 19.0596, 72.8295),
  VenuePick('Powai Hiranandani, Mumbai, Maharashtra', 19.1197, 72.9051),
  VenuePick('Dadar West, Mumbai, Maharashtra', 19.0178, 72.8478),
  VenuePick('Connaught Place, New Delhi', 28.6315, 77.2167),
  VenuePick('Saket Mall Road, New Delhi', 28.5245, 77.2066),
  VenuePick('Dwarka Sector 21, New Delhi', 28.5524, 77.0580),
  VenuePick('T Nagar, Chennai, Tamil Nadu', 13.0418, 80.2341),
  VenuePick('Anna Nagar, Chennai, Tamil Nadu', 13.0850, 80.2101),
  VenuePick('Adyar, Chennai, Tamil Nadu', 13.0067, 80.2570),
  VenuePick('Banjara Hills Road No. 1, Hyderabad', 17.4156, 78.4347),
  VenuePick('Sunny Hall, Road No. 2, Banjara Hills, Hyderabad', 17.4156, 78.4347),
  VenuePick('Door No. 1-98/5, Hitec City Main Road, Hyderabad', 17.4474, 78.3762),
  VenuePick('Building 22, Raheja Mindspace, Madhapur, Hyderabad', 17.4504, 78.3809),
  VenuePick('Locality: Manikonda, Hyderabad, Telangana', 17.4010, 78.3610),
  VenuePick('Locality: Narsingi, Hyderabad, Telangana', 17.3855, 78.3575),
  VenuePick('Locality: Uppal, Hyderabad, Telangana', 17.3985, 78.5583),
  VenuePick('Locality: Alwal, Secunderabad, Telangana', 17.5030, 78.5070),
  // Apartments, blocks and flats.
  VenuePick('Flat 403, Block C, Aparna Sarovar, Nallagandla, Hyderabad', 17.4449, 78.3087),
  VenuePick('Tower 5, My Home Avatar, Narsingi, Hyderabad', 17.3920, 78.3650),
  VenuePick('Block B, Janapriya Nile Valley, Miyapur, Hyderabad', 17.4906, 78.3491),
  VenuePick('Aparna CyberZon, Nallagandla, Hyderabad', 17.4540, 78.3090),
  VenuePick('Flat 1204, Brigade Gateway, Malleshwaram, Bengaluru', 13.0106, 77.5550),
  VenuePick('Prestige Shantiniketan, Block A, Whitefield, Bengaluru', 12.9895, 77.7280),
  VenuePick('Sobha Dream Acres, Varthur, Bengaluru', 12.9550, 77.7450),
  VenuePick('Lodha Splendora, Thane West, Mumbai', 19.2510, 72.9740),
  VenuePick('Hiranandani Estate, Ghodbunder Road, Thane', 19.2700, 72.9700),
  VenuePick('DLF Phase 3, Block U, Gurugram, Haryana', 28.4930, 77.0930),
  VenuePick('Sector 50, Noida, Uttar Pradesh', 28.5730, 77.3700),
  VenuePick('Godrej Woodsman Estate, Hebbal, Bengaluru', 13.0460, 77.5930),
  // Landmarks.
  VenuePick('Landmark: Inorbit Mall, Madhapur, Hyderabad', 17.4344, 78.3866),
  VenuePick('Landmark: Sarath City Capital Mall, Kondapur, Hyderabad', 17.4570, 78.3690),
  VenuePick('Landmark: Cyber Towers, Hitech City, Hyderabad', 17.4500, 78.3808),
  VenuePick('Landmark: GVK One Mall, Banjara Hills, Hyderabad', 17.4195, 78.4480),
  VenuePick('Landmark: Phoenix Marketcity, Whitefield, Bengaluru', 12.9960, 77.6963),
  VenuePick('Landmark: Marine Drive, Mumbai, Maharashtra', 18.9430, 72.8230),
  VenuePick('Landmark: India Gate, New Delhi', 28.6129, 77.2295),
  VenuePick('Landmark: Marina Beach, Chennai, Tamil Nadu', 13.0500, 80.2824),
];

String _normalizePlaceText(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

double _distanceScore(VenuePick place, double nearLat, double nearLon) {
  final dLat = place.latitude - nearLat;
  final dLon =
      (place.longitude - nearLon) * math.cos(nearLat * math.pi / 180);
  return dLat * dLat + dLon * dLon;
}

List<VenuePick> searchIndiaPlaces(
  String query, {
  int limit = 8,
  double? nearLat,
  double? nearLon,
}) {
  final tokens = _normalizePlaceText(
    query,
  ).split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  if (tokens.isEmpty) return const [];

  final scored = <({VenuePick place, int score})>[];
  for (final place in indiaPlaces) {
    final label = _normalizePlaceText(place.label);
    var score = 0;
    for (final token in tokens) {
      if (label.contains(token)) score += token.length > 2 ? 3 : 1;
    }
    if (score == 0) continue;
    // Prefer matches that cover more of the typed tokens.
    if (tokens.every(label.contains)) score += 10;
    scored.add((place: place, score: score));
  }
  scored.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0 || nearLat == null || nearLon == null) return byScore;
    return _distanceScore(
      a.place,
      nearLat,
      nearLon,
    ).compareTo(_distanceScore(b.place, nearLat, nearLon));
  });
  return scored.take(limit).map((row) => row.place).toList();
}
