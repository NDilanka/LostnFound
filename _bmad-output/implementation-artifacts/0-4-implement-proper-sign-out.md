# Story 0.4: Implement Proper Sign-Out

Status: review

## Story

As a **user**,
I want to properly log out of the app,
so that my session is terminated and another user can sign in.

## Acceptance Criteria

1. **Given** the user is logged in and on the ProfilePage
   **When** the user taps "Logout" in the drawer
   **Then** `FirebaseAuth.instance.signOut()` is called before navigation
   **And** the user is navigated to `/signin` via `pushReplacementNamed`
   **And** `FirebaseAuth.instance.currentUser` returns null after sign-out

## Tasks / Subtasks

- [x] Task 1: Add async sign-out logic to Logout drawer item (AC: #1)
  - [x] In `profile_page.dart`, locate the Logout `InkWell.onTap` callback (line ~188-195)
  - [x] Make the `onTap` callback `async`
  - [x] Add `await FirebaseAuth.instance.signOut();` before navigation
  - [x] Replace `Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInPage()))` with `Navigator.pushReplacementNamed(context, '/signin')`
- [x] Task 2: Verify (AC: #1)
  - [x] Run `flutter analyze` — no new warnings or errors
  - [x] Test: sign in, navigate to profile, tap Logout, confirm redirected to sign-in page
  - [x] Test: after logout, `FirebaseAuth.instance.currentUser` should be null (verify by checking the sign-in page loads fresh, not auto-redirected)

## Dev Notes

### Current Bug Analysis

The Logout button in `profile_page.dart` (lines 188-195) currently does:
```dart
InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInPage(),
      ),
    );
  },
  // ... Logout icon + text
)
```

**Two bugs:**
1. `FirebaseAuth.instance.signOut()` is never called — the Firebase session persists after "logout", meaning `currentUser` is still non-null
2. Uses `Navigator.push` (adds to stack) instead of `Navigator.pushReplacementNamed` — user can press back to return to ProfilePage while supposedly "logged out"

### Required Change

Replace the `onTap` callback with:
```dart
onTap: () async {
  await FirebaseAuth.instance.signOut();
  if (mounted) {
    Navigator.pushReplacementNamed(context, '/signin');
  }
},
```

**Note:** Use `mounted` (from State class) rather than `context.mounted` — the existing codebase consistently uses `mounted` for post-async checks (see architecture pattern: `if (mounted) setState(...)`). Both work identically here since the closure captures the State's `this`, but `mounted` maintains codebase consistency.

### Critical Rules

- `await` the `signOut()` call — do NOT fire-and-forget
- Check `mounted` after the async `signOut()` before using `context` for navigation (Flutter best practice after async gaps; use `mounted` not `context.mounted` to match codebase convention)
- Use `pushReplacementNamed` not `push` — prevents back-navigation to authenticated pages
- Use the named route `'/signin'` (already registered in `main.dart` line 35) — do NOT use `MaterialPageRoute` with direct widget construction
- The `SignInPage` import on line 5 (`import 'package:lost_and_found/pages/signinpage.dart';`) can be removed after this change since we're using named routes instead of direct widget reference — but this is optional cleanup; the import doesn't cause issues if left

### What NOT to Do

- DO NOT add a sign-out button anywhere else — only fix the existing drawer Logout item
- DO NOT modify the drawer structure, styling, or other drawer items (note: Home drawer at line 118 and Profile drawer at line 152 also use `Navigator.push` with `MaterialPageRoute` instead of named routes — this is a known inconsistency but is OUT OF SCOPE for this story)
- DO NOT add error handling/try-catch around `signOut()` — Firebase signOut() does not throw for local session clearing; it always succeeds
- DO NOT modify `_fetchUserData()`, `_updateUserData()`, or any profile form logic
- DO NOT touch any other file — this is a single-file change

### Files Modified

| File | Change |
|---|---|
| `lib/pages/profile_page.dart` | Modify Logout `onTap`: add `signOut()`, use `pushReplacementNamed` |

**0 files created, 1 file modified.**

### Project Structure Notes

- `FirebaseAuth` is already imported on line 2 of `profile_page.dart` — no new imports needed
- Named route `/signin` is already registered in `main.dart` line 35
- This fix satisfies FR3 ("Users can sign out and have their session properly terminated") and AR4 from the architecture document

### Previous Story Intelligence (Story 0-3)

- Story 0-3 added `dispose()` to four pages but did NOT touch `profile_page.dart` (it already had correct `dispose()`)
- The same pattern of keeping changes minimal and not modifying unrelated logic applies here
- No git commits exist yet beyond the initial commit — this is greenfield work on a brownfield codebase

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 0.4]
- [Source: _bmad-output/planning-artifacts/architecture.md#Authentication & Security — signOut pattern]
- [Source: _bmad-output/planning-artifacts/architecture.md#Epic 0 Foundation Fixes — Story 0.3 row]
- [Source: _bmad-output/planning-artifacts/prd.md#FR3 — Users can sign out]
- [Source: lib/pages/profile_page.dart lines 188-195 — current broken logout]
- [Source: lib/main.dart line 35 — `/signin` route registration]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6 (1M context)

### Debug Log References

### Completion Notes List

- ✅ Task 1: Replaced Logout `InkWell.onTap` in `profile_page.dart`. Made callback `async`, added `await FirebaseAuth.instance.signOut()`, added `if (mounted)` guard, replaced `Navigator.push` with `Navigator.pushReplacementNamed(context, '/signin')`. Removed now-unused `signinpage.dart` import (eliminated new `unused_import` warning).
- ✅ Task 2: `flutter analyze` passes — 0 new warnings. Only 2 pre-existing `info` diagnostics (`library_private_types_in_public_api`, `use_build_context_synchronously`). Navigation verified via Playwright in prior session.

### Change Log

- 2026-03-27: Fixed Logout to call `FirebaseAuth.instance.signOut()` before navigation, use `pushReplacementNamed` instead of `push`, and check `mounted` after async gap. Removed unused `signinpage.dart` import.

### File List

- `lost_and_found/lib/pages/profile_page.dart` — fixed Logout onTap: added signOut(), pushReplacementNamed, mounted check; removed unused import
