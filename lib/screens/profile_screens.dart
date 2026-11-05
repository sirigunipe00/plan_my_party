import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/catalog_widgets.dart';
import 'vendor_screens.dart';

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
