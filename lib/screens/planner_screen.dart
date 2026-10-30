import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'event_screens.dart';
import 'vendor_screens.dart';

Future<void> openPlanner(
  BuildContext context,
  AppStore store, {
  String? type,
}) async {
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
  int step = 0;
  final form = GlobalKey<FormState>();
  final scroll = ScrollController();
  late final EventPlan draft;
  @override
  void initState() {
    super.initState();
    draft = widget.store.draft ?? widget.store.startDraft();
  }

  void save() => widget.store.changed(debounce: true);
  void move(int value) {
    FocusScope.of(context).unfocus();
    setState(() => step = value);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: step == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && step > 0) move(step - 1);
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => step > 0 ? move(step - 1) : Navigator.pop(context),
        ),
        title: Text(
          [
            'Plan a celebration',
            'A little of everything',
            'Make every rupee count',
            'One last happy check',
          ][step],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                '${step + 1} / 4',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      4,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: i <= step
                                      ? AppColors.purple
                                      : AppColors.line,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              gap8,
                              Text(
                                [
                                  '1. The basics',
                                  '2. Services',
                                  '3. Budget',
                                  '4. Review',
                                ][i],
                                style: TextStyle(
                                  fontSize: 9,
                                  color: i <= step
                                      ? AppColors.purple
                                      : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  gap24,
                  if (step == 0) _basics(),
                  if (step == 1) _services(),
                  if (step == 2) _budget(),
                  if (step == 3) _review(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            child: PrimaryButton(
              [
                'Choose your services',
                'Let’s talk budget',
                'Review my celebration',
                'Save my celebration',
              ][step],
              icon: step == 3
                  ? Icons.auto_awesome_outlined
                  : Icons.arrow_forward,
              onPressed: _next,
            ),
          ),
        ),
      ),
    ),
  );
  Widget _field(
    String label,
    String key,
    String value,
    ValueChanged<String> onChanged, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: TextFormField(
      key: ValueKey(key),
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
      ),
      keyboardType: keyboard,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: (text) {
        onChanged(text);
        save();
      },
    ),
  );
  String? requiredText(String? s) =>
      s == null || s.trim().isEmpty ? 'Please fill in this detail.' : null;
  Widget _basics() => Form(
    key: form,
    child: Column(
      key: const ValueKey('basics'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          'Let’s start with\nthe happy details.',
          subtitle: 'A few little things to make your event feel like you.',
        ),
        _field(
          'Give your event a name',
          'event-name',
          draft.name,
          (v) => draft.name = v,
          validator: requiredText,
          maxLength: 90,
        ),
        const Text(
          'What are we celebrating?',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        gap8,
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: eventTypes
              .map(
                (t) => ChoiceChip(
                  label: Text(t),
                  selected: draft.type == t,
                  onSelected: (_) {
                    setState(() => draft.type = t);
                    save();
                  },
                ),
              )
              .toList(),
        ),
        gap24,
        _picker(
          Icons.calendar_month_outlined,
          'Event date',
          dateLabel(draft.date),
          () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: draft.date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null && mounted) {
              setState(() => draft.date = picked);
              save();
            }
          },
        ),
        gap16,
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
        gap24,
        _field(
          'Where’s the party?',
          'event-location',
          draft.location,
          (v) => draft.location = v,
          validator: requiredText,
          maxLength: 180,
        ),
        _field(
          'How many guests?',
          'event-guests',
          '${draft.guests}',
          (v) => draft.guests = int.tryParse(v) ?? 0,
          keyboard: TextInputType.number,
          validator: (v) {
            final n = int.tryParse(v ?? '');
            return n == null || n < 1 || n > 10000
                ? 'Enter 1 to 10,000 guests.'
                : null;
          },
        ),
        _field(
          'Anything else? (optional)',
          'event-description',
          draft.description,
          (v) => draft.description = v,
          maxLines: 3,
          maxLength: 1000,
        ),
        const Text(
          'Your draft saves automatically as you go.',
          style: TextStyle(fontSize: 11),
        ),
      ],
    ),
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
      ],
    ),
  );
  Future<void> _chooseTime(bool start) async {
    final parts = (start ? draft.start : draft.end)
        .split(':')
        .map(int.parse)
        .toList();
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: parts[0], minute: parts[1]),
    );
    if (value != null && mounted) {
      final t =
          '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (start) {
          draft.start = t;
        } else {
          draft.end = t;
        }
      });
      save();
    }
  }

  Widget _services() => Column(
    key: const ValueKey('services'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PageHeading(
        'Build your\nkind of celebration.',
        subtitle: 'Pick the services you need. You can mix and match.',
      ),
      Text(
        '${draft.services.length} services selected',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.purple,
          fontWeight: FontWeight.w600,
        ),
      ),
      gap16,
      ...serviceGroups.map(
        (group) => Padding(
          padding: const EdgeInsets.only(bottom: 23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(group.icon, size: 19, color: AppColors.purple),
                  const SizedBox(width: 9),
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              gap8,
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: group.items
                    .map(
                      (item) => FilterChip(
                        label: Text(item),
                        selected: draft.services.contains(item),
                        onSelected: (value) {
                          setState(() {
                            value
                                ? draft.services.add(item)
                                : draft.services.remove(item);
                          });
                          save();
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      PartyCard(
        onTap: () async {
          await pushPage(
            context,
            BalloonsScreen(store: widget.store, draft: draft),
          );
          if (mounted) setState(() {});
        },
        child: const Row(
          children: [
            Icon(Icons.palette_outlined, color: AppColors.purple),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Make it a little more you',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Customize balloons, colors & inspiration',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    ],
  );
  Widget _budget() => Column(
    key: const ValueKey('budget'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PageHeading(
        'A beautiful party.\nA comfortable budget.',
        subtitle: 'Set your total, then decide what matters most.',
      ),
      Container(
        padding: const EdgeInsets.all(23),
        decoration: BoxDecoration(
          color: AppColors.deep,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your total event budget (₹)',
              style: TextStyle(fontSize: 12, color: Color(0xffD1C3E7)),
            ),
            gap12,
            TextFormField(
              key: const ValueKey('total-budget'),
              initialValue: draft.budget.toInt().toString(),
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                filled: false,
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0x44FFFFFF)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                contentPadding: EdgeInsets.only(bottom: 9),
              ),
              onChanged: (v) {
                setState(() => draft.budget = double.tryParse(v) ?? 0);
                save();
              },
            ),
            gap24,
            BudgetBar(draft.allocations),
            gap12,
            const Text(
              'A little room for everything you love.',
              style: TextStyle(fontSize: 11, color: Color(0xffD1C3E7)),
            ),
          ],
        ),
      ),
      SectionTitle(
        'Your budget breakdown',
        action: 'Reset split',
        onAction: () {
          setState(() => draft.allocations = defaultAllocations());
          save();
        },
      ),
      ...draft.allocations.asMap().entries.map((entry) {
        final a = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 19),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Color(a.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      a.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Text(
                    money(draft.budget * a.percent / 100),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              gap8,
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Share of your total budget',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  SizedBox(
                    width: 75,
                    child: TextFormField(
                      key: ValueKey('allocation-${entry.key}-${a.hashCode}'),
                      initialValue: a.percent.toStringAsFixed(
                        a.percent % 1 == 0 ? 0 : 1,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        suffixText: '%',
                      ),
                      onChanged: (v) {
                        setState(() => a.percent = double.tryParse(v) ?? 0);
                        save();
                      },
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        );
      }),
      Center(
        child: Text(
          '${draft.allocatedPercent.toStringAsFixed(0)}% allocated ${(draft.allocatedPercent - 100).abs() < .001 ? '· Looking good!' : '· Adjust your split to 100%'}',
          style: TextStyle(
            fontSize: 12,
            color: (draft.allocatedPercent - 100).abs() < .001
                ? AppColors.green
                : Colors.redAccent,
          ),
        ),
      ),
    ],
  );
  Widget _review() => Column(
    key: const ValueKey('review'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PageHeading(
        'Looking good.\nReady to make it happen?',
        subtitle: 'Check your details before saving your celebration.',
      ),
      ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Image.asset(
          'assets/images/${draft.image}',
          height: 148,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StatusBadge(draft.type),
          TextButton(
            onPressed: () => move(0),
            child: const Text('Edit details'),
          ),
        ],
      ),
      Text(draft.name, style: Theme.of(context).textTheme.titleLarge),
      gap24,
      EventFacts(draft),
      if (draft.description.isNotEmpty) Text(draft.description),
      SectionTitle(
        'Your party essentials',
        action: 'Edit',
        onAction: () => move(1),
      ),
      Wrap(
        spacing: 7,
        runSpacing: 6,
        children: draft.services
            .map(
              (s) => Chip(label: Text(s), backgroundColor: AppColors.lavender),
            )
            .toList(),
      ),
      const SectionTitle('A happy budget'),
      PartyCard(
        child: Column(
          children: [
            InfoPair('Total event budget', money(draft.budget)),
            gap12,
            BudgetBar(draft.allocations),
            gap8,
            const Text(
              '6 categories · 100% allocated',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
      const DemoNotice(
        text:
            'Your event is saved on this device. Vendors, quotes and bookings are demonstrations.',
      ),
    ],
  );
  Future<void> _next() async {
    if (step == 0) {
      if (!form.currentState!.validate()) return;
      final error = draft.validateBasics();
      if (error != null) {
        notify(context, error);
        return;
      }
    }
    if (step == 1 && draft.services.isEmpty) {
      notify(context, 'Choose at least one service.');
      return;
    }
    if (step == 2) {
      final error = draft.validateBudget();
      if (error != null) {
        notify(context, error);
        return;
      }
    }
    if (step < 3) {
      await widget.store.persist();
      if (mounted) move(step + 1);
      return;
    }
    try {
      final event = widget.store.saveEvent();
      await widget.store.persist();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CreatedScreen(store: widget.store, eventId: event.id),
        ),
      );
    } catch (e) {
      if (mounted) notify(context, e.toString());
    }
  }
}

class BalloonsScreen extends StatefulWidget {
  final AppStore store;
  final EventPlan draft;
  const BalloonsScreen({super.key, required this.store, required this.draft});
  @override
  State<BalloonsScreen> createState() => _BalloonsScreenState();
}

class _BalloonsScreenState extends State<BalloonsScreen> {
  final form = GlobalKey<FormState>();
  final picker = ImagePicker();
  bool picking = false;
  BalloonSpec get b => widget.draft.balloons;
  void save() => widget.store.changed(debounce: true);
  @override
  void initState() {
    super.initState();
    _recoverPhotos();
  }

  Future<void> _recoverPhotos() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final lost = await picker.retrieveLostData();
        if (lost.files != null && mounted) await _import(lost.files!);
      } catch (_) {
        /* The regular photo chooser remains available. */
      }
    }
  }

  Future<void> _import(List<XFile> files) async {
    final available = 4 - b.images.length;
    for (final file in files.take(available)) {
      final data = await file.readAsBytes();
      if (data.length > 2 * 1024 * 1024) {
        if (mounted) notify(context, 'Choose a smaller photo, under 2 MB.');
        continue;
      }
      b.images.add(base64Encode(data));
    }
    save();
    if (mounted) setState(() {});
  }

  Future<void> _pick() async {
    setState(() => picking = true);
    try {
      final files = await picker.pickMultiImage(
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 72,
      );
      await _import(files);
    } catch (_) {
      if (mounted) {
        notify(context, 'The photo chooser could not open. Please try again.');
      }
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'The little details',
    bottom: PrimaryButton(
      'Save the little details',
      icon: Icons.check,
      onPressed: () {
        if (!form.currentState!.validate()) return;
        if (!widget.draft.services.contains('Balloons')) {
          widget.draft.services.add('Balloons');
        }
        widget.store.changed();
        Navigator.pop(context);
      },
    ),
    children: [
      const PageHeading(
        'Balloons, your way.',
        subtitle: 'Help your decorator understand the look you love.',
      ),
      Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: '${b.quantity}',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'How many balloons?',
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return n == null || n < 1 || n > 10000
                    ? 'Enter 1 to 10,000 balloons.'
                    : null;
              },
              onChanged: (v) {
                b.quantity = int.tryParse(v) ?? 0;
                save();
              },
            ),
            gap24,
            const Text(
              'Pick your palette',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            gap8,
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  const {
                        'Pink': Color(0xffEDB6C3),
                        'White': Colors.white,
                        'Gold': Color(0xffD8B868),
                        'Blue': Color(0xff98B6E2),
                        'Red': Color(0xffD97F7F),
                      }.entries
                      .map(
                        (e) => FilterChip(
                          avatar: CircleAvatar(
                            backgroundColor: e.value,
                            radius: 6,
                          ),
                          label: Text(e.key),
                          selected: b.colors.contains(e.key),
                          onSelected: (s) {
                            setState(() {
                              s ? b.colors.add(e.key) : b.colors.remove(e.key);
                            });
                            save();
                          },
                        ),
                      )
                      .toList(),
            ),
            gap24,
            TextFormField(
              initialValue: b.theme,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Theme or idea',
                hintText: 'e.g. Pastel garden party',
              ),
              onChanged: (v) {
                b.theme = v;
                save();
              },
            ),
            gap16,
            TextFormField(
              initialValue: b.budget.toInt().toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Balloon budget (₹)',
              ),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                return n == null || !n.isFinite || n < 0 || n > 10000000
                    ? 'Enter a valid budget.'
                    : null;
              },
              onChanged: (v) {
                b.budget = double.tryParse(v) ?? 0;
                save();
              },
            ),
            gap24,
            TextFormField(
              initialValue: b.notes,
              maxLines: 3,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Notes for your decorator',
                alignLabelWithHint: true,
              ),
              onChanged: (v) {
                b.notes = v;
                save();
              },
            ),
          ],
        ),
      ),
      gap16,
      const Text(
        'A little inspiration (up to 4 photos)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      gap12,
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (int i = 0; i < b.images.length; i++)
            SizedBox(
              width: 85,
              height: 85,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      base64Decode(b.images[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton.filledTonal(
                      tooltip: 'Remove photo ${i + 1}',
                      onPressed: () {
                        setState(() => b.images.removeAt(i));
                        save();
                      },
                      icon: const Icon(Icons.close, size: 15),
                    ),
                  ),
                ],
              ),
            ),
          if (b.images.length < 4)
            SizedBox(
              width: 85,
              height: 85,
              child: OutlinedButton(
                onPressed: picking ? null : _pick,
                child: picking
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Icon(Icons.add_photo_alternate_outlined, size: 26),
              ),
            ),
        ],
      ),
      const DemoNotice(
        text:
            'Inspiration photos are resized by the device picker where supported and saved only on this device.',
      ),
    ],
  );
}

