# Project Overview: Lost and Found Campus Mobile Application

## Academic Context

- **University:** University of Plymouth
- **Module:** PUSL2023 — Mobile Application Development
- **Batch:** Plymouth Batch 13, 2024/2025 Academic Year
- **Lecturer:** Mr. Diluka Wijesinghe
- **Group:** Group 147 (7 members)
  - Sudira Kasun (10967171)
  - Hasintha Kaluwila (10967316)
  - Pasindu Sankalpa (10967204)
  - K.D.D.V Gunasingha (10967151)
  - RPRM Samarasekara (10967201)
  - L.G.T Vishvika (10967218)
  - G.G.C.M Randika (10965522)

## Executive Summary

Lost and Found is a **campus-focused Flutter mobile application** designed to help university students and staff report and discover lost and found items within the campus. The app allows users to create accounts, post items with descriptions, photos, and GPS-tagged locations on a Google Map, and manage their profile. Firebase serves as the backend for authentication, data storage, and image hosting.

**App Display Name:** "Lost And Found" (iOS), "Hathi App" (internal MaterialApp title)

## Problem Statement (from Proposal)

University campuses are large, busy places where students frequently misplace personal belongings (IDs, wallets, keys, laptops, phones). Currently there is no simple, organized system for reporting lost and found items — students rely on social media, notice boards, or asking friends, which often fails to connect finders with owners. This app provides a centralized platform accessible via smartphone.

## Target Users

- University students
- Academic staff members
- Non-academic staff members
- Campus security staff

## Project Scope

### In Scope (per Proposal)
- User registration and login system
- Posting details about lost items (name, description, location, date, image)
- Posting details about found items
- Browsing and searching for items
- Item details page with full information
- Contact option to communicate with the item poster
- User profile page to manage personal info and view posted items

### Out of Scope (per Proposal)
- GPS tracking of lost items
- Integration with external social media platforms
- Online payment systems
- Support for multiple universities or campuses

## Current Implementation Status

The app has **partial implementation** of the proposed features:

| Proposed Feature | Status | Notes |
|---|---|---|
| User registration | Implemented | Email/password via Firebase Auth |
| User login | Implemented | Email/password sign-in |
| Post lost items | Implemented | Name, description, location, images |
| Post found items | Implemented | Identical structure to lost items |
| Browse/search items | **NOT implemented** | No listing or search screen exists |
| Item details page | **NOT implemented** | No detail view for posted items |
| Contact the poster | **NOT implemented** | No messaging or contact feature |
| User profile | Partially implemented | View/edit fields, but no posted items list |
| Date field on items | **NOT implemented** | Items lack a date/timestamp field |
| Associate items with user | **NOT implemented** | Items have no userId field |

## Final Report Requirements (from Guidelines)

The final deliverable requires a report (max 3,000 words) with:
- Chapter 01: Introduction, existing systems, problem definition, aims, scope
- Chapter 02: Requirements gathering, functional/non-functional requirements, features
- Chapter 03: Use case diagram, high-level diagram, ER diagram, UI screenshots
- Chapter 04: Development methodology, technologies/tools, future implementation
- Chapter 05: Individual contributions, GitHub commit history + link, source code link (Plymouth OneDrive)

Report must be: past tense, third-person, passive voice, no personal pronouns, PDF format named `Group_147_Final_Report.pdf`.

## Tech Stack Summary

| Category | Technology | Version | Notes |
|---|---|---|---|
| Framework | Flutter | SDK >=3.3.0 <4.0.0 | Cross-platform mobile framework |
| Language | Dart | >=3.3.0 <4.0.0 | Primary language |
| Auth | Firebase Auth | 4.x (any) | Email/password authentication |
| Database | Cloud Firestore | 4.16.1 (any) | NoSQL document database |
| Storage | Firebase Storage | (any) | Image file uploads |
| Maps | Google Maps Flutter | 2.6.0 | Interactive map for location tagging |
| Geolocation | Geolocator | 11.0.0 | Device GPS access |
| Image Picker | image_picker | 1.0.7 | Camera/gallery image selection |
| Permissions | permission_handler | 11.3.1 | Runtime permission requests |
| Alt Maps | flutter_map + latlong2 | 6.1.0 / 0.9.1 | Declared but unused in current code |
| Linting | flutter_lints | 3.0.0 | Static analysis rules |

## Architecture Classification

- **Repository Type:** Monolith (single cohesive Flutter codebase)
- **Project Type:** Mobile
- **Architecture Pattern:** Simple stateful widget-based UI with direct Firebase SDK calls (no separation of concerns — no service layer, no repository pattern, no state management library)
- **State Management:** Local `setState()` only (no Provider, BLoC, Riverpod, or similar)
- **Platforms Supported:** Android, iOS, macOS, Web, Linux, Windows (Firebase configured for Android, iOS, macOS, Web only)

## Firebase Project

- **Project ID:** `lostfoundapp-1e774`
- **Android Package:** `com.example.lost_and_found`
- **iOS Bundle ID:** `com.example.lostAndFound`
- **Storage Bucket:** `lostfoundapp-1e774.appspot.com`
- **Analytics:** Enabled on Android

## Links to Detailed Documentation

- [Architecture](./architecture.md)
- [Data Models](./data-models.md)
- [Component Inventory](./component-inventory.md)
- [Source Tree Analysis](./source-tree-analysis.md)
- [Development Guide](./development-guide.md)
