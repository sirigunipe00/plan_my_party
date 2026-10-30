# Plan My Party — Flutter Source

This is a **Flutter/Dart recreation of the Plan My Party app** delivered earlier. That APK used an Android WebView with HTML, CSS and JavaScript. This project implements the customer experience with Flutter widgets and Dart, with a similar design and the same local demo journey.

Start with **[SETUP_VSCODE.md](SETUP_VSCODE.md)** for step-by-step installation and running instructions.

## Quick start

Open this directory (the folder containing `pubspec.yaml`) in VS Code:

```bash
flutter pub get
flutter doctor
flutter devices
flutter run
```

## Included

- Onboarding, guest entry and an editable local profile.
- Home dashboard, nine event types and five navigation tabs.
- Four-step planner, eight service groups and saved drafts.
- Validated guest counts, event times and budget allocations.
- Balloon details, color palettes and up to four inspiration photos.
- Vendor search, categories, area/rating/price filters and sorting.
- Persistent favorites, individual profiles and package details.
- Sample quote requests for the selected vendor and event.
- Quote comparison, booking confirmation and duplicate-booking protection.
- Per-event budget totals, bookings and timeline.
- Event completion, cancellation and restoration.
- In-app updates, read state, preferences and saved addresses.
- Android back handling, native date/time pickers and photo chooser.
- Bundled photographs, DM Sans font and launcher artwork.
- Android/web platform folders, dependency lockfile, VS Code settings and tests.

## Files to edit

| Path | Purpose |
| --- | --- |
| `lib/main.dart` | Startup, theme and app lifecycle |
| `lib/screens/app_shell.dart` | Five-tab navigation |
| `lib/screens/home_screen.dart` | Home dashboard |
| `lib/screens/welcome_screen.dart` | Onboarding |
| `lib/screens/planner_screen.dart` | Planner and balloon customization |
| `lib/screens/vendor_screens.dart` | Search, filters, profiles and requests |
| `lib/screens/quote_screens.dart` | Quotes, comparison and demo bookings |
| `lib/screens/event_screens.dart` | Events, details and updates |
| `lib/screens/profile_screens.dart` | Profile, favorites, addresses and privacy |
| `lib/models/models.dart` | Typed app models |
| `lib/state/app_store.dart` | App actions and local persistence |
| `lib/data/catalog.dart` | Sample vendors, services and event types |
| `lib/theme/app_theme.dart` | Colors, typography and styling |
| `lib/widgets/` | Reusable UI components |
| `assets/` | Images and font |
| `android/` | Android application and Gradle configuration |
| `web/` | Optional local browser preview |
| `test/` | Persistence, model and Flutter widget tests |

## Data and demo scope

The app starts with the same illustrative Ananya profile, birthday event and vendor catalog as the earlier app. Edit the profile inside the app or change the defaults in the model/store files.

State is saved as JSON using `shared_preferences`. Draft writes are debounced and serialized. Inspiration images are stored as base64 with drafts and events. Unreadable saved state is retained under a recovery key before sample data is restored.

This is an **offline customer demo**. Vendors, ratings, reviews, prices and quotes are illustrative. No online account is created. Requests do not send messages; bookings do not reserve services or collect money. Authentication, cloud sync, real vendors, availability, messaging, payments and push delivery need a backend.

The application ID is `com.planmyparty.plan_my_party`. It installs separately from the earlier `com.planmyparty.customer` APK. Data from the HTML/WebView app is not automatically imported.

## Toolchain

- Verified using Flutter **3.35.7** and Dart **3.9.2**.
- Minimum project requirements: Flutter **3.35+**, Dart **3.9+**.
- Android minimum: **API 26 / Android 8.0**.
- Flutter 3.35.7 defaults to compile/target SDK **36** and NDK **27.0.12077973**. Newer Flutter SDKs may request newer defaults.
- Android Gradle plugin **8.9.1**, Gradle wrapper **8.12**, Kotlin **2.1.0**, JDK **17**.
- Resolved package versions are recorded in `pubspec.lock`.

## Check and build

```bash
flutter analyze
flutter test
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`.

The release configuration currently uses the **development/debug signing identity** for testing. Configure your own private release signing before public distribution. See `VALIDATION.md` for completed checks and testing limits.

No credentials or API keys are required for the included demo.
