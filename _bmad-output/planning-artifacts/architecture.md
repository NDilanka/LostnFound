---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
lastStep: 8
status: 'complete'
completedAt: '2026-03-24'
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/prd-validation-report.md'
  - '_bmad-output/project-context.md'
  - 'docs/data-models.md'
  - 'docs/architecture.md'
  - 'docs/component-inventory.md'
workflowType: 'architecture'
project_name: 'group147'
user_name: 'Navee'
date: '2026-03-24'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements (35 FRs):**
- 6 FRs for user accounts (registration, login, sign-out, profile CRUD, item history)
- 7 FRs for item reporting (lost/found posting with photos, location, timestamps, user association)
- 6 FRs for item discovery (browse feed, distinguish types, search, thumbnail listing, sort, pagination)
- 6 FRs for item details (full view with photos, description, map, date, poster info)
- 2 FRs for user communication (contact poster, email mechanism)
- 4 FRs for navigation (home, drawer, splash, named routes)
- 4 FRs for error handling (success/error feedback, empty states)

**Non-Functional Requirements (20 NFRs):**
- Performance: 3s listing load, 60s posting flow, 2s search, pagination required
- Security: Auth-only access, user-scoped edits, Firebase Auth for all auth
- Accessibility: Material Design touch targets, contrast, labels, loading indicators
- Reliability: Cross-platform builds, zero errors, controller disposal, graceful failures

**Scale & Complexity:**
- Primary domain: Mobile/Web (Flutter cross-platform with Firebase BaaS)
- Complexity level: Low-Medium (CRUD + maps + images, no real-time or complex state)
- Estimated new components: 2 pages, 1 model class, 3 Firestore field additions, 1 search widget, 1 contact action

### Technical Constraints & Dependencies

- **Brownfield:** Maintain existing patterns — `setState()`, direct Firestore calls, named routes, no service layer
- **Platform:** Flutter 3.41.5, Dart SDK >=3.3.0, Firebase (Auth + Firestore + Storage)
- **Cross-platform:** Must work on Chrome (web) and Android. No `dart:io`.
- **New package approved:** `url_launcher: ^6.2.0` for email contact (FR26-27)
- **Data model prerequisite:** `userId`, `createdAt`, `posterName` must be added to item documents before listing/details/profile-history can work
- **Backward compatibility:** New fields are additive and nullable. Existing data is NOT migrated. Display fallbacks: `posterName ?? 'Unknown poster'`, `createdAt ?? 'Date unknown'`.

### Cross-Cutting Concerns

| Concern | Approach |
|---|---|
| User identity propagation | Add `userId`, `posterName`, `createdAt` to post documents in LostPage + FoundPage |
| Authentication gating | Rely on auth flow (no route guards for coursework scope) |
| Cross-platform compatibility | No `dart:io`, use `readAsBytes()` + `MemoryImage` |
| Consistent UI patterns | Follow project-context.md: drawer, loading states, SnackBars |
| Firestore pagination | All listing queries use `.limit(50)` + `.orderBy('createdAt', descending: true)` |

### Key Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Service layer | **No** — maintain direct Firestore calls | Consistency with existing 7 files > architectural purity. Document as known trade-off. |
| Model classes | **Yes, minimal** — single `ItemModel` class | Needed for listing (reads from 2 collections) and passing items between pages. One file, not an overhaul. |
| url_launcher package | **Yes** — add `url_launcher: ^6.2.0` | Required for FR26-27 contact poster. Standard package, full web support, zero risk. |
| Item listing structure | **Tabs** — `All | Lost | Found` | Two separate Firestore queries + client-side merge for All tab. Matches FR15. Simpler than cross-collection query. |
| Search approach | **Client-side filter** | Firestore has no full-text search. Dataset is small (~50-200 items). Client-side filtering is instant for demo. |
| Data migration | **None** — nullable new fields with display fallbacks | Existing data not migrated. `posterName ?? 'Unknown poster'`, `createdAt ?? 'Date unknown'`. |

