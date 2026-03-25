# Story 0.3: Add Controller Disposal to Existing Pages

Status: ready-for-dev

## Story

As a **user**,
I want the app to not leak memory during navigation,
so that the app remains responsive during the demo.

## Acceptance Criteria

1. **Given** `SignInPage`, `SignUpPage`, `LostPage`, and `FoundPage` have `TextEditingController` instances without `dispose()`
   **When** a `dispose()` override is added to each page's `State` class
   **Then** all `TextEditingController` instances are disposed in the override
   **And** `super.dispose()` is called last in every `dispose()` method
   **And** `flutter analyze` shows no new warnings related to these files

## Tasks / Subtasks

- [ ] Task 1: Add dispose() to SignInPage (AC: #1)
  - [ ] Add `@override void dispose()` to `_SignInPageState`
  - [ ] Dispose `_usernameController` and `_passwordController`
  - [ ] Call `super.dispose()` last
- [ ] Task 2: Add dispose() to SignUpPage (AC: #1)
  - [ ] Add `@override void dispose()` to `_SignUpPageState`
  - [ ] Dispose `_firstNameController`, `_lastNameController`, `_usernameController`, `_passwordController`, `_confirmPasswordController`
  - [ ] Call `super.dispose()` last
- [ ] Task 3: Add dispose() to LostPage (AC: #1)
  - [ ] Add `@override void dispose()` to `_LostPageState`
  - [ ] Dispose `_itemNameController` and `_descriptionController`
  - [ ] Dispose `_mapController` (GoogleMapController) with null check
  - [ ] Call `super.dispose()` last
- [ ] Task 4: Add dispose() to FoundPage (AC: #1)
  - [ ] Add `@override void dispose()` to `_FoundPageState`
  - [ ] Dispose `_itemNameController` and `_descriptionController`
  - [ ] Dispose `_mapController` (GoogleMapController) with null check
  - [ ] Call `super.dispose()` last
- [ ] Task 5: Verify (AC: #1)
  - [ ] Run `flutter analyze` — no new warnings
  - [ ] Navigate between all pages in Chrome — no crashes

## Dev Notes

### Exact Controllers Per File

**signinpage.dart** — `_SignInPageState` (2 controllers):
```dart
// Line 13-14:
final TextEditingController _usernameController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
```

Add after the existing methods, before the closing `}` of the State class:
```dart
@override
void dispose() {
  _usernameController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

---

**signuppage.dart** — `_SignUpPageState` (5 controllers):
```dart
// Lines 15-20:
final TextEditingController _firstNameController = TextEditingController();
final TextEditingController _lastNameController = TextEditingController();
final TextEditingController _usernameController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final TextEditingController _confirmPasswordController = TextEditingController();
```

Add:
```dart
@override
void dispose() {
  _firstNameController.dispose();
  _lastNameController.dispose();
  _usernameController.dispose();
  _passwordController.dispose();
  _confirmPasswordController.dispose();
  super.dispose();
}
```

---

**lost_items.dart** — `_LostPageState` (2 controllers + 1 map controller):
```dart
// Lines 19-22:
final TextEditingController _itemNameController = TextEditingController();
final TextEditingController _descriptionController = TextEditingController();
LatLng? _pickedLocation;
GoogleMapController? _mapController;
```

Add:
```dart
@override
void dispose() {
  _itemNameController.dispose();
  _descriptionController.dispose();
  _mapController?.dispose();
  super.dispose();
}
```

---

**found_page.dart** — `_FoundPageState` (2 controllers + 1 map controller):
```dart
// Lines 19-22: (identical structure to lost_items.dart)
final TextEditingController _itemNameController = TextEditingController();
final TextEditingController _descriptionController = TextEditingController();
LatLng? _pickedLocation;
GoogleMapController? _mapController;
```

Add:
```dart
@override
void dispose() {
  _itemNameController.dispose();
  _descriptionController.dispose();
  _mapController?.dispose();
  super.dispose();
}
```

### Critical Rules

- `super.dispose()` MUST be the LAST call in every `dispose()` method — calling it first is a bug
- `_mapController?.dispose()` uses null-safe operator because `_mapController` is nullable (`GoogleMapController?`)
- Do NOT dispose `_auth` or `_firestore` instances — these are singleton references, not owned resources
- Do NOT add `dispose()` to `ProfilePage` — it ALREADY has a correct `dispose()` implementation (lines 34-39)

### What NOT to Do

- DO NOT modify any logic, UI, or navigation in these files — only add `dispose()` methods
- DO NOT change `_isPasswordVisible`, `_isLoading`, `_isPosting`, or any other state variables
- DO NOT touch `ProfilePage` (`profile_page.dart`) — it already disposes correctly
- DO NOT touch `SplashScreen` (`splashscreen.dart`) — no controllers to dispose
- DO NOT add `initState()` overrides — they're not needed for this story

### Reference: Correct dispose() from ProfilePage

`profile_page.dart` (lines 34-39) already has the correct pattern:
```dart
@override
void dispose() {
  _emailController.dispose();
  _firstNameController.dispose();
  _phoneNumberController.dispose();
  _lastNameController.dispose();
  super.dispose();
}
```

### Files Modified

| File | State Class | Controllers to Dispose |
|---|---|---|
| `lib/pages/signinpage.dart` | `_SignInPageState` | `_usernameController`, `_passwordController` |
| `lib/pages/signuppage.dart` | `_SignUpPageState` | `_firstNameController`, `_lastNameController`, `_usernameController`, `_passwordController`, `_confirmPasswordController` |
| `lib/pages/lost_items.dart` | `_LostPageState` | `_itemNameController`, `_descriptionController`, `_mapController` |
| `lib/pages/found_page.dart` | `_FoundPageState` | `_itemNameController`, `_descriptionController`, `_mapController` |

### Project Structure Notes

- 4 files modified, 0 files created
- No new imports needed
- No dependency changes
- Place `dispose()` override after all other methods but before the closing `}` of the State class

### References

- [Source: _bmad-output/planning-artifacts/architecture.md#Epic 0 Foundation Fixes - Story 0.3]
- [Source: _bmad-output/project-context.md#Memory Management — CRITICAL]
- [Source: _bmad-output/project-context.md#Anti-Patterns - "Missing dispose()"]
- [Source: _bmad-output/planning-artifacts/epics.md#Story 0.3]
- [Source: lib/pages/profile_page.dart lines 34-39 — reference correct dispose() pattern]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
