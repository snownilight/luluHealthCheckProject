# 🐾 Pet Health Tracker - Active Status

* **Current Active Task**: `PET-007` (Implement Redis Key Expiration (TTL) Listener for Dehydration Alert)
* **Status**: Completed
* **Plan**:
  - [x] Configure `RedisMessageListenerContainer`
  - [x] Register listener for key expiry events (`__keyevent@0__:expired`)
  - [x] Catch `pet:health:water:timer` expiration and call Notification Service

---

## 🟢 Completed Tasks
* `PET-001` (Done): Environment/Architecture docs setup.
* `PET-002` (Done): Database Schema & MyBatis Mapper Mapping (Refactored from JPA to MyBatis XML; table structures auto-initialized via `schema.sql`).
* `PET-003` (Done): Docker Compose setup (MariaDB, Redis with Ex notify, Kafka KRaft).
* `PET-004` (Done): Configure Kafka Producer & Care Event API endpoints (validated DTO, serialization paths corrected, REST API publishes events, integration test passed).
* `PET-005` (Done): Configure Redis Connection & Current State Machine Hash (Configured Lettuce pool, custom JSON RedisTemplate serialization, and RedisStateService wrapper).
* `PET-006` (Done): Configure Kafka Consumer for Care Events (Implemented consumer with multi-event routing, Redis status updater, and food/water safety timers).
* `PET-007` (Done): Implement Redis Key Expiration (TTL) Listener for Dehydration Alert (Configured listener container, registered keyspace events listener, and integrated notification service stub).

---

## ⚙️ Key Technical Stack & Preferences
* **Java 21 / Spring Boot 3.2.5**
* **MyBatis (XML-configured)** instead of Spring Data JPA
* **MariaDB** for historical records
* **Kafka** (topic: `pet-events`) for asynchronous event streams
* **Redis** (keyspace notifications enabled) for active timer caching
