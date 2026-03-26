# Story 1.1: Create ItemModel Class

Status: ready-for-dev

## Story

As a **developer**,
I want a typed model class for item data,
so that all pages read Firestore item documents consistently via `ItemModel.fromFirestore()`.

## Acceptance Criteria

1. **Given** no model class exists for item data
   **When** `lib/models/item_model.dart` is created
   **Then** `ItemModel` has fields: `id`, `itemName`, `description`, `type` (lost/found), `location` (GeoPoint?), `imageUrls` (List\<String\>), `userId`, `posterName`, `posterEmail`, `createdAt` (Timestamp?)
   **And** `factory ItemModel.fromFirestore(DocumentSnapshot doc, String type)` correctly maps all fields with null-safe access (`data['field'] ?? defaultValue`)
   **And** all new fields (`userId`, `posterName`, `posterEmail`, `createdAt`) are nullable for backward compatibility

## Tasks / Subtasks

- [ ] Task 1: Create lib/models/ directory (AC: #1)
  - [ ] Create `lib/models/` directory (does not exist yet)
- [ ] Task 2: Create item_model.dart (AC: #1)
  - [ ] Create `lib/models/item_model.dart`
  - [ ] Import `package:cloud_firestore/cloud_firestore.dart` (for `GeoPoint`, `Timestamp`, `DocumentSnapshot`)
  - [ ] Define `ItemModel` class with all fields per AC
  - [ ] Implement `factory ItemModel.fromFirestore(DocumentSnapshot doc, String type)`
  - [ ] Use null-safe access for all fields with appropriate defaults
- [ ] Task 3: Verify (AC: #1)
  - [ ] Run `flutter analyze` — no errors or warnings in the new file
  - [ ] Verify the file compiles by running `flutter build` or `flutter run` briefly

## Dev Notes

### Complete Implementation

The architecture document provides the exact code. Create `lib/models/item_model.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String itemName;
  final String description;
  final String type; // 'lost' or 'found'
  final GeoPoint? location;
  final List<String> imageUrls;
  final String? userId;
  final String? posterName;
  final String? posterEmail;
  final Timestamp? createdAt;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.description,
    required this.type,
    this.location,
    required this.imageUrls,
    this.userId,
    this.posterName,
    this.posterEmail,
    this.createdAt,
  });

  factory ItemModel.fromFirestore(DocumentSnapshot doc, String type) {
    final rawData = doc.data();
    if (rawData == null) {
      throw StateError('Document ${doc.id} does not exist');
    }
    final data = rawData as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      itemName: data['itemName'] ?? '',
      description: data['description'] ?? '',
      type: type,
      location: data['location'] as GeoPoint?,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      userId: data['userId'],
      posterName: data['posterName'],
      posterEmail: data['posterEmail'],
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
```

### Field Mapping to Existing Firestore Documents

Current fields written by `lost_items.dart` (line 56-63) and `found_page.dart` (line 56-63):

| Firestore Field | Type | ItemModel Field | Default |
|---|---|---|---|
| `itemName` | String | `itemName` | `''` |
| `description` | String | `description` | `''` |
| `location` | GeoPoint? | `location` | `null` |
| `imageUrls` | List | `imageUrls` | `[]` |

New fields (added by Story 1.2, not yet in Firestore):

| Firestore Field | Type | ItemModel Field | Default |
|---|---|---|---|
| `userId` | String? | `userId` | `null` |
| `posterName` | String? | `posterName` | `null` |
| `posterEmail` | String? | `posterEmail` | `null` |
| `createdAt` | Timestamp? | `createdAt` | `null` |

### Backward Compatibility

All new fields are nullable (`String?`, `Timestamp?`). Old documents that lack these fields will have `null` values. Display fallbacks are handled by consuming pages (not this model):
- `item.posterName ?? 'Unknown poster'`
- `item.createdAt` → `'Date unknown'` when null

### The `type` Parameter

The `type` field (`'lost'` or `'found'`) is NOT stored in Firestore — it's passed as a parameter to `fromFirestore()` because items live in separate collections (`lost_items` vs `found_items`). The caller knows which collection it queried and passes the type:

```dart
// Example usage (in future listing page):
final lostDocs = await FirebaseFirestore.instance.collection('lost_items').get();
final lostItems = lostDocs.docs.map((doc) => ItemModel.fromFirestore(doc, 'lost')).toList();

final foundDocs = await FirebaseFirestore.instance.collection('found_items').get();
final foundItems = foundDocs.docs.map((doc) => ItemModel.fromFirestore(doc, 'found')).toList();
```

### Critical Rules

- Use ONLY `package:cloud_firestore/cloud_firestore.dart` as import — do NOT import `dart:io` or any other package
- The single import gives you `GeoPoint`, `Timestamp`, and `DocumentSnapshot`
- `doc.data()` returns `Object?` — check for `null` first (document may not exist), then cast to `Map<String, dynamic>`. The factory accepts raw `DocumentSnapshot` (not `QueryDocumentSnapshot<Map<String, dynamic>>`) to remain flexible across query results and direct `.doc(id).get()` calls
- `imageUrls` MUST use `List<String>.from(data['imageUrls'] ?? [])` — Firestore returns `List<dynamic>`, not `List<String>`
- All new fields (`userId`, `posterName`, `posterEmail`, `createdAt`) MUST be nullable
- `location` and `createdAt` use `as GeoPoint?` / `as Timestamp?` casts (not `??` defaults) because they're complex types
- `id` comes from `doc.id`, NOT from a field inside the document data

### What NOT to Do

- DO NOT add a `toMap()` or `toFirestore()` method — posting pages (Story 1.2) write raw maps directly, not through the model
- DO NOT modify any existing `.dart` files — this story only creates one new file
- DO NOT import this model into any existing page yet — that happens in later stories (Story 1.2 for posting, Story 2.1 for listing)
- DO NOT create a service layer or repository — maintain the direct Firestore call pattern
- DO NOT add `equatable`, `freezed`, or any code generation — plain Dart class only
- DO NOT add `toString()`, `hashCode`, `==` overrides — not needed

### Files Created/Modified

| File | Action |
|---|---|
| `lib/models/` | CREATE directory |
| `lib/models/item_model.dart` | CREATE new file |

**1 file created, 0 files modified.**

### Project Structure After This Story

```
lib/
  main.dart
  firebase_options.dart
  models/
    item_model.dart          ← NEW
  pages/
    splashscreen.dart
    signinpage.dart
    signuppage.dart
    lost_items.dart
    found_page.dart
    profile_page.dart
```

### Consumers of This Model (Future Stories)

| Story | File | Usage |
|---|---|---|
| 2.1 | `item_listing_page.dart` | `ItemModel.fromFirestore()` to display items in tabbed feed |
| 3.1 | `item_details_page.dart` | Receives `ItemModel` via Navigator arguments |
| 4.1 | `profile_page.dart` | `ItemModel.fromFirestore()` for user's posted items |

### Previous Story Intelligence (Story 0-5)

- Story 0-5 **will add** `url_launcher` dependency — not yet implemented, no overlap
- All Epic 0 stories are ready-for-dev but none have been implemented yet
- Pattern: this codebase uses `camelCase` for Firestore fields (except legacy `phone_number`), confirmed by reading both posting pages

### References

- [Source: _bmad-output/planning-artifacts/architecture.md#Data Architecture — ItemModel Structure (lines 168-201)]
- [Source: _bmad-output/planning-artifacts/architecture.md#Target File Structure — lib/models/item_model.dart]
- [Source: _bmad-output/planning-artifacts/architecture.md#Key Architectural Decisions — "Yes, minimal — single ItemModel class"]
- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.1]
- [Source: _bmad-output/planning-artifacts/prd.md#FR12-13 — user identity and timestamps on items]
- [Source: lib/pages/lost_items.dart lines 56-63 — current Firestore fields written]
- [Source: lib/pages/found_page.dart lines 56-63 — identical Firestore fields written]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
