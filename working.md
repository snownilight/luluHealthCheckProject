# 🐾 Pet Health Check Project - Progress Tracking

This file tracks the active status of our development. We update this before starting each new development phase.

---

## 📊 Project Status Overview

| Phase | Description | Status | Progress |
|---|---|---|---|
| **Phase 1** | Environment & Architecture Setup | **DONE** | 100% |
| **Phase 2** | Backend Core (Event Stream & Cache) | **IN PROGRESS** | 0% |
| **Phase 3** | Real-Time Sync & Notifications | PENDING | 0% |
| **Phase 4** | Flutter Mobile App (Frontend) | PENDING | 0% |
| **Phase 5** | End-to-End & Polish | PENDING | 0% |

---

## 🟢 Completed Tasks (Phase 1)

### `PET-001` - Init Project Ground Rules & Architecture Docs
*   **Status**: Done (Issue #1 Closed & Assigned)
*   **Deliverables**:
    *   `CLAUDE.md`: Build/Run/Test guidelines.
    *   `docs/CODE-STYLE.md`: Code style standards for Java and Flutter.
    *   `docs/GIT-COMMIT.md`: Conventional commits format instructions.
    *   `docs/ARCHITECTURE.md`: Technical flow architecture diagram (Kafka/Redis/MariaDB).

### `PET-002` - Database Schema & MyBatis Mapper Mapping
*   **Status**: Done (Issue #2 Closed & Assigned)
*   **Deliverables**:
    *   POJO mappings for `CareLog`, `DailyHealthSummary`, and `WeightLog`.
    *   MyBatis `@Mapper` interfaces: `CareLogMapper`, `DailyHealthSummaryMapper`, and `WeightLogMapper`.
    *   Database auto-initialization script: `src/main/resources/schema.sql`.
    *   Migration away from Spring Data JPA to MyBatis to meet optimization preferences.

### `PET-003` - Docker Compose Configuration
*   **Status**: Done (Issue #3 Closed & Assigned)
*   **Deliverables**:
    *   `docker-compose.yml` defining:
        *   **MariaDB** (Database container on port `3306`)
        *   **Redis** (Cache container on port `6379`, configured with keyspace events `Ex` enabled)
        *   **Kafka** (KRaft mode message broker on port `9092` / internal `29092`)

---

## ⚡ Current Task: `PET-004` (Configure Kafka Producer & Care Event API endpoints)

### Objectives
1.  Implement the REST API endpoint `POST /api/v1/care-logs` to accept pet care entries (feeding, drinking, weight, activity, grooming).
2.  Add validation rules to incoming logs to prevent invalid inputs (e.g. negative or excessive numbers).
3.  Configure `KafkaTemplate` to produce events into the `pet-events` topic.
4.  Write integration tests to verify successful publishing to Kafka upon HTTP POST request.

---

## 🛠️ Tech Stack & Current Configurations
*   **Java Version**: JDK 21
*   **Framework**: Spring Boot 3.2.5
*   **Persistence**: MyBatis (3.0.3) & MariaDB
*   **Messaging**: Apache Kafka (KRaft mode)
*   **Cache**: Redis (keyspace notifications enabled) & Caffeine L1 Cache
*   **Lombok**: Configured for clean builders/constructors.
