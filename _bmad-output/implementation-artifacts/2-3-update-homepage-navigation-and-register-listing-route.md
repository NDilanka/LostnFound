# Story 2.3: Update HomePage Navigation and Register Listing Route

Status: ready-for-dev

## Story

As a **user**,
I want to access the item listing from the home screen,
so that browsing items is the primary app action.

## Acceptance Criteria

1. **Given** the user is on the HomePage
   **When** the HomePage is rendered
   **Then** "Browse Items" is the first button (primary, orange, full-width)
   **And** "Report Lost Item" and "Report Found Item" are secondary buttons below
   **And** tapping "Browse Items" navigates to `/items`
   **And** the `/items` route is registered in `MaterialApp.routes` in `main.dart`

## Tasks / Subtasks

- [ ] Task 1: Add "Browse Items" button as primary action in HomePage (AC: #1)
  - [ ] In `main.dart`, locate the `HomePage` widget's button Column
  - [ ] Add a new "Browse Items" `ElevatedButton` BEFORE the existing "Lost Items" button
  - [ ] Style it as primary: orange background, full-width, same style as existing buttons
  - [ ] `onPressed` navigates to `/items` via `Navigator.pushReplacementNamed`
- [ ] Task 2: Reorder existing buttons as secondary (AC: #1)
  - [ ] "Report Lost Item" (renamed from "Lost Items") becomes second button
  - [ ] "Report Found Item" (renamed from "Found Items") becomes third button
- [ ] Task 3: Verify `/items` route exists (AC: #1)
  - [ ] Confirm `/items` route is registered in `MaterialApp.routes` (done in Story 2.1)
  - [ ] If Story 2.1 is not yet implemented, add the route registration here
- [ ] Task 4: Verify (AC: #1)
  - [ ] Run `flutter analyze` — no errors
  - [ ] Test: HomePage shows "Browse Items" as first button
  - [ ] Test: tapping "Browse Items" navigates to `/items`
  - [ ] Test: "Report Lost Item" and "Report Found Item" still work

## Dev Notes

### Hard Dependency on Story 0.2

**Story 0.2 (Fix HomePage Nested MaterialApp) MUST be completed first.** The current `HomePage` returns a nested `MaterialApp` (`main.dart` line 49) which creates its own navigator. Any `Navigator.pushReplacementNamed(context, '/items')` call from inside this nested `MaterialApp` will fail because it doesn't know about the `/items` route registered in the root `MaterialApp`.

After Story 0.2 fixes this, `HomePage.build()` returns a `Scaffold` directly, and navigation works through the root `MaterialApp`'s route table.

**If Story 0.2 is NOT yet implemented, implement it first or combine the fix into this story:** Change `HomePage.build()` to return `Scaffold(...)` instead of `MaterialApp(home: Scaffold(...))`.

### Current HomePage Button Layout (main.dart lines 78-119)

**Important: All line numbers reference the ORIGINAL unmodified `main.dart`.** Story 0.2 (hard dependency) removes the `MaterialApp(home:` wrapper from HomePage, which shifts all subsequent line numbers. After Story 0.2 is applied, locate the buttons by searching for `ElevatedButton` within the `HomePage` class, not by line number.

```dart
// Current: Two buttons
ElevatedButton(
  onPressed: () {
    Navigator.pushReplacementNamed(context, '/lost');
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 214, 128, 23), // orange
    minimumSize: const Size(325, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
  ),
  child: const Text('Lost Items', ...),
),
const SizedBox(height: 20.0),
ElevatedButton(
  onPressed: () {
    Navigator.pushReplacementNamed(context, '/found');
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF6CB523), // green
    minimumSize: const Size(325, 50),
    ...
  ),
  child: const Text('Found Items', ...),
),
```

### Required Change — New Button Layout

Replace the two-button section (after the description text and `SizedBox(height: 30.0)`) with three buttons:

```dart
// 1. Browse Items — PRIMARY (orange, full-width)
ElevatedButton(
  onPressed: () {
    Navigator.pushReplacementNamed(context, '/items');
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 214, 128, 23),
    minimumSize: const Size(325, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
  ),
  child: const Text(
    'Browse Items',
    style: TextStyle(
      color: Colors.white,
      fontFamily: 'Poppins',
      fontSize: 18,
    ),
  ),
),
const SizedBox(height: 20.0),
// 2. Report Lost Item — secondary (orange)
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
    'Report Lost Item',
    style: TextStyle(
      color: Colors.white,
      fontFamily: 'Poppins',
      fontSize: 18,
    ),
  ),
),
const SizedBox(height: 20.0),
// 3. Report Found Item — secondary (green)
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
    'Report Found Item',
    style: TextStyle(
      color: Colors.white,
      fontFamily: 'Poppins',
      fontSize: 18,
    ),
  ),
),
```

### Button Label Changes

| Position | Old Label | New Label | Color | Route |
|---|---|---|---|---|
| 1st (NEW) | — | Browse Items | Orange | `/items` |
| 2nd | Lost Items | Report Lost Item | Orange | `/lost` |
| 3rd | Found Items | Report Found Item | Green | `/found` |

The label change from "Lost Items" → "Report Lost Item" and "Found Items" → "Report Found Item" adds clarity — "Browse Items" is for viewing, "Report" is for posting. This matches the architecture doc's description: "Browse Items as primary button, reorder existing buttons."

**Note on visual differentiation:** Both "Browse Items" and "Report Lost Item" use the same orange color and identical button styling — they are differentiated by label only. This is per the architecture spec. Do NOT attempt to make the primary button visually distinct (larger, different shade, etc.) — keep all three buttons at the same size and style.

### Route Registration

**AC clarification:** The AC states "the `/items` route is registered in `MaterialApp.routes`" — this route registration is handled by Story 2.1, not this story. This story's responsibility is to verify it exists and add the "Browse Items" button that navigates to it. If Story 2.1 has not been implemented, this story must also add the route.

The `/items` route should already be registered by Story 2.1 in the `MaterialApp.routes` map. Verify it exists:

```dart
'/items': (context) => const ItemListingPage(),
```

If Story 2.1 is not yet implemented:
- Add `import 'pages/item_listing_page.dart';` to imports
- Add `'/items': (context) => const ItemListingPage(),` to routes

### Critical Rules

- Keep the same button style (size, border radius, font) as existing buttons — maintain visual consistency
- Use `Navigator.pushReplacementNamed` (not `push`) — matches existing button behavior
- The `fontFamily: 'Poppins'` must be used on the new button text — matches existing buttons
- Do NOT change the logo, description text, or overall page layout — only modify the buttons section

### What NOT to Do

- DO NOT change the `Scaffold` structure, logo image, or description text
- DO NOT add drawer navigation to HomePage — it doesn't have one and doesn't need one per current design
- DO NOT change the color scheme or button styling — match existing exactly
- DO NOT modify any other file besides `main.dart`
- DO NOT remove the existing Lost/Found buttons — reorder and relabel them

### Files Modified

| File | Changes |
|---|---|
| `lib/main.dart` | Add "Browse Items" button to HomePage, reorder and relabel existing buttons |

**0 files created, 1 file modified.**

### Dependencies on Previous Stories

| Story | Dependency | Blocking? |
|---|---|---|
| 0.2 | **Fix HomePage nested MaterialApp** — must return `Scaffold` not `MaterialApp` for `/items` navigation to work | **YES — hard blocker** |
| 2.1 | `/items` route and `ItemListingPage` must exist for "Browse Items" button to navigate successfully | YES |

### Previous Story Intelligence

- Story 0.2 fixes the nested `MaterialApp` in `HomePage` — this story's navigation depends on that fix
- Story 2.1 creates `item_listing_page.dart` and registers the `/items` route
- The existing buttons use `pushReplacementNamed` and consistent styling (orange/green, 325x50, Poppins font, border radius 15)

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.3]
- [Source: _bmad-output/planning-artifacts/architecture.md#Frontend Architecture — HomePage Navigation Update]
- [Source: _bmad-output/planning-artifacts/prd.md#FR28 — Home navigation to lost/found + browse]
- [Source: lib/main.dart lines 78-119 — current HomePage button layout]
- [Source: lib/main.dart line 84 — orange color value]
- [Source: lib/main.dart line 105 — green color value]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
