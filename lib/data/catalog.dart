import 'package:flutter/material.dart';
import '../models/models.dart';

const eventTypes = [
  'Birthday',
  'Wedding',
  'Engagement',
  'Reception',
  'Anniversary',
  'Baby Shower',
  'Corporate',
  'House Warming',
  'Other',
];
const serviceGroups = <({String name, IconData icon, List<String> items})>[
  (
    name: 'Decoration',
    icon: Icons.local_florist_outlined,
    items: [
      'Flowers',
      'Balloons',
      'Stage Decoration',
      'Entrance Decoration',
      'Theme Decoration',
      'Backdrop',
    ],
  ),
  (
    name: 'Music & sound',
    icon: Icons.music_note_outlined,
    items: ['DJ', 'Live Music', 'Speakers', 'Microphones', 'Sound System'],
  ),
  (
    name: 'Photography',
    icon: Icons.camera_alt_outlined,
    items: [
      'Photographer',
      'Videographer',
      'Drone',
      'Candid Photography',
      'Photo Booth',
    ],
  ),
  (
    name: 'Food & drinks',
    icon: Icons.restaurant_outlined,
    items: [
      'Catering',
      'Welcome Drinks',
      'Snacks',
      'Vegetarian',
      'Non-Vegetarian',
      'Desserts',
    ],
  ),
  (
    name: 'Furniture & seating',
    icon: Icons.chair_outlined,
    items: [
      'Chairs',
      'Tables',
      'Sofas',
      'Dining Tables',
      'VIP Seating',
      'Lounge Furniture',
    ],
  ),
  (
    name: 'Flooring & staging',
    icon: Icons.layers_outlined,
    items: ['Stage', 'Dance Floor', 'Carpet', 'Platform', 'Ramp'],
  ),
  (
    name: 'Tents & shelters',
    icon: Icons.holiday_village_outlined,
    items: ['Tent', 'Canopy', 'Waterproof Tent', 'Gazebo'],
  ),
  (
    name: 'Lighting & power',
    icon: Icons.lightbulb_outline,
    items: [
      'Decorative Lights',
      'Stage Lights',
      'LED Lights',
      'Focus Lights',
      'Generator',
      'Power Backup',
    ],
  ),
];

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
