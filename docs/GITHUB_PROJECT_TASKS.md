# GitHub Projects & Issues Task List

This document lists all development tasks organized by Phase, mapping directly to our `[PET-XXX]` Git commit ticket format. You can copy and paste these into your GitHub Project board or GitHub Issues.

---

## 📋 Phase 1: Environment & Architecture (Done / In Progress)

### 🟢 `PET-001`: Init Project Ground Rules & Architecture Docs
*   **Description**: Setup the repository, write basic style guidelines (`CLAUDE.md`, `CODE-STYLE.md`, `GIT-COMMIT.md`), and define the architecture document.
*   **Checklist**:
    - [x] Create project files structure
    - [x] Create style guides and architecture schema
    - [x] Push baseline files to `dev` branch

### 🟢 `PET-002`: Database Schema & MyBatis Mapper Mapping
*   **Description**: Define the MariaDB database schema, write `schema.sql`, and map MyBatis mappers (`CareLogMapper`, `DailyHealthSummaryMapper`, `WeightLogMapper`) instead of JPA.
*   **Checklist**:
    - [x] Add Lombok-enabled POJOs
    - [x] Implement MyBatis Mapper interfaces
    - [x] Create schema.sql for table auto-creation
    - [x] Verify compile-time checks

### 🟢 `PET-003`: Docker Compose Configuration for MariaDB, Redis, & Kafka
*   **Description**: Setup the local infrastructure running on Docker (MariaDB, Redis with key expiry notify, Kafka broker in KRaft mode).
*   **Checklist**:
    - [x] Write `docker-compose.yml`
    - [x] Enable Redis key expiry events (`--notify-keyspace-events Ex`)
    - [x] Configure Kafka listener mapping for local host communication

---

## 📋 Phase 2: Backend Core (Event Stream & Cache)

### 🟢 `PET-004`: Configure Kafka Producer & Care Event API endpoints
*   **Description**: Implement the REST API endpoint `POST /api/v1/care-logs` that takes feeding, drinking, weight, activity, and grooming logs, validates them, and produces them into the Kafka `pet-events` topic.
*   **Checklist**:
    - [x] Configure `KafkaTemplate<String, Object>` in Spring Boot
    - [x] Create `CareLogRequest` DTO and API controller
    - [x] Implement event validation (prevent negative/excessive inputs)
    - [x] Write integration test verifying REST controller publishes to Kafka

### 🟢 `PET-005`: Configure Redis Connection & Current State Machine Hash
*   **Description**: Configure Redis connection pool in Spring Boot and define repository/helper classes to read/write the pet's current state (`pet:status:current`).
*   **Checklist**:
    - [x] Define Redis connection properties & configs
    - [x] Implement `RedisStateService` to read/write state hashes
    - [x] Ensure serialization handles DTO models cleanly

### 🟢 `PET-006`: Configure Kafka Consumer for Care Events
*   **Description**: Implement a Kafka Consumer listening to the `pet-events` topic to process incoming events sequentially. It should update the Redis current state hash and refresh health timer keys.
*   **Checklist**:
    - [x] Write `@KafkaListener` consumer service
    - [x] Implement logic to update `pet:status:current` values (e.g. cumulative daily food/water)
    - [x] Implement logic to refresh/set water/food timers (`pet:health:water:timer` / `pet:health:food:timer`)

### 🟢 `PET-007`: Implement Redis Key Expiration (TTL) Listener for Dehydration Alert
*   **Description**: Setup a Redis MessageListener to catch keyspace expiration events and trigger alert workflows when the water/food timer keys expire.
*   **Checklist**:
    - [x] Configure `RedisMessageListenerContainer`
    - [x] Register listener for key expiry events (`__keyevent@0__:expired`)
    - [x] Catch `pet:health:water:timer` expiration and call Notification Service

### 🟢 `PET-008`: Implement Batch DB Persistence (MariaDB Write-behind)
*   **Description**: Buffer incoming logs processed by the Kafka Consumer and batch persist them to MariaDB to minimize DB I/O.
*   **Checklist**:
    - [x] Design an in-memory buffer or use Kafka batch consumers for persistence
    - [x] Persist care logs, weekly weight logs, and calculate daily summaries
    - [x] Verify transactional safety and rollback on DB failure

