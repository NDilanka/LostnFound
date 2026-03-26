# Story 3.1: Create Item Details Page

Status: ready-for-dev

## Story

As a **user**,
I want to see the full details of a posted item,
so that I can determine if it's the item I lost or found.

## Acceptance Criteria

1. **Given** the user taps an item in the listing page
   **When** the app navigates to `/details` with the `ItemModel` as argument
   **Then** the details page displays: all uploaded photos (scrollable), item name and description, type badge (orange "Lost" / green "Found"), tagged location on a Google Map (if location exists), posting date and time (full format), poster name (or "Unknown poster" if null)
   **And** the page has a 3-item drawer (Home, Browse Items, Profile)
   **And** the `/details` route is registered in `MaterialApp.routes`
   **And** the item data is extracted via `ModalRoute.of(context)!.settings.arguments as ItemModel`

## Tasks / Subtasks

- [ ] Task 1: Create `lib/pages/item_details_page.dart` (AC: #1)
  - [ ] Create new file with `ItemDetailsPage` StatefulWidget
  - [ ] Import `cloud_firestore` (for Timestamp, GeoPoint), `flutter/material`, `google_maps_flutter`, and `models/item_model.dart`
  - [ ] Extract `ItemModel` from route arguments in `didChangeDependencies()` or `build()`
  - [ ] Build scrollable page with: photo carousel, item name + type badge, description, map (conditional), date/time, poster name
  - [ ] Add 3-item drawer (Home, Browse Items, Profile)
- [ ] Task 2: Register `/details` route in `main.dart` (AC: #1)
  - [ ] Add `import 'pages/item_details_page.dart';` to `main.dart`
  - [ ] Add `'/details': (context) => const ItemDetailsPage(),` to routes map
- [ ] Task 3: Verify (AC: #1)
  - [ ] Run `flutter analyze` — no errors
  - [ ] Test: tap an item in listing → details page shows all fields
  - [ ] Test: item with no location → map section hidden
  - [ ] Test: item with no posterName → shows "Unknown poster"
  - [ ] Test: item with no createdAt → shows "Date unknown"

## Dev Notes

### Complete Page Structure

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lost_and_found/models/item_model.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({super.key});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  ItemModel? _item;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _item ??= ModalRoute.of(context)!.settings.arguments as ItemModel;
  }

  @override
  Widget build(BuildContext context) {
    if (_item == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final item = _item!;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.itemName, overflow: TextOverflow.ellipsis, maxLines: 1),
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos
            if (item.imageUrls.isNotEmpty) _buildPhotoSection(item),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name + type badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.type == 'lost'
                              ? const Color.fromARGB(255, 214, 128, 23)
                              : const Color(0xFF6CB523),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.type == 'lost' ? 'Lost' : 'Found',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(item.description,
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 16),

                  // Location map (conditional)
                  if (item.location != null) ...[
                    const Text('Location',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              item.location!.latitude, item.location!.longitude),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('item_location'),
                            position: LatLng(item.location!.latitude,
                                item.location!.longitude),
                          ),
                        },
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Posting date and time
                  const Text('Posted',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_formatFullDate(item.createdAt),
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 16),

                  // Poster info
                  const Text('Posted by',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(item.posterName ?? 'Unknown poster',
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(item.posterEmail ?? 'Contact info not available',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(ItemModel item) {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: item.imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(
            item.imageUrls[index],
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          ListTile(
            title: const Text('Browse Items'),
            onTap: () => Navigator.pushReplacementNamed(context, '/items'),
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Date unknown';
    final date = timestamp.toDate();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute $amPm';
  }
}
```

### Route Registration in main.dart

Add to routes map (after the `/items` route or after `/profile`):

```dart
'/details': (context) => const ItemDetailsPage(),
```

Add import at top of `main.dart`:

```dart
import 'pages/item_details_page.dart';
```

**Note:** If Story 2.1 has already added the `/items` route, add `/details` right after it. If not, add after `/profile` (line 38).

### Data Extraction Pattern

The `ItemModel` is passed from the listing page via `Navigator.pushNamed(context, '/details', arguments: item)` (Story 2.1). This page extracts it using:

```dart
_item ??= ModalRoute.of(context)!.settings.arguments as ItemModel;
```

Using `didChangeDependencies()` with `??=` ensures:
- The route arguments are available (not available in `initState`)
- The item is extracted only once (not re-extracted on rebuilds)
- A null guard (`_item == null`) in `build()` handles the brief moment before extraction

### Photo Section

Uses `PageView.builder` for a swipeable horizontal photo carousel:
- Height: 250px
- `fit: BoxFit.contain` — shows full image without cropping
- `errorBuilder` handles broken URLs
- Only rendered if `item.imageUrls.isNotEmpty`
- Users swipe left/right to view additional photos

### Google Map (Conditional)

The map only renders when `item.location != null`. Pattern matches existing `lost_items.dart` (lines 239-265):
- `SizedBox(height: 200)` with `GoogleMap` widget
- `CameraPosition` centered on `item.location` at zoom 15
- Single `Marker` at the item's location
- All gesture controls and zoom controls disabled — fully static read-only display
- `LatLng` is constructed from `GeoPoint.latitude` and `GeoPoint.longitude`
- **Web (Chrome) note:** The `GoogleMap` widget may render blank on Chrome without a Maps JavaScript API key configured in `web/index.html`. This is a known limitation (CLAUDE.md: "Partial — no web API key"). Test on Android emulator for full map functionality, or obtain a Maps JS API key for web testing

### Date Display — Full Format

Details page uses full date+time: "March 24, 2026 at 2:30 PM" per architecture format patterns. Manual formatting avoids adding the `intl` package. Null `createdAt` displays "Date unknown".

### Poster Info with Fallbacks

- `item.posterName ?? 'Unknown poster'` — per architecture backward compatibility rule (AR16)
- `item.posterEmail ?? 'Contact info not available'` — satisfies FR25 ("displays poster's name and contact information"). The email is displayed as grey text below the poster name. Story 3.2 adds the interactive "Contact Poster" button with copy/email actions.

### Type Badge Colors

Same as listing page and HomePage:
- **Lost:** `Color.fromARGB(255, 214, 128, 23)` (orange)
- **Found:** `Color(0xFF6CB523)` (green)

### 3-Item Drawer

Same universal pattern as Story 2.1's listing page:
- Home → `/home`
- Browse Items → `/items`
- Profile → `/profile`

All use `pushReplacementNamed` per architecture template.

### Critical Rules

- Use `didChangeDependencies()` not `initState()` for `ModalRoute.of(context)` — context is not ready in `initState`
- The `??=` operator prevents re-extraction on rebuilds
- `item.location` is a `GeoPoint` (from `cloud_firestore`) — convert to `LatLng` (from `google_maps_flutter`) for the map
- Map gestures mostly disabled — this is a read-only location display, not a picker
- `Image.network` must have `errorBuilder` — broken URLs should not crash the page
- `PageView.builder` (not `ListView`) for horizontal photo swiping

### What NOT to Do

- DO NOT add a "Contact Poster" button — that's Story 3.2
- DO NOT add edit or delete functionality — out of scope
- DO NOT use `dart:io` for image handling
- DO NOT add `cached_network_image` — use built-in `Image.network`
- DO NOT make the map interactive (no tapping, no location picking) — read-only display
- DO NOT modify `item_listing_page.dart` — the `onTap` navigation is already wired in Story 2.1
- DO NOT modify `item_model.dart` — use existing fields as-is

### Files Created/Modified

| File | Action |
|---|---|
| `lib/pages/item_details_page.dart` | CREATE — new details page |
| `lib/main.dart` | MODIFY — add import + `/details` route |

**1 file created, 1 file modified.**

### Dependencies on Previous Stories

| Story | Dependency | Blocking? |
|---|---|---|
| 0.2 | **Fix HomePage nested MaterialApp** — drawer navigation to `/home` and `/items` will fail if HomePage still has its own `MaterialApp` | **YES — hard blocker** |
| 1.1 | `ItemModel` class with all fields | YES |
| 2.1 | Listing page passes `ItemModel` via `Navigator.pushNamed(context, '/details', arguments: item)` | YES (navigation source) |

### Project Structure After This Story

```
lib/
  main.dart                      ← MODIFIED (add /details route)
  firebase_options.dart
  models/
    item_model.dart
  pages/
    splashscreen.dart
    signinpage.dart
    signuppage.dart
    lost_items.dart
    found_page.dart
    profile_page.dart
    item_listing_page.dart
    item_details_page.dart       ← NEW
```

### Previous Story Intelligence

- Story 2.1 wires `Navigator.pushNamed(context, '/details', arguments: item)` on item tap — this story provides the destination
- Story 2.1 notes "tapping an item will throw a route-not-found error until Story 3.1" — this story resolves that
- The Google Maps widget pattern is borrowed from `lost_items.dart` lines 239-265 but simplified (no onTap, no location picker, no controller needed)
- Existing pages use `google_maps_flutter` with `LatLng` and `Marker` — same pattern here

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 3.1]
- [Source: _bmad-output/planning-artifacts/architecture.md#Frontend Architecture — Page-to-Page Data Passing]
- [Source: _bmad-output/planning-artifacts/architecture.md#Format Patterns — Date Display (full), Image Display (details)]
- [Source: _bmad-output/planning-artifacts/architecture.md#Implementation Patterns — Standard Drawer Pattern (3 items)]
- [Source: _bmad-output/planning-artifacts/architecture.md#Data Architecture — backward compatibility (posterName ?? 'Unknown poster')]
- [Source: _bmad-output/planning-artifacts/prd.md#FR20-25 — Item Details requirements]
- [Source: lib/pages/lost_items.dart lines 239-265 — existing Google Maps pattern]
- [Source: lib/main.dart lines 31-39 — current routes map]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
