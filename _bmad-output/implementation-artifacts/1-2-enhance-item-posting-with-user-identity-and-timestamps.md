# Story 1.2: Enhance Item Posting with User Identity and Timestamps

Status: ready-for-dev

## Story

As a **user**,
I want my name, email, and the current time recorded when I post a lost or found item,
so that other users know who posted the item and when.

## Acceptance Criteria

1. **Given** the user is authenticated and on the LostPage or FoundPage
   **When** the page loads (`initState`)
   **Then** the current user's profile (firstName, lastName) is fetched from the `users` Firestore collection
   **And** the poster name is stored locally as `_posterName`

2. **Given** the user fills in item details and taps "Post"
   **When** the Firestore document is created
   **Then** the document includes `userId` (current user UID), `posterName` (fetched name), `posterEmail` (current user email), and `createdAt` (`FieldValue.serverTimestamp()`)
   **And** both `lost_items.dart` and `found_page.dart` have identical field additions
   **And** old documents without these fields still display with fallbacks

## Tasks / Subtasks

- [ ] Task 1: Add firebase_auth import to both posting pages (AC: #1)
  - [ ] Add `import 'package:firebase_auth/firebase_auth.dart';` to `lost_items.dart`
  - [ ] Add `import 'package:firebase_auth/firebase_auth.dart';` to `found_page.dart`
- [ ] Task 2: Add state variables and initState to LostPage (AC: #1)
  - [ ] Add `String _posterName = '';` state variable after `_isPosting` (line 23)
  - [ ] Add `initState()` override that calls `_fetchUserProfile()`
  - [ ] Implement `_fetchUserProfile()` method
- [ ] Task 3: Add state variables and initState to FoundPage (AC: #1)
  - [ ] Same changes as Task 2, mirrored identically in `found_page.dart`
- [ ] Task 4: Add new fields to Firestore document in LostPage (AC: #2)
  - [ ] In `_postDetailsToFirestore()`, add `userId`, `posterName`, `posterEmail`, `createdAt` to the `.add()` map (line 56-63)
- [ ] Task 5: Add new fields to Firestore document in FoundPage (AC: #2)
  - [ ] Same changes as Task 4, mirrored identically in `found_page.dart`
- [ ] Task 6: Verify (AC: #1, #2)
  - [ ] Run `flutter analyze` — no new errors or warnings
  - [ ] Test: post a lost item, verify the Firestore document contains all 4 new fields
  - [ ] Test: post a found item, verify identical new fields

## Dev Notes

### New Import Required

Both `lost_items.dart` and `found_page.dart` currently do NOT import `firebase_auth`. Add at the top of each file:

```dart
import 'package:firebase_auth/firebase_auth.dart';
```

Place it after the existing `cloud_firestore` import (line 3 in both files).

**Important: All line numbers in this story reference the ORIGINAL unmodified files.** After adding this import, all subsequent line numbers shift by +1. Use the variable/method names as primary anchors (e.g., "after `bool _isPosting = false;`") rather than relying strictly on line numbers.

### New State Variable

Add after `bool _isPosting = false;` (line 23 in both files):

```dart
String _posterName = '';
```

### New initState Override

Neither page currently has an `initState()`. Add before `_pickImages()` (line 25 in both files):

```dart
@override
void initState() {
  super.initState();
  _fetchUserProfile();
}
```

### New _fetchUserProfile Method

Add after `initState()`, before `_pickImages()`:

```dart
Future<void> _fetchUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userData = snapshot.data();
    if (userData != null && mounted) {
      setState(() {
        _posterName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
      });
    }
  }
}
```

**Pattern source:** This mirrors `profile_page.dart` lines 42-61 which fetches from the same `users` collection using the same field names (`firstName`, `lastName`).

**Architecture discrepancy note:** The architecture doc uses two separate variables (`'$_posterFirstName $_posterLastName'`). This story uses a single pre-concatenated `_posterName` instead — functionally equivalent but cleaner (one variable instead of two, concatenation in one place). If the dev agent sees the architecture doc's approach, use this story's single-variable pattern.

### Modified Firestore Document Write

In `_postDetailsToFirestore()`, replace the current `.add()` call.

**LostPage** (`lost_items.dart` lines 56-63) — current:
```dart
await firestore.collection('lost_items').add({
  'itemName': _itemNameController.text,
  'description': _descriptionController.text,
  'location': _pickedLocation != null
      ? GeoPoint(_pickedLocation!.latitude, _pickedLocation!.longitude)
      : null,
  'imageUrls': imageUrls,
});
```

**Replace with:**
```dart
await firestore.collection('lost_items').add({
  'itemName': _itemNameController.text,
  'description': _descriptionController.text,
  'location': _pickedLocation != null
      ? GeoPoint(_pickedLocation!.latitude, _pickedLocation!.longitude)
      : null,
  'imageUrls': imageUrls,
  'userId': FirebaseAuth.instance.currentUser?.uid,
  'posterName': _posterName,
  'posterEmail': FirebaseAuth.instance.currentUser?.email,
  'createdAt': FieldValue.serverTimestamp(),
});
```

**FoundPage** (`found_page.dart` lines 56-63) — identical change, but collection is `'found_items'`.

### Field Details

| Field | Value | Type in Firestore |
|---|---|---|
| `userId` | `FirebaseAuth.instance.currentUser?.uid` | String (nullable if somehow unauthenticated) |
| `posterName` | `_posterName` (fetched in initState) | String |
| `posterEmail` | `FirebaseAuth.instance.currentUser?.email` | String (nullable) |
| `createdAt` | `FieldValue.serverTimestamp()` | Timestamp (null locally until server syncs) |

### Critical Rules

- Both files MUST have identical changes — they are structurally mirrored
- Use `FieldValue.serverTimestamp()` for `createdAt` — NOT `DateTime.now()` or `Timestamp.now()`. Server timestamp ensures consistency across devices
- Fetch `posterName` from `users` collection in `initState()` — do NOT use `FirebaseAuth.instance.currentUser?.displayName` (it's usually null for email/password auth)
- Use `userData['firstName']` and `userData['lastName']` — these are the exact field names in the `users` collection (confirmed from `signuppage.dart` lines 52-57 and `profile_page.dart` lines 55-57)
- Check `mounted` before `setState` in `_fetchUserProfile()` — the async fetch may complete after navigation away
- The `_posterName` concatenation uses `'${firstName} ${lastName}'.trim()` — trim handles cases where one name is empty
- Use `?.uid` and `?.email` with null-safe operator on `currentUser` — defensive even though user should be authenticated

### What NOT to Do

- DO NOT modify the existing 4 fields (`itemName`, `description`, `location`, `imageUrls`) — only ADD the 4 new fields
- DO NOT create a service layer or helper class for the user fetch — maintain direct Firestore call pattern
- DO NOT add the new fields to the `users` collection — they go in `lost_items` and `found_items` documents
- DO NOT use `ItemModel` in these pages yet — the posting pages write raw maps, reading pages (Story 2.1+) use ItemModel
- DO NOT add `import 'package:lost_and_found/models/item_model.dart';` — not needed here
- DO NOT modify the UI, form fields, navigation, drawer, or any visual elements
- DO NOT add error handling around `_fetchUserProfile()` — if it fails, `_posterName` stays `''` which is acceptable (backward-compatible with empty poster name)
- DO NOT add `phone_number` to the fetched fields — it's not part of the poster identity per the architecture

### Backward Compatibility (AC: #2)

Old documents in `lost_items` and `found_items` that lack `userId`, `posterName`, `posterEmail`, `createdAt` will continue to work. The `ItemModel.fromFirestore()` (Story 1.1) handles these with null defaults. Display fallbacks are handled by consuming pages:
- `item.posterName ?? 'Unknown poster'`
- `item.createdAt` null → `'Date unknown'`

### Files Modified

| File | Changes |
|---|---|
| `lib/pages/lost_items.dart` | Add `firebase_auth` import, `_posterName` variable, `initState()`, `_fetchUserProfile()`, 4 new fields in Firestore write |
| `lib/pages/found_page.dart` | Identical changes to lost_items.dart (different collection name) |

**0 files created, 2 files modified.**

### Dependency on Story 1.1

Story 1.1 creates `ItemModel` which defines the new fields (`userId`, `posterName`, `posterEmail`, `createdAt`). This story writes those fields to Firestore. The model is NOT imported or used in this story — it's used by reading pages in later stories. However, the field names MUST match exactly:
- `userId` (camelCase) — NOT `user_id`
- `posterName` (camelCase) — NOT `poster_name`
- `posterEmail` (camelCase) — NOT `poster_email`
- `createdAt` (camelCase) — NOT `created_at`

### Previous Story Intelligence (Story 1-1)

- Story 1-1 creates `ItemModel` with `fromFirestore()` factory — defines the canonical field names this story must match
- The model uses null-safe access: `data['userId']`, `data['posterName']`, etc. — our writes must use these exact keys
- Story 1-1 is a new file only — no code changes to existing pages

### Project Structure Notes

- `FirebaseAuth` is already available in the project via `firebase_auth: ^4.19.1` in pubspec.yaml
- The `users` collection structure (from `signuppage.dart` lines 52-57): `{ uid, email, firstName, lastName }`
- Note: `phone_number` is added later via profile editing but is NOT included in poster identity

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.2]
- [Source: _bmad-output/planning-artifacts/architecture.md#Data Architecture — New Fields Added to Item Documents]
- [Source: _bmad-output/planning-artifacts/architecture.md#Authentication & Security — fetch poster name pattern]
- [Source: _bmad-output/planning-artifacts/architecture.md#Naming Patterns — camelCase for all new Firestore fields]
- [Source: _bmad-output/planning-artifacts/prd.md#FR12 — record poster identity, FR13 — record timestamp]
- [Source: lib/pages/lost_items.dart lines 56-63 — current Firestore write]
- [Source: lib/pages/found_page.dart lines 56-63 — current Firestore write]
- [Source: lib/pages/profile_page.dart lines 42-61 — user profile fetch pattern]
- [Source: lib/pages/signuppage.dart lines 52-57 — users collection field names]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
