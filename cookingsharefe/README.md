# CookingShare Frontend 🍳

Flutter mobile and web application for the CookingShare platform - a recipe sharing and discovery app with ratings, comments, and multimedia support.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Running the App](#running-the-app)
- [Technologies Used](#technologies-used)
- [Build Instructions](#build-instructions)

## Features

- User Authentication (Signup/Login)
- Browse and Search Recipes
- Create and Share Recipes
- Upload Images and Videos
- Rate and Comment on Recipes
- User Profiles
- Responsive UI for all platforms
- Secure Token Storage
- Image Caching
- Offline Support (SharedPreferences)

## Prerequisites

- **Flutter SDK:** >= 3.1.5 and < 4.0.0
- **Dart SDK:** Included with Flutter
- **IDE:** Android Studio, VS Code, or Xcode
- **Android:** Android SDK 21+
- **iOS:** iOS 12.0+

## Installation

### 1. Install Flutter

Follow official guide: https://flutter.dev/docs/get-started/install

### 2. Clone and Setup

```bash
cd cookingsharefe
```

### 3. Get Dependencies

```bash
flutter pub get
```

### 4. Configure API Endpoint

Update API configuration in `lib/config/`:
```dart
const String API_BASE_URL = 'http://localhost:5000/api';
```

## Project Structure

```
cookingsharefe/
├── lib/
│   ├── main.dart               # Application entry point
│   │
│   ├── config/                 # Configuration files
│   │   ├── app_config.dart    # API URLs, constants
│   │   └── theme_config.dart  # Theme & colors
│   │
│   ├── core/                   # Core utilities & helpers
│   │   ├── models/            # Data models
│   │   ├── services/          # API & storage services
│   │   ├── providers/         # State management
│   │   └── utils/             # Helper functions
│   │
│   └── features/               # Feature modules
│       ├── auth/              # Authentication screens
│       ├── recipes/           # Recipe listing & details
│       ├── recipe_create/     # Create recipe screen
│       ├── user_profile/      # User profile screen
│       └── home/              # Home screen
│
├── assets/
│   ├── images/                # App images
│   └── icons/                 # App icons
│
├── android/                   # Android configuration
├── ios/                       # iOS configuration
├── web/                       # Web configuration
├── windows/                   # Windows configuration
├── macos/                     # macOS configuration
├── linux/                     # Linux configuration
│
├── pubspec.yaml               # Project dependencies
├── analysis_options.yaml      # Code analysis options
└── README.md                  # This file
```

## Running the App

### Run on Mobile Device

```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Run on Emulator/Simulator

```bash
# Android Emulator
flutter run

# iOS Simulator
flutter run -d "iPhone 15 Pro"
```

### Run on Web

```bash
flutter run -d chrome
```

### Run on Desktop (Windows)

```bash
flutter run -d windows
```

### Development Mode (Hot Reload)

```bash
flutter run
# Press 'r' to hot reload
# Press 'R' to hot restart
```

## 🔧 Technologies Used

| Package | Version | Purpose |
|---------|---------|---------|
| **http** | 1.1.0 | HTTP requests to backend |
| **provider** | 6.0.5 | State management |
| **shared_preferences** | 2.2.2 | Local data storage |
| **flutter_secure_storage** | 9.0.0 | Secure token storage |
| **image_picker** | 1.0.4 | Pick images from device |
| **image_picker_web** | 3.1.1 | Pick images on web |
| **file_picker** | 6.1.1 | Pick files |
| **video_player** | 2.7.2 | Play videos |
| **chewie** | 1.7.1 | Video player UI |
| **cached_network_image** | 3.3.0 | Image caching |
| **flutter_staggered_grid_view** | 0.7.0 | Staggered grid layout |
| **google_fonts** | 6.1.0 | Google fonts support |
| **font_awesome_flutter** | 10.6.0 | Font Awesome icons |
| **shimmer** | 3.0.0 | Loading shimmer effect |
| **intl** | 0.18.1 | Internationalization |
| **flutter_carousel_widget** | 2.1.2 | Carousel widget |
| **json_annotation** | 4.8.1 | JSON serialization |

## 🏗 Build Instructions

### Generate Build Files

```bash
flutter pub get
flutter clean
flutter pub get
```

### Android Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Google Play)
flutter build appbundle --release
```

### iOS Build

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

### Web Build

```bash
flutter build web --release
```

### Windows Build

```bash
flutter build windows --release
```

## Security Features

- Secure token storage using `flutter_secure_storage`
- HTTPS/TLS for API calls
- Input validation before API requests
- JWT token-based authentication
- Automatic token refresh

## Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Generate coverage report
flutter test --coverage
```

## App Metrics

- **Min SDK Version:** Android 21
- **Target SDK Version:** Latest
- **iOS Minimum:** iOS 12.0
- **Dart Version:** >= 3.1.5

## Troubleshooting

### Build Issues

```bash
# Clean everything
flutter clean

# Reinstall dependencies
rm -rf pubspec.lock
flutter pub get
```

### Android Issues

```bash
# Update Android Studio & SDK
# Check Gradle compatibility
cd android
./gradlew --version
```

### iOS Issues

```bash
# Update CocoaPods
pod repo update
cd ios
pod install
```

### API Connection Issues

- Verify backend server is running
- Check API URL in `lib/config/app_config.dart`
- Ensure device can reach backend IP/host
- Check firewall settings

## Support

For issues or questions, contact: thevinhp333@gmail.com

## License

ISC License

## Author

**Phùng Thế Vinh**
- Student ID: 4451051043

---

**Happy Cooking!**
