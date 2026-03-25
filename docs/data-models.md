# Data Models: Lost and Found

## Overview

The app uses **Cloud Firestore** (NoSQL document database) with 3 collections. There are no Dart model classes — data is read and written as raw `Map<String, dynamic>` throughout the codebase.

## Firestore Collections

### `users`

User profile data created during signup, keyed by Firebase Auth UID.

| Field | Type | Source | Description |
|---|---|---|---|
| `uid` | `string` | Auth | Firebase Auth user ID (also the document ID) |
| `email` | `string` | Auth | User's email address |
| `firstName` | `string` | SignUp form | User's first name |
| `lastName` | `string` | SignUp form | User's last name |
| `phone_number` | `string` | Profile edit | Phone number (added via profile page only) |

**Created in:** `signuppage.dart` (`usersCollection.doc(uid).set({...})`)
**Read in:** `profile_page.dart` (`collection('users').doc(_userId).get()`)
**Updated in:** `profile_page.dart` (`collection('users').doc(_userId).update({...})`)

**Notes:**
- Document ID = Firebase Auth UID
- `phone_number` uses snake_case while other fields use camelCase (inconsistent naming)
- `phone_number` is not set during signup — ProfilePage reads it, which may cause null errors if the field doesn't exist

---

### `lost_items`

Lost item reports. Auto-generated document IDs.

| Field | Type | Description |
|---|---|---|
| `itemName` | `string` | Name of the lost item |
| `description` | `string` | Detailed description (up to 5 lines in UI) |
| `location` | `GeoPoint?` | Latitude/longitude where item was lost (nullable) |
| `imageUrls` | `array<string>` | Firebase Storage download URLs for uploaded images |

**Created in:** `lost_items.dart` (`firestore.collection('lost_items').add({...})`)
**Read in:** Nowhere — no listing/search functionality exists

**Notes:**
- No `userId` field — items are not associated with the user who posted them
- No `timestamp`/`createdAt` field
- No `status` field (e.g., resolved/open)
- Location is nullable — can post without location
- Images are optional — can post with empty `imageUrls` array

---

### `found_items`

Found item reports. Identical structure to `lost_items`.

| Field | Type | Description |
|---|---|---|
| `itemName` | `string` | Name of the found item |
| `description` | `string` | Detailed description |
| `location` | `GeoPoint?` | Latitude/longitude where item was found (nullable) |
| `imageUrls` | `array<string>` | Firebase Storage download URLs |

**Created in:** `found_page.dart` (`firestore.collection('found_items').add({...})`)
**Read in:** Nowhere — no listing/search functionality exists

---

## Firebase Storage Structure

```
Firebase Storage Root
├── lost_item_images/
│   ├── {millisecondsSinceEpoch}.jpg
│   └── ...
└── found_item_images/
    ├── {millisecondsSinceEpoch}.jpg
    └── ...
```

**Naming convention:** `DateTime.now().millisecondsSinceEpoch.toString()` + `.jpg`

**Risk:** If two users upload images at the same millisecond, filenames will collide and one image will be overwritten.

## Entity Relationship Diagram

```
┌──────────┐
│  users   │
│──────────│
│ uid (PK) │       ┌─────────────┐       ┌──────────────┐
│ email    │       │ lost_items  │       │ found_items  │
│ firstName│       │─────────────│       │──────────────│
│ lastName │       │ itemName    │       │ itemName     │
│ phone_   │       │ description │       │ description  │
│  number  │       │ location    │       │ location     │
└──────────┘       │ imageUrls[] │       │ imageUrls[]  │
     ║             └─────────────┘       └──────────────┘
     ║
     ╚══ No foreign key relationship exists between
         users and items (items have no userId field)
```

## Data Flow

### Write Flow (Post Item)
1. User fills form (itemName, description)
2. User optionally picks location on map or auto-detects GPS
3. User optionally picks images from gallery
4. On "Post" tap:
   - Each image uploaded to Firebase Storage sequentially
   - Download URLs collected into array
   - Single Firestore document created with all fields
5. Success/failure SnackBar shown

### Read Flow (Profile)
1. `FirebaseAuth.instance.currentUser` → get UID
2. `Firestore.collection('users').doc(uid).get()` → get user data
3. Populate form controllers with fetched data
4. User edits and taps save → `doc(uid).update({...})`
