import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/venue_picker.dart';

Future<void> openPlanner(
  BuildContext context,
  AppStore store, {
  String? type,
}) async {
  // Every new event starts with nothing selected.
  store.draft = null;
  store.startDraft(type);
  await pushPage(context, PlannerScreen(store: store));
}

class PlannerScreen extends StatefulWidget {
  final AppStore store;
  const PlannerScreen({super.key, required this.store});
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  static const _stepNames = [
    'Date & time',
    'Location',
    'Decoration',
    'Furniture',
  ];

  late EventPlan draft;
  int step = 0;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.store.draft;
    if (existing == null) {
      // Creating the draft notifies listeners, so do that after this first
      // frame. The screen is built from inside the store listener.
      draft = EventPlan(date: DateTime.now());
      widget.store.draft = draft;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.store.changed();
      });
    } else {
      draft = existing;
    }
    draft.normalizeLines();
  }

  void save() => widget.store.changed(debounce: true);

  void _go(int value) {
    FocusScope.of(context).unfocus();
    setState(() => step = value);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: step == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && step > 0) _go(step - 1);
    },
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: step > 0 || Navigator.canPop(context),
        leading: step > 0 || Navigator.canPop(context)
            ? IconButton(
                tooltip: 'Go back',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () =>
                    step > 0 ? _go(step - 1) : Navigator.pop(context),
              )
            : null,
        title: const Text('Plan my party'),
      ),
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _indicator(),
                  gap16,
                  Expanded(
                    child: switch (step) {
                      0 => _dateTime(),
                      1 => _location(),
                      2 => _items('Decoration'),
                      _ => _items('Furniture'),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.paper,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            child: Row(
              children: [
                if (step > 0) ...[
                  Expanded(
                    child: PrimaryButton(
                      'Back',
                      outline: true,
                      icon: null,
                      onPressed: submitting ? null : () => _go(step - 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    step < _stepNames.length - 1
                        ? 'Next'
                        : (submitting ? 'Creating…' : 'Create Event'),
                    icon: step < _stepNames.length - 1
                        ? Icons.arrow_forward_rounded
                        : Icons.check,
                    onPressed: submitting ? null : _next,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _indicator() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Step ${step + 1} of ${_stepNames.length}',
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.purple,
          fontWeight: FontWeight.w700,
        ),
      ),
      gap8,
      Row(
        children: List.generate(
          _stepNames.length,
          (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i < _stepNames.length - 1 ? 6 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: i <= step ? AppColors.purple : AppColors.line,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${i + 1}. ${_stepNames[i]}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: i <= step ? AppColors.purple : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _heading(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        gap8,
        Text(subtitle),
      ],
    ),
  );

  // Step 1 ---------------------------------------------------------------

  Widget _dateTime() => Column(
    key: const ValueKey('step-date-time'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('Date & time', 'When is the party?'),
      _picker(
        Icons.calendar_month_outlined,
        'Event date',
        dateLabel(draft.date),
        _chooseDate,
      ),
      gap12,
      Row(
        children: [
          Expanded(
            child: _picker(
              Icons.schedule,
              'Starts at',
              timeLabel(draft.start),
              () => _chooseTime(true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _picker(
              Icons.schedule,
              'Ends at',
              timeLabel(draft.end),
              () => _chooseTime(false),
            ),
          ),
        ],
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: SizedBox.expand(
              child: Image.asset(
                'assets/images/celebration.jpg',
                fit: BoxFit.cover,
                semanticLabel: 'Celebration',
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _picker(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) => PartyCard(
    padding: const EdgeInsets.all(13),
    onTap: onTap,
    child: Row(
      children: [
        Icon(icon, size: 19, color: AppColors.purple),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.expand_more, size: 19),
      ],
    ),
  );

  Future<void> _chooseDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.date.isBefore(today) ? today : draft.date,
      firstDate: today,
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => draft.date = picked);
    save();
  }

  Future<void> _chooseTime(bool start) async {
    final parts = (start ? draft.start : draft.end)
        .split(':')
        .map(int.parse)
        .toList();
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: parts[0], minute: parts[1]),
    );
    if (value == null || !mounted) return;
    final text =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (start) {
        draft.start = text;
      } else {
        draft.end = text;
      }
    });
    save();
  }

  // Step 2 ---------------------------------------------------------------

  Widget _location() => Column(
    key: const ValueKey('step-location'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('Location', 'Where is the party?'),
      Expanded(
        child: VenuePicker(
          fill: true,
          location: draft.location,
          latitude: draft.latitude,
          longitude: draft.longitude,
          onQueryChanged: () {
            setState(() {
              draft.latitude = null;
              draft.longitude = null;
              draft.location = '';
            });
            save();
          },
          onPicked: (place) {
            setState(() {
              draft.location = place.label;
              draft.latitude = place.latitude;
              draft.longitude = place.longitude;
            });
            save();
          },
        ),
      ),
    ],
  );

  // Step 3 ---------------------------------------------------------------

  int _quantity(Offering item) {
    for (final line in draft.lines) {
      if (line.id == item.id) return line.quantity;
    }
    return 0;
  }

  void _setQuantity(Offering item, int quantity) {
    final next = quantity.clamp(0, EventPlan.maxItemQuantity);
    setState(() {
      final index = draft.lines.indexWhere((line) => line.id == item.id);
      if (next == 0) {
        if (index >= 0) draft.lines.removeAt(index);
      } else if (index >= 0) {
        draft.lines[index].quantity = next;
      } else {
        draft.lines.add(
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
    save();
  }

  Widget _stepButton(IconData icon, String tooltip, VoidCallback? onPressed) =>
      SizedBox(
        width: 22,
        height: 22,
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          iconSize: 20,
          constraints: const BoxConstraints.tightFor(width: 20, height: 20),
          visualDensity: VisualDensity.compact,
          onPressed: onPressed,
          icon: Icon(icon, color: AppColors.purple),
        ),
      );

  Widget _items(String group) {
    final count = draft.lines.fold<int>(0, (sum, line) => sum + line.quantity);
    return Column(
      key: ValueKey('step-${group.toLowerCase()}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(group, 'Select at least one item.'),
        Expanded(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              for (final item in offeringsFor(group))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _tile(item),
                ),
            ],
          ),
        ),
        gap8,
        Text(
          count == 0
              ? 'No items selected yet'
              : '$count selected · ${money(draft.itemsTotal)}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.purple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _tile(Offering item) {
    final quantity = _quantity(item);
    final selected = quantity > 0;
    const height = 124.0;
    const image = 108.0;
    return SizedBox(
      height: height,
      child: Semantics(
        button: true,
        selected: selected,
        label: '${item.name}. ${item.detail}',
        child: Material(
          color: selected ? AppColors.lavender : Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: selected ? AppColors.purple : AppColors.line,
            ),
          ),
          child: InkWell(
            key: ValueKey('add-${item.id}'),
            onTap: selected ? null : () => _setQuantity(item, 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(
                      'assets/images/${item.image}',
                      width: image,
                      height: image,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.2,
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.detail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1.3,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (selected)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _stepButton(
                                  Icons.remove_circle_outline,
                                  'Remove one ${item.name}',
                                  () => _setQuantity(item, _quantity(item) - 1),
                                ),
                                SizedBox(
                                  width: 22,
                                  child: Text(
                                    '$quantity',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.2,
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                _stepButton(
                                  Icons.add_circle_outline,
                                  'Add another ${item.name}',
                                  quantity < EventPlan.maxItemQuantity
                                      ? () => _setQuantity(
                                          item,
                                          _quantity(item) + 1,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            money(item.price),
                            style: const TextStyle(fontSize: 10, height: 1.2),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Navigation & submit --------------------------------------------------

  String? _validate() {
    switch (step) {
      case 0:
        if (draft.date.isBefore(DateUtils.dateOnly(DateTime.now()))) {
          return 'Choose today or a future date.';
        }
        if (draft.end.compareTo(draft.start) <= 0) {
          return 'The end time must be after the start time.';
        }
        return null;
      case 1:
        if (draft.latitude == null ||
            draft.longitude == null ||
            draft.location.trim().isEmpty) {
          return 'Search and select an event location.';
        }
        return null;
      case 2:
        if (!_hasItem('Decoration')) {
          return 'Select at least one decoration item.';
        }
        return null;
      default:
        if (!_hasItem('Furniture')) {
          return 'Select at least one furniture item.';
        }
        return null;
    }
  }

  bool _hasItem(String group) => draft.lines.any(
    (line) => line.group == group && line.quantity > 0,
  );

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    final error = _validate();
    if (error != null) {
      notify(context, error);
      return;
    }
    if (step < _stepNames.length - 1) {
      _go(step + 1);
      return;
    }
    await _submit();
  }

  Future<void> _submit() async {
    draft.normalizeLines();
    setState(() => submitting = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    draft.location = draft.location.trim();
    draft.name =
        '${draft.occasionChosen ? draft.type : 'Event'} · ${dateLabel(draft.date, short: true)}';
    draft.applyLines();
    try {
      widget.store.saveEvent();
      await widget.store.persist();
      if (!mounted) return;
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        setState(() {
          submitting = false;
          step = 0;
          draft = widget.store.startDraft();
          draft.normalizeLines();
        });
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Your event has been created.'),
            duration: Duration(seconds: 3),
          ),
        );
    } catch (error) {
      if (mounted) {
        setState(() => submitting = false);
        notify(context, 'Could not create your event. Please try again.');
      }
    }
  }
}
