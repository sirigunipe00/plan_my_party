import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final AppStore store;
  final VoidCallback onOpen;
  const VendorCard({
    super.key,
    required this.vendor,
    required this.store,
    required this.onOpen,
  });
  @override
  Widget build(BuildContext context) => PartyCard(
    padding: EdgeInsets.zero,
    onTap: onOpen,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 122,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/${vendor.image}', fit: BoxFit.cover),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: .94),
                    minimumSize: const Size(44, 44),
                  ),
                  tooltip:
                      '${store.favorites.contains(vendor.id) ? 'Unsave' : 'Save'} ${vendor.name}',
                  onPressed: () => store.toggleFavorite(vendor.id),
                  icon: Icon(
                    store.favorites.contains(vendor.id)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border,
                    size: 18,
                    color: AppColors.purple,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      vendor.category,
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.star_rounded,
                    size: 12,
                    color: Color(0xffD3A146),
                  ),
                  Text(
                    ' ${vendor.rating}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              gap8,
              Text(
                vendor.name,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${vendor.area}, Hyderabad',
                maxLines: 2,
                style: const TextStyle(fontSize: 10),
              ),
              gap12,
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: money(vendor.from),
                      style: const TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const TextSpan(
                      text: ' onwards',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class VendorGrid extends StatelessWidget {
  final List<Vendor> vendors;
  final AppStore store;
  final ValueChanged<Vendor> onOpen;
  const VendorGrid({
    super.key,
    required this.vendors,
    required this.store,
    required this.onOpen,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth > 540 ? 3 : 2;
      final rows = <Widget>[];
      for (int i = 0; i < vendors.length; i += columns) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                columns,
                (j) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: j < columns - 1 ? 12 : 0),
                    child: i + j < vendors.length
                        ? VendorCard(
                            vendor: vendors[i + j],
                            store: store,
                            onOpen: () => onOpen(vendors[i + j]),
                          )
                        : const SizedBox(),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      return Column(children: rows);
    },
  );
}

class RootScroll extends StatelessWidget {
  final List<Widget> children;
  const RootScroll({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    ),
  );
}
