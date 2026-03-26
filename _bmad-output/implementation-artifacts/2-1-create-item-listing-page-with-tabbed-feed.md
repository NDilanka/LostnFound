# Story 2.1: Create Item Listing Page with Tabbed Feed

Status: ready-for-dev

## Story

As a **user**,
I want to browse all posted lost and found items in a tabbed feed,
so that I can find items that match what I'm looking for.

## Acceptance Criteria

1. **Given** `item_listing_page.dart` is created in `lib/pages/`
   **When** the user navigates to the listing page
   **Then** three tabs are displayed: "All", "Lost", "Found"
   **And** the "All" tab shows items from both collections merged and sorted by `createdAt` descending
   **And** the "Lost" tab shows only `lost_items` sorted by `createdAt` descending
   **And** the "Found" tab shows only `found_items` sorted by `createdAt` descending
   **And** each query uses `.limit(50)` and `.orderBy('createdAt', descending: true)`
   **And** each item displays: thumbnail (first image or placeholder icon), item name, type badge (orange "Lost" / green "Found"), and posting date
   **And** tapping an item navigates to `/details` with the `ItemModel` as argument
   **And** the page includes a 3-item drawer (Home, Browse Items, Profile)
   **And** a loading indicator is shown while data loads
   **And** null-safe sort is used for `createdAt`

## Tasks / Subtasks

- [ ] Task 1: Create `lib/pages/item_listing_page.dart` (AC: #1)
  - [ ] Create new file with `ItemListingPage` StatefulWidget
  - [ ] Import `cloud_firestore`, `flutter/material`, and `models/item_model.dart`
  - [ ] Implement `_ItemListingPageState` with `SingleTickerProviderStateMixin` for TabController
  - [ ] Add state variables: `_tabController`, `_isLoading`, `_lostItems`, `_foundItems`, `_allItems`
  - [ ] Implement `initState()` with TabController (3 tabs) and call `_fetchItems()`
  - [ ] Implement `dispose()` for TabController
  - [ ] Implement `_fetchItems()` — dual Firestore queries with `.orderBy('createdAt', descending: true).limit(50)`
  - [ ] Merge and null-safe sort for All tab
  - [ ] Build Scaffold with AppBar, TabBar, TabBarView, and 3-item drawer
  - [ ] Build item list tiles with thumbnail, name, type badge, date
  - [ ] Navigate to `/details` on tap with `ItemModel` as argument
  - [ ] Show `CircularProgressIndicator` while loading
- [ ] Task 2: Register `/items` route in `main.dart` (AC: #1)
  - [ ] Add `import 'pages/item_listing_page.dart';` to `main.dart`
  - [ ] Add `'/items': (context) => const ItemListingPage(),` to the routes map (after line 38)
- [ ] Task 3: Verify (AC: #1)
  - [ ] Run `flutter analyze` — no errors
  - [ ] Test: navigate to `/items`, verify 3 tabs display
  - [ ] Test: verify items load with thumbnails, names, badges, dates
  - [ ] Test: tap an item — verify navigation to `/details` (will show error until Story 3.1 creates the details page, but the navigation attempt confirms wiring)

## Dev Notes

### Complete Page Structure

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/models/item_model.dart';

class ItemListingPage extends StatefulWidget {
  const ItemListingPage({super.key});

  @override
  State<ItemListingPage> createState() => _ItemListingPageState();
}

class _ItemListingPageState extends State<ItemListingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ItemModel> _lostItems = [];
  List<ItemModel> _foundItems = [];
  List<ItemModel> _allItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    setState(() { _isLoading = true; });
    try {
      // Fetch both collections in parallel for faster load (NFR1: 3s target)
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('lost_items')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get(),
        FirebaseFirestore.instance
            .collection('found_items')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get(),
      ]);

      final lostItems = results[0].docs
          .map((doc) => ItemModel.fromFirestore(doc, 'lost'))
          .toList();
      final foundItems = results[1].docs
          .map((doc) => ItemModel.fromFirestore(doc, 'found'))
          .toList();

      // Merge and null-safe sort for All tab
      final allItems = [...lostItems, ...foundItems];
      allItems.sort((a, b) =>
          (b.createdAt?.millisecondsSinceEpoch ?? 0)
              .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0));

      if (mounted) {
        setState(() {
          _lostItems = lostItems;
          _foundItems = foundItems;
          _allItems = allItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load items: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Items'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Lost'),
            Tab(text: 'Found'),
          ],
        ),
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildItemList(_allItems),
                _buildItemList(_lostItems),
                _buildItemList(_foundItems),
              ],
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

  Widget _buildItemList(List<ItemModel> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No items posted yet'),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/details', arguments: item);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Thumbnail (80x80)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.imageUrls.isNotEmpty
                      ? Image.network(
                          item.imageUrls[0],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                                width: 80, height: 80,
                                child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                              ),
                        )
                      : const SizedBox(
                          width: 80, height: 80,
                          child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                // Item info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.itemName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(_formatDate(item.createdAt),
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.type == 'lost'
                        ? const Color.fromARGB(255, 214, 128, 23)
                        : const Color(0xFF6CB523),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.type == 'lost' ? 'Lost' : 'Found',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Date unknown';
    final date = timestamp.toDate();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
```

### Firestore Composite Index Requirement

The `.orderBy('createdAt', descending: true)` queries on `lost_items` and `found_items` may require Firestore composite indexes. When running for the first time:
1. The query may fail with an error containing a **direct link** to create the index in Firebase Console
2. Click the link in the debug console to auto-create the index
3. Wait ~2-5 minutes for index to build
4. Retry — queries will work

This is a one-time setup per collection. If no `createdAt` field exists on any documents yet (Epic 0 stories not implemented), the query will succeed but return only documents that DO have the field.

### Route Registration in main.dart

Add to `main.dart` after line 38 (`'/profile': (context) => const ProfilePage(),`):

```dart
'/items': (context) => const ItemListingPage(),
```

Add import at the top of `main.dart` (after line 10):

```dart
import 'pages/item_listing_page.dart';
```

**Note:** The `/details` route is NOT registered in this story — that happens in Story 3.1. Tapping an item will throw a route-not-found error until then. This is expected and acceptable.

### Null-Safe Sort Pattern

The All tab merges items from both collections and sorts client-side. `createdAt` can be `null` (old documents or `serverTimestamp` pending sync), so the sort MUST use:

```dart
allItems.sort((a, b) =>
    (b.createdAt?.millisecondsSinceEpoch ?? 0)
        .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0));
