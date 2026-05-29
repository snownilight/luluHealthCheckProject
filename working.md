# 🐾 Pet Health Tracker - Active Status

* **Current Active Task**: `PET-004` (Configure Kafka Producer & Care Event API endpoints)
* **Status**: Implementing code
* **Plan**:
  - [ ] Fix Kafka serializer class paths in `application-dev.properties`
  - [ ] Create DTO `CareLogRequest` and validate input constraints
  - [ ] Create `KafkaProducerConfig` (topic creation) and `CareLogProducer` service
  - [ ] Create `CareLogController` for `POST /api/v1/care-logs`
  - [ ] Write integration test `CareLogControllerTest` to verify validation & Kafka message publishing

---

## 🟢 Completed Tasks
* `PET-001` (Done): Environment/Architecture docs setup.
* `PET-002` (Done): Database Schema & MyBatis Mapper Mapping (Refactored from JPA to MyBatis; table structures auto-initialized via `schema.sql`).
* `PET-003` (Done): Docker Compose setup (MariaDB, Redis with Ex notify, Kafka KRaft).

---

## ⚙️ Key Technical Stack & Preferences
* **Java 21 / Spring Boot 3.2.5**
* **MyBatis** instead of Spring Data JPA
* **MariaDB** for historical records
* **Kafka** (topic: `pet-events`) for asynchronous event streams
* **Redis** (keyspace notifications enabled) for active timer caching
