---
stepsCompleted: [1, 2, 3, 4]
status: complete
completedAt: '2026-03-24'
totalEpics: 5
totalStories: 15
frCoverage: '35/35'
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/architecture.md'
---

# group147 - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for the Lost and Found Campus Mobile Application, decomposing the requirements from the PRD (35 FRs, 20 NFRs) and Architecture (Epic 0 fixes, implementation sequence, patterns) into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: Users can create an account with first name, last name, email, and password
FR2: Users can sign in with their registered email and password
FR3: Users can sign out and have their session properly terminated
FR4: Users can view their profile information (email, first name, last name, phone number)
FR5: Users can edit their profile information and save changes
FR6: Users can view a list of all items they have personally posted from their profile
FR7: Authenticated users can report a lost item with item name, description, location, date, and photos
FR8: Authenticated users can report a found item with item name, description, location, date, and photos
FR9: Users can upload one or more photos when reporting an item
FR10: Users can tag a location on a map when reporting an item
FR11: Users can auto-detect their current GPS location when reporting an item
FR12: The system records the posting user's identity (userId, name) with each item report
FR13: The system records a timestamp (createdAt) with each item report
FR14: Authenticated users can browse a scrollable feed of all posted items (both lost and found)
FR15: Users can distinguish between lost items and found items in the listing (visual indicator or tab)
FR16: Users can search for items by keyword across item names and descriptions
FR17: The item listing displays thumbnail image, item name, type (lost/found), and posting date for each item
FR18: Items in the listing are sorted by most recent first
FR19: The system limits query results to prevent loading the entire collection at once
FR20: Users can view the full details of any posted item from the listing
FR21: The item details page displays all uploaded photos for the item
FR22: The item details page displays the item description
FR23: The item details page displays the tagged location on a map
FR24: The item details page displays the posting date and time
FR25: The item details page displays the poster's name and contact information
FR26: Users can contact the poster of an item directly from the item details page
FR27: The contact mechanism reveals the poster's email address or launches an email compose action
FR28: The app provides a home screen with clear navigation to lost items and found items functionality
FR29: All content pages provide drawer navigation to Home and Profile at minimum
FR30: The app displays a splash screen on launch before navigating to sign-in
FR31: New pages (item listing, item details) are accessible via named routes
FR32: The system provides feedback messages on successful item posting
FR33: The system provides error messages when operations fail (posting, sign-in, sign-up)
FR34: The item listing displays a meaningful empty state when no items match a search query
FR35: The system handles gracefully when a user has no posted items in their profile history

### NonFunctional Requirements

NFR1: Item listing page loads and displays results within 3 seconds on a standard connection
NFR2: Item posting flow (fill form + upload images + submit) completes within 60 seconds end-to-end
NFR3: Search results update within 2 seconds of user input
NFR4: Image thumbnails in the listing render without blocking scroll performance
NFR5: Firestore queries use .limit() to cap results and .orderBy('createdAt') to avoid full collection scans
NFR6: Image uploads use bytes-based putData() for cross-platform compatibility (no dart:io)
NFR7: Only authenticated users can access item listing, posting, details, and profile pages
NFR8: Users can only edit their own profile data
NFR9: Firebase Auth manages all authentication — no custom password storage
NFR10: Item posts include the authenticated user's UID — preventing anonymous posting
NFR11: Firebase Storage upload paths are organized to prevent filename collisions
NFR12: All interactive elements meet Material Design minimum touch target size (48dp)
NFR13: Text maintains sufficient contrast ratio against backgrounds for readability
NFR14: Form fields include descriptive labels (not placeholder-only)
NFR15: Loading states display visual indicators (CircularProgressIndicator) during async operations
NFR16: Error and success feedback uses SnackBar messages consistently across all pages
NFR17: The app builds and runs without errors on Chrome (web) and Android
NFR18: flutter analyze passes with zero errors (warnings acceptable)
NFR19: All TextEditingControllers are properly disposed to prevent memory leaks
NFR20: The app handles network failures gracefully with user-facing error messages rather than crashes

### Additional Requirements

