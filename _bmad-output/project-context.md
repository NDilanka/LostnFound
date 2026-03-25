---
project_name: 'group147'
user_name: 'Navee'
date: '2026-03-23'
sections_completed: ['technology_stack', 'language_rules', 'framework_rules', 'testing_rules', 'code_quality', 'workflow_rules', 'critical_rules']
status: 'complete'
rule_count: 87
existing_patterns_found: 35
optimized_for_llm: true
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

_Project: Lost and Found Campus Mobile Application (University of Plymouth, PUSL2023, Group 147)_

---

## Technology Stack & Versions

### Core Framework
- Flutter SDK >=3.3.0 <4.0.0 (Dart)
- State management: `setState()` only — no Provider, BLoC, or Riverpod

### Firebase (Project: lostfoundapp-1e774)
- firebase_core: any (locked to specific version in pubspec.lock)
- firebase_auth: any (email/password auth only)
- cloud_firestore: 4.16.1 (collections: users, lost_items, found_items)
- firebase_storage: any (image uploads)
- ⚠️ `Firebase.initializeApp()` called WITHOUT `DefaultFirebaseOptions.currentPlatform` — `firebase_options.dart` exists but is NOT wired in
- ⚠️ Firebase security rules are undocumented — assume default open rules
- ⚠️ No Firebase emulator config — no local testing infrastructure

### Key Dependencies
- google_maps_flutter: ^2.6.0 (⚠️ API key NOT configured in Android manifest — maps will be blank)
- geolocator: ^11.0.0 (requires Android API 21+)
- image_picker: ^1.0.7 (uses dart:io File — mobile-only, web-incompatible)
- permission_handler: ^11.3.1
- cupertino_icons: ^1.0.6

### Dead Dependencies (declared but unused — should be removed)
- flutter_map: ^6.1.0
- latlong2: ^0.9.1

### Platform Configuration
- Android: `com.example.lost_and_found`, multidex via legacy `com.android.support` (NOT AndroidX)
- iOS: `com.example.lostAndFound`, CocoaPods configured
- Firebase configured for: Android, iOS, macOS, Web
- Firebase NOT configured for: Windows, Linux
- ⚠️ `any` version specifiers for Firebase packages — NEVER run `flutter pub upgrade` without checking compatibility

### Testing Infrastructure
- Only `flutter_test` available (SDK default)
- No mock packages (no mockito, fake_cloud_firestore, firebase_auth_mocks)
- Existing widget_test.dart tests a counter app — WILL FAIL (not updated for this app)
- Effectively zero working tests

## Critical Implementation Rules

### Dart/Flutter Language Rules

#### Naming Conventions
- File names: `snake_case.dart` — ⚠️ existing violations (`signinpage.dart`, `signuppage.dart`, `splashscreen.dart`) — do NOT rename, but all NEW files must use snake_case
- Classes: `PascalCase`, private members: `_underscorePrefix`, variables/methods: `camelCase`
- Firestore fields: camelCase EXCEPT `phone_number` (legacy — maintain for backward compatibility)

#### Target Directory Structure (for new code)
```
lib/
  widgets/     ← shared reusable widgets (NEW — extract buildPasswordFormField here)
  utils/       ← shared helpers (NEW)
  services/    ← Firebase service classes (NEW)
  models/      ← data model classes (NEW)
  pages/       ← existing page widgets
```

#### Widget Construction Rules
- ALL widget constructors must be `const`: `const MyWidget({super.key})`
- Use `TextFormField` for ALL inputs (NOT `TextField`) — enables future Form validation
- NEVER create a nested `MaterialApp` — HomePage currently does this (line 78) and it's a bug
- Shared widget builders must go in `lib/widgets/`, not duplicated across pages

#### Import Conventions
- Package imports for cross-directory: `import 'package:lost_and_found/pages/...';`
- Relative imports within same directory: `import 'signinpage.dart';`
- Do NOT "fix" existing mixed imports in main.dart

#### Null Safety Rules (Dart 3.3+ sound null safety)
- Always use null-aware operators reading Firestore data: `userData['field'] ?? ''`
- Use `late` when initializing in `initState()`, use direct `final` initialization otherwise

