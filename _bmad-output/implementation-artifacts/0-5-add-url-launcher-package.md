# Story 0.5: Add url_launcher Package

Status: ready-for-dev

## Story

As a **developer**,
I want `url_launcher` available as a dependency,
so that the contact poster feature (Epic 3, Story 3.2) can launch email clients.

## Acceptance Criteria

1. **Given** `pubspec.yaml` does not include `url_launcher`
   **When** `url_launcher: ^6.2.0` is added to dependencies
   **Then** `flutter pub get` succeeds without errors
   **And** `flutter analyze` passes with no new errors

## Tasks / Subtasks

- [ ] Task 1: Add url_launcher to pubspec.yaml (AC: #1)
  - [ ] Open `lost_and_found/pubspec.yaml`
  - [ ] Add `url_launcher: ^6.2.0` to the `dependencies:` section (line 40, after `google_maps_flutter: ^2.6.0`)
- [ ] Task 2: Add Android query intents for mailto scheme (AC: #1)
  - [ ] Open `android/app/src/main/AndroidManifest.xml`
  - [ ] Inside the existing `<queries>` block, insert the new `<intent>` between line 49 (closing `</intent>` of PROCESS_TEXT) and line 50 (closing `</queries>`)
- [ ] Task 3: Add mailto to iOS LSApplicationQueriesSchemes (AC: #1)
  - [ ] Open `ios/Runner/Info.plist`
  - [ ] On line 45, the existing `LSApplicationQueriesSchemes` is compressed onto one line: `<key>LSApplicationQueriesSchemes</key> <array> <string>sms</string> <string>tel</string> </array>`
  - [ ] Add `<string>mailto</string>` inside the `<array>`, after `<string>tel</string>`
  - [ ] Result: `<key>LSApplicationQueriesSchemes</key> <array> <string>sms</string> <string>tel</string> <string>mailto</string> </array>`
- [ ] Task 4: Run flutter pub get (AC: #1)
  - [ ] Run `flutter pub get` from `lost_and_found/` directory
  - [ ] Verify it completes without errors
- [ ] Task 5: Verify (AC: #1)
  - [ ] Run `flutter analyze` — no new errors
  - [ ] Verify `url_launcher` appears in `pubspec.lock`

## Dev Notes

### pubspec.yaml Change

Add on a new line immediately after line 40 (`google_maps_flutter: ^2.6.0`), before the blank line at line 41:
```yaml
  url_launcher: ^6.2.0
```

The dependencies section should look like:
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.29.0
  cloud_firestore: ^4.16.1
  firebase_auth: ^4.19.1
  firebase_storage: ^11.7.1
  cupertino_icons: ^1.0.6
  image_picker: ^1.0.7
  geolocator: ^11.0.0
  google_maps_flutter: ^2.6.0
  url_launcher: ^6.2.0
```

### AndroidManifest.xml Change — CRITICAL for Android 11+

Android 11 (API 30+) enforces package visibility restrictions. Without declaring query intents, `launchUrl(Uri.parse('mailto:...'))` will silently fail — it won't open the email app and `canLaunchUrl()` will return false.

The existing `<queries>` block at lines 45-50 currently only has the `PROCESS_TEXT` intent. Add the `mailto:` intent inside the same `<queries>` block:

```xml
<queries>
    <intent>
        <action android:name="android.intent.action.PROCESS_TEXT"/>
        <data android:mimeType="text/plain"/>
    </intent>
    <!-- Required for url_launcher mailto: support (Epic 3 contact poster) -->
    <intent>
        <action android:name="android.intent.action.SENDTO"/>
        <data android:scheme="mailto"/>
    </intent>
</queries>
```

**Why `SENDTO` not `VIEW`:** The `mailto:` scheme uses `ACTION_SENDTO` to compose an email. `ACTION_VIEW` with `mailto:` is also common but `SENDTO` is the canonical intent for email composition.

### Web Support

No additional configuration needed for Chrome/web — `url_launcher` handles web URLs natively via `window.open()`. The `mailto:` scheme works out of the box on web browsers.

### iOS Info.plist Change — REQUIRED for canLaunchUrl

The project's `ios/Runner/Info.plist` already declares `LSApplicationQueriesSchemes` on line 45 (compressed single-line format):
```xml
<key>LSApplicationQueriesSchemes</key> <array> <string>sms</string> <string>tel</string> </array>
```

Add `mailto` to the existing array. The line should become:
```xml
<key>LSApplicationQueriesSchemes</key> <array> <string>sms</string> <string>tel</string> <string>mailto</string> </array>
```

**Why this is needed:** Since iOS 9, `canLaunchUrl()` requires schemes to be declared in `LSApplicationQueriesSchemes`. Without `mailto` in this list, `canLaunchUrl(Uri.parse('mailto:...'))` returns `false` — even though `launchUrl` itself may still work. The architecture shows fallback logic using `canLaunchUrl`, so this must be declared.

**Warning:** Do NOT create a new `LSApplicationQueriesSchemes` key — one already exists on line 45. Add `<string>mailto</string>` inside the existing `<array>` on that same line. The formatting is compressed (all on one line) — maintain that style.

### Version Choice

Architecture doc specifies `^6.2.0`. This is compatible with:
- Dart SDK >=3.3.0 (project constraint)
- Flutter 3.41.5 (current version)

The `^` allows minor/patch upgrades. `flutter pub get` will resolve to the latest compatible version within the 6.x range.

### Critical Rules

- Use exactly `^6.2.0` as specified in the architecture document — do NOT use a different version
- Add inside the existing `<queries>` block — do NOT create a duplicate `<queries>` block
- Do NOT add `import 'package:url_launcher/url_launcher.dart'` to any Dart file yet — that happens in Story 3.2
- Do NOT write any Dart code that uses url_launcher — this story is dependency-only

### What NOT to Do

- DO NOT modify any `.dart` files — this is a dependency + config change only
- DO NOT add `https` scheme queries — not needed for the contact poster feature (only `mailto:`). Note: if a future story needs to launch `https` URLs, the Android `<queries>` block will need an additional `ACTION_VIEW` intent for `https` scheme
- DO NOT change any existing dependencies or their versions
- DO NOT run `flutter pub upgrade` — use `flutter pub get` only to preserve existing locked versions
- DO NOT create a duplicate `<queries>` element in AndroidManifest.xml
- DO NOT create a duplicate `LSApplicationQueriesSchemes` key in Info.plist — one already exists on line 45

### Files Modified

| File | Change |
|---|---|
| `pubspec.yaml` | Add `url_launcher: ^6.2.0` to dependencies |
| `android/app/src/main/AndroidManifest.xml` | Add `mailto` SENDTO intent query inside existing `<queries>` block |
| `ios/Runner/Info.plist` | Add `<string>mailto</string>` to existing `LSApplicationQueriesSchemes` array on line 45 |

**0 files created, 3 files modified.**

### Project Structure Notes

- This satisfies AR5 from the architecture document: "Add url_launcher ^6.2.0 to pubspec.yaml for contact poster feature"
- The package is consumed later in Epic 3 Story 3.2 (Contact Poster) which uses `launchUrl(Uri.parse('mailto:${item.posterEmail}?subject=Lost and Found: ${item.itemName}'))`
- `pubspec.lock` will be auto-updated by `flutter pub get` — commit it to version control

### Previous Story Intelligence (Story 0-4)

- Story 0-4 was a single-file change to `profile_page.dart` (sign-out fix) — no overlap with this story
- Pattern: minimal, focused changes — this story follows the same principle

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 0.5]
- [Source: _bmad-output/planning-artifacts/architecture.md#Package Additions — url_launcher ^6.2.0]
- [Source: _bmad-output/planning-artifacts/architecture.md#Frontend Architecture — Contact Poster code example]
- [Source: _bmad-output/planning-artifacts/prd.md#FR26-27 — Contact poster via email]
- [Source: lost_and_found/pubspec.yaml — current dependencies (no url_launcher)]
- [Source: android/app/src/main/AndroidManifest.xml lines 45-50 — existing queries block]
- [Source: ios/Runner/Info.plist line 45 — existing LSApplicationQueriesSchemes with sms, tel]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
