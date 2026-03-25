---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-02b-vision', 'step-02c-executive-summary', 'step-03-success', 'step-04-journeys', 'step-05-domain', 'step-06-innovation-skipped', 'step-07-project-type', 'step-08-scoping', 'step-09-functional', 'step-10-nonfunctional', 'step-11-polish', 'step-12-complete']
status: complete
completedAt: '2026-03-24'
classification:
  projectType: mobile_app
  domain: edtech
  complexity: medium
  projectContext: brownfield
inputDocuments:
  - 'docs/proposal.md'
  - 'docs/Project_guidelines.md'
  - 'docs/Report_Guidelines.md'
  - 'docs/project-overview.md'
  - 'docs/architecture.md'
  - 'docs/data-models.md'
  - 'docs/component-inventory.md'
  - 'docs/source-tree-analysis.md'
  - 'docs/development-guide.md'
  - 'docs/index.md'
  - '_bmad-output/project-context.md'
workflowType: 'prd'
documentCounts:
  briefs: 0
  research: 0
  projectDocs: 10
  projectContext: 1
---

# Product Requirements Document — Lost and Found Campus Mobile Application

**Author:** Navee
**Date:** 2026-03-24

## Executive Summary

University campus communities lack a centralized system for reuniting lost items with their owners. Students and staff currently rely on fragmented methods — social media groups, physical notice boards, word-of-mouth — that fail because the message rarely reaches the right person at the right time. This results in permanently lost personal belongings, wasted time, and unnecessary stress.

The Lost and Found Campus Mobile Application solves this by providing a single, visual, location-aware platform where users report and discover lost and found items using their smartphones. Built with Flutter and Firebase, the app serves students, academic staff, non-academic staff, and campus security at the University of Plymouth.

**Target Users:** University students, academic staff, non-academic staff, campus security staff.

**Current State:** The app has working user registration, login, post lost items, and post found items flows with photo upload and GPS map tagging. Users can create accounts and submit item reports — but cannot yet browse, search, or view posted items, and have no way to contact item posters.

**Scope of this PRD:** This document defines requirements for completing the seven remaining proposal features — item listing/browsing, search, item details, contact poster, date tracking, user-item association, and profile item history — and improving the existing implementation for demo readiness.

### What Makes This Special

Picture this: a student realizes their wallet is missing after a lecture. They open the app, tap "Lost Items," and immediately see a feed of recently found items on campus. There — posted 20 minutes ago — is a photo of their wallet, found in Lecture Hall B, with a map pin showing the exact location. They tap "Contact," message the finder, and collect it within the hour. No posters. No mass WhatsApp messages. No waiting days.

The combination of **photo confirmation + GPS map tagging + direct contact** in a single campus-focused app creates an integrated visual-location-contact workflow. The existing infrastructure (Google Maps, Geolocator, Image Picker, Firebase) already supports this vision — the gap is in the discovery and communication features, not the underlying technology.

**Target experience:** A campus community member can report a lost item in under 60 seconds and find a matching item in under 30 seconds.

## Project Classification

- **Project Type:** Mobile application (Flutter cross-platform — Android, iOS, Web)
- **Domain:** Education technology (university campus utility)
- **Complexity:** Medium — student data handling, multi-platform, location services, no regulatory compliance beyond academic standards
- **Project Context:** Brownfield — existing partially-implemented app with established Firebase backend and working auth/posting flows

### Project Constraints

- Academic coursework: PUSL2023 Mobile Application Development, University of Plymouth
- Team: 7 members with individual GitHub commit requirements (10% of coursework grade)
- Minimum 5 qualifying application pages (login/logout/welcome excluded) — currently at 4
- Must demonstrate: database integration, device features (camera, GPS, maps), polished UI/UX
- Presentation demo required (20% of module grade) — app must run and look good live
- For 1st class: "Fully functional, polished app with excellent UI/UX, innovative use of device features, and robust database integration"

