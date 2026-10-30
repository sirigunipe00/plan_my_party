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
  final String id, group, name, detail;
  final double price;
  const Offering({
    required this.id,
    required this.group,
    required this.name,
    required this.detail,
    required this.price,
  });
}

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
    price: 4500,
  ),
  Offering(
    id: 'balloons',
    group: 'Decoration',
    name: 'Balloon styling',
    detail: 'An arch, clusters, and a color palette',
    price: 6500,
  ),
  Offering(
    id: 'stage',
    group: 'Decoration',
    name: 'Stage backdrop',
    detail: 'Draped backdrop with soft lighting',
    price: 12000,
  ),
  Offering(
    id: 'entrance',
    group: 'Decoration',
    name: 'Entrance decoration',
    detail: 'Garlands and a welcome setup',
    price: 3500,
  ),
  Offering(
    id: 'theme',
    group: 'Decoration',
    name: 'Theme styling',
    detail: 'One coordinated look across the venue',
    price: 8000,
  ),
  Offering(
    id: 'lights',
    group: 'Decoration',
    name: 'Fairy lights',
    detail: 'Warm decorative lighting',
    price: 2800,
  ),
  Offering(
    id: 'chairs',
    group: 'Furniture',
    name: 'Guest chairs',
    detail: 'A set of 10 cushioned chairs',
    price: 2500,
  ),
  Offering(
    id: 'tables',
    group: 'Furniture',
    name: 'Banquet table',
    detail: 'Round table dressed with linen',
    price: 1800,
  ),
  Offering(
    id: 'sofa',
    group: 'Furniture',
    name: 'Lounge sofa',
    detail: 'A two-seater for a relaxed corner',
    price: 4000,
  ),
  Offering(
    id: 'dining',
    group: 'Furniture',
    name: 'Dining table',
    detail: 'Seats eight, with place settings',
    price: 3200,
  ),
  Offering(
    id: 'vip',
    group: 'Furniture',
    name: 'VIP seating',
    detail: 'A dressed seating set for the hosts',
    price: 7500,
  ),
  Offering(
    id: 'lounge',
    group: 'Furniture',
    name: 'Lounge furniture',
    detail: 'Low tables and extra seating',
    price: 5400,
  ),
];

List<Offering> offeringsFor(String group) =>
    offerings.where((item) => item.group == group).toList();

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
