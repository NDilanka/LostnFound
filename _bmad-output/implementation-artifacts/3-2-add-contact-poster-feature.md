# Story 3.2: Add Contact Poster Feature

Status: ready-for-dev

## Story

As a **user**,
I want to contact the person who posted an item,
so that I can arrange to recover my lost item or return a found item.

## Acceptance Criteria

1. **Given** the user is viewing an item details page with a poster email
   **When** the user taps the "Contact Poster" button
   **Then** a dialog is displayed showing the poster's email address
   **And** the dialog has a "Copy Email" button that copies to clipboard via `Clipboard.setData()`
   **And** the dialog has an "Open Email App" button that launches `mailto:` via `url_launcher`
   **And** a SnackBar confirms "Email copied to clipboard" when copy is tapped

2. **Given** the item has no `posterEmail` (old data)
   **When** the user views the details
   **Then** the "Contact Poster" button is hidden or disabled
   **And** a message shows "Contact information not available"

## Tasks / Subtasks

- [ ] Task 1: Add imports to `item_details_page.dart` (AC: #1)
  - [ ] Add `import 'package:url_launcher/url_launcher.dart';`
  - [ ] Add `import 'package:flutter/services.dart';` (for `Clipboard`)
- [ ] Task 2: Add "Contact Poster" button below poster info (AC: #1, #2)
  - [ ] If `posterEmail` is not null: show an enabled "Contact Poster" `ElevatedButton`
  - [ ] If `posterEmail` is null: the button is absent (AC #2 is already satisfied by the "Contact info not available" text from Story 3.1)
- [ ] Task 3: Implement contact dialog (AC: #1)
  - [ ] On button tap, show `AlertDialog` with poster email, "Copy Email" button, "Open Email App" button
  - [ ] "Copy Email" copies email to clipboard + shows SnackBar confirmation
  - [ ] "Open Email App" launches `mailto:` URI via `launchUrl`
- [ ] Task 4: Verify (AC: #1, #2)
  - [ ] Run `flutter analyze` — no errors
  - [ ] Test: tap "Contact Poster" → dialog shows email
  - [ ] Test: tap "Copy Email" → clipboard + SnackBar
  - [ ] Test: tap "Open Email App" → email app opens (or fails gracefully on web)
  - [ ] Test: item with no posterEmail → no button shown, "Contact info not available" text visible

## Dev Notes

### Changes to item_details_page.dart

This story ONLY modifies `lib/pages/item_details_page.dart` created in Story 3.1. No other files are touched.

### New Imports

Add at the top of `item_details_page.dart`:

```dart
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
```

### Contact Poster Button

Add after the poster email text and before `const SizedBox(height: 32)` in the poster info section. The button is conditionally rendered based on `posterEmail`:

```dart
                  // Poster info (existing from Story 3.1)
                  const Text('Posted by',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(item.posterName ?? 'Unknown poster',
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(item.posterEmail ?? 'Contact info not available',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),

                  // Contact Poster button (NEW)
                  if (item.posterEmail != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showContactDialog(item),
                        icon: const Icon(Icons.email),
                        label: const Text('Contact Poster'),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
```

### Contact Dialog Method

Add as a new method in `_ItemDetailsPageState`:

```dart
void _showContactDialog(ItemModel item) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Contact Poster'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email address:'),
            const SizedBox(height: 8),
            SelectableText(
              item.posterEmail!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: item.posterEmail!));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Copy Email'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: item.posterEmail,
                queryParameters: {
                  'subject': 'Lost and Found: ${item.itemName}',
                },
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open email app'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text('Open Email App'),
          ),
        ],
      );
    },
  );
}
```

### How It Works

1. User taps "Contact Poster" → `_showContactDialog(item)` called
2. `AlertDialog` shows the poster's email as `SelectableText` (user can long-press to select/copy natively too)
3. **"Copy Email"** → `Clipboard.setData()` copies email → closes dialog → shows SnackBar "Email copied to clipboard"
4. **"Open Email App"** → closes dialog → `launchUrl(mailto:...)` opens default email client with pre-filled subject line
5. If `launchUrl` fails (no email client, web browser blocks mailto) → fallback SnackBar "Could not open email app"

### mailto URI Format

Uses the `Uri` constructor (not `Uri.parse`) to safely encode the subject line:
```dart
final Uri emailUri = Uri(
  scheme: 'mailto',
  path: item.posterEmail,
  queryParameters: {'subject': 'Lost and Found: ${item.itemName}'},
);
```

**Why `Uri()` not `Uri.parse()`:** The architecture doc shows `Uri.parse('mailto:...')`, but `Uri.parse` does NOT encode query parameters. Item names containing `&`, `=`, `#`, or `+` (e.g., "Keys & Wallet") would corrupt the URI. The `Uri` constructor with `queryParameters` handles encoding automatically. The subject line is pre-filled with the item name for convenience.

### No posterEmail Case (AC #2)

When `item.posterEmail` is null (old data without the field):
- The "Contact Poster" button is not rendered (`if (item.posterEmail != null)`)
- Story 3.1 already displays "Contact info not available" in grey text below the poster name
- No additional changes needed for this case

### Critical Rules

- Close the dialog (`Navigator.pop(dialogContext)`) BEFORE showing SnackBar or launching URL — prevents SnackBar from appearing behind the dialog
- Use `dialogContext` (from builder) to close dialog, but `context` (from State) for `ScaffoldMessenger` — they are different contexts
- Check `canLaunchUrl` before `launchUrl` — graceful fallback if no email client
- Check `mounted` after async `launchUrl` before using `context` for SnackBar
- Use `SelectableText` for the email in the dialog — users can long-press to select/copy even without tapping the button
- The `!` on `item.posterEmail!` is safe because the button only renders when `posterEmail != null`
- Use `ElevatedButton.icon` for the contact button — matches Material Design with an email icon

### What NOT to Do

- DO NOT add in-app chat or messaging — out of scope
- DO NOT store contact history or log contact attempts
- DO NOT modify the poster info section layout from Story 3.1 (except inserting the button)
- DO NOT add `tel:` phone calling — email only per architecture
- DO NOT show the dialog if `posterEmail` is null — the button shouldn't exist in that case
- DO NOT use `launch()` (deprecated) — use `launchUrl()` (current API)

### url_launcher Dependency

Story 0.5 adds `url_launcher: ^6.2.0` to `pubspec.yaml` and configures Android `<queries>` for `mailto:` intent and iOS `LSApplicationQueriesSchemes`. This story depends on Story 0.5 being completed first.

### Files Modified

| File | Changes |
|---|---|
| `lib/pages/item_details_page.dart` | Add `url_launcher` and `services` imports, "Contact Poster" button, `_showContactDialog` method |

**0 files created, 1 file modified.**

### Dependencies on Previous Stories

| Story | Dependency | Blocking? |
|---|---|---|
| 0.5 | `url_launcher` package must be in `pubspec.yaml` with Android/iOS platform config | YES |
| 3.1 | `item_details_page.dart` must exist with poster info section and `/details` route | YES |

### Previous Story Intelligence

- Story 3.1 creates the details page with poster name + email display — this story adds the interactive contact button below it
- Story 0.5 adds `url_launcher` to pubspec.yaml and configures `AndroidManifest.xml` queries for `mailto:` and `Info.plist` `LSApplicationQueriesSchemes` — required for `launchUrl` to work on Android 11+ and iOS
- The architecture doc (Frontend Architecture section) shows the exact `mailto:` URI format with subject line

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 3.2]
- [Source: _bmad-output/planning-artifacts/architecture.md#Frontend Architecture — Contact Poster code example]
- [Source: _bmad-output/planning-artifacts/architecture.md#Gap Analysis — Contact UX refinement (dialog with Copy + Open)]
- [Source: _bmad-output/planning-artifacts/prd.md#FR26 — Contact poster from details page]
- [Source: _bmad-output/planning-artifacts/prd.md#FR27 — Email mechanism]
- [Source: _bmad-output/implementation-artifacts/3-1-create-item-details-page.md — poster info section baseline]
- [Source: _bmad-output/implementation-artifacts/0-5-add-url-launcher-package.md — url_launcher setup]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