From Architecture document:
- AR1: Initialize git repository with .gitignore, push to GitHub, invite all 7 team members (commits = 10% of grade)
- AR2: Fix HomePage nested MaterialApp — return Scaffold instead (navigation blocker)
- AR3: Add dispose() to LostPage, FoundPage, SignInPage, SignUpPage (memory leak fix)
- AR4: Implement FirebaseAuth.instance.signOut() in ProfilePage logout (FR3)
- AR5: Add url_launcher ^6.2.0 to pubspec.yaml for contact poster feature
- AR6: Create ItemModel class in lib/models/item_model.dart with fromFirestore() factory
- AR7: Add userId, posterName, posterEmail, createdAt fields to LostPage and FoundPage posting logic
- AR8: Fetch user profile (name) in initState of posting pages for posterName field
- AR9: Register new routes /items and /details in MaterialApp.routes in main.dart
- AR10: Update HomePage to add "Browse Items" as primary button, reorder existing buttons
- AR11: Create Firestore composite indexes for orderBy('createdAt') on lost_items and found_items
- AR12: Use null-safe sort for serverTimestamp (createdAt can be null until Firestore syncs)
- AR13: Contact UX: show email in dialog with "Copy Email" + "Open Email App" buttons
- AR14: Seed 10-15 sample items in both collections before demo presentation
- AR15: All new pages use 3-item drawer (Home, Browse Items, Profile)
- AR16: Backward compatibility — new fields nullable, old data shows fallback: posterName ?? 'Unknown poster'

### UX Design Requirements

No UX Design document available. UX patterns are defined in Architecture implementation patterns section (drawer template, tab structure, color badges, image display, loading states).

### FR Coverage Map

| FR | Epic | Description |
|---|---|---|
| FR1 | Existing | User registration |
| FR2 | Existing | User sign-in |
| FR3 | Epic 0 | Sign out with FirebaseAuth.signOut() |
| FR4 | Existing | View profile |
| FR5 | Existing | Edit profile |
| FR6 | Epic 4 | Profile item history |
| FR7 | Epic 1 | Post lost item (enhanced with new fields) |
| FR8 | Epic 1 | Post found item (enhanced with new fields) |
| FR9 | Existing | Upload photos |
| FR10 | Existing | Tag location on map |
| FR11 | Existing | Auto-detect GPS |
| FR12 | Epic 1 | Record poster identity on items |
| FR13 | Epic 1 | Record timestamp on items |
| FR14 | Epic 2 | Browse scrollable item feed |
| FR15 | Epic 2 | Distinguish lost/found (tabs + badges) |
| FR16 | Epic 2 | Search by keyword |
| FR17 | Epic 2 | Listing display (thumbnail, name, type, date) |
| FR18 | Epic 2 | Sort by most recent |
| FR19 | Epic 2 | Limit query results |
| FR20 | Epic 3 | View full item details |
| FR21 | Epic 3 | Display all photos |
| FR22 | Epic 3 | Display description |
| FR23 | Epic 3 | Display location on map |
| FR24 | Epic 3 | Display posting date/time |
| FR25 | Epic 3 | Display poster name/contact |
| FR26 | Epic 3 | Contact poster from details |
| FR27 | Epic 3 | Email mechanism |
| FR28 | Epic 0 + Epic 2 | Home navigation (fix bug + add Browse button) |
| FR29 | Epic 2 + Epic 3 | Drawer on new pages |
| FR30 | Existing | Splash screen |
| FR31 | Epic 2 + Epic 3 | Named routes for new pages |
| FR32 | Existing | Success feedback |
| FR33 | Existing | Error feedback |
| FR34 | Epic 2 | Empty state for search |
| FR35 | Epic 4 | Empty state for profile history |

**Coverage: 35/35 FRs mapped** (13 existing + 22 new across 5 epics)

## Epic List

### Epic 0: Foundation & Team Setup
Establish a stable, bug-free foundation and git-based team collaboration. After this epic, the app runs without known bugs and all 7 team members can contribute via GitHub.
**FRs covered:** FR3, FR28 (fix)
**ARs covered:** AR1, AR2, AR3, AR4, AR5
**NFRs addressed:** NFR17, NFR18, NFR19

### Epic 1: Enhanced Item Posting
Items posted through the app now carry the poster's identity, email, and timestamp. Users see enhanced posting confirmation. This enables all future discovery and contact features.
**FRs covered:** FR7-8 (enhanced), FR12, FR13
**ARs covered:** AR6, AR7, AR8, AR11, AR12, AR16

### Epic 2: Item Discovery
Users can browse all posted items in a tabbed feed (All | Lost | Found), search by keyword, and see thumbnails with item names, types, and dates. HomePage updated with "Browse Items" as primary action.
**FRs covered:** FR14, FR15, FR16, FR17, FR18, FR19, FR28 (update), FR29, FR31, FR34
**ARs covered:** AR9, AR10, AR15
**NFRs addressed:** NFR1, NFR3, NFR4, NFR5

### Epic 3: Item Details & Contact
Users can tap any item to see full details — all photos, description, map location, posting date, and poster info — and contact the poster via email directly from the details page.
**FRs covered:** FR20, FR21, FR22, FR23, FR24, FR25, FR26, FR27, FR29, FR31
**ARs covered:** AR9, AR13, AR15

### Epic 4: Profile Item History & Demo Prep
Users can view all items they've personally posted from their profile page. Pre-demo data seeding ensures the app has realistic content for the presentation.
**FRs covered:** FR6, FR35
**ARs covered:** AR14

