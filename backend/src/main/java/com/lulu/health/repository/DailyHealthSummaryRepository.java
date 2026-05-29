package com.lulu.health.repository;

import com.lulu.health.model.DailyHealthSummary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface DailyHealthSummaryRepository extends JpaRepository<DailyHealthSummary, Long> {
    Optional<DailyHealthSummary> findByDate(LocalDate date);
}