## Success Criteria

### User Success

- A student can report a lost item with photo, description, location, and date in **under 60 seconds**
- A student can browse all posted items (lost and found) and find a relevant item in **under 30 seconds**
- A user can view full item details (photo, description, map location, poster info) from the listing
- A user can contact the poster of an item directly from the item details page
- A user can view all items they've posted from their profile page
- A user can sign out properly and their session is terminated

### Business Success (Academic)

- All 7 proposal-mandated features implemented and functional
- App meets the **5-page minimum** requirement (currently 4, need at least 1 more qualifying page)
- App demonstrates **database integration** (Firestore CRUD — create, read, list, search)
- App demonstrates **device features** (camera, GPS, Google Maps — already working)
- App achieves **"fully functional, polished" standard** per 1st-class rubric criteria
- App runs successfully for **live demo** on device/emulator (20% of module grade)
- All 7 team members have **visible, meaningful GitHub commits**
- Final report completed within 3,000-word limit with all required chapters

### Technical Success

- App builds and runs on Android and Chrome (web) without errors
- Firebase Auth, Firestore, and Storage operations work reliably
- All pages navigate correctly using named routes
- Image upload works cross-platform (mobile and web) using bytes-based upload
- Firestore queries return results with pagination (`.limit()`)
- No memory leaks from undisposed controllers
- `flutter analyze` passes with zero errors (warnings acceptable)

### Measurable Outcomes

| Metric | Target | Measurement |
|---|---|---|
| Qualifying app pages | >= 5 | Count of pages excluding login/logout/welcome |
| Proposal features complete | 7/7 | Feature checklist against proposal |
| Team member commits | 7/7 with meaningful history | GitHub commit log |
| App crash rate during demo | 0 | Live demo execution |
| Item posting flow | < 60 seconds | Timed user flow |
| Item discovery flow | < 30 seconds | Timed user flow |

## User Journeys

### Journey 1: Amara — The Panicked Student (Lost Item, Success Path)

**Persona:** Amara, 2nd-year Computer Science student. Always rushing between lectures with too many things in her hands.

**Opening Scene:** It's 2:30 PM. Amara reaches for her student ID to enter the library and realizes it's gone. She retraces her steps — cafeteria at noon, Lecture Hall B, then the student union. Three buildings. Without her ID, she can't access the lab for her 4 PM session.

**Rising Action:** She opens the Lost and Found app, taps "Report Lost Item," fills in "Student ID Card," describes the blue lanyard, tags the location near Lecture Hall B, and uploads a photo. The whole process takes 45 seconds. She then switches to "Browse Items" and scrolls through recently found items.

**Climax:** Three items down — someone posted a found student ID card 40 minutes ago, with a photo showing *her name*, found in Lecture Hall B, Row 5. The map pin confirms the exact location. She taps "Contact" and sees the finder's name and email.

**Resolution:** Amara emails the finder. They meet at the student union in 15 minutes. She has her ID back before her 4 PM lab.

**Requirements Revealed:** FR7, FR14-19, FR16, FR20-25, FR26-27 — posting, listing, search, details, contact.

---

### Journey 2: Raj — The Good Samaritan (Found Item Path)

**Persona:** Raj, 3rd-year Engineering student. Finds expensive headphones on a bench outside the science building.

**Opening Scene:** Raj picks up the headphones. They're clearly expensive — someone will be looking for them. He has a lecture in 10 minutes and no time to walk to campus security.

**Rising Action:** He opens the app, taps "Report Found Item," snaps a photo, types "Sony headphones, black, found on bench," and the app auto-detects his GPS location. Posts in under 30 seconds.

**Climax:** Someone recognizes the headphones from his post and contacts him to arrange pickup.

**Resolution:** After class, Raj meets the owner. The owner is relieved. Raj feels good — it took almost no effort.

