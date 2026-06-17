# Pet Health Tracker - Active Status

* **Current Active Task**: `None`
* **Status**: Idle
* **Plan**:
  - [ ] No active work item.

---

## Recently Completed Tasks

* `PET-046` (Done): Implemented timezone-aware daily statistics aggregation in `PetStatusNotifier` based on the user's local timezone. Restricted the homepage care timeline to today's logs, added a warm empty-state placeholder, improved Google Sheets re-authentication on reload, and reduced Google Sign-In scope to `drive.file`.
* `PET-045` (Done): Fixed Riverpod reactivity by watching `storageSettingsProvider` inside `careLogsProvider`. Added storage setting listeners in timeline and trends screens so storage mode changes refresh immediately. Increased homepage timeline limit to 5 logs.
* `PET-044` (Done): Resolved `sqlite3.wasm` version mismatch for Flutter web and verified Google Sheets creation / synchronization after OAuth setup.
* `PET-043` (Done): Replaced Redis expiration alerts with scheduled database-driven dehydration checks.
* `PET-042` (Done): Refactored REST operations to save logs synchronously to MariaDB and aggregate pet status dynamically using MyBatis XML mappers.
* `PET-041` (Done): Removed Spring Kafka and Spring Data Redis dependencies and removed Redis / Kafka containers from Docker Compose.
* `PET-040` (Done): Verified backend compatibility and refactored frontend screens/providers to use the unified `petRepositoryProvider` contract.
* `PET-039` (Done): Documented native OAuth setup for iOS and Android.
* `PET-038` (Done): Upgraded settings screen with dynamic storage switching, Google OAuth status, and custom spreadsheet naming.
* `PET-037` (Done): Implemented storage onboarding for Local SQLite, Create Cloud Sheet, and Link Existing Sheet flows.
* `PET-036` (Done): Implemented Google Sheets integration, OAuth flow, sheet initialization, and Google Drive write capability checks.
* `PET-035` (Done): Implemented Drift / SQLite local storage and offline repository CRUD.
* `PET-034` (Done): Introduced the `PetRepository` abstraction and storage dependencies.

Older completed tasks are tracked in `docs/GITHUB_PROJECT_TASKS.md`.

---

## Current Technical Stack

* **Frontend**: Flutter, Riverpod, Drift / SQLite, Google Sign-In, Google Sheets API, Google Drive API, STOMP WebSocket, `fl_chart`.
* **Backend**: Java 21, Spring Boot 3.2.5, MyBatis XML mappers, MariaDB, Caffeine cache, STOMP WebSocket, Firebase Admin SDK.
* **Infrastructure**: Docker Compose currently runs MariaDB only.
* **Storage modes**: Local SQLite, Google Sheets cloud sync, or Spring Boot server mode.

---

## Notes

* Kafka and Redis were part of the earlier architecture but are no longer active runtime dependencies.
* `github_token.md` is ignored and should remain local-only. Use `github_token.example.md` as the committed reference file.
