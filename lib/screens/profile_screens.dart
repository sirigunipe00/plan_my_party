import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/catalog_widgets.dart';
import 'vendor_screens.dart';

class ProfileScreen extends StatelessWidget {
  final AppStore store;
  final ValueChanged<int> onTab;
  const ProfileScreen({super.key, required this.store, required this.onTab});
  @override
  Widget build(BuildContext context) => RootScroll(
    children: [
      Text(
        'A little about you.',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      gap24,
      Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xffE8DCCF),
              child: Text(
                store.profile.initials,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 27,
                  color: Color(0xff765640),
                ),
              ),
            ),
            gap16,
            Text(
              store.profile.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            gap8,
            Text(store.profile.email, style: const TextStyle(fontSize: 12)),
            gap12,
            const StatusBadge('LOCAL DEMO PROFILE'),
          ],
        ),
      ),
      gap24,
      Row(
        children: [
          for (final stat in [
            ('${store.events.length}', 'Celebrations'),
            ('${store.favorites.length}', 'Saved vendors'),
            (
              '${store.events.fold<int>(0, (s, e) => s + e.bookings.length)}',
              'Demo bookings',
            ),
          ])
            Expanded(
              child: Column(
                children: [
                  Text(
                    stat.$1,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(stat.$2, style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
        ],
      ),
      gap24,
      PartyCard(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            _menu(
              Icons.person_outline,
              'Personal information',
              'Your name and contact details',
              () => pushPage(context, PersonalScreen(store: store)),
            ),
            _menu(
              Icons.location_on_outlined,
              'Saved addresses',
              'Your favorite places to celebrate',
              () => pushPage(context, AddressesScreen(store: store)),
            ),
            _menu(
              Icons.calendar_month_outlined,
              'My celebrations',
              'Everything you’re planning',
              () => onTab(2),
            ),
            _menu(
              Icons.favorite_border,
              'Saved vendors',
              'Your dream team, in one place',
              () => pushPage(context, FavoritesScreen(store: store)),
            ),
            _menu(
              Icons.notifications_none,
              'Notification preferences',
              'Choose your in-app updates',
              () => _preferences(context),
            ),
            _menu(
              Icons.help_outline,
              'Help & support',
              'A little help along the way',
              () => _help(context),
            ),
            _menu(
              Icons.lock_outline,
              'Privacy & app information',
              'How this demo handles your data',
              () => pushPage(context, PrivacyScreen(store: store)),
            ),
          ],
        ),
      ),
      gap24,
      PrimaryButton(
        'Switch local profile',
        outline: true,
        icon: Icons.person_outline,
        onPressed: () => pushPage(context, PersonalScreen(store: store)),
      ),
      gap24,
      const Center(
        child: Text(
          'Plan My Party · Flutter customer demo v1.0.0\nMade for the moments that matter.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10),
        ),
      ),
    ],
  );
  Widget _menu(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback action,
  ) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
    leading: Icon(icon, color: const Color(0xff9E88BD), size: 21),
    title: Text(
      title,
      style: const TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 10)),
    trailing: const Icon(Icons.chevron_right, size: 17),
    onTap: action,
  );
  Future<void> _preferences(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => StoreView(
      store: store,
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A little control over updates.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              gap12,
              const Text(
                'Choose which local updates appear in the app. Push delivery is not connected.',
              ),
              gap16,
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Event reminders',
                  style: TextStyle(fontSize: 13),
                ),
                subtitle: const Text(
                  'Show in-app updates on the day before and day of your event.',
                  style: TextStyle(fontSize: 11),
                ),
                value: store.eventReminders,
                onChanged: (v) {
                  store.eventReminders = v;
                  store.changed();
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Quote updates',
                  style: TextStyle(fontSize: 13),
                ),
                value: store.quoteUpdates,
                onChanged: (v) {
                  store.quoteUpdates = v;
                  store.changed();
                },
              ),
              gap16,
              PrimaryButton(
                'Save preferences',
                icon: Icons.check,
                onPressed: () => Navigator.pop(sheet),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Future<void> _help(BuildContext context) => showDialog<void>(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('A little help along the way'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How do I plan an event?',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            gap8,
            Text(
              'Tap Plan an event, add the details, choose a venue on the map, then add decoration and furniture. Your budget follows the items you add.',
            ),
            gap16,
            Text(
              'Can I make a real booking?',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            gap8,
            Text(
              'This is an offline demo. Quotes and bookings are local examples. No service is reserved and no money is collected.',
            ),
            gap16,
            Text(
              'Where are my plans saved?',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            gap8,
            Text(
              'In local app storage on this device. Uninstalling or clearing app data removes your plans.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: const Text('Got it, thank you'),
        ),
      ],
    ),
  );
}

class PersonalScreen extends StatefulWidget {
  final AppStore store;
  final bool onboarding;
  const PersonalScreen({
    super.key,
    required this.store,
    this.onboarding = false,
  });
  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, email, phone, city;
  @override
  void initState() {
    super.initState();
    final p = widget.store.profile;
    name = TextEditingController(text: p.name);
    email = TextEditingController(text: p.email);
    phone = TextEditingController(text: p.phone);
    city = TextEditingController(text: p.city);
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    city.dispose();
    super.dispose();
  }

  String? requiredText(String? v) =>
      v == null || v.trim().isEmpty ? 'Please fill in this detail.' : null;
  @override
  Widget build(BuildContext context) => AppPage(
    title: widget.onboarding ? 'Make yourself at home' : 'Personal information',
    bottom: PrimaryButton(
      widget.onboarding ? 'Start planning' : 'Save my details',
      icon: Icons.check,
      onPressed: () async {
        if (!form.currentState!.validate()) return;
        widget.store.profile = Profile(
          name: name.text.trim(),
          email: email.text.trim(),
          phone: phone.text.trim(),
          city: city.text.trim(),
        );
        if (widget.onboarding) widget.store.onboarded = true;
        widget.store.changed();
        await widget.store.persist();
        if (!context.mounted) return;
        Navigator.pop(context);
      },
    ),
    children: [
      PageHeading(
        widget.onboarding
            ? 'A party with\nyour name on it.'
            : 'Make it feel like you.',
        subtitle: 'Your profile is saved only on this device.',
      ),
      Form(
        key: form,
        child: Column(
          children: [
            TextFormField(
              key: const Key('profile-name'),
              controller: name,
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Your name'),
              validator: requiredText,
            ),
            gap16,
            TextFormField(
              key: const Key('profile-email'),
              controller: email,
              maxLength: 100,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address'),
              validator: (s) =>
                  s == null ||
                      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s.trim())
                  ? 'Enter a valid email address.'
                  : null,
            ),
            gap16,
            TextFormField(
              controller: phone,
              maxLength: 20,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
            ),
            gap16,
            TextFormField(
              controller: city,
              maxLength: 60,
              decoration: const InputDecoration(labelText: 'City'),
              validator: requiredText,
            ),
          ],
        ),
      ),
      const DemoNotice(
        text:
            'This is a local demo profile. No online account is created and no password is required.',
      ),
    ],
  );
}

