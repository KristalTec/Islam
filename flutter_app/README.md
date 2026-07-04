# Islam Online — Flutter Native App

Kurdish Sorani Islamic mobile app built with Flutter for Android & iOS.

---

## Features

| Screen | Description |
|---|---|
| 🏠 Home | Daily feed (hadiths, duas, ayahs, info) with AI-generated content |
| 🕌 Prayer Times | Real-time prayer times via aladhan.com, adhan audio playback |
| 📖 Hadith | Local database of 14 authentic hadiths across 4 major books |
| 📗 Quran | Full Quran reader with speech recognition for tilawah practice |
| 📚 Library | Search Islamic books from OpenLibrary, Google Books, Archive.org |

---

## Prerequisites

- Flutter SDK ≥ 3.0.0 ([install guide](https://docs.flutter.dev/get-started/install))
- Dart SDK ≥ 3.0.0 (bundled with Flutter)
- Android Studio or Xcode (for Android/iOS builds)

---

## Setup

```bash
cd flutter_app
flutter pub get
```

---

## Running

```bash
# Android emulator or device
flutter run

# iOS simulator (macOS only)
flutter run -d "iPhone 15"
```

---

## Building

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android AAB (Google Play)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS IPA (macOS + Xcode required)

```bash
flutter build ipa --release
# Output: build/ios/ipa/Islam Online.ipa
```

---

## App Icon Setup

The app uses [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) for generating launcher icons.

### Steps

1. **Design your icon** — Create a 1024×1024 PNG with an Islamic-themed design (e.g., crescent moon, star, mosque, Quran). A placeholder icon is included at `assets/images/app_icon.png`.

2. **Replace the placeholder** — Copy your icon file to:
   ```
   flutter_app/assets/images/app_icon.png
   ```

3. **Generate all platform icons**:
   ```bash
   cd flutter_app
   flutter pub run flutter_launcher_icons
   ```
   This generates icons for all sizes in:
   - `android/app/src/main/res/mipmap-*/`
   - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

4. **Rebuild the app** to see your new icon.

> **Tip**: Use [App Icon Generator](https://appicon.co/) or [Icon Kitchen](https://icon.kitchen/) to design Islamic-themed icons online.

---

## Permissions

### Android (`AndroidManifest.xml`)

| Permission | Purpose |
|---|---|
| `INTERNET` | API calls (prayer times, Quran, library) |
| `ACCESS_FINE_LOCATION` | Precise GPS for prayer times |
| `RECORD_AUDIO` | Quran speech recognition |
| `POST_NOTIFICATIONS` | Adhan prayer time alerts |
| `VIBRATE` | Notification vibration |

### iOS (`Info.plist`)

| Key | Purpose |
|---|---|
| `NSMicrophoneUsageDescription` | Quran recitation verification |
| `NSLocationWhenInUseUsageDescription` | Prayer times calculation |
| `NSLocationAlwaysUsageDescription` | Background prayer alerts |

---

## Architecture

```
lib/
├── main.dart                    # Entry point, provider setup
├── app.dart                     # MaterialApp, RTL locale, theme
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # Color palette
│   │   ├── app_strings.dart     # Kurdish/Arabic UI strings
│   │   └── api_constants.dart   # All API endpoint URLs
│   ├── theme/
│   │   └── app_theme.dart       # Material3 theme
│   ├── usecases/
│   │   └── usecase.dart         # Shared use case contract
│   └── utils/
│       └── date_utils.dart      # Date formatting helpers
├── domain/
│   ├── entities/                 # Core business models
│   └── repositories/             # Repository contracts
├── data/
│   ├── models/                  # Data models (Hadith, Prayer, Book, etc.)
│   ├── services/                # API clients (prayer, quran, library, AI)
│   └── repositories/           # Local data (hadith DB, feed fallbacks)
├── providers/                   # State management (ChangeNotifier)
│   ├── home_provider.dart
│   ├── prayer_provider.dart
│   ├── hadith_provider.dart
│   ├── quran_provider.dart
│   └── library_provider.dart
└── presentation/
    ├── screens/
    │   ├── home/
    │   ├── prayer_times/
    │   ├── hadith/
    │   ├── quran/
    │   └── library/
    └── widgets/                 # Shared widgets (settings, history sheets)
```

---

## Fonts

The app uses [Amiri](https://fonts.google.com/specimen/Amiri) Arabic font via the [`google_fonts`](https://pub.dev/packages/google_fonts) package (downloaded at runtime).

**To bundle fonts offline:**
1. Download `Amiri-Regular.ttf` and `Amiri-Bold.ttf` from [Google Fonts](https://fonts.google.com/specimen/Amiri)
2. Place them in `flutter_app/assets/fonts/`
3. Uncomment the `fonts:` section in `pubspec.yaml`

---

## Credits

- Prayer Times: [aladhan.com API](https://aladhan.com/prayer-times-api)
- Quran Data: [alquran.cloud API](https://alquran.cloud/api)
- Library: [OpenLibrary](https://openlibrary.org), [Google Books](https://developers.google.com/books), [Archive.org](https://archive.org)
- Adhan Audio: Various Islamic recitation sources
- Built by Muhamad Ibrahim Rasul