---

## Epic 0: Foundation & Team Setup

Establish a stable, bug-free foundation and git-based team collaboration. After this epic, the app runs without known bugs and all 7 team members can contribute via GitHub.

### Story 0.1: Initialize Git Repository and Team Setup

As a **team member**,
I want the project under version control with GitHub access for all 7 members,
So that individual commits are tracked for grading (10% of coursework).

**Acceptance Criteria:**

**Given** the project exists at `lost_and_found/`
**When** git is initialized with proper `.gitignore`
**Then** `build/`, `.dart_tool/`, `ios/Pods/`, `.env` are excluded from tracking
**And** the repository is pushed to GitHub
**And** all 7 team members are invited as collaborators

### Story 0.2: Fix HomePage Nested MaterialApp

As a **user**,
I want the HomePage to work correctly within the app's navigation system,
So that I can navigate to all pages without routing errors.

**Acceptance Criteria:**

**Given** `main.dart` has `HomePage` class returning `MaterialApp`
**When** the developer changes `HomePage.build()` to return `Scaffold` instead of `MaterialApp`
**Then** `Navigator.pushReplacementNamed` works correctly from within HomePage
**And** the existing "Lost Items" and "Found Items" buttons still navigate to `/lost` and `/found`
**And** the app has only ONE `MaterialApp` at the root level

### Story 0.3: Add Controller Disposal to Existing Pages

As a **user**,
I want the app to not leak memory during navigation,
So that the app remains responsive during the demo.

**Acceptance Criteria:**

**Given** `SignInPage`, `SignUpPage`, `LostPage`, and `FoundPage` have `TextEditingController` instances without `dispose()`
**When** a `dispose()` override is added to each page's `State` class
**Then** all `TextEditingController` instances are disposed in the override
**And** `super.dispose()` is called last in every `dispose()` method
**And** `flutter analyze` shows no new warnings related to these files

### Story 0.4: Implement Proper Sign-Out

As a **user**,
I want to properly log out of the app,
So that my session is terminated and another user can sign in.

**Acceptance Criteria:**

**Given** the user is logged in and on the ProfilePage
**When** the user taps "Logout" in the drawer
**Then** `FirebaseAuth.instance.signOut()` is called before navigation
**And** the user is navigated to `/signin` via `pushReplacementNamed`
**And** `FirebaseAuth.instance.currentUser` returns null after sign-out

### Story 0.5: Add url_launcher Package

As a **developer**,
I want `url_launcher` available as a dependency,
So that the contact poster feature can launch email clients.

**Acceptance Criteria:**

**Given** `pubspec.yaml` does not include `url_launcher`
**When** `url_launcher: ^6.2.0` is added to dependencies
**Then** `flutter pub get` succeeds without errors
**And** `flutter analyze` passes with no new errors

---

## Epic 1: Enhanced Item Posting

Items posted through the app now carry the poster's identity, email, and timestamp. This enables all future discovery and contact features.

### Story 1.1: Create ItemModel Class

As a **developer**,
I want a typed model class for item data,
So that all pages read Firestore item documents consistently via `ItemModel.fromFirestore()`.

**Acceptance Criteria:**

**Given** no model class exists for item data
**When** `lib/models/item_model.dart` is created
**Then** `ItemModel` has fields: `id`, `itemName`, `description`, `type` (lost/found), `location` (GeoPoint?), `imageUrls` (List<String>), `userId`, `posterName`, `posterEmail`, `createdAt` (Timestamp?)
**And** `factory ItemModel.fromFirestore(DocumentSnapshot doc, String type)` correctly maps all fields with null-safe access (`data['field'] ?? defaultValue`)
**And** all new fields (`userId`, `posterName`, `posterEmail`, `createdAt`) are nullable for backward compatibility

### Story 1.2: Enhance Item Posting with User Identity and Timestamps

As a **user**,
I want my name, email, and the current time recorded when I post a lost or found item,
So that other users know who posted the item and when.

**Acceptance Criteria:**

**Given** the user is authenticated and on the LostPage or FoundPage
**When** the page loads (`initState`)
**Then** the current user's profile (firstName, lastName) is fetched from the `users` Firestore collection
**And** the poster name is stored locally as `_posterName`

**Given** the user fills in item details and taps "Post"
**When** the Firestore document is created
**Then** the document includes `userId` (current user UID), `posterName` (fetched name), `posterEmail` (current user email), and `createdAt` (`FieldValue.serverTimestamp()`)
**And** both `lost_items.dart` and `found_page.dart` have identical field additions
**And** old documents without these fields still display with fallbacks

---

## Epic 2: Item Discovery

Users can browse all posted items in a tabbed feed, search by keyword, and navigate from the updated HomePage.

### Story 2.1: Create Item Listing Page with Tabbed Feed