class FavoritesScreen extends StatelessWidget {
  final AppStore store;
  const FavoritesScreen({super.key, required this.store});
  @override
  Widget build(BuildContext context) => StoreView(
    store: store,
    builder: (context) {
      final saved = vendors
          .where((v) => store.favorites.contains(v.id))
          .toList();
      return AppPage(
        title: 'Your kind of people',
        children: [
          const PageHeading(
            'Saved for\nsomething special.',
            subtitle: 'Keep your favorites close while you make your plans.',
          ),
          if (saved.isEmpty)
            EmptyState(
              'Your dream team starts here.',
              'Tap the heart on a vendor to save them for later.',
              icon: Icons.favorite_border,
              action: PrimaryButton(
                'Explore vendors',
                onPressed: () =>
                    pushPage(context, VendorBrowsePage(store: store)),
              ),
            )
          else
            VendorGrid(
              vendors: saved,
              store: store,
              onOpen: (v) => pushPage(
                context,
                VendorDetailScreen(store: store, vendor: v),
              ),
            ),
        ],
      );
    },
  );
}

class AddressesScreen extends StatelessWidget {
  final AppStore store;
  const AddressesScreen({super.key, required this.store});
  @override
  Widget build(BuildContext context) => StoreView(
    store: store,
    builder: (context) => AppPage(
      title: 'Saved addresses',
      bottom: PrimaryButton(
        'Add an address',
        icon: Icons.add,
        outline: true,
        onPressed: () => _add(context),
      ),
      children: [
        const PageHeading(
          'Your happy places.',
          subtitle: 'Save a venue or an address for your next celebration.',
        ),
        if (store.addresses.isEmpty)
          const EmptyState(
            'A place for happy memories.',
            'Add your first address below.',
            icon: Icons.location_on_outlined,
          ),
        ...store.addresses.asMap().entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PartyCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.purple,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.value.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          e.value.address,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove ${e.value.label}',
                    onPressed: () {
                      store.addresses.removeAt(e.key);
                      store.changed();
                    },
                    icon: const Icon(Icons.delete_outline, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
  Future<void> _add(BuildContext context) async {
    final form = GlobalKey<FormState>();
    final label = TextEditingController(), address = TextEditingController();
    final result = await showDialog<SavedAddress>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('A place for happy memories'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: label,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'A name for this place',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Add a name.' : null,
              ),
              gap12,
              TextFormField(
                controller: address,
                maxLength: 180,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Add an address.' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(
                  d,
                  SavedAddress(label.text.trim(), address.text.trim()),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      store.addresses.add(result);
      store.changed();
    }
  }
}

class PrivacyScreen extends StatelessWidget {
  final AppStore store;
  const PrivacyScreen({super.key, required this.store});
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Privacy & app information',
    children: [
      const PageHeading(
        'A little clarity.',
        subtitle: 'Plan My Party · Flutter customer demo v1.0.0',
      ),
      ...[
        (
          'Your data stays with you',
          'Your profile, drafts, events, inspiration photos and favorites are saved locally using shared_preferences. Clearing app data or uninstalling removes them. No analytics, ads or tracking are included.',
        ),
        (
          'A working Flutter demo',
          'This app recreates the supplied Plan My Party Android experience with Flutter widgets and Dart. Vendors, ratings, reviews, packages and quotes are sample data. Booking saves a local demonstration record; it does not reserve services, send messages or collect money.',
        ),
        (
          'Accounts & notifications',
          'Your profile is local. Online authentication, Google sign-in, recovery, cloud sync and push delivery are not connected. Notification preferences control the in-app updates.',
        ),
        (
          'Inspiration photos',
          'The system photo picker lets you choose up to four inspiration images. Images are saved with your local draft and event. The app does not require broad storage, camera or location access.',
        ),
        (
          'Photographs',
          'Bundled Unsplash photographs are illustrative inspiration, not verified portfolios of the sample vendors. The source project includes image source URLs and the DM Sans font license.',
        ),
        (
          'Before a public launch',
          'Connect secure user accounts, a real vendor catalog, availability and a backend for bookings, messaging, payments and notifications. Release builds should use your own signing key.',
        ),
      ].expand(
        (p) => [
          Text(p.$1, style: Theme.of(context).textTheme.titleMedium),
          gap8,
          Text(p.$2),
          gap24,
        ],
      ),
      PrimaryButton(
        'Reset local demo data',
        outline: true,
        icon: Icons.delete_outline,
        onPressed: () async {
          final ok = await confirm(
            context,
            title: 'Start fresh?',
            message:
                'Remove local events, drafts, profile details, photos and favorites, then restore the sample celebration?',
            action: 'Reset demo',
          );
          if (!ok) return;
          await store.reset();
          if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
        },
      ),
    ],
  );
}
