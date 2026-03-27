# Story 0.2: Fix HomePage Nested MaterialApp

Status: review

## Story

As a **user**,
I want the HomePage to work correctly within the app's navigation system,
so that I can navigate to all pages without routing errors.

## Acceptance Criteria

1. **Given** `main.dart` has `HomePage` class returning `MaterialApp` (line 49)
   **When** the developer changes `HomePage.build()` to return `Scaffold` instead of `MaterialApp`
   **Then** `Navigator.pushReplacementNamed` works correctly from within HomePage
   **And** the existing "Lost Items" and "Found Items" buttons still navigate to `/lost` and `/found`
   **And** the app has only ONE `MaterialApp` at the root level (`MyApp`)

## Tasks / Subtasks

- [x] Task 1: Remove nested MaterialApp from HomePage (AC: #1)
  - [x] In `lib/main.dart`, line 49: change `return MaterialApp(` to `return Scaffold(`
  - [x] Remove the `home:` wrapper — `Scaffold` becomes the direct return, not wrapped in `MaterialApp(home: Scaffold(...))`
  - [x] Keep the entire body content (Center > SingleChildScrollView > Column with logo, text, buttons) unchanged
  - [x] Verify both buttons (`/lost` and `/found` navigation) still work
- [x] Task 2: Verify navigation works (AC: #1)
  - [x] Run the app in Chrome: `/c/flutter/bin/flutter run -d chrome`
  - [x] Navigate from HomePage → Lost Items page (tap "Lost Items" button)
  - [x] Navigate from HomePage → Found Items page (tap "Found Items" button)
  - [x] Navigate back to HomePage from Lost/Found pages via drawer
  - [x] Verify no console errors about nested navigators or route not found

## Dev Notes

### The Bug

`HomePage.build()` at line 49 returns `MaterialApp(home: Scaffold(...))`. This creates a **second navigator stack** inside the app. The root `MyApp` already provides a `MaterialApp` with all routes registered (lines 25-41). The nested `MaterialApp` in `HomePage` creates its own navigator that does NOT have access to the routes defined in `MyApp`.

**Why this matters now:** When Story 2.3 adds a "Browse Items" button navigating to `/items`, and Story 3.1 adds `/details` navigation from the listing — these routes are registered in the root `MaterialApp`. If `HomePage` has its own `MaterialApp`, `Navigator.pushReplacementNamed(context, '/items')` from inside `HomePage` will fail with "route not found" because the inner navigator doesn't know about `/items`.

### Exact Code Change

**Current code (lines 48-127):**
```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(       // ← LINE 49: THIS IS THE BUG
    home: Scaffold(         // ← LINE 50: Scaffold wrapped inside MaterialApp
      body: Center(
        // ... rest of content
      ),
    ),
  );
}
```

**Fixed code:**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(           // ← Return Scaffold directly, no MaterialApp wrapper
    body: Center(
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/LF_logo.png',
                  width: 200.0,
                  height: 200.0,
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'You can Find or Post Lost and Found Items!',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/lost');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 214, 128, 23),
                    minimumSize: const Size(325, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text(
                    'Lost Items',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/found');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6CB523),
                    minimumSize: const Size(325, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text(
                    'Found Items',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
```

**Key changes:**
1. Line 49: `return MaterialApp(` → `return Scaffold(`
2. Line 50: Remove `home: Scaffold(` wrapper — `Scaffold` is now the top-level return
3. All body content stays exactly the same — just unwrap one nesting level
4. The closing brackets at the bottom lose one `)` (the MaterialApp closing paren)
5. Existing inline comments (`// Description text`, `// Replace text fields with buttons`) may be preserved or removed — they restate the obvious and add no value
6. Minor SizedBox formatting (multi-line vs single-line) may differ from the template above — `dart format` normalizes these automatically

### What NOT to Do

- DO NOT change `MyApp` class or route definitions — only change `HomePage`
- DO NOT add an `AppBar` to HomePage — it currently doesn't have one, and the design shows just the logo + buttons
- DO NOT change button styles, colors, or navigation routes
- DO NOT add a drawer to HomePage — that's for Story 2.3 which will restructure the buttons
- DO NOT change `HomePage` from `StatelessWidget` to `StatefulWidget` — no state needed yet
- DO NOT remove the `fontFamily: 'Poppins'` references — they exist in the original code (they silently fall back to system font since Poppins isn't installed)

### File Modified

| File | Change |
|---|---|
| `lib/main.dart` | Lines 49-127: Replace `MaterialApp(home: Scaffold(...))` with `Scaffold(...)` |

### Verification

After the change, the app should:
- Show the same visual appearance (logo, text, two buttons)
- Theme inherits from root `MaterialApp` (`Colors.orange` primary swatch) — the current nested `MaterialApp` has NO theme, so HomePage currently uses default blue. After fix, subtle color changes in focus/selection states may appear as orange theme takes effect. This is the CORRECT behavior.
- Both buttons navigate correctly via `Navigator.pushReplacementNamed`
- No console warnings about nested MaterialApp or navigator issues

### Project Structure Notes

- Only file modified: `lib/main.dart`
- `HomePage` class stays in `main.dart` (not moved to separate file for this story)
- No new files created, no new imports, no new dependencies

### References

- [Source: _bmad-output/planning-artifacts/architecture.md#Epic 0 Foundation Fixes - Story 0.2]
- [Source: _bmad-output/project-context.md#Widget Construction Rules - "NEVER create a nested MaterialApp"]
- [Source: _bmad-output/project-context.md#Anti-Patterns - "Nested MaterialApp: One MaterialApp at root only"]
- [Source: _bmad-output/planning-artifacts/epics.md#Story 0.2]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6 (1M context)

### Debug Log References

### Completion Notes List

- ✅ Task 1: Removed nested `MaterialApp` from `HomePage.build()` in `lib/main.dart`. Changed `return MaterialApp(home: Scaffold(...))` to `return Scaffold(...)`, removing one level of widget nesting and one extra closing bracket. `flutter analyze` passed with no issues.
- ✅ Task 2: Verified navigation in Chrome via Playwright MCP. HomePage renders correctly (logo + two buttons). Navigation to `/lost`, `/found`, and back to `/home` all work. No console errors about nested navigators or route-not-found. Only pre-existing Google Maps API key error (documented, unrelated).

### Change Log

- 2026-03-27: Removed nested MaterialApp from HomePage — replaced with direct Scaffold return. Single MaterialApp at root (MyApp) now correctly serves all routes.

### File List

- `lost_and_found/lib/main.dart` — removed nested MaterialApp from HomePage.build(), returning Scaffold directly
