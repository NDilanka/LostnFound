# Story 4.1: Add Item History to Profile Page

Status: ready-for-dev

## Story

As a **user**,
I want to see my posted lost and found items on my profile page,
so that I can track what I've posted.

## Acceptance Criteria

1. **Given** the user is on the profile page
   **When** the page loads
   **Then** a "My Posted Items" section appears below the profile form
   **And** it lists all items the user has posted (from both `lost_items` and `found_items` where `userId` matches)
   **And** each item shows: item name, type badge (Lost/Found), posting date
   **And** tapping an item navigates to `/details` with the `ItemModel`
   **And** a "You haven\'t posted any items yet" message shows if the user has no items
   **And** a loading indicator shows while items are being fetched

## Tasks / Subtasks

- [ ] Task 1: Add ItemModel import to profile_page.dart (AC: #1)
  - [ ] Add `import 'package:lost_and_found/models/item_model.dart';`
- [ ] Task 2: Add item history state variables (AC: #1)
  - [ ] Add `List<ItemModel> _myItems = []` and `bool _isLoadingItems = true`
- [ ] Task 3: Implement `_fetchMyItems()` method (AC: #1)
  - [ ] Query both `lost_items` and `found_items` where `userId == currentUser.uid`
  - [ ] Map to ItemModel, merge, sort by createdAt descending
  - [ ] Call from `_fetchUserData()` after getting user UID
- [ ] Task 4: Wrap body in SingleChildScrollView (AC: #1)
  - [ ] Change `body: Padding(...)` with `Column` to `body: SingleChildScrollView(child: Padding(...))`
  - [ ] This prevents overflow when items list is added below the form
- [ ] Task 5: Add "My Posted Items" section below profile form (AC: #1)
  - [ ] Add section header "My Posted Items"
  - [ ] Show loading indicator or item list or empty state
  - [ ] Each item row: item name, type badge, date, tap to navigate
- [ ] Task 6: Verify (AC: #1)
  - [ ] Run `flutter analyze` — no errors
  - [ ] Test: profile page shows posted items below form
  - [ ] Test: tap an item → navigates to `/details`
  - [ ] Test: user with no items → shows "You haven\'t posted any items yet"

## Dev Notes

### Changes to profile_page.dart

This story ONLY modifies `lib/pages/profile_page.dart`. No other files are touched.

**All line numbers reference the ORIGINAL unmodified file.** If Story 0.4 (sign-out fix) has been applied, the Logout onTap callback will be different but line numbers for the body/form section (lines 225-263) remain unchanged.

### New Import

Add at the top of `profile_page.dart`:

```dart
import 'package:lost_and_found/models/item_model.dart';
```

### New State Variables

Add after `late String _userId;` (line 20):

```dart
List<ItemModel> _myItems = [];
bool _isLoadingItems = true;
```

### New _fetchMyItems() Method

Add after `_updateUserData()` (line 72):

```dart
Future<void> _fetchMyItems() async {
  try {
    final results = await Future.wait([
      FirebaseFirestore.instance
          .collection('lost_items')
          .where('userId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get(),
      FirebaseFirestore.instance
          .collection('found_items')
          .where('userId', isEqualTo: _userId)
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

    final allItems = [...lostItems, ...foundItems];
    allItems.sort((a, b) =>
        (b.createdAt?.millisecondsSinceEpoch ?? 0)
            .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0));

    if (mounted) {
      setState(() {
        _myItems = allItems;
        _isLoadingItems = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() { _isLoadingItems = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load your items: $e')),
      );
    }
  }
}
```

### Call _fetchMyItems from _fetchUserData

Add `_fetchMyItems()` call at the end of `_fetchUserData()`, after `_userId` is set (line 45):

```dart
void _fetchUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    _userId = user.uid;
    _fetchMyItems(); // ADD THIS LINE — fetch items in parallel with user data
    // ... rest of existing code unchanged
  }
}
```

Place `_fetchMyItems()` right after `_userId = user.uid;` (line 45) and before the Firestore user doc fetch (line 47). This lets the item fetch run in parallel with the user profile fetch.

### Pre-Existing Bugs — DO NOT FIX (Out of Scope)

**1. `phone_number` null crash (line 58):** `_phoneNumberController.text = userData['phone_number']` throws a `TypeError` when `phone_number` is null. This happens for users who signed up but never edited their profile (signup only stores `uid`, `email`, `firstName`, `lastName`). The fix would be `userData['phone_number'] ?? ''` but this is **out of scope** — do not modify the existing `_fetchUserData` logic beyond adding the `_fetchMyItems()` call.

**2. Missing `mounted` check (line 54):** `_fetchUserData()` calls `setState()` without checking `mounted` first. This is a pre-existing issue. The new `_fetchMyItems()` correctly checks `mounted` — do not "fix" the existing method to match, as that would be scope creep.

### Wrap Body in SingleChildScrollView

The current body (line 225) is:
```dart
body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
```

Replace with:
```dart
body: SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
```

And add the matching closing `)` for `SingleChildScrollView` after the `Column`'s closing. This prevents layout overflow when the items list extends beyond the screen.

### Add "My Posted Items" Section

Add inside the `Column.children` list, after the last `SizedBox(height: 16.0)` (line 260) and before the closing `]` of the Column:

```dart
// My Posted Items section
const SizedBox(height: 24),
const Divider(),
const SizedBox(height: 8),
const Text(
  'My Posted Items',
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
const SizedBox(height: 12),
if (_isLoadingItems)
  const Center(child: CircularProgressIndicator())
else if (_myItems.isEmpty)
  const Padding(
    padding: EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Text(
        'You haven\'t posted any items yet',
        style: TextStyle(fontSize: 15, color: Colors.grey),
      ),
    ),
  )
else
  ..._myItems.map((item) => InkWell(
    onTap: () {
      Navigator.pushNamed(context, '/details', arguments: item);
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName,
                    style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 2),
                Text(_formatDate(item.createdAt),
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
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
  )),
```

### Add _formatDate Helper

Add as a method in the State class (after `_fetchMyItems`):

```dart
String _formatDate(Timestamp? timestamp) {
  if (timestamp == null) return 'Date unknown';
  final date = timestamp.toDate();
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
```

Same short date format as the item listing page (Story 2.1).

### Firestore Composite Index Requirement

The `.where('userId', ...).orderBy('createdAt', ...)` queries require Firestore composite indexes (one per collection). On first run:
1. Query may fail with a **direct link** to create the index in Firebase Console
2. Click the link to auto-create
3. Wait ~2-5 minutes for build
4. Retry — queries will work

Two indexes needed:
- `lost_items`: `userId` (ascending) + `createdAt` (descending)
- `found_items`: `userId` (ascending) + `createdAt` (descending)

### Empty State (FR35)

When the user has no posted items, the section shows "You haven\'t posted any items yet" in grey centered text. This satisfies FR35: "The system handles gracefully when a user has no posted items in their profile history."

### Critical Rules

- Use `Future.wait` for parallel queries on both collections — same pattern as Story 2.1
- Null-safe sort on `createdAt` — same pattern as Story 2.1
- Check `mounted` before `setState` in the async callback
- `_fetchMyItems()` is called from `_fetchUserData()` AFTER `_userId` is assigned — it needs the UID for the `.where()` filter
- Use the spread operator `..._myItems.map(...)` to embed list items directly in the Column children
- Wrap body in `SingleChildScrollView` — the existing `Column` will overflow without it once items are added
- Navigate to `/details` with `arguments: item` — same as listing page
- Type badge colors match existing: orange `Color.fromARGB(255, 214, 128, 23)`, green `Color(0xFF6CB523)`

### What NOT to Do

- DO NOT modify the profile form fields (email, name, phone) — only add below them
- DO NOT change the drawer structure or styling — profile page has a custom styled drawer (different from other pages)
- DO NOT add edit/delete item functionality — out of scope
- DO NOT use `StreamBuilder` — use one-time `.get()` queries per architecture pattern
- DO NOT add thumbnails to the item rows — keep it simple (name + badge + date) to match the profile page's clean layout
- DO NOT modify `_fetchUserData()` beyond adding the `_fetchMyItems()` call
- DO NOT add pull-to-refresh — out of scope

### Files Modified

| File | Changes |
|---|---|
| `lib/pages/profile_page.dart` | Add ItemModel import, state variables, `_fetchMyItems()`, `_formatDate()`, wrap body in SingleChildScrollView, add "My Posted Items" section |

**0 files created, 1 file modified.**

### Dependencies on Previous Stories

| Story | Dependency | Blocking? |
|---|---|---|
| 1.1 | `ItemModel` class at `lib/models/item_model.dart` | YES |
| 1.2 | `userId` field must be written to Firestore items for `.where('userId', ...)` to match | Soft — query works but returns no items if userId not written yet |
| 3.1 | `/details` route must exist for item tap navigation | Soft — tap will error if route doesn't exist yet |

### Previous Story Intelligence

- Story 2.1 establishes the `Future.wait` parallel query pattern, null-safe sort, and type badge colors — reused here
- Story 3.1 registers the `/details` route that item taps navigate to
- Story 1.2 writes `userId` to item documents — items posted without Story 1.2 won't appear in the user's history
- The profile page has a **custom drawer** (red background, icon+text rows, logout button) different from other pages — do NOT change it to the standard 3-item drawer

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.1]
- [Source: _bmad-output/planning-artifacts/architecture.md#Frontend Architecture — Profile Page Item History]
- [Source: _bmad-output/planning-artifacts/architecture.md#Data Architecture — Firestore Query with userId filter]
- [Source: _bmad-output/planning-artifacts/prd.md#FR35 — graceful empty state for no posted items]
- [Source: lib/pages/profile_page.dart — full current page structure]
- [Source: _bmad-output/implementation-artifacts/2-1-create-item-listing-page-with-tabbed-feed.md — Future.wait, null-safe sort, badge patterns]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
