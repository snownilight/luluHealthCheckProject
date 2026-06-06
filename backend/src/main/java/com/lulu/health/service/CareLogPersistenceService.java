package com.lulu.health.service;

import com.lulu.health.mapper.CareLogMapper;
import com.lulu.health.mapper.DailyHealthSummaryMapper;
import com.lulu.health.mapper.WeightLogMapper;
import com.lulu.health.model.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Slf4j
@Service
@RequiredArgsConstructor
public class CareLogPersistenceService {

    private final CareLogMapper careLogMapper;
    private final WeightLogMapper weightLogMapper;
    private final DailyHealthSummaryMapper dailyHealthSummaryMapper;

    @Transactional
    @CacheEvict(value = {"weeklyWeightTrend", "monthlyDailySummary"}, allEntries = true)
    public void persistBatch(List<CareLog> batch) {
        if (batch == null || batch.isEmpty()) {
            return;
        }

        log.info("Starting transactional batch persistence for {} care logs", batch.size());
        Set<LocalDate> affectedDates = new HashSet<>();

        for (CareLog careLog : batch) {
            // 1. Persist CareLog
            careLogMapper.insert(careLog);
            if (careLog.getEventTimestamp() != null) {
                affectedDates.add(careLog.getEventTimestamp().toLocalDate());
            }

            // 2. If it's a weight update, persist to weight logs
            if (careLog.getEventType() == EventType.WEIGHT_UPDATE && careLog.getValue() != null) {
                WeightLog weightLog = WeightLog.builder()
                        .weightKg(careLog.getValue())
                        .recordedAt(careLog.getEventTimestamp() != null ? careLog.getEventTimestamp() : LocalDateTime.now())
                        .build();
                weightLogMapper.insert(weightLog);
            }
        }

        // 3. Update daily summaries for affected dates
        for (LocalDate date : affectedDates) {
            updateDailySummary(date);
        }

        log.info("Completed batch persistence successfully");
    }

    private void updateDailySummary(LocalDate date) {
        log.debug("Updating daily summary for date: {}", date);

        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.plusDays(1).atStartOfDay();

        // Fetch only logs and weights for the specific date range
        List<CareLog> dayLogs = careLogMapper.findByTimestampRange(startOfDay, endOfDay);
        List<WeightLog> dayWeights = weightLogMapper.findByRecordedAtRange(startOfDay, endOfDay);

        // Calculate totals for this date
        double waterSum = 0;
        double foodSum = 0;
        for (CareLog cl : dayLogs) {
            if (cl.getEventType() == EventType.DRINKING && cl.getValue() != null) {
                waterSum += cl.getValue();
            } else if (cl.getEventType() == EventType.FEEDING && cl.getValue() != null) {
                foodSum += cl.getValue();
            }
        }

        // Calculate average weight
        double weightSum = 0;
        int weightCount = 0;
        for (WeightLog wl : dayWeights) {
            weightSum += wl.getWeightKg();
            weightCount++;
        }
        double avgWeight = weightCount > 0 ? (weightSum / weightCount) : 0.0;

        // Save or update the daily summary
        DailyHealthSummary summary = dailyHealthSummaryMapper.findByDate(date);
        if (summary == null) {
            summary = DailyHealthSummary.builder()
                    .date(date)
                    .totalWaterIntakeMl(waterSum)
                    .totalFoodIntakeG(foodSum)
                    .averageWeightKg(avgWeight)
                    .build();
            dailyHealthSummaryMapper.insert(summary);
        } else {
            summary.setTotalWaterIntakeMl(waterSum);
            summary.setTotalFoodIntakeG(foodSum);
            summary.setAverageWeightKg(avgWeight);
            dailyHealthSummaryMapper.update(summary);
        }
    }

    public List<CareLog> getAllLogs() {
        return careLogMapper.findAll();
    }
}