## Starter Template Evaluation

### Primary Technology Domain

**Flutter Mobile/Web** — brownfield project with established tech stack. No starter template selection needed.

### Existing Foundation (Brownfield)

| Decision | Status | Rule |
|---|---|---|
| Language: Dart (SDK >=3.3.0) | Locked | Cannot change |
| Framework: Flutter 3.41.5 | Locked | Cannot change |
| Backend: Firebase (Auth/Firestore/Storage) | Locked | Cannot change |
| State management: `setState()` | Locked | No Provider/BLoC/Riverpod |
| Navigation: Named routes | Locked | All pages in `MaterialApp.routes` |
| Styling: Material Design, hardcoded colors | Constrained | New pages CAN use shared constants; don't refactor existing pages |
| Project structure: flat `lib/pages/` | Constrained | Add `lib/models/` for MVP; `lib/widgets/`, `lib/utils/` deferred to Phase 2 |
| Firebase access: Direct Firestore calls | Locked | No service layer; maintain direct-call pattern |
| Image handling: `readAsBytes()` + `putData` | Locked | No `dart:io` |
| Linting: `flutter_lints` | Locked | Follow existing `analysis_options.yaml` |
| Data model: `lost_items`, `found_items`, `users` | Evolving | Adding `userId`, `createdAt`, `posterName` fields |

### Package Additions

| Package | Version | Phase | Purpose | Status |
|---|---|---|---|---|
| `url_launcher` | ^6.2.0 | MVP | FR26-27: Contact poster via `mailto:` | Approved |
| `timeago` | ^3.6.0 | Phase 2 | "Posted 2 hours ago" recency badges | Pre-approved |

### Epic 0: Foundation Fixes (Before Feature Work)

Three housekeeping fixes required before any new features. Each assignable to a different team member for individual commit credit.

| Story | Fix | Risk if Skipped |
|---|---|---|
| 0.1 | Fix HomePage: return `Scaffold` instead of nested `MaterialApp` | Navigation bugs — new routes won't be found from HomePage |
| 0.2 | Add `dispose()` to LostPage, FoundPage, SignInPage, SignUpPage | Memory leaks — app slows during demo from accumulated controllers |
| 0.3 | Implement `FirebaseAuth.instance.signOut()` in ProfilePage logout | FR3 incomplete — session persists after "logout" |

### Target File Structure (MVP)

```
lib/
  main.dart                    ← MODIFY: fix HomePage, add new routes
  firebase_options.dart        ← DO NOT TOUCH (generated)
  models/
    item_model.dart            ← NEW: ItemModel with fromFirestore()
  pages/
    splashscreen.dart          ← EXISTING
    signinpage.dart             ← EXISTING (add dispose)
    signuppage.dart             ← EXISTING (add dispose)
    lost_items.dart             ← MODIFY: add userId/createdAt/posterName, add dispose
    found_page.dart             ← MODIFY: add userId/createdAt/posterName, add dispose
    profile_page.dart           ← MODIFY: add item history section
    item_listing_page.dart      ← NEW: Tabbed feed with search (FR14-19)
    item_details_page.dart      ← NEW: Full item view with contact (FR20-27)
```

### New Routes

```dart
// Add to MaterialApp.routes in main.dart:
'/items':   (context) => const ItemListingPage(),
'/details': (context) => const ItemDetailsPage(),
```

**Note:** `ItemDetailsPage` receives item data via `Navigator` arguments, not route parameters.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
1. ItemModel structure with fromFirestore factory — single model for both collections
2. Dual-collection Firestore queries — separate per tab, client-side merge for All
3. Page-to-page data passing via Navigator arguments

**Important Decisions (Shape Architecture):**
4. Contact poster via `mailto:` link with `url_launcher`
5. Search bar above TabBar, filters active tab, query persists across tabs
6. Thumbnails via `Image.network` with placeholder icon

