import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class CategoryItemsScreen extends StatefulWidget {
  final PartyCategory category;
  final EventPlan draft;
  final VoidCallback onChanged;
  const CategoryItemsScreen({
    super.key,
    required this.category,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  int _quantity(Offering item) {
    for (final line in widget.draft.lines) {
      if (line.id == item.id) return line.quantity;
    }
    return 0;
  }

  void _setQuantity(Offering item, int quantity) {
    final next = quantity.clamp(0, EventPlan.maxItemQuantity);
    setState(() {
      final index = widget.draft.lines.indexWhere((line) => line.id == item.id);
      if (next == 0) {
        if (index >= 0) widget.draft.lines.removeAt(index);
      } else if (index >= 0) {
        widget.draft.lines[index].quantity = next;
      } else {
        widget.draft.lines.add(
          ServiceLine(
            id: item.id,
            group: item.group,
            name: item.name,
            price: item.price,
            quantity: next,
          ),
        );
      }
    });
    widget.onChanged();
  }

  int get _selectedCount => widget.draft.lines
      .where((line) => line.group == widget.category.id)
      .fold<int>(0, (sum, line) => sum + line.quantity);

  @override
  Widget build(BuildContext context) {
    final items = offeringsFor(widget.category.id);
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.label)),
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
                    itemCount: items.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _tile(items[index]),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
                  decoration: const BoxDecoration(
                    color: AppColors.paper,
                    border: Border(top: BorderSide(color: AppColors.line)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedCount == 0
                                ? 'No items selected yet'
                                : '$_selectedCount selected in ${widget.category.label}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: PrimaryButton(
                            'Done',
                            icon: Icons.check,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepButton(IconData icon, String tooltip, VoidCallback? onPressed) =>
      SizedBox(
        width: 28,
        height: 28,
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          iconSize: 22,
          constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          onPressed: onPressed,
          icon: Icon(icon, color: AppColors.purple),
        ),
      );

  Widget _tile(Offering item) {
    final quantity = _quantity(item);
    final selected = quantity > 0;
    return Material(
      color: selected ? AppColors.lavender : Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selected ? AppColors.purple : AppColors.line),
      ),
      child: InkWell(
        key: ValueKey('add-${item.id}'),
        onTap: selected ? null : () => _setQuantity(item, 1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/${item.image}',
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, height: 1.35),
                    ),
                    if (item.packLabel != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lavender,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selected && item.packSize != null
                              ? '${item.packLabel} · ${item.packSize! * quantity} total'
                              : item.packLabel!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purple,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      money(item.price),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.purple,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (selected)
                Column(
                  children: [
                    _stepButton(
                      Icons.add_circle_outline,
                      'Add another ${item.name}',
                      quantity < EventPlan.maxItemQuantity
                          ? () => _setQuantity(item, quantity + 1)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (item.packSize != null)
                      Text(
                        '${item.packSize! * quantity}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                    if (item.packUnit != null)
                      Text(
                        item.packUnit!,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.muted,
                        ),
                      ),
                    _stepButton(
                      Icons.remove_circle_outline,
                      'Remove one ${item.name}',
                      () => _setQuantity(item, quantity - 1),
                    ),
                  ],
                )
              else
                const Icon(Icons.add_circle_outline, color: AppColors.purple),
            ],
          ),
        ),
      ),
    );
  }
}
