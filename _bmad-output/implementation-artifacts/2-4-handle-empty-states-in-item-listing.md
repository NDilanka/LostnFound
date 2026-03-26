# Story 2.4: Handle Empty States in Item Listing

Status: ready-for-dev

## Story

As a **user**,
I want to see a helpful message when no items are available,
so that I know the listing is working and what to do next.

## Acceptance Criteria

1. **Given** the listing page has loaded but no items exist
   **When** the tab displays
   **Then** an empty state message is shown: "No items posted yet"

2. **Given** the user has searched with no matches
   **When** the filtered results are empty
   **Then** an empty state message is shown: "No items match your search. Try a different keyword."

## Tasks / Subtasks

- [ ] Task 1: Update `_buildItemList` empty state logic (AC: #1, #2)
  - [ ] Modify `_buildItemList` in `item_listing_page.dart` to distinguish between no-items and no-search-results
  - [ ] When `_searchQuery` is empty and list is empty → show "No items posted yet"
  - [ ] When `_searchQuery` is not empty and list is empty → show "No items match your search. Try a different keyword."
- [ ] Task 2: Verify (AC: #1, #2)
  - [ ] Run `flutter analyze` — no errors
  - [ ] Test: with no items in Firestore, verify "No items posted yet" displays
  - [ ] Test: search for a non-existent keyword, verify search-specific message displays

## Dev Notes

### Change to _buildItemList in item_listing_page.dart

This modifies the `_buildItemList` method created in Story 2.1. Replace the empty state block:

**Current (from Story 2.1):**
```dart
Widget _buildItemList(List<ItemModel> items) {
  if (items.isEmpty) {
    return const Center(
      child: Text('No items posted yet'),
    );
  }
  // ... ListView.builder
}
```

**Replace with:**
```dart
Widget _buildItemList(List<ItemModel> items) {
  if (items.isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          _searchQuery.isNotEmpty
              ? 'No items match your search. Try a different keyword.'
              : 'No items posted yet',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
  // ... rest of ListView.builder unchanged
}
```

### How It Works

The `_searchQuery` state variable (added by Story 2.2) is accessible from `_buildItemList` since both are in the same `_ItemListingPageState` class. When the items list is empty:
- `_searchQuery.isNotEmpty` → user searched and got no results → show search-specific message
- `_searchQuery.isEmpty` → no items exist in this tab at all → show generic message

This works for all three tabs (All, Lost, Found) since `_filterItems` from Story 2.2 is applied before passing to `_buildItemList`.

### Critical Rules

- Use the EXACT message text from the AC: "No items posted yet" and "No items match your search. Try a different keyword."
- The `Center` widget is no longer `const` because `_searchQuery` is runtime state — remove the `const` keyword
- Add `Padding` and `textAlign: TextAlign.center` for better visual presentation
- Add grey text styling to differentiate empty state from regular content
- Do NOT modify the `ListView.builder` section — only change the empty state block

### What NOT to Do

- DO NOT add illustrations or icons to the empty state — keep it text-only for MVP
- DO NOT add a "Post an item" button in the empty state — out of scope
- DO NOT modify `_fetchItems()`, `_filterItems()`, the search bar, tabs, drawer, or item row layout
- DO NOT add empty state handling to any other page — this story only covers the listing page

### Files Modified

| File | Changes |
|---|---|
| `lib/pages/item_listing_page.dart` | Update empty state in `_buildItemList` to show contextual message |

**0 files created, 1 file modified.**

### Dependencies on Previous Stories

| Story | Dependency | Blocking? |
|---|---|---|
| 2.1 | `item_listing_page.dart` must exist with `_buildItemList` method | YES |
| 2.2 | `_searchQuery` state variable must exist for distinguishing empty states | YES |

### Previous Story Intelligence

- Story 2.1 creates `_buildItemList` with a basic "No items posted yet" empty state — this story enhances it
- Story 2.2 adds `_searchQuery` to the state class — this story reads it to determine which message to show
- Story 2.1 explicitly says "DO NOT add enhanced empty states — that's Story 2.4" — confirming scope

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.4]
- [Source: _bmad-output/planning-artifacts/prd.md#FR34 — meaningful empty state when no items match search]
- [Source: _bmad-output/implementation-artifacts/2-1-create-item-listing-page-with-tabbed-feed.md — _buildItemList baseline]
- [Source: _bmad-output/implementation-artifacts/2-2-add-search-functionality-to-item-listing.md — _searchQuery variable]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