**Deferred Decisions (Post-MVP):**
- Category filter data structure
- Map view item pin clustering
- Image compression implementation
- Infinite scroll pagination

### Data Architecture

**ItemModel Structure:**
```dart
// lib/models/item_model.dart
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

  ItemModel({required this.id, required this.itemName, required this.description,
    required this.type, this.location, required this.imageUrls,
    this.userId, this.posterName, this.posterEmail, this.createdAt});

  factory ItemModel.fromFirestore(DocumentSnapshot doc, String type) {
    final data = doc.data() as Map<String, dynamic>;
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

**Denormalization Decision:** Store `posterName`, `posterEmail`, and `userId` directly in each item document. No secondary lookups. Stale data after profile changes is acceptable — posts record the identity at time of posting.

**Firestore Query Pattern:**
- Lost tab: `collection('lost_items').orderBy('createdAt', descending: true).limit(50)`
- Found tab: `collection('found_items').orderBy('createdAt', descending: true).limit(50)`
- All tab: Fetch both queries, merge into single list, sort client-side by `createdAt`
- Pagination: Deferred. `.limit(50)` per collection (100 max on All tab) is sufficient for campus scale.

**New Fields Added to Item Documents (LostPage + FoundPage):**
```dart
'userId': FirebaseAuth.instance.currentUser?.uid,
'posterName': '$_posterFirstName $_posterLastName',
'posterEmail': FirebaseAuth.instance.currentUser?.email,
'createdAt': FieldValue.serverTimestamp(),
```
Poster name fetched from `users` collection in `initState()`, stored locally.

**Backward Compatibility:** All new fields are nullable. Old documents display: `posterName ?? 'Unknown poster'`, `createdAt` → `'Date unknown'`.

### Authentication & Security

- Get current user: `FirebaseAuth.instance.currentUser`
- Fetch poster name from `users` collection by UID in `initState()` of posting pages
- Store userId + posterName + posterEmail in item document at post time
- Sign-out: `await FirebaseAuth.instance.signOut()` then navigate to `/signin`
- No route guards for coursework scope — rely on auth flow

### Frontend Architecture

**Page-to-Page Data Passing:**
```dart
// Listing → Details:
Navigator.pushNamed(context, '/details', arguments: itemModel);
// In details page:
final item = ModalRoute.of(context)!.settings.arguments as ItemModel;
```

**Search Implementation:**
- Search bar at top of `ItemListingPage`, above `TabBar`
- Filters the active tab's data (Lost tab shows filtered lost items, Found tab shows filtered found items, All tab shows filtered all items)
- Search query persists across tab switches
- Client-side filter: `item.itemName.toLowerCase().contains(query) || item.description.toLowerCase().contains(query)`

**Contact Poster:**
```dart
final Uri emailUri = Uri.parse('mailto:${item.posterEmail}?subject=Lost and Found: ${item.itemName}');
await launchUrl(emailUri);
// Fallback: display email as selectable text if launchUrl fails
```

**Listing Thumbnails:**
- First image from `imageUrls[0]` as 80x80 thumbnail via `Image.network`
- Empty `imageUrls`: show `Icon(Icons.image_not_supported)`
- No `cached_network_image` package — Flutter built-in cache is sufficient

**HomePage Navigation Update:**
- Reorder buttons: **Browse Items** (primary, orange, full-width) → Report Lost Item → Report Found Item
- Browse Items navigates to `/items` (new listing page)
- Matches user journey priority: discover first, report second

### Infrastructure & Deployment

- No CI/CD — manual builds only (coursework scope)
- Git initialization required before development
- Single Firebase project — no dev/staging/prod separation
- Firebase Console for monitoring Firestore/Storage usage

### Implementation Sequence

| Step | Action | Route Changes | Files Modified/Created |
|---|---|---|---|
| 1 | Epic 0: Fix HomePage nested MaterialApp | None | `main.dart` |
| 2 | Epic 0: Add dispose() to 4 pages | None | `signinpage.dart`, `signuppage.dart`, `lost_items.dart`, `found_page.dart` |
| 3 | Epic 0: Implement signOut() | None | `profile_page.dart` |
| 4 | Add `url_launcher` to pubspec | None | `pubspec.yaml` |
| 5 | Create ItemModel | None | `lib/models/item_model.dart` (NEW) |
| 6 | Add new fields to posting | None | `lost_items.dart`, `found_page.dart` |
| 7 | Create ItemListingPage + route + update HomePage | Add `/items` route, reorder HomePage buttons | `item_listing_page.dart` (NEW), `main.dart` |
| 8 | Create ItemDetailsPage + route + wire from listing | Add `/details` route | `item_details_page.dart` (NEW), `main.dart` |
| 9 | Add profile item history | None | `profile_page.dart` |

**Cross-Component Dependencies:**
- ItemModel → used by listing, details, profile history
- New Firestore fields → required by listing, details, profile history
- `url_launcher` → used by details page only
- HomePage update → depends on ItemListingPage existing with `/items` route

## Implementation Patterns & Consistency Rules

### Critical Conflict Points Identified

7 areas where AI agents could make different choices when implementing the new features.

### Naming Patterns

**Firestore Field Naming:**
- Existing: `camelCase` (`itemName`, `description`, `imageUrls`). Exception: `phone_number` (legacy)
- New fields: `camelCase` always (`userId`, `posterName`, `posterEmail`, `createdAt`)
- **Rule:** ALL new Firestore fields use `camelCase`. Never introduce new `snake_case`.

**File Naming:** New files: `snake_case.dart`. Do NOT follow existing violations.

**Route Naming:** `'/lowercase'`, no trailing slash. New: `/items`, `/details`.

### Structure Patterns

**New Page Template (always StatefulWidget):**
Always use `StatefulWidget` for new pages, even if initial implementation appears stateless. Avoids refactoring when state is needed later.

```dart
class NewPage extends StatefulWidget {
  const NewPage({super.key});
  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  @override
  void initState() { super.initState(); /* async init */ }

