# 🐾 Pet Health Tracker - Active Status

* **Current Active Task**: None (Waiting for Assignment)
* **Status**: Idle
* **Plan**:

---

## 🟢 Completed Tasks
* `PET-023` (Done): UI - Preventative Care Card (Implemented `_PreventativeCareCard` with border, custom colors, and conditional dynamic logic based on the pet's water intake level matching the SVG specification).
* `PET-022` (Done): UI - Three-column Grid Cards (Replaced old 2x2 metrics grid with new 3-column horizontal row layout containing 飲水, 進食, 活動 stats matching the SVG style exactly).
* `PET-021` (Done): UI - Real-time Status Card & Custom Cat Painter (Rounded corner `#FFF0DC` card containing "Luna 今天很穩定" text status, "剛剛同步" badge, and a custom cat face illustration using CustomPainter).
* `PET-020` (Done): UI - Greeting & Header Bar (Greeting "早安，Luna 的家人", title "智慧成長觀測站", and right-side translucent notification and custom profile avatar icons matching the SVG layout).
* `PET-019` (Done): UI - Background & Decorative Circles (Cozy Warm Cream background with top-right, center-left, and bottom-right decorative colored circles).
* `PET-017` (Done): End-to-End Simulation Tests.
* `PET-018` (Done): Final UI Polish & Transitions.
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
* `PET-016` (Done): Implement Growth Curve & Health Summary Charts UI (Exposed trend endpoints via ApiService, created TrendsScreen showing curved weight graphs and nutrient comparison double-bar charts using fl_chart, and integrated it into the MainLayout navigation).
* `PET-017` (Done): End-to-End Simulation Tests (Created comprehensive EndToEndSimulationTest verifying mock REST ingestion, simulated Kafka processing, Redis state tracking, and dehydration notification triggers).
* `PET-018` (Done): Final UI Polish & Transitions (Created custom glassmorphism card component with dynamic light/dark opacity borders and BackdropFilter blur, and upgraded HomeScreen dashboard metrics layout).

---

## ⚙️ Key Technical Stack & Preferences
* **Java 21 / Spring Boot 3.2.5**
* **MyBatis (XML-configured)** instead of Spring Data JPA
* **MariaDB** for historical records
* **Kafka** (topic: `pet-events`) for asynchronous event streams
* **Redis** (keyspace notifications enabled) for active timer caching