**Requirements Revealed:** FR8-11, FR12-13, FR26-27 — quick posting, GPS auto-detect, contact via email.

---

### Journey 3: Amara — The Unsuccessful Search (Edge Case)

**Persona:** Same Amara. Loses her USB drive somewhere on campus.

**Opening Scene:** She searches "USB drive" and "flash drive" — nothing comes up.

**Rising Action:** She posts a lost item report with a description and approximate area. Checks back every few hours. After two days, still no match.

**Resolution:** The item was never found, but she tried the organized channel first.

**Requirements Revealed:** FR16, FR34, FR35, FR6 — search with no-results handling, empty states, profile history for re-checking.

---

### Journey 4: Mr. Davies — Campus Security (Secondary User)

**Persona:** Mr. Davies, campus security officer at the lost property desk.

**Opening Scene:** A student drops off a found laptop bag. Mr. Davies logs it in his paper notebook as usual.

**Rising Action:** He opens the app, posts the laptop bag as a found item, then browses recent lost item reports to see if anyone reported a missing laptop bag.

**Climax:** He finds a matching lost report from yesterday — posted by a student named Priya. He taps "Contact" and emails her.

**Resolution:** Priya collects her bag within the hour. Far more efficient than the traditional shelf-and-wait approach.

**Requirements Revealed:** FR1-2, FR14-15, FR20, FR26-27 — staff accounts, reverse lookup, contact poster.

---

### Journey Requirements Summary

| Journey | Key Capabilities |
|---|---|
| Amara (Lost - Success) | Item listing, search, item details, contact poster, speed |
| Raj (Found) | Quick posting, GPS auto-detect, photo upload, contact via email |
| Amara (Lost - Failure) | No-results handling, empty states, profile history, date stamps |
| Mr. Davies (Security) | Staff accounts, reverse lookup, power user posting |

## Domain-Specific Requirements

### Privacy & Data Handling
- User email addresses are visible to other users via the contact feature — users should be informed during registration
- Item posts (including photos and locations) are visible to all authenticated users
- No personal data export or deletion mechanism needed for coursework scope
- Firebase security rules should restrict write access to authenticated users only

### Accessibility Considerations
- Follow Material Design defaults for accessible touch targets (48dp minimum)
- Maintain sufficient color contrast on text elements
- Ensure form labels are descriptive for screen reader compatibility

### Campus Context Constraints
- App assumes single-campus deployment (University of Plymouth)
- Map default location should be set to campus coordinates, not `LatLng(0.0, 0.0)`
- Item categories should reflect common campus lost items: ID cards, keys, wallets, electronics, bags, books, clothing

## Mobile App Specific Requirements

### Platform Requirements

| Platform | Status | Target |
|---|---|---|
| Android | Supported | Development & demo via emulator |
| iOS | Supported (code exists) | Cannot build (no macOS available) |
| Web (Chrome) | Supported | Primary development target, verified working |
| macOS/Windows/Linux | Scaffolded | Not targeted |

- **Primary development platform:** Chrome (web) — verified working
- **Demo platform:** Chrome or Android emulator
- **Flutter SDK:** >=3.3.0 <4.0.0 (currently running 3.41.5)

### Device Permissions & Features

| Feature | Plugin | Status | Web Support |
|---|---|---|---|
| Camera / Photo Gallery | `image_picker: ^1.0.7` | Working | Yes (browser file dialog) |
| GPS Location | `geolocator: ^11.0.0` | Working | Yes (browser geolocation API) |
| Google Maps | `google_maps_flutter: ^2.6.0` | Partial (no web API key) | Yes (requires JS API key) |
| Storage (photos) | `firebase_storage: ^11.7.1` | Working | Yes (bytes upload via `putData`) |

### Implementation Considerations

