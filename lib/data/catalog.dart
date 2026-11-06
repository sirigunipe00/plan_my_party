import 'package:flutter/material.dart';
import '../models/models.dart';

const eventTypes = [
  'Birthday',
  'Anniversary',
  'Baby Shower',
  'Corporate',
  'House Warming',
  'Other',
];

class Offering {
  final String id, group, name, detail, image;
  final double price;
  /// How many physical pieces are included in one ordered item, e.g. 10 chairs.
  final int? packSize;
  final String? packUnit;
  const Offering({
    required this.id,
    required this.group,
    required this.name,
    required this.detail,
    required this.image,
    required this.price,
    this.packSize,
    this.packUnit,
  });

  String? get packLabel {
    if (packSize == null || packUnit == null) return null;
    return '$packSize $packUnit per set';
  }
}

class PartyCategory {
  final String id, label, blurb, image;
  final IconData icon;
  final Color tint;
  const PartyCategory({
    required this.id,
    required this.label,
    required this.blurb,
    required this.image,
    required this.icon,
    required this.tint,
  });
}

const partyCategories = <PartyCategory>[
  PartyCategory(
    id: 'Decoration',
    label: 'Party Decorations',
    blurb: 'Flowers, balloons, lights, and finishing touches',
    image: 'decoration.jpg',
    icon: Icons.auto_awesome_outlined,
    tint: Color(0xffF5E5EC),
  ),
  PartyCategory(
    id: 'Furniture',
    label: 'Furniture',
    blurb: 'Seating, tables, and a comfortable setup',
    image: 'furniture.jpg',
    icon: Icons.chair_outlined,
    tint: Color(0xffE6EDE8),
  ),
  PartyCategory(
    id: 'Party Props',
    label: 'Party Props',
    blurb: 'Photo moments, music, and playful extras',
    image: 'camera.jpg',
    icon: Icons.celebration_outlined,
    tint: Color(0xffF7E7DE),
  ),
  PartyCategory(
    id: 'Other Party Needs',
    label: 'Other Party Needs',
    blurb: 'Stage, entrance, and everything else you need',
    image: 'stage.jpg',
    icon: Icons.inventory_2_outlined,
    tint: Color(0xffEBE5F6),
  ),
];

const serviceCatalog = <({String name, String image, String blurb})>[
  (
    name: 'Decoration',
    image: 'decoration.jpg',
    blurb: 'Flowers, balloons, and the finishing touches',
  ),
  (
    name: 'Furniture',
    image: 'furniture.jpg',
    blurb: 'Seating, tables, and a comfortable setup',
  ),
];

