package com.lulu.health.controller;

import com.lulu.health.dto.ApiResponse;
import com.lulu.health.dto.CareLogRequest;
import com.lulu.health.model.CareLog;
import com.lulu.health.model.PetStatus;
import com.lulu.health.service.CareLogPersistenceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/api/v1/care-logs")
@RequiredArgsConstructor
public class CareLogController {

    private final CareLogPersistenceService careLogPersistenceService;
    private final SimpMessagingTemplate messagingTemplate;

    @GetMapping("/pet-status")
    public ApiResponse<PetStatus> getPetStatus() {
        log.info("Request received for latest pet status");
        PetStatus status = careLogPersistenceService.getPetStatus();
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

        // Persist directly to DB synchronously
        careLogPersistenceService.persistSingle(careLog);

        // Fetch updated status and push to WebSocket
        try {
            PetStatus updatedStatus = careLogPersistenceService.getPetStatus();
            messagingTemplate.convertAndSend("/topic/status", updatedStatus);
            log.info("Successfully pushed updated status via WebSocket to /topic/status: {}", updatedStatus);
        } catch (Exception e) {
            log.error("Failed to push status update via WebSocket", e);
        }

        return ApiResponse.success("Care log processed successfully", careLog);
    }

    @GetMapping
    public ApiResponse<java.util.List<CareLog>> getAllCareLogs() {
        log.info("Retrieving all care logs from database");
        return ApiResponse.success("Care logs retrieved successfully", careLogPersistenceService.getAllLogs());
    }
}
