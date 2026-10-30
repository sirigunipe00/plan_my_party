# Plan My Party — Step-by-step VS Code Setup

These steps are written for **Ubuntu/Linux**. The VS Code workflow and Flutter commands also work on other systems when the matching SDKs are installed.

## 1. Install prerequisites

```bash
sudo apt update
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk
```

Install VS Code from https://code.visualstudio.com/download if needed.

## 2. Install Flutter in VS Code

1. Open VS Code and press **Ctrl + Shift + X**.
2. Search for **Flutter** and install the extension published by **Dart Code**. It also installs the Dart extension.
3. Press **Ctrl + Shift + P**, then choose **Flutter: New Project**.
4. If the Flutter SDK is missing, choose **Download SDK**, select a folder such as `~/develop`, and choose **Clone Flutter**.
5. After the download, choose **Add SDK to PATH**.
6. Restart VS Code and your terminal. Cancel the new-project wizard: the complete app is already provided in the ZIP.

Verify:

```bash
flutter --version
dart --version
flutter doctor
```

Use Flutter 3.35+ and Dart 3.9+. The project was tested using Flutter 3.35.7 / Dart 3.9.2.

If `flutter` is not found, add your actual SDK's `bin` directory to PATH. For an SDK installed at `~/develop/flutter`, add this line to `~/.bashrc`, then open a new terminal:

```bash
export PATH="$HOME/develop/flutter/bin:$PATH"
```

Use a different path if you installed Flutter elsewhere.

Official guide: https://docs.flutter.dev/install/with-vs-code

## 3. Install Android tools

You can edit everything in VS Code. Android Studio is used here to manage the Android SDK and emulator.

1. Install Android Studio from https://developer.android.com/studio and finish its setup wizard.
2. Open **SDK Manager** under **More Actions** or **Tools**.
3. Under **SDK Platforms**, install **Android API 36**. If your newer Flutter SDK requests another compile SDK, install that version too.
4. Under **SDK Tools**, install **Android SDK Command-line Tools (latest)**, **Android SDK Platform-Tools**, and **Android SDK Build-Tools**.
5. Install **Android Emulator** if you want a virtual phone.
6. Use **JDK 17** for this project's Android Gradle toolchain. Check the JDK reported by `flutter doctor -v`; a newer Android Studio installation might bundle a different version.

Then run:

```bash
flutter doctor --android-licenses
flutter doctor
```

Read and accept the licenses when prompted. Fix Android toolchain errors before building an APK. Gradle may download the matching NDK during the first Android build; let it finish.

If Flutter cannot find your SDK and it is installed at the usual Linux location:

```bash
flutter config --android-sdk "$HOME/Android/Sdk"
```

Use your actual directory if it is elsewhere. To select a JDK explicitly, run the following with a real JDK path:

```bash
flutter config --jdk-dir /absolute/path/to/your/jdk-17
```

Official Android setup: https://docs.flutter.dev/platform-integration/android/setup

## 4. Extract the project and open it

Download `PlanMyParty-Flutter-Source.zip`. If it is saved in Downloads:

```bash
cd "$HOME/Downloads"
unzip PlanMyParty-Flutter-Source.zip
cd plan_my_party
code .
```

If the extraction folder already exists, choose a fresh destination so versions do not get mixed.

Alternatively use **VS Code → File → Open Folder** and choose `plan_my_party`. That folder directly contains `pubspec.yaml`, `lib`, `android` and `assets`.

If `code .` is unavailable, use the Open Folder menu instead.

## 5. Install the project packages

In **VS Code → Terminal → New Terminal**, from the project root:

```bash
flutter pub get
flutter analyze
flutter test
```

Keep `pubspec.lock` for reproducible package versions. The SDK, package caches, build output and machine-specific `android/local.properties` are intentionally excluded from the ZIP. Flutter creates local configuration as needed.

## 6. Connect your phone or start an emulator

For a phone:

