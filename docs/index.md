# Project Documentation Index

> Generated: 2026-03-23 | Scan Level: Exhaustive | Workflow: Initial Scan (Revised)

## Project Overview

- **Type:** Monolith (single Flutter codebase)
- **Academic:** University of Plymouth, PUSL2023 Mobile Application Development, Group 147 (7 members)
- **Primary Language:** Dart (Flutter SDK >=3.3.0)
- **Architecture:** Flat page-based, direct Firebase SDK calls, setState() state management
- **Firebase Project:** `lostfoundapp-1e774`

## Quick Reference

- **Framework:** Flutter (cross-platform mobile)
- **Backend:** Firebase (Auth + Firestore + Storage)
- **Entry Point:** `lib/main.dart` → `main()` → Firebase init → `MyApp()`
- **Architecture Pattern:** Stateful widgets with direct Firebase calls (no layering)
- **Platforms:** Android, iOS, macOS, Web (Linux/Windows scaffolded but no Firebase config)

## Key Project Context

- This is a **university coursework project** with a proposal defining required features
- Several proposed features (item listing, search, item details, contact poster) are **NOT yet implemented**
- Final report required: max 3,000 words, PDF named `Group_147_Final_Report.pdf`
- Report must include: GitHub commit history, source code link (Plymouth OneDrive)

## Generated Documentation

- [Project Overview](./project-overview.md) — Academic context, proposal summary, implementation status, tech stack
- [Architecture](./architecture.md) — Gap analysis vs proposal, navigation flow, auth flow, data architecture
- [Data Models](./data-models.md) — Firestore collections schema, Storage structure, entity relationships
- [Component Inventory](./component-inventory.md) — All widgets, UI patterns, assets, permissions, theme
- [Source Tree Analysis](./source-tree-analysis.md) — Annotated directory tree, critical folders, entry points
- [Development Guide](./development-guide.md) — Prerequisites, setup, build/run/test commands, known issues

## Project Reference Documents

- [Project Proposal](./proposal.md) — Full project proposal with problem definition, scope, features, wireframes
- [Final Report Guidelines](./Guidelines.md) — Report structure, style requirements, deliverable format

## Existing Documentation

- [README.md](../lost_and_found/README.md) — Default Flutter boilerplate (no project-specific content)

## Getting Started

1. Ensure Flutter SDK >=3.3.0 is installed
2. Run `cd lost_and_found && flutter pub get`
3. Configure Google Maps API key for your target platform
4. Run `flutter run` on a connected device or emulator
5. Sign up with email/password to create an account
6. Use the app to report lost or found items with location and photos
