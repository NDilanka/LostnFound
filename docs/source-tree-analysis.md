# Source Tree Analysis: Lost and Found

## Annotated Directory Tree

```
lost_and_found/                          # Flutter project root
├── lib/                                 # *** PRIMARY SOURCE CODE ***
│   ├── main.dart                        # ENTRY POINT - Firebase init, permissions, routes, MyApp + HomePage
│   ├── firebase_options.dart            # Generated - Platform-specific Firebase config (FlutterFire CLI)
│   └── pages/                           # All app screens
│       ├── splashscreen.dart            # Splash screen (2s delay → SignIn)
│       ├── signinpage.dart              # Email/password sign-in with FirebaseAuth
│       ├── signuppage.dart              # Registration with Auth + Firestore user creation
│       ├── lost_items.dart              # Report lost items (form + map + images → Firestore)
│       ├── found_page.dart              # Report found items (near-identical copy of lost_items.dart)
│       └── profile_page.dart            # User profile CRUD against Firestore 'users' collection
│
├── test/                                # Test directory
│   └── widget_test.dart                 # DEFAULT TEMPLATE - tests counter app (NOT this app, will fail)
│
├── assets/                              # Static assets
│   └── LF_logo.png                      # App logo used on splash, signin, signup, home screens
│
├── android/                             # Android platform (auto-generated + config)
│   ├── app/
│   │   ├── build.gradle                 # Android build config - namespace com.example.lost_and_found
│   │   ├── google-services.json         # Firebase Android config (project: lostfoundapp-1e774)
│   │   └── src/
│   │       ├── main/
│   │       │   ├── AndroidManifest.xml  # Permissions: INTERNET, READ/WRITE_EXTERNAL_STORAGE
│   │       │   └── kotlin/.../MainActivity.kt  # Default Flutter activity
│   │       ├── debug/AndroidManifest.xml
│   │       └── profile/AndroidManifest.xml
│   ├── build.gradle                     # Root Gradle config
│   ├── gradle.properties                # Gradle settings
│   └── settings.gradle                  # Gradle settings
│
├── ios/                                 # iOS platform
│   ├── Podfile                          # CocoaPods dependencies
│   ├── Pods/                            # Installed pods (Firebase, GoogleMaps, Geolocator, etc.)
│   ├── Runner/
│   │   ├── Info.plist                   # iOS permissions (Photo Library, Location, Microphone)
│   │   ├── Assets.xcassets/             # App icons and launch images
│   │   └── Base.lproj/                  # Storyboards (LaunchScreen, Main)
│   ├── Runner.xcodeproj/               # Xcode project
│   ├── Runner.xcworkspace/             # Xcode workspace (with Pods)
│   ├── firebase_app_id_file.json       # Firebase iOS app ID
│   └── RunnerTests/RunnerTests.swift   # iOS native test template
│
├── macos/                               # macOS platform
│   ├── Podfile                          # CocoaPods for macOS
│   ├── firebase_app_id_file.json       # Firebase macOS app ID
│   └── Runner/                          # macOS runner with entitlements
│
├── web/                                 # Web platform
│   ├── index.html                       # Web entry point with Flutter loader
│   ├── manifest.json                    # PWA manifest
│   └── icons/                           # Web app icons (192px, 512px, maskable)
│
├── linux/                               # Linux platform (auto-generated)
│   ├── CMakeLists.txt
│   ├── main.cc
│   └── my_application.cc/.h
│
├── windows/                             # Windows platform (auto-generated)
│   ├── CMakeLists.txt
│   └── runner/                          # Win32 window, utils, resources
│
├── pubspec.yaml                         # *** PROJECT MANIFEST *** - dependencies, assets, SDK constraints
├── pubspec.lock                         # Locked dependency versions
├── analysis_options.yaml                # Dart static analysis config (flutter_lints)
├── .metadata                            # Flutter project metadata
├── .flutter-plugins                     # Resolved plugin paths
├── .flutter-plugins-dependencies        # Plugin dependency graph
├── .gitignore                           # Git ignore rules
├── lost_and_found.iml                   # IntelliJ IDEA module file
├── .vscode/settings.json               # VS Code settings (Java only)
├── .dart_tool/                          # Dart/Flutter tooling cache
├── build/                               # Build output (iOS Debug builds present)
└── README.md                            # Default Flutter README (boilerplate)
```

## Critical Folders

| Folder | Purpose | Files |
|---|---|---|
| `lib/` | All application source code | 8 Dart files |
| `lib/pages/` | Screen/page widgets | 6 pages |
| `assets/` | Static assets (logo only) | 1 file |
| `android/app/` | Android build config + Firebase | build.gradle, google-services.json, AndroidManifest.xml |
| `ios/Runner/` | iOS config + permissions | Info.plist, Assets |

## Entry Points

| Entry Point | File | Description |
|---|---|---|
| Dart main() | `lib/main.dart:14` | Firebase init → permissions → runApp(MyApp()) |
| Android | `android/app/src/main/kotlin/.../MainActivity.kt` | Default FlutterActivity |
| iOS | `ios/Runner/` via Main.storyboard | Standard Flutter iOS runner |
| Web | `web/index.html` | Flutter web loader script |

## Build Artifacts Present

The `build/ios/` directory contains Debug-iphoneos build artifacts, indicating the app has been built and run on an iOS device/simulator at some point. No Android or web build artifacts are present.