const offerings = <Offering>[
  Offering(
    id: 'flowers',
    group: 'Decoration',
    name: 'Floral arrangement',
    detail: 'Fresh flowers for the tables and stage',
    image: 'flowers.jpg',
    price: 4500,
  ),
  Offering(
    id: 'balloons',
    group: 'Decoration',
    name: 'Balloon styling',
    detail: 'An arch, clusters, and a color palette',
    image: 'balloons.jpg',
    price: 6500,
  ),
  Offering(
    id: 'theme',
    group: 'Decoration',
    name: 'Theme styling',
    detail: 'One coordinated look across the venue',
    image: 'theme.jpg',
    price: 8000,
  ),
  Offering(
    id: 'lights',
    group: 'Decoration',
    name: 'Fairy lights',
    detail: 'Warm decorative lighting',
    image: 'lights.jpg',
    price: 2800,
  ),
  Offering(
    id: 'chairs',
    group: 'Furniture',
    name: 'Guest chairs',
    detail: 'Cushioned chairs for your guests',
    image: 'chairs.jpg',
    price: 2500,
    packSize: 10,
    packUnit: 'chairs',
  ),
  Offering(
    id: 'tables',
    group: 'Furniture',
    name: 'Banquet table',
    detail: 'Round table dressed with linen',
    image: 'tables.jpg',
    price: 1800,
    packSize: 1,
    packUnit: 'table',
  ),
  Offering(
    id: 'sofa',
    group: 'Furniture',
    name: 'Lounge sofa',
    detail: 'A relaxed corner seating set',
    image: 'sofa.jpg',
    price: 4000,
    packSize: 1,
    packUnit: 'sofa',
  ),
  Offering(
    id: 'dining',
    group: 'Furniture',
    name: 'Dining table',
    detail: 'Dining table with place settings',
    image: 'dining.jpg',
    price: 3200,
    packSize: 1,
    packUnit: 'table (seats 8)',
  ),
  Offering(
    id: 'vip',
    group: 'Furniture',
    name: 'VIP seating',
    detail: 'A dressed seating set for the hosts',
    image: 'vip.jpg',
    price: 7500,
    packSize: 4,
    packUnit: 'seats',
  ),
  Offering(
    id: 'lounge',
    group: 'Furniture',
    name: 'Lounge furniture',
    detail: 'Low tables and extra seating',
    image: 'lounge.jpg',
    price: 5400,
    packSize: 6,
    packUnit: 'pieces',
  ),
  Offering(
    id: 'photo-booth',
    group: 'Party Props',
    name: 'Photo booth props',
    detail: 'Signs, frames, and playful accessories',
    image: 'camera.jpg',
    price: 2200,
  ),
  Offering(
    id: 'music-kit',
    group: 'Party Props',
    name: 'Music & speaker kit',
    detail: 'Portable speakers for a lively playlist',
    image: 'music.jpg',
    price: 4500,
  ),
  Offering(
    id: 'party-favors',
    group: 'Party Props',
    name: 'Party favors set',
    detail: 'Take-home treats for your guests',
    image: 'celebration.jpg',
    price: 1800,
  ),
  Offering(
    id: 'stage',
    group: 'Other Party Needs',
    name: 'Stage backdrop',
    detail: 'Draped backdrop with soft lighting',
    image: 'stage.jpg',
    price: 12000,
  ),
  Offering(
    id: 'entrance',
    group: 'Other Party Needs',
    name: 'Entrance decoration',
    detail: 'Garlands and a welcome setup',
    image: 'entrance.jpg',
    price: 3500,
  ),
  Offering(
    id: 'wedding-setup',
    group: 'Other Party Needs',
    name: 'Ceremony setup kit',
    detail: 'A polished setup for special occasions',
    image: 'wedding.jpg',
    price: 15000,
  ),
];

List<Offering> offeringsFor(String group) =>
    offerings.where((item) => item.group == group).toList();

PartyCategory? categoryById(String id) {
  for (final category in partyCategories) {
    if (category.id == id) return category;
  }
  return null;
}

