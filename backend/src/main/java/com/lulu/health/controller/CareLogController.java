package com.lulu.health.controller;

import com.lulu.health.dto.ApiResponse;
import com.lulu.health.dto.CareLogRequest;
import com.lulu.health.model.CareLog;
import com.lulu.health.producer.CareLogProducer;
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
    private final com.lulu.health.service.CareLogPersistenceService careLogPersistenceService;

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
