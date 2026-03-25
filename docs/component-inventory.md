# Component Inventory: Lost and Found

## Overview

The app contains 8 Dart source files with 7 widget classes. All widgets are StatefulWidgets using `setState()` for state management. There are no reusable/shared components — each page is self-contained.

## Widget Inventory

| Widget | File | Type | Lines | Purpose |
|---|---|---|---|---|
| `MyApp` | `lib/main.dart` | StatelessWidget | 20 | App root — MaterialApp with routes and theme |
| `HomePage` | `lib/main.dart` | StatelessWidget | 87 | Main hub with logo and Lost/Found buttons |
| `SplashScreen` | `lib/pages/splashscreen.dart` | StatefulWidget | 47 | Splash with logo, 2s auto-navigate to SignIn |
| `SignInPage` | `lib/pages/signinpage.dart` | StatefulWidget | 157 | Email/password login form |
| `SignUpPage` | `lib/pages/signuppage.dart` | StatefulWidget | 214 | Registration form (name, email, password) |
| `LostPage` | `lib/pages/lost_items.dart` | StatefulWidget | 312 | Report lost item with map, images, form |
| `FoundPage` | `lib/pages/found_page.dart` | StatefulWidget | 312 | Report found item (identical to LostPage) |
| `ProfilePage` | `lib/pages/profile_page.dart` | StatefulWidget | 266 | View/edit user profile fields |

**Total Dart source lines:** ~1,395 (excluding `firebase_options.dart`)

## UI Component Patterns

### Forms
- `TextFormField` used for text inputs across all pages
- `buildPasswordFormField()` — private helper in both SignIn and SignUp pages (duplicated, not shared)
- No form validation with `Form` widget or `GlobalKey<FormState>` — validation is ad-hoc

### Navigation Drawers
- **LostPage/FoundPage:** Basic drawer with blue header, "Home" and "Profile" links
- **ProfilePage:** Styled drawer with orange background (`Color.fromRGBO(232, 99, 70, 1)`), icons, Home/Profile/Logout links
- Drawer implementations are completely different between pages (not shared)

### Maps
- `GoogleMap` widget embedded in Lost/Found pages (200px height)
- Initial position: `LatLng(0.0, 0.0)` with zoom 10 (off the coast of Africa)
- Tap-to-select location with marker
- "Pick Location" button triggers GPS auto-detect via Geolocator

### Image Handling
- `ImagePicker.pickMultiImage()` for multi-selection
- Preview as 100x100 thumbnails in a `Wrap` widget
- Images uploaded to Firebase Storage on post submission

### Loading States
- `_isLoading` boolean with `CircularProgressIndicator` on SignIn/SignUp buttons
- `_isPosting` boolean with inline spinner on Lost/Found post buttons
- Buttons disabled during loading

### Feedback
- `SnackBar` messages for success/error on all form submissions
- `AlertDialog` for location fetch errors

## Assets

| Asset | Path | Usage |
|---|---|---|
| `LF_logo.png` | `assets/LF_logo.png` | Shown on SplashScreen, SignIn, SignUp, and HomePage |

## Fonts

No custom fonts defined in `pubspec.yaml`. The app references `fontFamily: 'Poppins'` in HomePage text styles, but Poppins is **not declared as an asset** — it will silently fall back to the default system font.

## Theme

- **Primary swatch:** `Colors.orange` (set in MaterialApp)
- No custom `ThemeData` beyond primary swatch
- Individual pages use hardcoded colors:
  - Lost button: `Color.fromARGB(255, 214, 128, 23)` (orange)
  - Found button: `Color(0xFF6CB523)` (green)
  - Profile drawer: `Color.fromRGBO(232, 99, 70, 1)` (red-orange)
  - Lost/Found drawer header: `Colors.blue`

## Permissions (iOS Info.plist)

| Permission | Description |
|---|---|
| `NSPhotoLibraryUsageDescription` | Photo library access for image picking |
| `NSLocationWhenInUseUsageDescription` | Location access for address tagging |
| `NSLocationAlwaysUsageDescription` | Background location (likely unnecessary) |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | Combined location permission |
| `NSMicrophoneUsageDescription` | Microphone access (declared but unused in code) |

## Permissions (Android Manifest)

| Permission | Notes |
|---|---|
| `android.permission.INTERNET` | Required for Firebase |
| `android.permission.WRITE_EXTERNAL_STORAGE` | Legacy storage access |
| `android.permission.READ_EXTERNAL_STORAGE` | Legacy storage access |

**Note:** No `ACCESS_FINE_LOCATION` or `ACCESS_COARSE_LOCATION` declared in AndroidManifest, but the `geolocator` plugin adds these automatically via its own manifest.
