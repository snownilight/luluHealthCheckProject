package com.lulu.health.repository;

import com.lulu.health.model.CareLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CareLogRepository extends JpaRepository<CareLog, Long> {
}
