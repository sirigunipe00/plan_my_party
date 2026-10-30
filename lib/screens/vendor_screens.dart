import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/catalog_widgets.dart';
import 'planner_screen.dart';
import 'quote_screens.dart';

class VendorBrowsePage extends StatelessWidget {
  final AppStore store;
  final String? eventId;
  const VendorBrowsePage({super.key, required this.store, this.eventId});
  @override
  Widget build(BuildContext context) => StoreView(
    store: store,
    builder: (context) => Scaffold(
      appBar: AppBar(title: const Text('Your party people')),
      body: SafeArea(
        child: ExploreScreen(store: store, eventId: eventId),
      ),
    ),
  );
}

class ExploreScreen extends StatefulWidget {
  final AppStore store;
  final String? eventId;
  const ExploreScreen({super.key, required this.store, this.eventId});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final searchController = TextEditingController();
  String category = 'All', area = 'All areas', sort = 'recommended';
  double rating = 0, maxPrice = 100000;
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = findVendors(
      search: searchController.text,
      category: category,
      area: area,
      rating: rating,
      maxPrice: maxPrice,
      sort: sort,
    );
    return RootScroll(
      children: [
        const Eyebrow('YOUR CELEBRATION, YOUR PEOPLE'),
        gap8,
        Row(
          children: [
            Expanded(
              child: Text(
                'Find your\ndream team.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Filter vendors',
              onPressed: _filters,
              icon: const Icon(Icons.tune_rounded, size: 22),
            ),
          ],
        ),
        gap8,
        const Text('Lovely people for life’s happiest moments.'),
        gap16,
        TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, size: 21),
            hintText: 'Decorators, photographers, DJs…',
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close, size: 18),
                  ),
          ),
        ),
        gap12,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                [
                      'All',
                      'Decoration',
                      'Photography',
                      'Music & DJ',
                      'Tents & Shelters',
                    ]
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c),
                          selected: category == c,
                          onSelected: (_) => setState(() => category = c),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        gap8,
        Row(
          children: [
            Expanded(
              child: Text(
                '${result.length} sample vendors in Hyderabad',
                style: const TextStyle(fontSize: 11),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Sort vendors',
              initialValue: sort,
              onSelected: (v) => setState(() => sort = v),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'recommended', child: Text('Recommended')),
                PopupMenuItem(
                  value: 'price',
                  child: Text('Price: low to high'),
                ),
                PopupMenuItem(value: 'rating', child: Text('Highest rated')),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  '${sort == 'price'
                      ? 'Lowest price'
                      : sort == 'rating'
                      ? 'Highest rated'
                      : 'Recommended'} ⌄',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.purple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        gap8,
        if (result.isEmpty)
          EmptyState(
            'No matches just yet.',
            'Try another search or give your filters a little more room.',
            icon: Icons.search,
            action: PrimaryButton(
              'Clear filters',
              onPressed: _reset,
              outline: true,
            ),
          )
        else
          VendorGrid(
            vendors: result,
            store: widget.store,
            onOpen: (v) => pushPage(
              context,
              VendorDetailScreen(
                store: widget.store,
                vendor: v,
                eventId: widget.eventId,
              ),
            ),
          ),
        const DemoNotice(
          text:
              'Sample catalog · Illustrative photos and prices. Live availability is not connected.',
        ),
      ],
    );
  }

  void _reset() {
    setState(() {
      category = 'All';
      area = 'All areas';
      sort = 'recommended';
      rating = 0;
      maxPrice = 100000;
      searchController.clear();
    });
  }

  Future<void> _filters() async {
    String selectedArea = area;
    double selectedRating = rating;
    final price = TextEditingController(text: maxPrice.toInt().toString());
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => StatefulBuilder(
        builder: (context, update) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            8,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Make it your kind of fit.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  gap24,
                  DropdownButtonFormField<String>(
                    initialValue: selectedArea,
                    decoration: const InputDecoration(
                      labelText: 'Area in Hyderabad',
                    ),
                    items:
                        [
                              'All areas',
                              'Banjara Hills',
                              'Jubilee Hills',
                              'Gachibowli',
                            ]
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                    onChanged: (v) => update(() => selectedArea = v!),
                  ),
                  gap16,
                  DropdownButtonFormField<double>(
                    initialValue: selectedRating,
                    decoration: const InputDecoration(
                      labelText: 'Minimum sample rating',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Any rating')),
                      DropdownMenuItem(
                        value: 4.5,
                        child: Text('4.5 and above'),
                      ),
                      DropdownMenuItem(
                        value: 4.8,
                        child: Text('4.8 and above'),
                      ),
                      DropdownMenuItem(
                        value: 4.9,
                        child: Text('4.9 and above'),
                      ),
                    ],
                    onChanged: (v) => update(() => selectedRating = v!),
                  ),
                  gap16,
                  TextField(
                    controller: price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Maximum starting price (₹)',
                    ),
                  ),
                  gap24,
                  PrimaryButton(
                    'Show matching vendors',
                    icon: Icons.check,
                    onPressed: () {
                      final n = double.tryParse(price.text);
                      if (n == null || !n.isFinite || n < 0 || n > 10000000) {
                        notify(
                          sheet,
                          'Enter a valid price from ₹0 to ₹1,00,00,000.',
                        );
                        return;
                      }
                      Navigator.pop(sheet, true);
                    },
                  ),
                  gap8,
                  PrimaryButton(
                    'Reset filters',
                    outline: true,
                    icon: null,
                    onPressed: () {
                      Navigator.pop(sheet);
                      _reset();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (applied == true && mounted) {
      setState(() {
        area = selectedArea;
        rating = selectedRating;
        maxPrice = double.parse(price.text);
      });
    }
  }
}

class VendorDetailScreen extends StatelessWidget {
  final AppStore store;
  final Vendor vendor;
  final String? eventId;
  const VendorDetailScreen({
    super.key,
    required this.store,
    required this.vendor,
    this.eventId,
  });
  @override
  Widget build(BuildContext context) => StoreView(
    store: store,
    builder: (context) => AppPage(
      title: vendor.name,
      actions: [
        IconButton(
          tooltip: store.favorites.contains(vendor.id)
              ? 'Remove from favorites'
              : 'Save vendor',
          onPressed: () => store.toggleFavorite(vendor.id),
          icon: Icon(
            store.favorites.contains(vendor.id)
                ? Icons.favorite
                : Icons.favorite_border,
            color: AppColors.purple,
          ),
        ),
      ],
      bottom: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Packages from', style: TextStyle(fontSize: 10)),
                Text(
                  money(vendor.packagePrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.purple,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PrimaryButton(
              'Try a quote',
              onPressed: () => pushPage(
                context,
                QuoteRequestScreen(
                  store: store,
                  vendor: vendor,
                  eventId: eventId,
                ),
              ),
            ),
          ),
        ],
      ),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(
            'assets/images/${vendor.image}',
            height: 218,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        gap24,
        Eyebrow(vendor.tagline),
        gap8,
        Text(vendor.name, style: Theme.of(context).textTheme.headlineLarge),
        gap8,
        Text(
          '${vendor.category} · ${vendor.area}, Hyderabad',
          style: const TextStyle(fontSize: 12),
        ),
        gap8,
        const Text(
          'ⓘ Sample vendor profile',
          style: TextStyle(fontSize: 11, color: AppColors.green),
        ),
        const Divider(height: 35),
        Row(
          children: [
            for (final pair in [
              ('★ ${vendor.rating}', '${vendor.reviews} sample reviews'),
              (money(vendor.from), 'Starting price'),
              ('Hyderabad', 'Service area'),
            ])
              Expanded(
                child: Column(
                  children: [
                    Text(
                      pair.$1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      pair.$2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SectionTitle('A little about us'),
        Text(vendor.about),
        const SectionTitle('What we bring to the party'),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: vendor.services.map((s) => Chip(label: Text(s))).toList(),
        ),
        const SectionTitle('A package you’ll love'),
        PartyCard(
          color: AppColors.lavender,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('THOUGHTFULLY PUT TOGETHER'),
              gap12,
              Text(
                vendor.packageName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              gap8,
              Text(
                money(vendor.packagePrice),
                style: const TextStyle(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
              ),
              const Text(
                'The essentials, with a little extra magic.',
                style: TextStyle(fontSize: 12),
              ),
              gap16,
              ...vendor.services.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check,
                        size: 15,
                        color: AppColors.purple,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(s, style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('A little inspiration'),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/${vendor.image}',
                  height: 112,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/wedding.jpg',
                  height: 112,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        gap8,
        const Text(
          'Illustrative images; not a verified vendor portfolio.',
          style: TextStyle(fontSize: 10),
        ),
        const SectionTitle('Kind words'),
        const PartyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meera K. · Sample review',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              gap8,
              Text('★ 5.0', style: TextStyle(color: Color(0xffB18B3B))),
              gap12,
              Text(
                '“The little details made the whole celebration feel so special. Beautifully put together.”',
              ),
            ],
          ),
        ),
        const DemoNotice(),
      ],
    ),
  );
}

class QuoteRequestScreen extends StatefulWidget {
  final AppStore store;
  final Vendor vendor;
  final String? eventId;
  const QuoteRequestScreen({
    super.key,
    required this.store,
    required this.vendor,
    this.eventId,
  });
  @override
  State<QuoteRequestScreen> createState() => _QuoteRequestScreenState();
}

class _QuoteRequestScreenState extends State<QuoteRequestScreen> {
  final form = GlobalKey<FormState>();
  final notes = TextEditingController();
  late final TextEditingController budget;
  String? selected;
  @override
  void initState() {
    super.initState();
    selected = widget.eventId;
    budget = TextEditingController(
      text: widget.vendor.quote.toInt().toString(),
    );
  }

  @override
  void dispose() {
    notes.dispose();
    budget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StoreView(
    store: widget.store,
    builder: (context) {
      final events = widget.store.events
          .where((e) => e.status == 'Upcoming')
          .toList();
      if (events.isEmpty) {
        return AppPage(
          title: 'Request a sample quote',
          children: [
            EmptyState(
              'First, a happy occasion.',
              'Create an event to try out vendor quotes.',
              icon: Icons.calendar_month_outlined,
              action: PrimaryButton(
                'Plan an event',
                onPressed: () => openPlanner(context, widget.store),
              ),
            ),
          ],
        );
      }
      final event =
          events.where((e) => e.id == selected).firstOrNull ?? events.first;
      selected = event.id;
      return AppPage(
        title: 'Request a sample quote',
        bottom: PrimaryButton(
          'Generate sample quote',
          onPressed: () async {
            if (!form.currentState!.validate()) return;
            widget.store.requestQuote(
              event,
              widget.vendor,
              double.parse(budget.text),
              notes.text.trim(),
            );
            await widget.store.persist();
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) =>
                    QuotesScreen(store: widget.store, eventId: event.id),
              ),
            );
          },
        ),
        children: [
          const PageHeading(
            'Let’s talk\nabout your celebration.',
            subtitle: 'Put together a little brief for your party people.',
          ),
          PartyCard(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(
                    'assets/images/${widget.vendor.image}',
                    width: 49,
                    height: 49,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vendor.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${widget.vendor.category} · ★ ${widget.vendor.rating}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          gap24,
          Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey(selected),
                  initialValue: selected,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Choose your event',
                  ),
                  items: events
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (s) => setState(() => selected = s),
                ),
                gap16,
                EventTile(event),
                gap24,
                const Text(
                  'Services you’re interested in',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                gap8,
                Wrap(
                  spacing: 8,
                  children: widget.vendor.services
                      .map(
                        (s) => Chip(
                          label: Text(s),
                          backgroundColor: AppColors.lavender,
                        ),
                      )
                      .toList(),
                ),
                gap24,
                TextFormField(
                  controller: budget,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Your budget for this vendor (₹)',
                  ),
                  validator: (s) {
                    final n = double.tryParse(s ?? '');
                    return n == null || !n.isFinite || n < 1 || n > 100000000
                        ? 'Enter a valid vendor budget.'
                        : null;
                  },
                ),
                gap24,
                TextFormField(
                  controller: notes,
                  maxLines: 3,
                  maxLength: 1500,
                  decoration: const InputDecoration(
                    labelText: 'Tell them what you have in mind',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          const DemoNotice(
            text:
                'This generates a quote example on your device. No message is sent to a real vendor.',
          ),
        ],
      );
    },
  );
}
