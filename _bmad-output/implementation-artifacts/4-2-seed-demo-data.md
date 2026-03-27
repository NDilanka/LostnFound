# Story 4.2: Seed Demo Data

Status: ready-for-dev

## Story

As a **team member preparing for the demo**,
I want realistic sample data in the app,
so that the presentation shows a populated, functional app.

## Acceptance Criteria

1. **Given** the app is ready for demo preparation
   **When** 10-15 sample items are created via the app or Firebase Console
   **Then** items are distributed across both `lost_items` and `found_items`
   **And** items include realistic names (wallet, student ID, headphones, laptop charger, keys, etc.)
   **And** items have varied dates and at least one image each
   **And** items include `userId`, `posterName`, `posterEmail`, `createdAt` fields
   **And** at least 2 items have location GeoPoints set

## Tasks / Subtasks

- [ ] Task 1: Create seed script at `lib/seed_demo_data.dart` (AC: #1)
  - [ ] Create a standalone function `seedDemoData()` that writes sample items to Firestore
  - [ ] Include 12 sample items (7 lost, 5 found) with realistic campus-relevant names
  - [ ] Each item has: itemName, description, imageUrls (at least 1 placeholder), userId, posterName, posterEmail, createdAt
  - [ ] At least 2 items have location GeoPoints (campus coordinates)
  - [ ] Varied createdAt timestamps across the past 2 weeks
- [ ] Task 2: Add temporary seed button to HomePage (AC: #1)
  - [ ] Add a small "Seed Demo Data" button on HomePage (below existing buttons) visible only during development
  - [ ] Button calls `seedDemoData()` and shows SnackBar on completion
- [ ] Task 3: Run seeding and verify (AC: #1)
  - [ ] Run the app, tap "Seed Demo Data"
  - [ ] Verify in Firebase Console: 12 items across both collections
  - [ ] Verify listing page shows items with thumbnails, badges, dates
  - [ ] Verify at least 2 items show location on details page map
  - [ ] Verify profile page shows items for the seeding user
- [ ] Task 4: Remove seed button after seeding (AC: #1)
  - [ ] Remove the temporary "Seed Demo Data" button from HomePage
  - [ ] Keep `seed_demo_data.dart` in the codebase for reference/re-seeding

## Dev Notes

### Seed Script — lib/seed_demo_data.dart

Create a new file `lib/seed_demo_data.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> seedDemoData() async {
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userId = user.uid;

  // Fetch poster name from users collection
  final userDoc = await firestore.collection('users').doc(userId).get();
  final userData = userDoc.data();
  final posterName = userData != null
      ? '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim()
      : 'Demo User';
  final posterEmail = user.email ?? 'demo@university.edu';

  final now = DateTime.now();

  // 7 Lost items
  final lostItems = [
    {
      'itemName': 'Black Leather Wallet',
      'description': 'Lost near the main library entrance. Contains student ID and bank cards. Brown leather with a small scratch on the front.',
      'imageUrls': ['https://picsum.photos/seed/wallet/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      'location': const GeoPoint(6.9271, 79.8612), // Colombo area
    },
    {
      'itemName': 'Student ID Card',
      'description': 'Lost somewhere between the cafeteria and lecture hall B. Name on card: A. Perera. Please contact if found.',
      'imageUrls': ['https://picsum.photos/seed/studentid/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
    },
    {
      'itemName': 'Sony WH-1000XM4 Headphones',
      'description': 'Black over-ear headphones left in computer lab 3 on the second floor. Has a small sticker on the right ear cup.',
      'imageUrls': ['https://picsum.photos/seed/headphones/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
    },
    {
      'itemName': 'MacBook Charger (USB-C)',
      'description': 'White 67W USB-C charger left plugged in at the study area near the window. Has tape with my name on it.',
      'imageUrls': ['https://picsum.photos/seed/charger/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
    },
    {
      'itemName': 'Car Keys (Toyota)',
      'description': 'Set of car keys with a Toyota fob and a red keychain. Lost in the parking lot near building A.',
      'imageUrls': ['https://picsum.photos/seed/carkeys/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
      'location': const GeoPoint(6.9147, 79.8624), // Nearby campus
    },
    {
      'itemName': 'Blue Umbrella',
      'description': 'Compact blue umbrella with wooden handle. Left in the entrance of the engineering building after the rain.',
      'imageUrls': ['https://picsum.photos/seed/umbrella/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 9))),
    },
    {
      'itemName': 'Prescription Glasses',
      'description': 'Black rectangular frame glasses in a brown case. Very important — cannot see without them. Left in room 204.',
      'imageUrls': ['https://picsum.photos/seed/glasses/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 12))),
    },
  ];

  // 5 Found items
  final foundItems = [
    {
      'itemName': 'Water Bottle (Hydro Flask)',
      'description': 'Found a green 32oz Hydro Flask on the bench outside the sports complex. Has stickers on it.',
      'imageUrls': ['https://picsum.photos/seed/bottle/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1, hours: 5))),
    },
    {
      'itemName': 'Scientific Calculator (Casio)',
      'description': 'Found a Casio fx-991ES PLUS in lecture hall C after the math exam. Has initials "RJ" written on the back.',
      'imageUrls': ['https://picsum.photos/seed/calculator/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 4))),
    },
    {
      'itemName': 'Notebook with Handwritten Notes',
      'description': 'A5 spiral notebook with detailed chemistry notes. Found on a desk in the quiet study zone on the 3rd floor.',
      'imageUrls': ['https://picsum.photos/seed/notebook/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 6))),
    },
    {
      'itemName': 'USB Flash Drive (32GB)',
      'description': 'Black SanDisk flash drive found plugged into a computer in the media lab. Has a red lanyard attached.',
      'imageUrls': ['https://picsum.photos/seed/usb/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 8))),
      'location': const GeoPoint(6.9220, 79.8580), // Another campus point
    },
    {
      'itemName': 'Denim Jacket',
      'description': 'Blue denim jacket size M found draped over a chair in the student lounge. Has a pin on the collar.',
      'imageUrls': ['https://picsum.photos/seed/jacket/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 11))),
    },
  ];

  // Write to Firestore
  final batch = firestore.batch();

  for (final item in lostItems) {
    batch.set(firestore.collection('lost_items').doc(), item);
  }
  for (final item in foundItems) {
    batch.set(firestore.collection('found_items').doc(), item);
  }

  await batch.commit();
}
```

### Temporary Seed Button on HomePage

**Blocking dependency:** Story 0.2 (Fix HomePage nested MaterialApp) MUST be completed before adding this button. The current `HomePage` is a `StatelessWidget` with a nested `MaterialApp`, which causes `ScaffoldMessenger.of(context)` to find the wrong messenger and makes the button unreliable. After Story 0.2 fixes HomePage, the button works correctly.

Add temporarily in `main.dart` inside the `HomePage` Column children, after the last `ElevatedButton` (Found Items / Report Found Item):

```dart
const SizedBox(height: 40.0),
TextButton(
  onPressed: () async {
    // Import at top: import 'seed_demo_data.dart';
    try {
      await seedDemoData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo data seeded successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to seed data: $e')),
        );
      }
    }
  },
  child: const Text(
    'Seed Demo Data (remove before demo)',
    style: TextStyle(fontSize: 12, color: Colors.grey),
  ),
),
```

Add the import at the top of `main.dart`:
```dart
import 'seed_demo_data.dart';
```

**Note on `context.mounted`:** After Story 0.2, if `HomePage` becomes a `StatefulWidget`, use `mounted` (from State) instead of `context.mounted`. If it remains a `StatelessWidget` (just removing the nested `MaterialApp`), `context.mounted` works in Flutter 3.41.5 (Dart 3.11.3).

**Remove this button and import after seeding is complete.** The script file `seed_demo_data.dart` can stay in the codebase.

### Image URLs — Placeholder via picsum.photos

The seed data uses `https://picsum.photos/seed/{keyword}/400/300` which generates unique, deterministic placeholder images based on the seed keyword. These are real images served from the internet — they will display correctly in `Image.network` on the listing and details pages. No Firebase Storage upload needed.

**Note:** These are placeholder images, not actual photos of the items. For a more polished demo, the team could replace these with real photos uploaded via the app's image picker (which stores to Firebase Storage). But placeholder images are sufficient to demonstrate the app's functionality.

### Location GeoPoints

Three items have location GeoPoints set (Colombo area coordinates):
- Black Leather Wallet: `GeoPoint(6.9271, 79.8612)`
- Car Keys: `GeoPoint(6.9147, 79.8624)`
- USB Flash Drive: `GeoPoint(6.9220, 79.8580)`

These coordinates are in the Colombo, Sri Lanka area. Adjust to your campus coordinates if needed. The remaining items have no location field (null) — this tests the conditional map display on the details page.

### Batch Write

Uses `WriteBatch` to write all 12 items in a single atomic operation. This is more efficient than 12 individual `.add()` calls and ensures all-or-nothing semantics.

### userId and Poster Fields

The seed script uses the **currently logged-in user** for all items:
- `userId`: `FirebaseAuth.instance.currentUser!.uid`
- `posterName`: Fetched from the `users` collection (first + last name)
- `posterEmail`: `currentUser.email`

This means all seeded items will appear in the seeding user's "My Posted Items" on the profile page. For the demo, this demonstrates the full flow. If the team wants items from "different" users, they can log in as different accounts and re-run the seed.

### Varied Dates

Items are spread across 12 days in the past using `now.subtract(Duration(days: N))`. This creates a realistic timeline:
- Today to 1 day ago: 2 items
- 2-5 days ago: 3 items
- 6-8 days ago: 3 items
- 9-12 days ago: 4 items

### Critical Rules

- User MUST be logged in before running the seed — `seedDemoData()` checks `currentUser` and returns early if null
- Use `batch.set(doc(), item)` with auto-generated IDs — do NOT hardcode document IDs
- Omit the `location` field entirely for items without location — do NOT set it to `null`. Note: the existing posting pages (`lost_items.dart`, `found_page.dart`) write `'location': null` when no location is picked. Both approaches (missing field and explicit null) result in the same display behavior — `ItemModel.fromFirestore` reads `data['location'] as GeoPoint?` which returns `null` in both cases, and the details page conditionally hides the map when `location == null`
- `createdAt` uses `Timestamp.fromDate()` — NOT `FieldValue.serverTimestamp()` because we need specific past dates
- Remove the seed button from HomePage AFTER seeding — it's a temporary dev tool

### What NOT to Do

- DO NOT upload actual images to Firebase Storage — use URL-based placeholder images
- DO NOT create fake user accounts — use the current authenticated user
- DO NOT hardcode document IDs — let Firestore auto-generate them
- DO NOT leave the seed button in the app for the demo — remove it after seeding
- DO NOT seed more than once without clearing previous data (duplicates will appear)
- DO NOT modify any existing page code beyond the temporary button
- DO NOT use `FieldValue.serverTimestamp()` for createdAt — we need specific past dates for realistic variety

### Files Created/Modified

| File | Action |
|---|---|
| `lib/seed_demo_data.dart` | CREATE — seed script |
| `lib/main.dart` | MODIFY (temporary) — add seed button + import, remove after seeding |

**1 file created, 1 file temporarily modified.**

### Dependencies on Previous Stories

| Story | Dependency | Blocking? |
|---|---|---|
| 0.2 | **Fix HomePage nested MaterialApp** — seed button uses `ScaffoldMessenger.of(context)` which will not work correctly inside the nested `MaterialApp`. Must be fixed first. | **YES — hard blocker for seed button** |
| 1.1 | `ItemModel` fields define what data to seed (though seed doesn't import ItemModel) | No — just field name reference |
| 1.2 | The `userId`, `posterName`, `posterEmail`, `createdAt` fields must be the ones the app reads | No — just field name reference |

### Previous Story Intelligence

- Story 1.2 defines the exact Firestore field names: `userId`, `posterName`, `posterEmail`, `createdAt` — seed data uses these exact same camelCase names
- Story 2.1 fetches items with `.orderBy('createdAt', descending: true).limit(50)` — seeded items with `createdAt` Timestamps will appear correctly sorted
- Story 3.1 shows location on map when `location` GeoPoint exists — seeded items with GeoPoints will display maps
- Story 4.1 queries items by `userId` — all seeded items use current user's UID so they appear in profile history

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.2]
- [Source: _bmad-output/planning-artifacts/architecture.md#Gap Analysis — Pre-demo data seeding]
- [Source: _bmad-output/planning-artifacts/architecture.md#Team Assignments — Member 7: demo data seeding]
- [Source: _bmad-output/planning-artifacts/prd.md#FR6 — realistic demo content]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