  @override
  void dispose() {
    // Dispose ALL controllers
    super.dispose(); // ALWAYS last
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Title')),
      drawer: _buildDrawer(),
      body: // page content
    );
  }
}
```

**Standard Drawer Pattern (new pages — 3 items):**
```dart
Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      const DrawerHeader(
        decoration: BoxDecoration(color: Colors.blue),
        child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
      ),
      ListTile(title: const Text('Home'),
        onTap: () => Navigator.pushReplacementNamed(context, '/home')),
      ListTile(title: const Text('Browse Items'),
        onTap: () => Navigator.pushReplacementNamed(context, '/items')),
      ListTile(title: const Text('Profile'),
        onTap: () => Navigator.pushReplacementNamed(context, '/profile')),
    ],
  ),
)
```
- New pages: 3 drawer items (Home, Browse Items, Profile)
- Existing pages: keep current drawers unchanged (2 items)
- Phase 2: extract to `lib/widgets/app_drawer.dart`

**Firestore Read Pattern:**
```dart
Future<void> _fetchItems() async {
  setState(() { _isLoading = true; });
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('collection_name')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    final items = snapshot.docs
        .map((doc) => ItemModel.fromFirestore(doc, 'type'))
        .toList();
    if (mounted) setState(() { _items = items; _isLoading = false; });
  } catch (e) {
    if (mounted) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load items: $e')),
      );
    }
  }
}
```

### Format Patterns

**Date Display:**
- Listing: relative time or short date ("Mar 24, 2026")
- Details: full date+time ("March 24, 2026 at 2:30 PM")
- Null `createdAt`: display "Date unknown"

**Image Display:**
- Listing thumbnail: `Image.network(url, width: 80, height: 80, fit: BoxFit.cover)`
- Details full image: `Image.network(url, fit: BoxFit.contain)` in `SizedBox`
- No image: `Icon(Icons.image_not_supported, size: 40, color: Colors.grey)`

**Lost/Found Visual Indicator:**
- Lost: orange badge — `Color.fromARGB(255, 214, 128, 23)`
- Found: green badge — `Color(0xFF6CB523)`

### Process Patterns

**Error Handling:** Always check `mounted` before `context` after `await`. Use `SnackBar` (2s success, 3s error).

**Loading States:** `_isLoading` boolean + `CircularProgressIndicator` centered. Disable interactive elements during loading.

### Enforcement Guidelines

**All AI Agents MUST:**
1. Follow `project-context.md` (87 rules) as primary authority
2. Use `ItemModel.fromFirestore()` for item data — never raw map access
3. Include `dispose()` in every new StatefulWidget with controllers
4. Check `mounted` before `setState()` in async — no exceptions
5. Add 3-item drawer (Home, Browse, Profile) to every new page
6. Register routes in `main.dart` immediately when creating pages

### Anti-Patterns

| Anti-Pattern | Correct Pattern |
|---|---|
| `dart:io` File usage | `readAsBytes()` + `MemoryImage` |
| Raw `Map<String, dynamic>` for items | `ItemModel.fromFirestore()` |
| `setState()` without mounted check | `if (mounted) setState(...)` |
| Missing `dispose()` | Always dispose, `super.dispose()` last |
| `TextField` for inputs | `TextFormField` for all inputs |
| Nested `MaterialApp` | One `MaterialApp` at root only |
| StatelessWidget for new pages | Always StatefulWidget |
| 2-item drawer on new pages | 3-item drawer (Home, Browse, Profile) |

## Project Structure & Boundaries

### Complete Project Structure (MVP)

```
lost_and_found/
├── lib/
│   ├── main.dart                      ← App entry, MyApp, HomePage, route registration
│   ├── firebase_options.dart          ← DO NOT TOUCH (generated)
│   ├── models/
│   │   └── item_model.dart            ← NEW: ItemModel with fromFirestore()
│   └── pages/
│       ├── splashscreen.dart          ← EXISTING (no changes)
│       ├── signinpage.dart            ← EXISTING (add dispose only)
│       ├── signuppage.dart            ← EXISTING (add dispose only)
│       ├── lost_items.dart            ← MODIFY: add new fields + dispose + fetch user profile
│       ├── found_page.dart            ← MODIFY: add new fields + dispose + fetch user profile
│       ├── profile_page.dart          ← MODIFY: add item history section (flat list with badges)
│       ├── item_listing_page.dart     ← NEW: Tabs (All|Lost|Found) + search + thumbnails
│       └── item_details_page.dart     ← NEW: Full item view + map + contact
├── assets/
│   └── LF_logo.png                    ← EXISTING
├── pubspec.yaml                       ← ADD url_launcher
├── test/
│   └── widget_test.dart               ← DELETE or rewrite
└── web/
    └── index.html                     ← EXISTING (add Maps JS API key when available)