const vendors = <Vendor>[
  Vendor(
    id: 'dream',
    name: 'Dream Events',
    category: 'Decoration',
    image: 'celebration.jpg',
    area: 'Banjara Hills',
    from: 10000,
    rating: 4.8,
    reviews: 120,
    tagline: 'POPULAR CHOICE',
    packageName: 'The birthday edit',
    packagePrice: 25000,
    quote: 28000,
    badge: 'Best value',
    setup: '4 hours',
    services: ['Balloons', 'Stage', 'Flowers', 'Entrance', 'Lighting'],
    about:
        'Thoughtfully styled celebrations, from beautiful balloon arches to floral backdrops. Explore sample birthday, wedding and corporate event packages.',
  ),
  Vendor(
    id: 'lens',
    name: 'Lens & Light',
    category: 'Photography',
    image: 'camera.jpg',
    area: 'Jubilee Hills',
    from: 15000,
    rating: 4.9,
    reviews: 98,
    tagline: 'CAPTURE THE JOY',
    packageName: 'Moments to keep',
    packagePrice: 22000,
    quote: 22000,
    badge: 'Top rated',
    setup: '1 hour',
    services: [
      'Photographer',
      'Candid Photography',
      'Videographer',
      'Photo Booth',
    ],
    about:
        'Candid photographs and carefully crafted films to keep your favorite moments close. Sample packages include event coverage, edited photographs and a digital gallery.',
  ),
  Vendor(
    id: 'beat',
    name: 'Beat Box DJs',
    category: 'Music & DJ',
    image: 'music.jpg',
    area: 'Gachibowli',
    from: 8000,
    rating: 4.6,
    reviews: 64,
    tagline: 'SET THE MOOD',
    packageName: 'The dance floor',
    packagePrice: 15000,
    quote: 15000,
    badge: 'Party favorite',
    setup: '2 hours',
    services: ['DJ', 'Speakers', 'Sound System', 'Microphones'],
    about:
        'Set the mood with a curated soundtrack, a clear sound system and a DJ who keeps the party going. Browse sample music packages for your event.',
  ),
  Vendor(
    id: 'royal',
    name: 'Royal Tents',
    category: 'Tents & Shelters',
    image: 'wedding.jpg',
    area: 'Banjara Hills',
    from: 12000,
    rating: 4.5,
    reviews: 86,
    tagline: 'CELEBRATE OUTSIDE',
    packageName: 'Under the stars',
    packagePrice: 30000,
    quote: 30000,
    badge: 'Outdoor favorite',
    setup: '5 hours',
    services: ['Tent', 'Canopy', 'Waterproof Tent', 'Gazebo', 'Chairs'],
    about:
        'Beautiful outdoor spaces with comfortable seating, canopies and ambient lighting. Explore sample tent and shelter packages for your celebration.',
  ),
  Vendor(
    id: 'petal',
    name: 'Petal & Co',
    category: 'Decoration',
    image: 'wedding.jpg',
    area: 'Jubilee Hills',
    from: 9000,
    rating: 4.6,
    reviews: 74,
    tagline: 'FLOWERS & FINISHING TOUCHES',
    packageName: 'Simply beautiful',
    packagePrice: 24000,
    quote: 26500,
    badge: 'Lowest price',
    setup: '3 hours',
    services: ['Stage', 'Balloons', 'Flowers'],
    about:
        'Soft florals, beautiful colors and considered details for an intimate celebration. Discover sample decoration concepts and event styling packages.',
  ),
  Vendor(
    id: 'glow',
    name: 'Glow Decor',
    category: 'Decoration',
    image: 'celebration.jpg',
    area: 'Gachibowli',
    from: 18000,
    rating: 4.9,
    reviews: 98,
    tagline: 'A LITTLE EXTRA MAGIC',
    packageName: 'The full celebration',
    packagePrice: 29000,
    quote: 31000,
    badge: 'Highest rated',
    setup: '5 hours',
    services: ['Stage', 'Balloons', 'Flowers', 'Lighting', 'Photo Booth'],
    about:
        'A complete sample celebration setup with florals, balloons, lighting and a photo booth. Explore an all-in-one styling concept for your next occasion.',
  ),
];

Vendor vendorById(String id) => vendors.firstWhere((v) => v.id == id);

List<Vendor> findVendors({
  String search = '',
  String category = 'All',
  String area = 'All areas',
  double rating = 0,
  double maxPrice = 100000,
  String sort = 'recommended',
}) {
  final query = search.toLowerCase().trim();
  final result = vendors
      .where(
        (v) =>
            (category == 'All' || v.category == category) &&
            (area == 'All areas' || v.area == area) &&
            v.rating >= rating &&
            v.from <= maxPrice &&
            (query.isEmpty ||
                '${v.name} ${v.category} ${v.area} ${v.services.join(' ')}'
                    .toLowerCase()
                    .contains(query)),
      )
      .toList();
  if (sort == 'price') result.sort((a, b) => a.from.compareTo(b.from));
  if (sort == 'rating') result.sort((a, b) => b.rating.compareTo(a.rating));
  return result;
}
