# Validation

Checked on 29 October 2026 using Flutter 3.35.7 / Dart 3.9.2.

## Completed

- `flutter pub get`: dependency resolution completed; resolved versions are included in `pubspec.lock`.
- `flutter analyze`: no issues found.
- `flutter test`: all 12 automated tests passed.
- `flutter build web --release --no-web-resources-cdn`: release compilation succeeded, including the WebAssembly compatibility dry run.
- The source archive includes Android Gradle files, the Gradle wrapper JAR and scripts, Kotlin activity, manifest, launcher images, Flutter assets and VS Code settings.

## Tests cover

1. Initial sample data and local profile/favorite persistence.
2. Draft, balloon theme, image data and budget persistence.
3. Event times, guest counts, budget limits and allocation validation.
4. Correct saved event fields and clearing the completed draft.
5. Requests/bookings for the selected vendor, correct totals, duplicate protection and event status rules.
6. Combined vendor filtering and sorting.
7. Resetting local data and restoring onboarding.
8. Guest entry and the full four-step event creation journey.
9. Vendor favorite selection and generating a quote for that vendor.
10. Main tabs and detail/form screens at 320 CSS/logical pixels without layout exceptions.
11. The same layout checks at 390 logical pixels.
12. The same layout checks at 430 logical pixels.

Widget tests load the bundled DM Sans font and use Flutter's rendering/test engine. Local storage is mocked by the shared_preferences package in tests.

## Limits

An Android SDK/emulator and physical phone were not used for an Android build or install-and-launch test in this conversion. Native plugin behavior (photo chooser, Android process recovery, system keyboard, system bars and device-specific rendering) still needs a phone/emulator check using the setup guide.

The previously supplied APK is the earlier Java/WebView build. This deliverable is the Flutter source recreation. An APK built from this project has a different application ID and uses its own local storage. It does not automatically migrate old WebView app data.

Production backend services and production signing are not configured. The Android release build configuration uses the development signing identity for testing.