### 🟢 `PET-009`: Configure Caffeine L1 Cache for Weight/Health Trend endpoints
*   **Description**: Configure Caffeine Cache to cache history statistics (e.g., last 12 weeks of weight logs and monthly daily summaries) for faster API responses.
*   **Checklist**:
    - [x] Enable Spring Cache annotations (`@Cacheable`, `@CacheEvict`)
    - [x] Configure cache-specific eviction rules upon new logs ingestion
    - [x] Write test proving cached data is returned directly on second requests

---

## 📋 Phase 3: Real-Time Sync & Notifications

### 🟢 `PET-010`: Implement WebSocket (STOMP) server for real-time status push
*   **Description**: Setup a WebSocket message broker to enable real-time UI updates on client apps. Whenever the pet's state changes in Redis, push the update to clients.
*   **Checklist**:
    - [x] Enable WebSocket Message Broker configuration (`/topic`)
    - [x] Setup STOMP endpoint `/ws-pet`
    - [x] Publish the latest Redis status to `/topic/status` upon Kafka event processing

### 🟢 `PET-011`: Configure FCM (Firebase Cloud Messaging) Service for Push Notifications
*   **Description**: Integrate Firebase Admin SDK to push push alerts (e.g., dehydration warnings) to connected Flutter clients. Support mocking notifications during dev.
*   **Checklist**:
    - [x] Integrate Firebase Admin dependency
    - [x] Implement `NotificationService` (supports mock logs + real FCM push)
    - [x] Verify message payloads include custom alert text and icons

---

## 📋 Phase 4: Flutter Mobile App (Frontend)

### 🟢 `PET-012`: Initialize Flutter Project & configure dependencies
*   **Description**: Initialize the Flutter project structure and add core packages (e.g., `riverpod` for state management, `fl_chart` for graphs, `web_socket_channel` for WebSocket, etc.).
*   **Checklist**:
    - [x] Init Flutter project under `frontend/`
    - [x] Add dependencies to `pubspec.yaml`
    - [x] Setup project directories (screens, services, models)

### 🟢 `PET-013`: Implement Flutter UI Base Theme, Layout & Navigation
*   **Description**: Define the styling guidelines, color palette, custom icons, and navigation bar for a premium, warm design experience.
*   **Checklist**:
    - [x] Choose a premium palette (warm/curated pastel colors, dark mode support)
    - [x] Design custom icons and navigation routes (Home, Contact Book, Settings)
    - [x] Implement responsive layout supporting different device sizes

### 🟢 `PET-014`: Implement Care Timeline (Digital Contact Book) UI
*   **Description**: Design the timeline page showing logged activities in chronological order. Allow users to manually log events (feeding, drinking, brushing, walking) with a quick modal sheet.
*   **Checklist**:
    - [x] Build vertical timeline layout with distinct event icons
    - [x] Create logging sheets with validation (e.g., numeric input only for weight/water)
    - [x] Integrate with HTTP API for submitting events

### 🟢 `PET-015`: Implement WebSocket Connection & Real-time Home Dashboard State UI
*   **Description**: Connect the Flutter app to the backend WebSocket broker and bind the incoming messages to dynamic UI widgets (e.g. real-time updating progress bars).
*   **Checklist**:
    - [x] Implement resilient WebSocket service (with automatic reconnect logic)
    - [x] Create micro-animations for updating values (e.g., water glass filling up)
    - [x] Show active countdown/progress timers for feeding/drinking status

### 🟢 `PET-016`: Implement Growth Curve & Health Summary Charts UI
*   **Description**: Use `fl_chart` to render smooth, responsive line graphs for the pet's weekly weight trends and daily food/water intake history.
*   **Checklist**:
    - [x] Build weekly weight trend line chart (with gradient fills)
    - [x] Build weekly food vs water bar charts
    - [x] Fetch data from the Caffeine-cached historical backend endpoints

---

## 📋 Phase 5: End-to-End & Polish

### 🟢 `PET-017`: End-to-End Simulation Tests
*   **Description**: Simulate active days by firing mock HTTP and Kafka events (e.g., drinking events, missed water intervals, weight gains) and verifying that the database stores logs correctly, Redis triggers alarms, and Flutter UI updates instantly.
*   **Checklist**:
    - [x] Create comprehensive EndToEndSimulationTest verifying event flows
    - [x] Mock Kafka ingestion and test status increment metrics
    - [x] Trigger Redis key expiration and verify mock dehydration alert notifications

