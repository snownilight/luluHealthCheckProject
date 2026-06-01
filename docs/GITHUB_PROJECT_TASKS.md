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

### ⬜ `PET-008`: Implement Batch DB Persistence (MariaDB Write-behind)
*   **Description**: Buffer incoming logs processed by the Kafka Consumer and batch persist them to MariaDB to minimize DB I/O.
*   **Checklist**:
    - [ ] Design an in-memory buffer or use Kafka batch consumers for persistence
    - [ ] Persist care logs, weekly weight logs, and calculate daily summaries
    - [ ] Verify transactional safety and rollback on DB failure

### ⬜ `PET-009`: Configure Caffeine L1 Cache for Weight/Health Trend endpoints
*   **Description**: Configure Caffeine Cache to cache history statistics (e.g., last 12 weeks of weight logs and monthly daily summaries) for faster API responses.
*   **Checklist**:
    - [ ] Enable Spring Cache annotations (`@Cacheable`, `@CacheEvict`)
    - [ ] Configure cache-specific eviction rules upon new logs ingestion
    - [ ] Write test proving cached data is returned directly on second requests

---

## 📋 Phase 3: Real-Time Sync & Notifications

### ⬜ `PET-010`: Implement WebSocket (STOMP) server for real-time status push
*   **Description**: Setup a WebSocket message broker to enable real-time UI updates on client apps. Whenever the pet's state changes in Redis, push the update to clients.
*   **Checklist**:
    - [ ] Enable WebSocket Message Broker configuration (`/topic`)
    - [ ] Setup STOMP endpoint `/ws-pet`
    - [ ] Publish the latest Redis status to `/topic/status` upon Kafka event processing

### ⬜ `PET-011`: Configure FCM (Firebase Cloud Messaging) Service for Push Notifications
*   **Description**: Integrate Firebase Admin SDK to push push alerts (e.g., dehydration warnings) to connected Flutter clients. Support mocking notifications during dev.
*   **Checklist**:
    - [ ] Integrate Firebase Admin dependency
    - [ ] Implement `NotificationService` (supports mock logs + real FCM push)
    - [ ] Verify message payloads include custom alert text and icons

---

## 📋 Phase 4: Flutter Mobile App (Frontend)

### ⬜ `PET-012`: Initialize Flutter Project & configure dependencies
*   **Description**: Initialize the Flutter project structure and add core packages (e.g., `riverpod` for state management, `fl_chart` for graphs, `web_socket_channel` for WebSocket, etc.).
*   **Checklist**:
    - [ ] Init Flutter project under `frontend/`
    - [ ] Add dependencies to `pubspec.yaml`
    - [ ] Setup project directories (screens, services, models)

### ⬜ `PET-013`: Implement Flutter UI Base Theme, Layout & Navigation
*   **Description**: Define the styling guidelines, color palette, custom icons, and navigation bar for a premium, warm design experience.
*   **Checklist**:
    - [ ] Choose a premium palette (warm/curated pastel colors, dark mode support)
    - [ ] Design custom icons and navigation routes (Home, Contact Book, Settings)
    - [ ] Implement responsive layout supporting different device sizes

### ⬜ `PET-014`: Implement Care Timeline (Digital Contact Book) UI
*   **Description**: Design the timeline page showing logged activities in chronological order. Allow users to manually log events (feeding, drinking, brushing, walking) with a quick modal sheet.
*   **Checklist**:
    - [ ] Build vertical timeline layout with distinct event icons
    - [ ] Create logging sheets with validation (e.g., numeric input only for weight/water)
    - [ ] Integrate with HTTP API for submitting events

### ⬜ `PET-015`: Implement WebSocket Connection & Real-time Home Dashboard State UI
*   **Description**: Connect the Flutter app to the backend WebSocket broker and bind the incoming messages to dynamic UI widgets (e.g. real-time updating progress bars).
*   **Checklist**:
    - [ ] Implement resilient WebSocket service (with automatic reconnect logic)
    - [ ] Create micro-animations for updating values (e.g., water glass filling up)
    - [ ] Show active countdown/progress timers for feeding/drinking status

### ⬜ `PET-016`: Implement Growth Curve & Health Summary Charts UI
*   **Description**: Use `fl_chart` to render smooth, responsive line graphs for the pet's weekly weight trends and daily food/water intake history.
*   **Checklist**:
    - [ ] Build weekly weight trend line chart (with gradient fills)
    - [ ] Build weekly food vs water bar charts
    - [ ] Fetch data from the Caffeine-cached historical backend endpoints

---

## 📋 Phase 5: End-to-End & Polish

### ⬜ `PET-017`: End-to-End Simulation Tests
*   **Description**: Simulate active days by firing mock HTTP and Kafka events (e.g., drinking events, missed water intervals, weight gains) and verifying that the database stores logs correctly, Redis triggers alarms, and Flutter UI updates instantly.

### ⬜ `PET-018`: Final UI Polish & Transitions
*   **Description**: Add sleek glassmorphism effects, page transition animations, and ensure clean error boundaries and loading indicators across all UI screens.
