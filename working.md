# 🐾 Pet Health Tracker - Active Status

* **Current Active Task**: `PET-005` (Configure Redis Connection & Current State Machine Hash)
* **Status**: Planning
* **Plan**:
  - [ ] Define Redis connection properties & configs in `application-dev.properties`
  - [ ] Implement `RedisStateService` (or helper components) to read/write state hashes
  - [ ] Ensure serialization handles DTO/POJO models cleanly

---

## 🟢 Completed Tasks
* `PET-001` (Done): Environment/Architecture docs setup.
* `PET-002` (Done): Database Schema & MyBatis Mapper Mapping (Refactored from JPA to MyBatis; table structures auto-initialized via `schema.sql`).
* `PET-003` (Done): Docker Compose setup (MariaDB, Redis with Ex notify, Kafka KRaft).
* `PET-004` (Done): Configure Kafka Producer & Care Event API endpoints (validated DTO, serialization paths corrected, REST API publishes events, integration test passed).

---

## ⚙️ Key Technical Stack & Preferences
* **Java 21 / Spring Boot 3.2.5**
* **MyBatis** instead of Spring Data JPA
* **MariaDB** for historical records
* **Kafka** (topic: `pet-events`) for asynchronous event streams
* **Redis** (keyspace notifications enabled) for active timer caching
