# Architecture: Lost and Found Campus Mobile Application

## Overview

This is a **University of Plymouth PUSL2023** group project (Group 147, 7 members). The application follows a **flat, page-based architecture** with no architectural layering. Each page (StatefulWidget) directly calls Firebase SDK methods for authentication, database operations, and file storage. There is no service layer, repository pattern, or dependency injection.

## Gap Analysis: Proposal vs Implementation

The project proposal specifies several features that are **not yet implemented**:

| Missing Feature | Proposal Requirement | Impact |
|---|---|---|
| Item listing/browsing screen | "Display a list of all lost and found items" | Core feature — users cannot see what others posted |
| Search functionality | "Search function based on keywords" | Core feature — no discoverability |
| Item details page | "Complete information about a selected item" | Core feature — no way to view item details |
| Contact the poster | "Contact the person who posted the item" | Core feature — no communication channel |
| Date field on items | "Date when it was lost" | Data completeness — items lack timestamps |
| User-item association | "Items associated with a specific user" | Accountability — items not linked to posters |
| View posted items in profile | "View items they have posted" | Profile completeness — no item history |

## Architecture Diagram (Conceptual)

```
┌──────────────────────────────────────────────────────┐
│                    Flutter App                        │
│                                                      │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────┐  │
│  │ Splash  │ │ SignIn  │ │ SignUp  │ │  HomePage  │  │
│  │ Screen  │→│  Page   │←│  Page   │ │            │  │
│  └─────────┘ └────┬────┘ └─────────┘ └──┬────┬───┘  │
│                   │                      │    │      │
│              ┌────▼────┐           ┌─────▼┐ ┌▼─────┐│
│              │ Profile │           │ Lost ││ │Found ││
│              │  Page   │           │ Page ││ │Page  ││
│              └────┬────┘           └──┬───┘│ └──┬──┘││
│                   │                   │    │    │   ││
└───────────────────┼───────────────────┼────┼────┼───┘│
                    │                   │         │    │
          ┌─────────▼───────────────────▼─────────▼──┐ │
          │              Firebase SDK                 │ │
          │  ┌──────────┐ ┌───────────┐ ┌──────────┐ │ │
          │  │   Auth   │ │ Firestore │ │ Storage  │ │ │
          │  └──────────┘ └───────────┘ └──────────┘ │ │
          └──────────────────────────────────────────┘ │
```

## Navigation Architecture

Uses Flutter's **named route** system defined in `MaterialApp.routes`:

| Route | Widget | Purpose |
|---|---|---|
| `/splash` | `SplashScreen` | App launch → 2s delay → SignIn |
| `/signin` | `SignInPage` | Email/password login |
| `/signup` | `SignUpPage` | User registration |
| `/home` | `HomePage` | Main hub with Lost/Found buttons |
| `/lost` | `LostPage` | Report a lost item |
| `/found` | `FoundPage` | Report a found item |
| `/profile` | `ProfilePage` | View/edit user profile |

**Navigation flow:**
- `SplashScreen` → `SignInPage` (via `pushReplacement`)
- `SignInPage` → `/home` (on success) or `/signup` (link)
- `SignUpPage` → `/signin` (on success)
- `HomePage` → `/lost` or `/found` (via `pushReplacementNamed`)
- Lost/Found/Profile pages have drawer navigation to Home and Profile
- ProfilePage drawer includes Logout → SignInPage

**Issue:** `HomePage` wraps itself in a second `MaterialApp`, creating a nested navigator. This means drawer navigation from Lost/Found pages using named routes may not work correctly when returning to HomePage.

## Authentication Flow

1. App starts → `Firebase.initializeApp()` → Request camera permission → Show SplashScreen
2. SplashScreen auto-navigates to SignInPage after 2 seconds
3. User signs in with email/password via `FirebaseAuth.signInWithEmailAndPassword()`
4. On success, navigate to HomePage
5. No auth state persistence check — app always starts at splash/signin regardless of existing session
6. **Logout** navigates to SignInPage via `Navigator.push` (does not call `FirebaseAuth.signOut()`)

## Data Architecture

See [Data Models](./data-models.md) for full schema.

Three Firestore collections:
- `users` — User profile data, keyed by Firebase Auth UID
- `lost_items` — Lost item reports with location and images
- `found_items` — Found item reports with location and images

## Image Upload Pipeline

1. User selects images via `ImagePicker.pickMultiImage()`
2. Images displayed as 100x100 local previews
3. On post: each image uploaded to Firebase Storage sequentially
4. Path: `{lost|found}_item_images/{millisecondsSinceEpoch}.jpg`
5. Download URLs collected and stored as string array in Firestore document

## Key Architectural Observations

### Code Duplication
`LostPage` and `FoundPage` are **near-identical copies** (~312 lines each). They differ only in:
- Firestore collection name (`lost_items` vs `found_items`)
- Storage path (`lost_item_images/` vs `found_item_images/`)
- AppBar title (`Report Lost Item` vs `Report Found Item`)

### No Separation of Concerns
- All Firebase calls are made directly from widget `State` classes
- No service layer, repository pattern, or models
- No input validation beyond password confirmation match

### Missing Security Patterns
- No auth state listener or route guard — unauthenticated users can access any route via deep links
- Logout does not call `FirebaseAuth.signOut()`
- Lost/found items are not associated with the posting user (no `userId` field)
- No Firestore security rules documented

### State Management
- Pure `setState()` — no global state, no state management library
- Each page manages its own isolated state
- No shared state between pages (user data is fetched independently in ProfilePage)
