package com.lulu.health.service;

import com.lulu.health.mapper.DailyHealthSummaryMapper;
import com.lulu.health.mapper.WeightLogMapper;
import com.lulu.health.model.DailyHealthSummary;
import com.lulu.health.model.WeightLog;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class HealthTrendService {

    private final WeightLogMapper weightLogMapper;
    private final DailyHealthSummaryMapper dailyHealthSummaryMapper;

    @Cacheable(value = "weeklyWeightTrend")
    public List<WeightLog> getWeeklyWeightTrend() {
        log.info("Cache miss! Fetching weekly weight trend from database.");
        return weightLogMapper.findAllOrderByRecordedAtDesc().stream()
                .limit(12)
                .collect(Collectors.toList());
    }

    @Cacheable(value = "monthlyDailySummary")
    public List<DailyHealthSummary> getMonthlyDailySummary() {
        log.info("Cache miss! Fetching monthly daily summaries from database.");
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(30);
        return dailyHealthSummaryMapper.findRange(startDate, endDate);
    }
}