```

Items with null `createdAt` sort to the bottom (treated as epoch 0). This matches AR12 from the architecture document.

### 3-Item Drawer Pattern (New Pages)

Per the architecture doc, ALL new pages use the 3-item drawer:
- Home → `/home`
- Browse Items → close drawer (already on this page)
- Profile → `/profile`

This differs from existing pages (Lost/Found/Profile) which have 2-item drawers. Do NOT change existing page drawers — they stay as-is.

The drawer uses `DrawerHeader` with blue `BoxDecoration` and `ListTile` entries with `pushReplacementNamed` — matching the pattern in `lost_items.dart` lines 96-126.

### Type Badge Colors

From the architecture doc and existing codebase:
- **Lost:** orange — `Color.fromARGB(255, 214, 128, 23)` (same as HomePage Lost Items button, `main.dart` line 84)
- **Found:** green — `Color(0xFF6CB523)` (same as HomePage Found Items button, `main.dart` line 105)

### Thumbnail Pattern

- Uses a custom `Row`-based layout (NOT `ListTile.leading`) to avoid the 40x40 leading constraint
- Thumbnail wrapped in `ClipRRect` with `borderRadius: 8` for rounded corners
- First image: `Image.network(item.imageUrls[0], width: 80, height: 80, fit: BoxFit.cover)`
- No images: `SizedBox(width: 80, height: 80)` with `Icon(Icons.image_not_supported, size: 40, color: Colors.grey)`
- Add `errorBuilder` on `Image.network` — handles broken image URLs gracefully without crashing
- **Do NOT use `ListTile.leading` for 80x80 images** — it has ~40x40 constraints that cause layout overflow

### Date Display

Listing uses short date format: "Mar 24, 2026". Manual formatting used to avoid adding a dependency (no `intl` package). Null `createdAt` displays "Date unknown".

### Critical Rules

- Use `SingleTickerProviderStateMixin` for `TabController` — required by Flutter
- Dispose `_tabController` in `dispose()` — `super.dispose()` last
- Check `mounted` before `setState` and `ScaffoldMessenger` after async calls
- Use `ItemModel.fromFirestore(doc, 'lost')` and `ItemModel.fromFirestore(doc, 'found')` — pass the type string
- `.limit(50)` on BOTH queries — per NFR5
- Navigate to `/details` with `arguments: item` — the `ItemModel` instance is passed via Navigator arguments
- Empty list shows "No items posted yet" — per FR34 (basic empty state, enhanced in Story 2.4)

### What NOT to Do

- DO NOT add search functionality — that's Story 2.2
- DO NOT update HomePage buttons — that's Story 2.3
- DO NOT add enhanced empty states — that's Story 2.4
- DO NOT create `item_details_page.dart` or register `/details` route — that's Story 3.1
- DO NOT use `StreamBuilder` or real-time listeners — use one-time `.get()` queries per architecture
- DO NOT add `cached_network_image` package — Flutter built-in cache is sufficient per architecture
- DO NOT add pull-to-refresh or infinite scroll — deferred to post-MVP
- DO NOT modify existing pages (Lost, Found, Profile drawers stay at 2 items)

### Files Created/Modified

| File | Action |
|---|---|
| `lib/pages/item_listing_page.dart` | CREATE — new tabbed listing page |
| `lib/main.dart` | MODIFY — add import + `/items` route |

**1 file created, 1 file modified.**

### Dependencies on Previous Stories

| Story | Dependency | Blocking? |
|---|---|---|
| 0.2 | **Fix HomePage nested MaterialApp** — `HomePage` currently returns its own `MaterialApp` with its own navigator that does NOT know about `/items`. Drawer navigation Home → Browse Items will fail with route-not-found until this is fixed. | **YES — hard blocker** |
| 1.1 | `ItemModel` class must exist at `lib/models/item_model.dart` | YES |
| 1.2 | New Firestore fields (`createdAt`, `posterName`, etc.) should be written for sort/display to work fully. **Warning:** `.orderBy('createdAt')` only returns documents that HAVE the `createdAt` field. Until Story 1.2 is implemented and items are re-posted with the new fields, this page will appear empty even if old items exist in Firestore. This is expected Firestore behavior, not a bug. | Soft — page works but shows empty |

### Project Structure After This Story

```
lib/
  main.dart                      ← MODIFIED (add import + /items route)
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
    item_listing_page.dart       ← NEW