### 🟢 `PET-018`: Final UI Polish & Transitions
*   **Description**: Add sleek glassmorphism effects, page transition animations, and ensure clean error boundaries and loading indicators across all UI screens.
*   **Checklist**:
    - [x] Create custom glassmorphism BackdropFilter container card
    - [x] Restyle HomeScreen dashboard grid to use premium GlassCard widgets

---

## 📋 Phase 6: Serverless Migration & Dual Storage (Phase 2 Upgrade)

### 🟢 `PET-034`: Configure Drift/SQLite & Google OAuth dependencies and define PetRepository
*   **Description**: Add dependencies to `pubspec.yaml` and define `PetRepository` abstract class.
*   **Checklist**:
    - [ ] Add `drift`, `google_sign_in`, and `googleapis` packages
    - [ ] Define abstract `PetRepository` class interface

### 🟢 `PET-035`: Implement Local SQLite Database & LocalPetRepository (Drift)
*   **Description**: Write Drift schema definitions for offline storage and implement `LocalPetRepository`.
*   **Checklist**:
    - [ ] Create Drift table schemas
    - [ ] Implement local CRUD operations matching repository interface

### 🟢 `PET-036`: Configure Google Sign-In, Google Sheets API & Write Permission check
*   **Description**: Implement Google login flow, Google Sheets data mapping, and validation of Editor write permission during linking.
*   **Checklist**:
    - [ ] Integrate Google Sign-in flow and retrieve API token
    - [ ] Implement GoogleSheetsPetRepository CRUD methods
    - [ ] Implement write-permission dry-run validation for option 3

### 🟢 `PET-037`: Implement Database Selection Onboarding Screen (storage_setup_screen.dart)
*   **Description**: Build a clean onboarding screen with three options: Local, Create New Sheet, Link Existing Sheet.
*   **Checklist**:
    - [ ] Create `storage_setup_screen.dart` with three selection cards
    - [ ] Wire up navigation and authentication triggers for each choice

### 🟢 `PET-038`: Upgrade Settings Page (settings_screen.dart) with Onboarding Configuration
*   **Description**: Restyle Settings screen to support switching databases, custom spreadsheet naming, and listing Google accounts.
*   **Checklist**:
    - [ ] Add custom text field for sheet naming
    - [ ] Implement database switching controls and OAuth connect/disconnect buttons

### 🟢 `PET-039`: Mobile Native Platform Configurations (Android & iOS)
*   **Description**: Configure native build files for OAuth credential handshakes.
*   **Checklist**:
    - [ ] Set up SHA-1 and `google-services.json` on Android
    - [ ] Configure `Info.plist` CFBundleURLTypes on iOS

### 🟢 `PET-040`: Spring Boot Server Backend Compatibility Verification
*   **Description**: Ensure original HTTP/WS server implementation remains compatible as a repository mode.
*   **Checklist**:
    - [ ] Validate HTTP/WebSocket repository connection
    - [ ] Complete regression testing on Spring Boot services

### 🟢 `PET-041`: Remove Kafka & Redis dependencies and simplify Docker Compose
*   **Description**: Remove spring-kafka and spring-boot-starter-data-redis dependencies, config classes, and containers.
*   **Checklist**:
    - [ ] Remove dependencies from pom.xml
    - [ ] Delete KafkaProducerConfig.java and RedisConfig.java
    - [ ] Update docker-compose.yml to keep only MariaDB

### 🟢 `PET-042`: Refactor Kafka ingestion & Redis state machine to synchronous DB operations
*   **Description**: Refactor endpoints to read/write from/to MySQL/MariaDB directly and publish real-time notifications via WebSocket.
*   **Checklist**:
    - [ ] Update CareLogController.java to invoke persistence service synchronously
    - [ ] Rewrite pet status endpoint using direct MyBatis aggregation queries
    - [ ] Delete CareLogConsumer.java, CareLogProducer.java, and RedisStateService.java

### 🟢 `PET-043`: Re-implement Dehydration Alerts using Database Query & Spring Scheduling
*   **Description**: Detect water alerts by checking last drinking time dynamically or via scheduling instead of Redis expiration listener.
*   **Checklist**:
    - [ ] Delete RedisKeyExpirationListener.java
    - [ ] Implement query-based dehydration check using @Scheduled
    - [ ] Update unit and integration tests to remove Redis/Kafka dependencies
