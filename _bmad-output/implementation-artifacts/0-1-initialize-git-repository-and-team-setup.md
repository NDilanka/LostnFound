# Story 0.1: Initialize Git Repository and Team Setup

Status: ready-for-dev

## Story

As a **team member**,
I want the project under version control with GitHub access for all 7 members,
so that individual commits are tracked for grading (10% of coursework).

## Acceptance Criteria

1. **Given** the project exists at `lost_and_found/`
   **When** git is initialized with proper `.gitignore`
   **Then** `build/`, `.dart_tool/`, `ios/Pods/`, `.env` are excluded from tracking
   **And** the repository is pushed to GitHub
   **And** all 7 team members are invited as collaborators

## Tasks / Subtasks

- [ ] Task 1: Update .gitignore (AC: #1)
  - [ ] Add `.metadata` to .gitignore (file exists at root, currently not ignored)
  - [ ] Add `ios/Pods/` to .gitignore (NOT currently covered — verified by grep)
  - [ ] Verify `build/`, `.dart_tool/` are already covered (they are)
  - [ ] Add `*.env` entry (not present yet, for future safety)
  - [ ] DO NOT add `firebase_options.dart` or `google-services.json` — these are client-side Firebase configs that are normal to commit
- [ ] Task 2: Initialize git repository (AC: #1)
  - [ ] Run `git init` in `D:/Naveen/group147/lost_and_found/`
  - [ ] Run `git branch -M main` to ensure branch is named `main` (Windows git may default to `master`)
  - [ ] Run `git add .` to stage all files (`.gitignore` will exclude build artifacts — expect this to take a moment due to ~800MB build/ exclusion)
  - [ ] Run `git commit -m "Initial commit: Lost and Found campus app with Firebase auth, posting, and web support"`
- [ ] Task 3: Create GitHub repository and push (AC: #1)
  - [ ] Create new repository on GitHub (public or private per team preference)
  - [ ] Add remote: `git remote add origin <github-url>`
  - [ ] Push: `git push -u origin main`
- [ ] Task 4: Invite team collaborators (AC: #1)
  - [ ] Go to GitHub repo → Settings → Collaborators
  - [ ] Invite all 7 team members by GitHub username or email
  - [ ] Verify each member can clone and push

## Dev Notes

### Critical Context

- **Git is NOT initialized** — neither at `lost_and_found/` nor parent `group147/` level
- **Initialize git INSIDE `lost_and_found/`** — this is the Flutter project root, not the parent directory which contains BMAD artifacts
- The parent `D:/Naveen/group147/` contains `_bmad/`, `_bmad-output/`, `docs/`, `.claude/` — these are planning artifacts, NOT part of the Flutter source code
- **Git user already configured globally**: user "Ndilanka" is set up in git config
- **Existing `.gitignore` covers most entries** — `build/`, `.dart_tool/`, `.idea/`, `*.iml`, Android debug/profile/release paths
- **Missing from .gitignore:** `.metadata`, `ios/Pods/`, `*.env` — these must be added
- **Backup directory exists** at `D:/Naveen/group147/lost_and_found_backup/` (962MB) — this is OUTSIDE the git root and will NOT be part of the repo. Do not delete it; it's the safety backup from the package update session.

### What NOT to Do

- DO NOT initialize git at the parent `D:/Naveen/group147/` level — only inside `lost_and_found/`
- DO NOT add `lib/firebase_options.dart` to `.gitignore` — these are client-side Firebase keys, normal to commit [Source: project-context.md, Security Gotchas section]
- DO NOT add `android/app/google-services.json` to `.gitignore` — same reason
- DO NOT run `flutter pub upgrade` — use pinned versions from existing `pubspec.lock`
- DO NOT modify any Dart source code — this story is git setup only

### .gitignore Additions

Add these lines to the existing `.gitignore`:

```
# Additional entries
.metadata
*.env
ios/Pods/
```

### Build Directory Warning

The `build/` directory is ~800MB. It's already in `.gitignore` so it won't be committed. `git add .` may take a moment as git scans and excludes this large directory — this is normal.

### Commit Message Format

Per Architecture doc: "Commit messages must be descriptive (shown in final report): `Add item listing page with Firestore query` — NOT `wip` or `fix`"

Format: `Verb + what changed`

### Academic Requirement

Individual commits are **10% of coursework grade**. Each of the 7 team members needs visible, meaningful commits. This story creates the repo; subsequent stories should be committed by the team member assigned to each story. [Source: PRD, Project Constraints; Architecture, Suggested Team Assignment]

### Project Structure Notes

- Git repo root: `D:/Naveen/group147/lost_and_found/`
- Flutter SDK: `C:/flutter/bin/flutter` (3.41.5)
- Platform: Windows 11, bash shell
- No CI/CD pipeline — manual builds only

### References

- [Source: _bmad-output/planning-artifacts/architecture.md#Gap Analysis - AR1]
- [Source: _bmad-output/planning-artifacts/architecture.md#Implementation Handoff - Step 0]
- [Source: _bmad-output/planning-artifacts/prd.md#Project Constraints]
- [Source: _bmad-output/project-context.md#Development Workflow Rules - Git section]
- [Source: _bmad-output/planning-artifacts/epics.md#Story 0.1]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
