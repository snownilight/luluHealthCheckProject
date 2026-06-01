package com.lulu.health.controller;

import com.lulu.health.dto.ApiResponse;
import com.lulu.health.model.DailyHealthSummary;
import com.lulu.health.model.WeightLog;
import com.lulu.health.service.HealthTrendService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/v1/trends")
@RequiredArgsConstructor
public class HealthTrendController {

    private final HealthTrendService healthTrendService;

    @GetMapping("/weight")
    public ApiResponse<List<WeightLog>> getWeeklyWeightTrend() {
        log.info("Request received for weekly weight trend");
        List<WeightLog> trend = healthTrendService.getWeeklyWeightTrend();
        return ApiResponse.success("Fetched weekly weight trend successfully", trend);
    }

    @GetMapping("/monthly-summary")
    public ApiResponse<List<DailyHealthSummary>> getMonthlyDailySummary() {
        log.info("Request received for monthly daily summary");
        List<DailyHealthSummary> summary = healthTrendService.getMonthlyDailySummary();
        return ApiResponse.success("Fetched monthly daily summaries successfully", summary);
    }
}