```

### Previous Story Intelligence

- Stories 1.1 and 1.2 establish the ItemModel and new Firestore fields — this story is the first consumer of ItemModel for reading
- All previous stories are ready-for-dev, none implemented yet
- The posting pages (`lost_items.dart`, `found_page.dart`) use a 2-item drawer (Home, Profile) — do NOT copy that pattern for new pages

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.1]
- [Source: _bmad-output/planning-artifacts/architecture.md#Frontend Architecture — Item Listing Structure, Tabs]
- [Source: _bmad-output/planning-artifacts/architecture.md#Data Architecture — Firestore Query Pattern]
- [Source: _bmad-output/planning-artifacts/architecture.md#Implementation Patterns — Standard Drawer Pattern (3 items)]
- [Source: _bmad-output/planning-artifacts/architecture.md#Implementation Patterns — Firestore Read Pattern]
- [Source: _bmad-output/planning-artifacts/architecture.md#Format Patterns — Date Display, Image Display, Lost/Found badges]
- [Source: _bmad-output/planning-artifacts/architecture.md#Gap Analysis — Null-safe sort for serverTimestamp (AR12)]
- [Source: _bmad-output/planning-artifacts/architecture.md#Gap Analysis — Firestore composite index]
- [Source: _bmad-output/planning-artifacts/prd.md#FR14-19 — Item Discovery requirements]
- [Source: _bmad-output/planning-artifacts/prd.md#NFR1 — 3s listing load, NFR5 — .limit() queries]
- [Source: lib/main.dart lines 31-39 — current routes map]
- [Source: lib/pages/lost_items.dart lines 96-126 — existing drawer pattern reference]
- [Source: lib/main.dart lines 84, 105 — badge color values from HomePage buttons]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