class CreatedScreen extends StatelessWidget {
  final AppStore store;
  final String eventId;
  const CreatedScreen({super.key, required this.store, required this.eventId});
  @override
  Widget build(BuildContext context) {
    final event = store.eventById(eventId);
    return AppPage(
      title: 'Your celebration',
      children: [
        const SizedBox(height: 30),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.lavender,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: AppColors.purple,
              size: 49,
            ),
          ),
        ),
        const SizedBox(height: 35),
        const Center(child: Eyebrow('LET THE HAPPY BEGIN')),
        gap16,
        Center(
          child: Text(
            'It’s a plan.\nAnd it’s going to be lovely.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        gap16,
        Text(
          '${event.name} is saved. Now find the people who’ll help bring it to life.',
          textAlign: TextAlign.center,
        ),
        gap24,
        EventTile(event),
        gap24,
        PrimaryButton(
          'Find my party people',
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => VendorBrowsePage(store: store, eventId: eventId),
            ),
          ),
        ),
        gap12,
        PrimaryButton(
          'View my event',
          outline: true,
          icon: Icons.calendar_month_outlined,
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(store: store, eventId: eventId),
            ),
          ),
        ),
        const DemoNotice(
          text: 'Saved on this device · No vendor has been contacted.',
        ),
      ],
    );
  }
}
