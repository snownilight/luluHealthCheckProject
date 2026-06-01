# 🐾 Pet Health Tracker - Active Status

* **Current Active Task**: `PET-010` (Implement WebSocket (STOMP) server for real-time status push)
* **Status**: Completed
* **Plan**:
  - [x] Enable WebSocket Message Broker configuration (`/topic`)
  - [x] Setup STOMP endpoint `/ws-pet`
  - [x] Publish the latest Redis status to `/topic/status` upon Kafka event processing

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

---

## ⚙️ Key Technical Stack & Preferences
* **Java 21 / Spring Boot 3.2.5**
* **MyBatis (XML-configured)** instead of Spring Data JPA
* **MariaDB** for historical records
* **Kafka** (topic: `pet-events`) for asynchronous event streams
* **Redis** (keyspace notifications enabled) for active timer caching
