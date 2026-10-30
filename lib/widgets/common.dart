import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';

String money(num value) => NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: value % 1 == 0 ? 0 : 2,
).format(value);
String dateLabel(DateTime date, {bool short = false}) =>
    DateFormat(short ? 'd MMM yyyy' : 'd MMMM yyyy').format(date);
String timeLabel(String value) {
  final parts = value.split(':').map(int.parse).toList();
  return DateFormat('h:mm a').format(DateTime(2026, 1, 1, parts[0], parts[1]));
}

void notify(BuildContext context, String text) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), duration: const Duration(seconds: 3)),
  );
}

Future<T?> pushPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));
const gap8 = SizedBox(height: 8),
    gap12 = SizedBox(height: 12),
    gap16 = SizedBox(height: 16),
    gap24 = SizedBox(height: 24);

class StoreView extends StatelessWidget {
  final AppStore store;
  final WidgetBuilder builder;
  const StoreView({super.key, required this.store, required this.builder});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => builder(context),
  );
}

class AppPage extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final Widget? bottom;
  final List<Widget>? actions;
  final bool padded;
  const AppPage({
    super.key,
    this.title,
    required this.children,
    this.bottom,
    this.actions,
    this.padded = true,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: title == null
        ? null
        : AppBar(title: Text(title!), actions: actions),
    body: SafeArea(
      top: title == null,
      bottom: bottom == null,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: padded
                ? const EdgeInsets.fromLTRB(22, 16, 22, 28)
                : EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ),
    ),
    bottomNavigationBar: bottom == null
        ? null
        : Container(
            decoration: const BoxDecoration(
              color: AppColors.paper,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                child: bottom,
              ),
            ),
          ),
  );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outline;
  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.outline = false,
  });
  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(label, textAlign: TextAlign.center)),
        if (icon != null) ...[const SizedBox(width: 10), Icon(icon, size: 18)],
      ],
    );
    return SizedBox(
      width: double.infinity,
      child: outline
          ? OutlinedButton(onPressed: onPressed, child: child)
          : FilledButton(onPressed: onPressed, child: child),
    );
  }
}

class PageHeading extends StatelessWidget {
  final String title, subtitle;
  const PageHeading(this.title, {super.key, this.subtitle = ''});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 23),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        if (subtitle.isNotEmpty) ...[gap8, Text(subtitle)],
      ],
    ),
  );
}

class Eyebrow extends StatelessWidget {
  final String text;
  final Color color;
  const Eyebrow(this.text, {super.key, this.color = AppColors.purple});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 9,
      letterSpacing: 1.7,
      fontWeight: FontWeight.w700,
      color: color,
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 25, bottom: 13),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    ),
  );
}

class PartyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;
  const PartyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(19),
      side: const BorderSide(color: AppColors.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}

class StatusBadge extends StatelessWidget {
  final String label;
  final bool green;
  const StatusBadge(this.label, {super.key, this.green = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: green ? const Color(0xffE6F4ED) : AppColors.lavender,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: green ? AppColors.green : AppColors.purple,
      ),
    ),
  );
}

class DemoNotice extends StatelessWidget {
  final String text;
  const DemoNotice({
    super.key,
    this.text =
        'Local demo · Sample vendors and prices. No real booking or payment is made.',
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.lavender,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.purple),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                height: 1.6,
                color: Color(0xff79668F),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Widget? action;
  const EmptyState(
    this.title,
    this.subtitle, {
    super.key,
    this.icon = Icons.celebration_outlined,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 12),
    child: Column(
      children: [
        Container(
          width: 79,
          height: 79,
          decoration: BoxDecoration(
            color: AppColors.lavender,
            borderRadius: BorderRadius.circular(27),
          ),
          child: Icon(icon, size: 34, color: AppColors.purple),
        ),
        gap24,
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        gap8,
        Text(subtitle, textAlign: TextAlign.center),
        if (action != null) ...[gap24, action!],
      ],
    ),
  );
}

class EventTile extends StatelessWidget {
  final EventPlan event;
  final VoidCallback? onTap;
  const EventTile(this.event, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) => PartyCard(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 55,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.lavender,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                '${event.date.day}',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: AppColors.purple,
                ),
              ),
              Text(
                DateFormat('MMM').format(event.date).toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.purple,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${event.location.split(',').first} · ${event.guests} guests',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              gap8,
              StatusBadge(event.statusLabel, green: event.bookings.isNotEmpty),
            ],
          ),
        ),
        if (onTap != null)
          const Padding(
            padding: EdgeInsets.only(left: 7),
            child: Icon(Icons.chevron_right, size: 20, color: AppColors.muted),
          ),
      ],
    ),
  );
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const DetailRow(this.icon, this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.lavender,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 19, color: AppColors.purple),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}

class EventFacts extends StatelessWidget {
  final EventPlan event;
  const EventFacts(this.event, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      DetailRow(
        Icons.calendar_month_outlined,
        dateLabel(event.date),
        '${timeLabel(event.start)} – ${timeLabel(event.end)}',
      ),
      DetailRow(Icons.location_on_outlined, event.location, 'Event location'),
      DetailRow(
        Icons.people_outline,
        '${event.guests} guests',
        '${event.type} celebration',
      ),
    ],
  );
}

class BudgetBar extends StatelessWidget {
  final List<Allocation> allocations;
  const BudgetBar(this.allocations, {super.key});
  @override
  Widget build(BuildContext context) {
    final positive = allocations
        .where((a) => a.percent > 0 && a.percent.isFinite)
        .toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Row(
        children: positive
            .map(
              (a) => Expanded(
                flex: (a.percent * 100).round().clamp(1, 100000),
                child: Container(
                  height: 7,
                  margin: const EdgeInsets.only(right: 2),
                  color: Color(a.color),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class InfoPair extends StatelessWidget {
  final String label, value;
  const InfoPair(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontSize: 11)),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String action = 'Confirm',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep my plan'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;