#### Async/Await Rules
- Return type: `Future<void>` for async methods (NOT `void`)
- ALWAYS check `if (!mounted) return;` before using `BuildContext` after any `await`
- ALWAYS check `if (mounted)` before `setState()` in async callbacks
- Cancel Timers in `dispose()`

#### Error Handling Pattern
```dart
try {
  // Firebase operation
} on FirebaseAuthException catch (e) {
  // Specific error → SnackBar
} catch (e) {
  // General error → SnackBar
} finally {
  if (mounted) setState(() { _isLoading = false; });
}
```

#### Memory Management — CRITICAL
- ALL TextEditingControllers MUST be disposed
- `super.dispose()` must be LAST in dispose():
```dart
@override
void dispose() {
  _controller1.dispose();
  _controller2.dispose();
  super.dispose(); // ALWAYS last
}
```
- ⚠️ Only ProfilePage does this correctly — 4 other pages leak controllers

### Flutter Framework Rules

#### Navigation
- Named routes ONLY — defined in `MaterialApp.routes` in main.dart
- Use `Navigator.pushReplacementNamed(context, '/route')` for screen transitions
- Do NOT use `MaterialPageRoute` for pages that have named routes (SplashScreen does this — it's wrong)
- Available routes: `/splash`, `/signin`, `/signup`, `/home`, `/lost`, `/found`, `/profile`
- New pages MUST be added to the routes map in main.dart

#### Scaffold + Drawer Pattern
- Lost/Found pages: AppBar + blue Drawer with Home/Profile links
- ProfilePage: AppBar with save icon + orange-red styled Drawer with Home/Profile/Logout
- When adding new pages, include a Drawer with at minimum Home and Profile navigation

#### Theme & Styling
- Primary swatch: `Colors.orange`
- Colors are hardcoded per-widget (no theme constants file)
- Key colors: orange `Color.fromARGB(255, 214, 128, 23)`, green `Color(0xFF6CB523)`, drawer red `Color.fromRGBO(232, 99, 70, 1)`
- Standard padding: `EdgeInsets.all(16.0)`
- Standard spacing: `SizedBox(height: 16.0)` between form fields
- Button style: `ElevatedButton.styleFrom()` with `RoundedRectangleBorder(borderRadius: 10-15)`

#### Loading State Pattern
```dart
bool _isLoading = false;

// In async method:
setState(() { _isLoading = true; });
try { /* operation */ } finally {
  if (mounted) setState(() { _isLoading = false; });
}

// In button:
ElevatedButton(
  onPressed: _isLoading ? null : _doAction,
  child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Label'),
)
```

### Firebase Usage Rules

#### Firestore Access Pattern
- Direct `FirebaseFirestore.instance` calls in widget State classes (no service layer)
- Collection references: `firestore.collection('collection_name')`
- User docs keyed by Firebase Auth UID: `collection('users').doc(uid)`
- Item docs use auto-generated IDs: `collection('lost_items').add({...})`
- Location stored as `GeoPoint(lat, lng)` — nullable
- Image URLs stored as `List<String>` in document

#### Storage Upload Pattern
```dart
String fileName = DateTime.now().millisecondsSinceEpoch.toString();
Reference ref = FirebaseStorage.instance
    .ref().child('folder_name').child('$fileName.jpg');
UploadTask uploadTask = ref.putFile(file);
TaskSnapshot snapshot = await uploadTask;
String downloadUrl = await snapshot.ref.getDownloadURL();
```
- ⚠️ Timestamp-based naming can collide — consider adding userId or UUID

#### Auth Pattern
- `FirebaseAuth.instance` for auth operations
- `FirebaseAuth.instance.currentUser` for current user check
- ⚠️ No auth state listener — no `onAuthStateChanged` stream
- ⚠️ No sign-out implementation — Logout button navigates without calling `signOut()`
- ⚠️ No route guards — unauthenticated users can access any route via deep link

### Testing Rules

#### Current State
- Zero working tests — `widget_test.dart` tests a non-existent counter app and WILL CRASH (imports Firebase)
- ⚠️ DELETE or completely rewrite `test/widget_test.dart` before running `flutter test`
- No test infrastructure for Firebase (no mocks, no emulator config)

#### Pre-Test Checklist
1. Run `flutter analyze` FIRST — fix warnings only in files you modified
2. Add Firebase mock packages to `dev_dependencies` before writing Firebase-dependent tests:
   - `fake_cloud_firestore: ^2.4.0`
   - `firebase_auth_mocks: ^0.13.0`
3. Set up Firebase mock in `setUpAll()` for any test that touches Firebase

#### Test Patterns
- Place tests in `test/` mirroring `lib/` structure: `test/pages/signin_page_test.dart`
- ALWAYS wrap widgets in `MaterialApp(home: WidgetUnderTest())` — all widgets assume MaterialApp ancestor
- Do NOT unit test pages containing `GoogleMap` directly — extract and test logic separately
- Use `group()` for organizing, `setUp()`/`tearDown()` for lifecycle
- No model classes exist — everything is raw `Map<String, dynamic>`. If creating models for tests, use them in production code too

#### Test Priority (for this coursework project)
1. Auth flow tests (sign in, sign up) — highest value
2. Form validation tests (when validation is added)
3. Data posting tests (Firestore operations with mocks)
4. Widget rendering smoke tests (pages render without crash)
5. Navigation tests

#### Test Expectations
- Don't aim for high coverage — this is university coursework
- Each new feature/story defines its own test requirements
- Smoke tests (app launches, pages render) add the most value with least effort
- NEVER suppress analyzer warnings without good reason

### Code Quality & Style Rules

#### Linting
- Uses `package:flutter_lints/flutter.yaml` (configured in `analysis_options.yaml`)
- Run `flutter analyze` — fix warnings in files you touch, leave others alone
- Use `const SizedBox.shrink()` for empty placeholders, NOT `Container()`

#### Code Organization
- One widget class per file (except main.dart which has both MyApp and HomePage)
- Pages in `lib/pages/`, new shared code in `lib/widgets/`, `lib/utils/`, `lib/services/`, `lib/models/`
- Keep `firebase_options.dart` untouched — auto-generated by FlutterFire CLI

#### Massive Code Duplication — CRITICAL
- `lost_items.dart` and `found_page.dart` are ~95% identical (312 lines each)
  - Differ ONLY in: collection name, storage path, AppBar title
  - **If you modify one, you MUST apply the same change to the other**
  - Correct refactoring target: shared `ItemFormPage` with parameters for title, collectionName, storagePath
- `buildPasswordFormField()` duplicated in signinpage.dart and signuppage.dart — extract to `lib/widgets/`
- Drawer navigation duplicated across 3 pages — extract shared drawer builder to `lib/widgets/`

#### Reusable Helpers to Extract
- SnackBar helper → `lib/utils/`:
```dart
void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: Duration(seconds: 2)),
  );
}
```

#### Styling Rules for New Code
- Match existing page style when modifying — don't unify colors unless asked
- New pages: use blue drawer pattern (Lost/Found style), orange for primary buttons, green for secondary
- ⚠️ `fontFamily: 'Poppins'` referenced in HomePage but NOT installed — do NOT use Poppins in new code
- Use local `static const` within widget class for repeated values — no global constants file needed

#### Comments & Documentation
- Codebase has zero dartdoc comments — do NOT add comments to existing code
- Add brief comments to new public methods only if name isn't self-explanatory
- Do NOT add comments that restate the code

#### Debug Prints
- Codebase has `print()` statements for debugging — do NOT add new ones
- Remove any debug prints you add after confirming the feature works

#### Form State
- After successful submission, clear all controllers, reset images list, reset location state

### Development Workflow Rules

#### Environment
- Development platform: Windows 11 (win32)
- iOS builds NOT possible — no macOS/Xcode available
- Target platforms for development: Android emulator and Chrome (web)
- Hot reload for UI changes, hot restart needed after initialization code changes

#### Build & Run
- `cd lost_and_found && flutter pub get` before first run
- `flutter run -d chrome` for web, `flutter run -d android` for Android emulator
- `flutter build apk` for Android release
- `flutter analyze` before committing — fix only warnings in files you changed
- If `flutter pub get` fails on Windows, check Flutter SDK installation and PATH

#### Git (NOT YET INITIALIZED — must set up)
- ⚠️ Repository has NO git initialization — set up git before development
- Branch strategy (simple for 7-person coursework team):
  - `main` = working code
  - Feature branches: `feature/item-listing`, `feature/search`, `fix/logout-signout`
  - No PR reviews required — merge when working
- Commit messages must be descriptive (shown in final report): `Add item listing page with Firestore query` — NOT `wip` or `fix`
- Format: `Verb + what changed` (Add, Fix, Update, Implement, Remove)
- Ensure `.gitignore` covers: `build/`, `.dart_tool/`, `ios/Pods/`

#### Project Structure
- All source code in `lost_and_found/` subdirectory (NOT repo root)
- BMAD artifacts in `_bmad-output/`, project docs in `docs/`
- Assets declared in `pubspec.yaml` under `assets:` — new assets must be added there

#### Implementation Priority (proposal requirements — affects grade)
1. Item listing/browsing page — app is useless without this
2. Search functionality — proposal requires keyword search
3. Item details page — full item information view
4. Contact the poster — communication between users
5. User-item association — add `userId` and `createdAt` to item documents
6. Sign-out implementation — currently broken
7. View posted items in profile page

#### Academic Constraints
- University of Plymouth coursework (PUSL2023, Group 147, 7 members)
- Final report: max 3,000 words, PDF named `Group_147_Final_Report.pdf`
- Must include GitHub commit history and Plymouth OneDrive source code link
- Report style: past tense, third-person, passive voice

#### No CI/CD
- No automated builds, no deployment pipeline
- Manual builds only

### Critical Don't-Miss Rules

#### Academic Requirements — GRADE IMPACT
- App MUST have at least 5 pages (login/logout/welcome DON'T count) — currently only 4 qualifying pages (Home, Lost, Found, Profile)
- GitHub individual commits are graded (10% of C1) — each team member needs visible, meaningful commits
- Presentation (20% of module) requires live demo recording on device/emulator — app must actually RUN
- For 1st class: "Fully functional, polished app with excellent UI/UX, innovative use of device features, and robust database integration"
- For 2.1: "Well-functioning app with good UI/UX, proper use of device features and database integration"
- Assessment: 80% Coursework (App Product 60% + Report 30% + Individual Contribution 10%) / 20% Presentation

#### Anti-Patterns to Avoid
- NEVER create a second `MaterialApp` widget — HomePage already does this (bug). One `MaterialApp` at root only
- NEVER use `dart:io` `File` class if targeting web — current image upload is mobile-only
- NEVER call `setState()` after `await` without `if (mounted)` check
- NEVER use `BuildContext` after `await` without `if (!mounted) return;`
- NEVER store Firebase API keys in new locations — already in `firebase_options.dart` and `google-services.json`
- NEVER run `flutter pub upgrade` — use `flutter pub get` only. `any` version specs + upgrade = breakage

#### Security Gotchas
- Lost/found items have NO `userId` field — anyone can post anonymously, no edit/delete possible
- No Firestore security rules — assume wide open
- Logout doesn't call `FirebaseAuth.signOut()` — session persists
- No auth route guards — all routes accessible without authentication
- Firebase client API keys in source is normal — don't add OTHER secrets

#### Edge Cases Agents Must Handle
- Google Maps initial position is `LatLng(0.0, 0.0)` (off coast of Africa) — update to campus location
- Image upload timestamp naming can collide — consider adding userId or UUID
- `phone_number` field may not exist in user doc — ProfilePage will throw
- Posting with no images = empty `imageUrls: []` — handle downstream
- Posting with no location = `location: null` — handle null GeoPoints
- `pickMultiImage()` may return null — maintain `?? []` pattern

#### Performance Gotchas
- Images uploaded sequentially — consider `Future.wait()` for parallel uploads
- No image compression — full resolution camera photos uploaded
- No Firestore pagination — MUST add `.limit()` when building item listing
- GoogleMapController not disposed — memory leak

---

## Usage Guidelines

**For AI Agents:**
- Read this file before implementing any code in this project
- Follow ALL rules exactly as documented
- When in doubt, prefer the more restrictive option
- Check the Implementation Priority list before starting new features
- Respect the existing code patterns even when imperfect — consistency over correctness for unchanged files

**For Humans:**
- Keep this file lean and focused on agent needs
- Update when technology stack or patterns change
- Remove rules that become obvious over time
- Add new rules when agents make recurring mistakes

Last Updated: 2026-03-23
