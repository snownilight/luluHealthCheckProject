package com.lulu.health.controller;

import com.lulu.health.dto.ApiResponse;
import com.lulu.health.dto.CareLogRequest;
import com.lulu.health.model.CareLog;
import com.lulu.health.model.PetStatus;
import com.lulu.health.producer.CareLogProducer;
import com.lulu.health.service.RedisStateService;
import com.lulu.health.service.CareLogPersistenceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/api/v1/care-logs")
@RequiredArgsConstructor
public class CareLogController {

    private final CareLogProducer careLogProducer;
    private final CareLogPersistenceService careLogPersistenceService;
    private final RedisStateService redisStateService;

    @GetMapping("/pet-status")
    public ApiResponse<PetStatus> getPetStatus() {
        log.info("Request received for latest pet status");
        PetStatus status = redisStateService.getPetStatus();
        if (status == null) {
            status = PetStatus.builder()
                    .lastWeightKg(4.8)
                    .todayWaterIntakeMl(0.0)
                    .todayFoodIntakeG(0.0)
                    .lastActiveTime(LocalDateTime.now().minusMinutes(15))
                    .build();
        }
        return ApiResponse.success("Fetched latest pet status successfully", status);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.ACCEPTED)
    public ApiResponse<CareLog> createCareLog(@Valid @RequestBody CareLogRequest request) {
        log.info("Received care log request: eventType={}, operator={}", request.getEventType(), request.getOperator());

        // Map DTO to domain model
        CareLog careLog = CareLog.builder()
                .eventId(UUID.randomUUID().toString())
                .eventType(request.getEventType())
                .operator(request.getOperator())
                .value(request.getValue())
                .unit(request.getUnit())
                .note(request.getNote())
                .eventTimestamp(request.getEventTimestamp() != null ? request.getEventTimestamp() : LocalDateTime.now())
                .createdAt(LocalDateTime.now())
                .build();

        // Send to Kafka
        careLogProducer.sendCareLogEvent(careLog);

        return ApiResponse.success("Care log accepted and queued for processing", careLog);
    }

    @GetMapping
    public ApiResponse<java.util.List<CareLog>> getAllCareLogs() {
        log.info("Retrieving all care logs from database");
        return ApiResponse.success("Care logs retrieved successfully", careLogPersistenceService.getAllLogs());
    }
}