```

### FR-to-File Mapping

| FR | File | Action |
|---|---|---|
| FR1-2 (register/login) | `signinpage.dart`, `signuppage.dart` | Existing — add dispose only |
| FR3 (sign out) | `profile_page.dart` | Epic 0: add `FirebaseAuth.signOut()` |
| FR4-5 (profile view/edit) | `profile_page.dart` | Existing — working |
| FR6 (profile item history) | `profile_page.dart` | MODIFY: flat list with orange/green badges |
| FR7-11 (post lost/found) | `lost_items.dart`, `found_page.dart` | MODIFY: add new fields + fetch user profile |
| FR12-13 (user/timestamp) | `lost_items.dart`, `found_page.dart` | Same modification as FR7-11 |
| FR14-19 (browse/list/search) | `item_listing_page.dart` | NEW page |
| FR20-25 (item details) | `item_details_page.dart` | NEW page |
| FR26-27 (contact poster) | `item_details_page.dart` | Part of details page (url_launcher) |
| FR28 (home navigation) | `main.dart` (HomePage) | MODIFY: add Browse Items button, fix MaterialApp |
| FR29 (drawer) | All new pages | 3-item drawer pattern |
| FR30 (splash) | `splashscreen.dart` | No changes |
| FR31 (named routes) | `main.dart` | ADD `/items` and `/details` routes |
| FR32-35 (feedback/errors) | All pages with Firestore ops | SnackBar pattern |

### Component Boundaries

```
┌─────────────────────────────────────────────────────────┐
│                    main.dart                              │
│  MyApp (routes) + HomePage (navigation hub)              │
│  Routes: /splash /signin /signup /home /lost /found      │
│          /profile /items /details                        │
└────────────┬──────────────────────────────┬──────────────┘
             │                              │
   ┌─────────▼──────────┐      ┌───────────▼───────────┐
   │   Posting Pages     │      │   Discovery Pages     │
   │  lost_items.dart    │      │  item_listing_page    │
   │  found_page.dart    │      │  item_details_page    │
   │  (write to Firestore│      │  (read from Firestore │
   │   + Storage)        │      │   + display)          │
   └─────────┬───────────┘      └───────────┬───────────┘
             │                              │
   ┌─────────▼──────────────────────────────▼───────────┐
   │              models/item_model.dart                  │
   │    Shared model: fromFirestore() factory             │
   │    Used by: listing, details, profile history        │
   └─────────┬──────────────────────────────┬───────────┘
             │                              │
   ┌─────────▼──────────┐      ┌───────────▼───────────┐
   │   Firebase Services │      │    Profile Page        │
   │  (direct calls)     │      │  profile_page.dart     │
   │  Auth + Firestore   │      │  (user info + flat     │
   │  + Storage          │      │   item history list)   │
   └─────────────────────┘      └───────────────────────┘