As a **user**,
I want to browse all posted lost and found items in a tabbed feed,
So that I can find items that match what I'm looking for.

**Acceptance Criteria:**

**Given** `item_listing_page.dart` is created in `lib/pages/`
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

### Story 2.2: Add Search Functionality to Item Listing

As a **user**,
I want to search for items by keyword,
So that I can quickly find a specific lost or found item.

**Acceptance Criteria:**

**Given** the item listing page is displaying items
**When** the user types a keyword in the search bar above the TabBar
**Then** items are filtered client-side by `itemName` and `description` containing the keyword (case-insensitive)
**And** the filter applies to the currently active tab's data
**And** the search query persists when switching between tabs
**And** search results update within 2 seconds of input
**And** a clear button resets the search

### Story 2.3: Update HomePage Navigation and Register Listing Route

As a **user**,
I want to access the item listing from the home screen,
So that browsing items is the primary app action.

**Acceptance Criteria:**

**Given** the user is on the HomePage
**When** the HomePage is rendered
**Then** "Browse Items" is the first button (primary, orange, full-width)
**And** "Report Lost Item" and "Report Found Item" are secondary buttons below
**And** tapping "Browse Items" navigates to `/items`
**And** the `/items` route is registered in `MaterialApp.routes` in `main.dart`

### Story 2.4: Handle Empty States in Item Listing

As a **user**,
I want to see a helpful message when no items are available,
So that I know the listing is working and what to do next.

**Acceptance Criteria:**

**Given** the listing page has loaded but no items exist
**When** the tab displays
**Then** an empty state message is shown: "No items posted yet"

**Given** the user has searched with no matches
**When** the filtered results are empty
**Then** an empty state message is shown: "No items match your search. Try a different keyword."

---

## Epic 3: Item Details & Contact

Users can view full item details and contact the poster.

### Story 3.1: Create Item Details Page

As a **user**,
I want to see the full details of a posted item,
So that I can determine if it's the item I lost or found.

**Acceptance Criteria:**

**Given** the user taps an item in the listing page
**When** the app navigates to `/details` with the `ItemModel` as argument
**Then** the details page displays: all uploaded photos (scrollable), item name and description, type badge (orange "Lost" / green "Found"), tagged location on a Google Map (if location exists), posting date and time (full format), poster name (or "Unknown poster" if null)
**And** the page has a 3-item drawer (Home, Browse Items, Profile)
**And** the `/details` route is registered in `MaterialApp.routes`
**And** the item data is extracted via `ModalRoute.of(context)!.settings.arguments as ItemModel`

### Story 3.2: Add Contact Poster Feature

As a **user**,
I want to contact the person who posted an item,
So that I can arrange to recover my lost item or return a found item.

**Acceptance Criteria:**

**Given** the user is viewing an item details page with a poster email
**When** the user taps the "Contact Poster" button
**Then** a dialog is displayed showing the poster's email address
**And** the dialog has a "Copy Email" button that copies to clipboard via `Clipboard.setData()`
**And** the dialog has an "Open Email App" button that launches `mailto:` via `url_launcher`
**And** a SnackBar confirms "Email copied to clipboard" when copy is tapped

**Given** the item has no `posterEmail` (old data)
**When** the user views the details
**Then** the "Contact Poster" button is hidden or disabled
**And** a message shows "Contact information not available"

---

## Epic 4: Profile Item History & Demo Prep

Users can view their posted items and the app has demo-ready data.

### Story 4.1: Add Item History to Profile Page

As a **user**,
I want to see all items I've posted from my profile page,
So that I can track my lost and found reports.

**Acceptance Criteria:**

**Given** the user is on the ProfilePage and is authenticated
**When** the profile page loads
**Then** a "My Posted Items" section appears below the existing profile fields
**And** the section queries both `lost_items` and `found_items` where `userId == currentUser.uid`
**And** results are merged, sorted by `createdAt` descending
**And** each item shows: item name, type badge (orange/green), and posting date
**And** the list uses `shrinkWrap: true` + `NeverScrollableScrollPhysics()` inside existing scroll
**And** tapping an item navigates to `/details`

**Given** the user has no posted items
**When** the profile loads
**Then** an informational message is shown: "You haven't posted any items yet"

### Story 4.2: Seed Demo Data

As a **team member preparing for the demo**,
I want realistic sample data in the app,
So that the presentation shows a populated, functional app.

**Acceptance Criteria:**

**Given** the app is ready for demo preparation
**When** 10-15 sample items are created via the app or Firebase Console
**Then** items are distributed across both `lost_items` and `found_items`
**And** items include realistic names (wallet, student ID, headphones, laptop charger, keys, etc.)
**And** items have varied dates and at least one image each
**And** items include `userId`, `posterName`, `posterEmail`, `createdAt` fields
**And** at least 2 items have location GeoPoints set
