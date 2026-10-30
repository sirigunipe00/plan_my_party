import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ServiceItemsScreen extends StatefulWidget {
  final AppStore store;
  final EventPlan draft;
  final String group;
  const ServiceItemsScreen({
    super.key,
    required this.store,
    required this.draft,
    required this.group,
  });

  @override
  State<ServiceItemsScreen> createState() => _ServiceItemsScreenState();
}

class _ServiceItemsScreenState extends State<ServiceItemsScreen> {
  EventPlan get draft => widget.draft;
  String get image =>
      serviceCatalog.firstWhere((item) => item.name == widget.group).image;

  int quantityOf(String id) {
    for (final line in draft.lines) {
      if (line.id == id) return line.quantity;
    }
    return 0;
  }

  void setQuantity(Offering offering, int quantity) {
    draft.lines.removeWhere((line) => line.id == offering.id);
    if (quantity > 0) {
      draft.lines.add(
        ServiceLine(
          id: offering.id,
          group: offering.group,
          name: offering.name,
          price: offering.price,
          quantity: quantity,
        ),
      );
    }
    draft.applyLines();
    widget.store.changed(debounce: true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = offeringsFor(widget.group);
    return AppPage(
      title: widget.group,
      bottom: PrimaryButton(
        'Done',
        icon: Icons.check,
        onPressed: () => Navigator.pop(context),
      ),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(
            'assets/images/$image',
            height: 168,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        gap16,
        PageHeading(
          'Add ${widget.group.toLowerCase()}.',
          subtitle: 'Your budget updates from the items you add.',
        ),
        ...items.map((offering) {
          final quantity = quantityOf(offering.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PartyCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offering.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        gap8,
                        Text(
                          offering.detail,
                          style: const TextStyle(fontSize: 11),
                        ),
                        gap8,
                        Text(
                          money(offering.price),
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  quantity == 0
                      ? FilledButton(
                          key: ValueKey('add-${offering.id}'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(72, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          onPressed: () => setQuantity(offering, 1),
                          child: const Text('Add'),
                        )
                      : _stepper(offering, quantity),
                ],
              ),
            ),
          );
        }),
        Text(
          'Added from ${widget.group.toLowerCase()}: ${money(draft.lines.where((line) => line.group == widget.group).fold<double>(0, (sum, line) => sum + line.total))}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.purple,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _stepper(Offering offering, int quantity) => Row(
    children: [
      IconButton(
        tooltip: 'Remove one ${offering.name}',
        onPressed: () => setQuantity(offering, quantity - 1),
        icon: const Icon(Icons.remove_circle_outline, color: AppColors.purple),
      ),
      Text(
        '$quantity',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      IconButton(
        tooltip: 'Add another ${offering.name}',
        onPressed: () => setQuantity(offering, quantity + 1),
        icon: const Icon(Icons.add_circle_outline, color: AppColors.purple),
      ),
    ],
  );
}