- **State management:** `setState()` only — no Provider, BLoC, or Riverpod
- **Navigation:** Named routes in `MaterialApp.routes` in `main.dart`. New pages must be added there.
- **Firebase:** Direct `FirebaseFirestore.instance` calls from widget State classes. No service layer.
- **Image handling:** Cross-platform `XFile.readAsBytes()` + `MemoryImage`, never `dart:io File`
- **Code duplication:** LostPage and FoundPage are near-identical — build shared components for new features
- **Offline:** Not required. Graceful error messages for no-connectivity.
- **Push notifications / Store compliance:** Out of scope.

## Project Scoping & Phased Development

### MVP Strategy

**Approach:** Completeness-first — implement all 7 proposal-mandated features, then polish for demo quality. "Minimum viable" = all proposal features working.

**Resource:** 7 team members, each needing visible GitHub commits.

### MVP Feature Set (Phase 1) — Proposal Completion

**Must-Have Capabilities (ordered by dependency):**

| # | Feature | Depends On | New Page? | Effort |
|---|---|---|---|---|
| 1 | User-item association | Nothing | No (modify existing) | Small — add `userId`, `createdAt`, `posterName` to post documents |
| 2 | Item listing page | #1 (needs timestamps for sorting) | Yes (qualifying page #5) | Medium — new page with Firestore query, ListView, thumbnails |
| 3 | Search functionality | #2 (needs listing to filter) | No (add to listing page) | Small — client-side keyword filter on item name/description |
| 4 | Item details page | #1 (needs poster info) | Yes (qualifying page #6) | Medium — new page with full photos, map, description, poster info |
| 5 | Contact poster | #4 (accessible from details) | No (button on details page) | Small — launch email via `url_launcher` or show poster email |
| 6 | Fix sign-out | Nothing | No | Tiny — add `FirebaseAuth.instance.signOut()` before navigation |
| 7 | Profile item history | #1 (needs userId on items) | No (modify existing profile) | Small — Firestore query filtered by current userId |

**Page count after MVP:** 6 qualifying pages (Home, Lost, Found, Profile, Item Listing, Item Details) — exceeds 5-page minimum.

### Post-MVP (Phase 2) — Polish & Demo Wow Factor

| Feature | Demo Impact | Effort |
|---|---|---|
| Category filters (tabs: All/Electronics/Keys/ID/etc.) | High | Small |
| Recency badges ("2 hours ago", "Yesterday") | Medium | Tiny |
| Map view of all items (pins on campus map) | Very High | Medium |
| Item status toggle (open/resolved) | Medium | Small |
| Image compression before upload | Low | Small |
| Empty state illustrations | Medium | Small |

### Phase 3 — Vision (Out of Scope per Proposal)

- Push notifications for matching items
- In-app real-time chat between users
- Multi-campus support
- Social media integration
- GPS tracking of items
- Admin dashboard for campus security

### Risk Mitigation

| Risk Category | Risk | Mitigation |
|---|---|---|
| Technical | Maps blank on web (no API key) | Demo on Android emulator, or obtain Maps JS API key |
| Technical | Firestore full collection load | Add `.limit(50)` + `.orderBy('createdAt', descending: true)` |
| Technical | Cross-platform image handling | Already resolved (bytes-based `putData` on web) |
| Academic | Not all 7 features before deadline | Features ordered by dependency — partial completion still yields working app |
| Academic | Team members without commits | Assign specific features per member |
| Academic | App crashes during demo | Test full demo flow 3+ times, have backup screenshots |
| Resource | Fewer contributors than planned | Features 1, 2, 4 are critical path — assign strongest developers there |

## Functional Requirements

### User Account Management

- **FR1:** Users can create an account with first name, last name, email, and password
- **FR2:** Users can sign in with their registered email and password
- **FR3:** Users can sign out and have their session properly terminated
- **FR4:** Users can view their profile information (email, first name, last name, phone number)
- **FR5:** Users can edit their profile information and save changes
- **FR6:** Users can view a list of all items they have personally posted from their profile

### Item Reporting

