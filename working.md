# 🐾 Pet Health Tracker - Active Status

* **Current Active Task**: `PET-015` (Implement WebSocket Connection & Real-time Home Dashboard State UI)
* **Status**: Completed
* **Plan**:
  - [x] Implement resilient WebSocket service (with automatic reconnect logic)
  - [x] Create micro-animations for updating values (e.g., water glass filling up)
  - [x] Show active countdown/progress timers for feeding/drinking status

---

## 🟢 Completed Tasks
* `PET-001` (Done): Environment/Architecture docs setup.
* `PET-002` (Done): Database Schema & MyBatis Mapper Mapping (Refactored from JPA to MyBatis XML; table structures auto-initialized via `schema.sql`).
* `PET-003` (Done): Docker Compose setup (MariaDB, Redis with Ex notify, Kafka KRaft).
* `PET-004` (Done): Configure Kafka Producer & Care Event API endpoints (validated DTO, serialization paths corrected, REST API publishes events, integration test passed).
* `PET-005` (Done): Configure Redis Connection & Current State Machine Hash (Configured Lettuce pool, custom JSON RedisTemplate serialization, and RedisStateService wrapper).
* `PET-006` (Done): Configure Kafka Consumer for Care Events (Implemented consumer with multi-event routing, Redis status updater, and food/water safety timers).
* `PET-007` (Done): Implement Redis Key Expiration (TTL) Listener for Dehydration Alert (Configured listener container, registered keyspace events listener, and integrated notification service stub).
* `PET-008` (Done): Implement Batch DB Persistence (MariaDB Write-behind) (Designed thread-safe queue buffer, transactional persistence service, and scheduled flushing with rollback recovery).
* `PET-009` (Done): Configure Caffeine L1 Cache for Weight/Health Trend endpoints (Configured CacheConfig with Caffeine specs, defined getWeeklyWeightTrend / getMonthlyDailySummary trends endpoints, and implemented cache eviction on batch persistence).
* `PET-010` (Done): Implement WebSocket (STOMP) server for real-time status push (Configured WebSocketConfig with STOMP endpoints, registered `/ws-pet` and broker `/topic`, and integrated SimpMessagingTemplate status publishing to `/topic/status` upon event ingestion).
* `PET-011` (Done): Configure FCM (Firebase Cloud Messaging) Service for Push Notifications (Added firebase-admin dependency, implemented FirebaseConfig with fallback mock mode, and updated NotificationService to push alerts/log payload).
* `PET-012` (Done): Initialize Flutter Project & configure dependencies (Created pubspec.yaml with State Management/Riverpod, Charts, WebSocket/Stomp clients, HTTP, and initialized lib structure under frontend/).
* `PET-013` (Done): Implement Flutter UI Base Theme, Layout & Navigation (Designed AppTheme with curated warm color schemes for light/dark modes, implemented responsive MainLayout utilizing BottomNavigationBar and NavigationRail, and configured main entry routing).
* `PET-014` (Done): Implement Care Timeline (Digital Contact Book) UI (Designed timeline layout with custom category icons, implemented a modal sheet for logging events with double validation, and added historical GET api to backend).
* `PET-015` (Done): Implement WebSocket Connection & Real-time Home Dashboard State UI (Connected Flutter Stomp client to the backend WebSocket broker, wrapped status updates in a global Riverpod provider, and updated the dashboard UI with live progress indicators and alerts).

---

## ⚙️ Key Technical Stack & Preferences
* **Java 21 / Spring Boot 3.2.5**
* **MyBatis (XML-configured)** instead of Spring Data JPA
* **MariaDB** for historical records
* **Kafka** (topic: `pet-events`) for asynchronous event streams
* **Redis** (keyspace notifications enabled) for active timer caching
