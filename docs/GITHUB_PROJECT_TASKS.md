# GitHub Projects & Issues Task List

This document summarizes the project tasks that map to the `[PET-XXX]` commit and issue format.

---

## Phase 1: Foundation

### Done

* `PET-001`: Initialized project ground rules and architecture documentation.
* `PET-002`: Implemented MariaDB schema and MyBatis mapper mapping.
* `PET-003`: Added Docker Compose infrastructure for the first backend iteration.

---

## Phase 2: Original Backend Event Architecture

These tasks are completed historical work. Kafka and Redis were later removed from the active architecture in `PET-041` and `PET-042`.

### Done

* `PET-004`: Configured Kafka producer and care event API endpoints.
* `PET-005`: Configured Redis connection and current state hash.
* `PET-006`: Configured Kafka consumer for care events.
* `PET-007`: Implemented Redis key expiration listener for dehydration alerts.
* `PET-008`: Implemented batch database persistence.
* `PET-009`: Configured Caffeine cache for trend endpoints.
* `PET-010`: Implemented STOMP WebSocket server for real-time status updates.
* `PET-011`: Integrated Firebase Cloud Messaging notification service.

---

## Phase 3: Flutter Application

### Done

* `PET-012`: Initialized Flutter project and dependencies.
* `PET-013`: Implemented base theme, responsive layout, and navigation.
* `PET-014`: Implemented care timeline and manual logging flow.
* `PET-015`: Integrated WebSocket connection and real-time dashboard state.
* `PET-016`: Implemented growth curve and health summary charts.
* `PET-017`: Added end-to-end simulation tests.
* `PET-018`: Added final UI polish, transitions, and glassmorphism card styling.

---

## Phase 4: Home UI Refinement

### Done

* `PET-019`: Implemented warm cream background and decorative shapes.
* `PET-020`: Implemented greeting and header bar.
* `PET-021`: Implemented real-time status card and custom cat painter.
* `PET-022`: Replaced metrics grid with a three-column layout.
* `PET-023`: Implemented preventative care card.
* `PET-024`: Implemented care timeline styling.
* `PET-025`: Implemented weight sparkline.
* `PET-026`: Integrated Riverpod and backend care logs.
* `PET-027`: Completed lint, compile, and theme verification.
* `PET-032`: Completed cross-page integration and brightness verification.
* `PET-033`: Added DB indexes and WebSocket reconnection improvements.

---

## Phase 5: Serverless Storage and Repository Abstraction

### Done

* `PET-034`: Added `PetRepository` abstraction and storage dependencies.
* `PET-035`: Implemented Drift / SQLite local storage and `LocalPetRepository`.
* `PET-036`: Implemented Google OAuth, Google Sheets repository, and Drive write permission checks.
* `PET-037`: Implemented storage onboarding screen.
* `PET-038`: Upgraded settings screen for storage switching and spreadsheet naming.
* `PET-039`: Documented native OAuth setup for iOS and Android.
* `PET-040`: Verified Spring Boot backend compatibility through repository mode.

---

## Phase 6: Backend Simplification

### Done

* `PET-041`: Removed Kafka and Redis dependencies and simplified Docker Compose to MariaDB.
* `PET-042`: Refactored backend operations to synchronous database persistence and MyBatis aggregation.
* `PET-043`: Re-implemented dehydration alerts using scheduled database checks.

---

## Phase 7: Cloud Sync Stabilization

### Done

* `PET-044`: Fixed Flutter web sqlite3 wasm version mismatch and verified Google Sheets sync.
* `PET-045`: Fixed Riverpod reactivity when switching storage modes or linking Google Sheets.
* `PET-046`: Added timezone-aware daily statistics, today's homepage timeline filter, Google re-auth screen, and reduced Google Sign-In scope to `drive.file`.

---

## Current Active Work

No active task is assigned. See `working.md` for the current status snapshot.