- **FR7:** Authenticated users can report a lost item with item name, description, location, date, and photos
- **FR8:** Authenticated users can report a found item with item name, description, location, date, and photos
- **FR9:** Users can upload one or more photos when reporting an item
- **FR10:** Users can tag a location on a map when reporting an item
- **FR11:** Users can auto-detect their current GPS location when reporting an item
- **FR12:** The system records the posting user's identity (userId, name) with each item report
- **FR13:** The system records a timestamp (createdAt) with each item report

### Item Discovery

- **FR14:** Authenticated users can browse a scrollable feed of all posted items (both lost and found)
- **FR15:** Users can distinguish between lost items and found items in the listing (visual indicator or tab)
- **FR16:** Users can search for items by keyword across item names and descriptions
- **FR17:** The item listing displays thumbnail image, item name, type (lost/found), and posting date for each item
- **FR18:** Items in the listing are sorted by most recent first
- **FR19:** The system limits query results to prevent loading the entire collection at once

### Item Details

- **FR20:** Users can view the full details of any posted item from the listing
- **FR21:** The item details page displays all uploaded photos for the item
- **FR22:** The item details page displays the item description
- **FR23:** The item details page displays the tagged location on a map
- **FR24:** The item details page displays the posting date and time
- **FR25:** The item details page displays the poster's name and contact information

### User Communication

- **FR26:** Users can contact the poster of an item directly from the item details page
- **FR27:** The contact mechanism reveals the poster's email address or launches an email compose action

### Navigation & App Structure

- **FR28:** The app provides a home screen with clear navigation to lost items and found items functionality
- **FR29:** All content pages provide drawer navigation to Home and Profile at minimum
- **FR30:** The app displays a splash screen on launch before navigating to sign-in
- **FR31:** New pages (item listing, item details) are accessible via named routes

### Error Handling & Feedback

- **FR32:** The system provides feedback messages on successful item posting
- **FR33:** The system provides error messages when operations fail (posting, sign-in, sign-up)
- **FR34:** The item listing displays a meaningful empty state when no items match a search query
- **FR35:** The system handles gracefully when a user has no posted items in their profile history

## Non-Functional Requirements

### Performance

- **NFR1:** Item listing page loads and displays results within 3 seconds on a standard connection
- **NFR2:** Item posting flow (fill form + upload images + submit) completes within 60 seconds end-to-end
- **NFR3:** Search results update within 2 seconds of user input
- **NFR4:** Image thumbnails in the listing render without blocking scroll performance
- **NFR5:** Firestore queries use `.limit()` to cap results and `.orderBy('createdAt')` to avoid full collection scans
- **NFR6:** Image uploads use bytes-based `putData()` for cross-platform compatibility (no `dart:io`)

### Security

- **NFR7:** Only authenticated users can access item listing, posting, details, and profile pages
- **NFR8:** Users can only edit their own profile data
- **NFR9:** Firebase Auth manages all authentication — no custom password storage
- **NFR10:** Item posts include the authenticated user's UID — preventing anonymous posting
- **NFR11:** Firebase Storage upload paths are organized to prevent filename collisions

### Accessibility & UI Quality

- **NFR12:** All interactive elements meet Material Design minimum touch target size (48dp)
- **NFR13:** Text maintains sufficient contrast ratio against backgrounds for readability
- **NFR14:** Form fields include descriptive labels (not placeholder-only)
- **NFR15:** Loading states display visual indicators (CircularProgressIndicator) during async operations
- **NFR16:** Error and success feedback uses SnackBar messages consistently across all pages

### Reliability

- **NFR17:** The app builds and runs without errors on Chrome (web) and Android
- **NFR18:** `flutter analyze` passes with zero errors (warnings acceptable)
- **NFR19:** All TextEditingControllers are properly disposed to prevent memory leaks
- **NFR20:** The app handles network failures gracefully with user-facing error messages rather than crashes
