# Story 2.2: Add Search Functionality to Item Listing

Status: ready-for-dev

## Story

As a **user**,
I want to search for items by keyword,
so that I can quickly find a specific lost or found item.

## Acceptance Criteria

1. **Given** the item listing page is displaying items
   **When** the user types a keyword in the search bar above the TabBar
   **Then** items are filtered client-side by `itemName` and `description` containing the keyword (case-insensitive)
   **And** the filter applies to the currently active tab's data
   **And** the search query persists when switching between tabs
   **And** search results update within 2 seconds of input
   **And** a clear button resets the search

## Tasks / Subtasks

- [ ] Task 1: Add search state variables to `_ItemListingPageState` (AC: #1)
  - [ ] Add `TextEditingController _searchController`
  - [ ] Add `String _searchQuery = ''`
- [ ] Task 2: Add search TextField to AppBar (AC: #1)
  - [ ] Add a `TextField` in the AppBar `title` area (replacing the static `Text('Browse Items')`)
  - [ ] Configure with hint text, search icon prefix, clear button suffix
  - [ ] On text change, update `_searchQuery` via `setState`
- [ ] Task 3: Implement client-side filtering (AC: #1)
  - [ ] Create `_filterItems(List<ItemModel> items)` method
  - [ ] Filter by `itemName` and `description` containing query (case-insensitive)
  - [ ] Pass filtered lists to `_buildItemList` in the `TabBarView`
- [ ] Task 4: Dispose _searchController (AC: #1)
  - [ ] Add `_searchController.dispose()` in `dispose()` before `_tabController.dispose()`
- [ ] Task 5: Verify (AC: #1)
  - [ ] Run `flutter analyze` — no errors
  - [ ] Test: type a keyword, verify items filter across current tab
  - [ ] Test: switch tabs while search is active, verify filter persists
  - [ ] Test: tap clear button, verify all items return

## Dev Notes

### Changes to item_listing_page.dart

This story ONLY modifies `lib/pages/item_listing_page.dart` created in Story 2.1. No other files are touched.

**All references below use Story 2.1's code structure as the baseline.** Since Story 2.1 may not be implemented yet, the dev agent should implement Story 2.1 first, then apply these modifications.

### New State Variables

Add after `List<ItemModel> _allItems = [];` in the state class:

```dart
final TextEditingController _searchController = TextEditingController();
String _searchQuery = '';
```

### Updated dispose()

Add `_searchController.dispose()` before `_tabController.dispose()`:

```dart
@override
void dispose() {
  _searchController.dispose();
  _tabController.dispose();
  super.dispose();
}
```

### New _filterItems Method

Add after `_fetchItems()`:

```dart
List<ItemModel> _filterItems(List<ItemModel> items) {
  if (_searchQuery.isEmpty) return items;
  final query = _searchQuery.toLowerCase();
  return items.where((item) =>
      item.itemName.toLowerCase().contains(query) ||
      item.description.toLowerCase().contains(query)).toList();
}
```

### Updated build() — AppBar with Search

Replace the `appBar` section in `build()`. The search bar replaces the static title, and the `TabBar` stays in `bottom`:

```dart
appBar: AppBar(
  title: TextField(
    controller: _searchController,
    decoration: InputDecoration(
      hintText: 'Search items...',
      border: InputBorder.none,
      prefixIcon: const Icon(Icons.search, color: Colors.white70),
      suffixIcon: _searchQuery.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                _searchController.clear();
                setState(() { _searchQuery = ''; });
              },
            )
          : null,
      hintStyle: const TextStyle(color: Colors.white70),
    ),
    style: const TextStyle(color: Colors.white),
    onChanged: (value) {
      setState(() { _searchQuery = value; });
    },
  ),
  bottom: TabBar(
    controller: _tabController,
    tabs: const [
      Tab(text: 'All'),
      Tab(text: 'Lost'),
      Tab(text: 'Found'),
    ],
  ),
),
```

### Updated TabBarView — Pass Filtered Lists

Replace the `TabBarView` children to pass items through `_filterItems`:

```dart
TabBarView(
  controller: _tabController,
  children: [
    _buildItemList(_filterItems(_allItems)),
    _buildItemList(_filterItems(_lostItems)),
    _buildItemList(_filterItems(_foundItems)),
  ],
),
```

### How Search Persists Across Tabs

The `_searchQuery` is a single state variable shared across all tabs. When the user switches tabs, the `TabBarView` rebuilds with the new tab's data, but `_filterItems` applies the same `_searchQuery` to whichever list is active. No additional logic needed — the architecture's design handles this naturally.

### Search Performance (NFR3: 2s)

Client-side filtering on ~100 items (50 per collection) is effectively instant. `setState` triggers a rebuild with the filtered list — no debounce needed for this dataset size. If the dataset grew significantly, a debounce could be added, but for MVP campus scale this is well within the 2-second requirement.

### Critical Rules

- Filter is **case-insensitive** — use `.toLowerCase()` on both the query and item fields
- Filter checks BOTH `itemName` AND `description` — use `||` (either matches)
- `_searchQuery` persists across tab switches — do NOT reset it on tab change
- Clear button only appears when `_searchQuery.isNotEmpty` — uses conditional `suffixIcon`
- `_searchController.dispose()` MUST be added to `dispose()` — memory leak otherwise
- The search `TextField` replaces the `title: const Text('Browse Items')` — it does NOT go in `bottom` (that's the TabBar)

### What NOT to Do

- DO NOT add server-side search (Firestore has no full-text search) — client-side only per architecture
- DO NOT add a debounce timer — unnecessary for ~100 items
- DO NOT add a separate search results page — filter in-place within tabs
- DO NOT reset `_searchQuery` when switching tabs — it must persist
- DO NOT modify `_fetchItems()`, the drawer, or the item row layout — only add search
- DO NOT add a search button — filter on every keystroke via `onChanged`

### Empty State After Search

When search filters all items, `_buildItemList` receives an empty list and shows "No items posted yet" (from Story 2.1). Story 2.4 will enhance this with a search-specific message ("No items match your search"). For now, the generic empty state is acceptable.

### Files Modified

| File | Changes |
|---|---|
| `lib/pages/item_listing_page.dart` | Add search controller, search TextField in AppBar, `_filterItems` method, filtered lists in TabBarView, dispose search controller |

**0 files created, 1 file modified.**

### Dependencies on Previous Stories

| Story | Dependency | Blocking? |
|---|---|---|
| 2.1 | `item_listing_page.dart` must exist with tabs, item lists, and `_buildItemList` method | YES |

### Previous Story Intelligence (Story 2-1)

- Story 2.1 creates the page with `_allItems`, `_lostItems`, `_foundItems` state variables — this story filters those lists before display
- Story 2.1's `_buildItemList` already handles empty lists with "No items posted yet"
- Story 2.1 explicitly says "DO NOT add search functionality — that's Story 2.2" — confirming this story's scope
- The `build()` method from Story 2.1 has `title: const Text('Browse Items')` which this story replaces with a search `TextField`

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.2]
- [Source: _bmad-output/planning-artifacts/architecture.md#Frontend Architecture — Search Implementation]
- [Source: _bmad-output/planning-artifacts/prd.md#FR16 — Search by keyword across item names and descriptions]
- [Source: _bmad-output/planning-artifacts/prd.md#NFR3 — Search results update within 2 seconds]
- [Source: _bmad-output/implementation-artifacts/2-1-create-item-listing-page-with-tabbed-feed.md — baseline code structure]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