1. Enable **Developer options** by tapping the phone's **Build number** seven times under About phone. Exact menus vary.
2. Enable **USB debugging**.
3. Connect a USB data cable, unlock the phone and approve the debugging authorization prompt.
4. Run:

```bash
flutter devices
```

Your phone should appear. If it says `unauthorized`, accept the prompt on the phone. If Linux reports a USB permissions issue, follow the Android setup guide for your distribution's USB/udev configuration.

For an emulator, open **Android Studio → Device Manager → Create Virtual Device**, download an Android system image and start the virtual phone.

## 7. Run the app

```bash
flutter run
```

Choose your Android phone/emulator if Flutter lists multiple devices. You can also use the actual device ID printed by `flutter devices`:

```bash
flutter run -d YOUR_DEVICE_ID
```

Replace `YOUR_DEVICE_ID`; it is a placeholder.

In VS Code, another option is to select your device in the bottom status bar and press **F5**. The supplied launch configuration already opens `lib/main.dart`.

The first Android run may download Gradle and SDK dependencies. Keep the terminal open until the app launches.

## 8. Edit and hot reload

Change a heading in `lib/screens/home_screen.dart`, or change colors in `lib/theme/app_theme.dart`.

Save, then use VS Code's **Hot Reload**, or press `r` in the terminal running `flutter run`. Use Hot Restart or `R` for changes that need reinitialization.

Changing initial sample data does not overwrite an existing saved profile. To restore new defaults, open **Profile → Privacy & app information → Reset local demo data**.

## 9. Build an APK

```bash
flutter build apk --release
```

Find the APK at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Copy it to an Android 8.0+ phone and open it to install. Android may ask you to allow installation from the app opening the APK.

This project's release configuration uses a development/debug signing key for testing. Configure your own private production key before a public release.

For smaller architecture-specific APKs:

```bash
flutter build apk --release --split-per-abi
```

This creates separate APKs for ARM64, ARM32 and x86-64 under the same output directory. For a simple first installation, the single APK avoids choosing an architecture.

Build guide: https://docs.flutter.dev/deployment/android

## 10. Optional browser preview

If Chrome is installed and recognized by Flutter:

```bash
flutter run -d chrome
```

The browser preview helps with layout changes; Android-specific features still need a phone/emulator check.

## 11. Optional GitHub workflow

This ZIP is a source download. It has not been published to GitHub, so there is no `git pull` URL yet.

To put it in a new repository:

```bash
git init
git add .
git commit -m "Add Plan My Party Flutter app"
git branch -M main
```

Create an empty GitHub repository in your account, then use its actual URL:

```bash
git remote add origin YOUR_GITHUB_REPOSITORY_URL
git push -u origin main
```

Replace the URL placeholder. After pushing, you can clone that repository on another computer or use VS Code's **Git: Clone** command.

The included `.gitignore` excludes build output, local paths, caches and signing secrets.

## Troubleshooting

| Message | Fix |
| --- | --- |
| `flutter: command not found` | Add the actual Flutter `bin` directory to PATH and reopen the terminal. |
| `No pubspec.yaml file found` | Open a terminal inside `plan_my_party`. |
| Command-line tools missing | Install Android SDK Command-line Tools (latest) in SDK Manager. |
| Android licenses missing | Run `flutter doctor --android-licenses`. |
| No devices | Start an emulator or connect and authorize a phone with USB debugging. |
| Gradle/JDK error | Check `flutter doctor -v` and select JDK 17. |
| SDK/NDK version missing | Install the exact version named in the build output, then retry. |
| Old sample/profile text | Reset local demo data from the app's privacy page. |

After a build-configuration change, stale generated output can be cleared with:

```bash
flutter clean
flutter pub get
flutter run
```

Normal text/color edits only need hot reload.

## Demo scope

Event plans, favorites, addresses, profiles and demo bookings save locally. Real login, cloud sync, live vendors, messaging, payments and push delivery require a backend. No server credentials or API keys are required for this demo.