```

### Data Flow Summary

**Posting Flow (LostPage/FoundPage → Firestore):**
1. initState: fetch user profile (name) from `users` collection
2. User fills form + picks images + tags location
3. Upload images to Storage → collect download URLs
4. Create Firestore doc: itemName, description, location, imageUrls, userId, posterName, posterEmail, createdAt

**Discovery Flow (Firestore → Listing → Details):**
1. Fetch items from both collections → map to `ItemModel.fromFirestore()`
2. Display in tabbed list (All|Lost|Found) with search bar
3. User taps item → navigate to `/details` with `ItemModel` as argument
4. Display full details + contact button (mailto via url_launcher)

**Profile History Flow (Firestore → ProfilePage):**
1. Get current userId from FirebaseAuth
2. Query `lost_items` + `found_items` where `userId == currentUid` (2 queries)
3. Merge results, sort by createdAt
4. Display as flat list below profile fields with orange/green badges
5. `shrinkWrap: true` + `NeverScrollableScrollPhysics()` nested inside existing scroll

## Architecture Validation Results

### Coherence Validation

**Decision Compatibility:** All technology choices (Flutter, Firebase, setState, named routes, url_launcher) are compatible. No version conflicts. ItemModel provides consistent data access across all new pages.

**Pattern Consistency:** Naming conventions (camelCase Firestore, snake_case files), structure patterns (StatefulWidget, 3-item drawer), and process patterns (SnackBar, mounted checks) are internally consistent.

**Structure Alignment:** Project structure supports all decisions — new files in correct locations, routes alongside pages, ItemModel shared across components.

### Requirements Coverage

**Functional Requirements:** 35/35 FRs architecturally supported. Every FR maps to a specific file with a defined action.

**Non-Functional Requirements:** 20/20 NFRs addressed. Performance (pagination, client-side search), security (Firebase Auth), accessibility (Material Design), reliability (dispose, mounted checks).

### Implementation Readiness

**Decision Completeness:** All critical decisions documented with code examples (ItemModel, queries, navigation, contact, drawer).

**Structure Completeness:** Every new file defined. FR-to-file mapping provides exact targets.

**Pattern Completeness:** Page template, drawer pattern, Firestore read pattern, error handling, and anti-patterns table provide comprehensive guidance.

### Gap Analysis

**Critical Gaps:** 0

**Important Gaps:** 5

1. **Firestore composite index** — `orderBy('createdAt')` on `lost_items` and `found_items` requires index creation. Firestore auto-prompts with creation link in debug console.

2. **Git initialization** — Must happen before ANY coding. Story 0.0: `git init`, add `.gitignore`, push to GitHub, invite all 7 team members as collaborators. Individual commits are 10% of coursework grade.

3. **Null-safe sort for serverTimestamp** — `FieldValue.serverTimestamp()` returns null in local doc until Firestore syncs. Sort function MUST use:
```dart
..sort((a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0)
    .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0));
```

4. **Contact UX refinement** — Instead of just `launchUrl(mailto:)`, show email in a dialog with "Copy Email" button (`Clipboard.setData()`) + "Open Email App" button. More polished for demo, no extra package needed.

5. **Pre-demo data seeding** — Before presentation, seed 10-15 realistic sample items in both `lost_items` and `found_items` collections (with photos, locations, varied dates). Empty listing = bad demo.

### Architecture Completeness Checklist

- [x] Project context analyzed with 35 FRs + 20 NFRs
- [x] Scale assessed: Low-Medium (CRUD + maps)
- [x] Technical constraints documented (brownfield, cross-platform)
- [x] Cross-cutting concerns mapped (auth, identity, compatibility, UI)
- [x] Technology stack with locked/constrained/evolving status
- [x] Epic 0 foundation fixes (3 stories + git init)
- [x] Target file structure with FR-to-file mapping
- [x] Core decisions: data model, queries, navigation, search, contact
- [x] Implementation patterns: naming, structure, format, process, drawer
- [x] Anti-patterns table
- [x] Data flow diagrams for posting, discovery, profile history
- [x] Implementation sequence with dependencies
- [x] Gap analysis with 5 important items documented

### Architecture Readiness Assessment

**Overall Status:** READY FOR IMPLEMENTATION

**Confidence Level:** High

**Key Strengths:**
- Every FR has a specific file target and action
- Code examples for all major patterns
- Implementation sequence ordered by dependency
- Backward compatibility addressed (nullable fields, no migration)
- Cross-platform verified (web + Android)
- Party Mode reviews caught 5 additional gaps before they became bugs

**Suggested Team Assignment (for individual commit credit):**

| Member | Assignment | Files |
|---|---|---|
| Member 1 | Git init + fix HomePage MaterialApp | repo setup, main.dart |
| Member 2 | Add dispose to 4 pages | signinpage, signuppage, lost_items, found_page |
| Member 3 | Implement signOut | profile_page |
| Member 4 | Create ItemModel + modify posting pages | models/item_model.dart, lost_items, found_page |
| Member 5 | Create ItemListingPage + route | item_listing_page.dart, main.dart |
| Member 6 | Create ItemDetailsPage + route | item_details_page.dart, main.dart |
| Member 7 | Profile item history + demo data seeding | profile_page, Firestore console |

### Implementation Handoff

**Sequence:**
0. Initialize git, push to GitHub, invite team
1. Epic 0: Foundation fixes (HomePage, dispose, signOut)
2. Add `url_launcher` to pubspec.yaml, run `flutter pub get`
3. Create `lib/models/item_model.dart`
4. Modify LostPage + FoundPage (new fields + fetch user profile)
5. Create ItemListingPage + register `/items` route + update HomePage buttons
6. Create ItemDetailsPage + register `/details` route + wire from listing
7. Modify ProfilePage (item history flat list)
8. Seed sample data for demo
9. Test full demo flow 3+ times
