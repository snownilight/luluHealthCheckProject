package com.lulu.health.scheduler;

import com.lulu.health.model.CareLog;
import com.lulu.health.model.EventType;
import com.lulu.health.mapper.CareLogMapper;
import com.lulu.health.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DehydrationAlertScheduler {

    private final CareLogMapper careLogMapper;
    private final NotificationService notificationService;

    // Track the timestamp of the last sent alerts to avoid duplicates
    private LocalDateTime lastWaterAlertTime = LocalDateTime.MIN;
    private LocalDateTime lastFoodAlertTime = LocalDateTime.MIN;

    @Scheduled(fixedDelayString = "${app.scheduler.delay:60000}") // Default: check every minute
    public void checkPetStatusTimers() {
        log.debug("Running scheduled pet health timers check...");
        List<CareLog> allLogs = careLogMapper.findAll();
        if (allLogs == null || allLogs.isEmpty()) {
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime lastDrinkingTime = null;
        LocalDateTime lastFeedingTime = null;

        for (CareLog logEntry : allLogs) {
            if (logEntry.getEventType() == EventType.DRINKING) {
                if (lastDrinkingTime == null || logEntry.getEventTimestamp().isAfter(lastDrinkingTime)) {
                    lastDrinkingTime = logEntry.getEventTimestamp();
                }
            } else if (logEntry.getEventType() == EventType.FEEDING) {
                if (lastFeedingTime == null || logEntry.getEventTimestamp().isAfter(lastFeedingTime)) {
                    lastFeedingTime = logEntry.getEventTimestamp();
                }
            }
        }

        // 1. Water timer check (8 hours)
        if (lastDrinkingTime != null) {
            long hoursSinceDrinking = Duration.between(lastDrinkingTime, now).toHours();
            if (hoursSinceDrinking >= 8) {
                // Only send alert if we haven't alerted for this dehydration period
                if (lastWaterAlertTime.isBefore(lastDrinkingTime)) {
                    log.warn("Water timer expired! O-Lulu has not drank water for {} hours. Sending dehydration alert.", hoursSinceDrinking);
                    notificationService.sendDehydrationAlert();
                    lastWaterAlertTime = now;
                }
            }
        }

        // 2. Food timer check (24 hours)
        if (lastFeedingTime != null) {
            long hoursSinceFeeding = Duration.between(lastFeedingTime, now).toHours();
            if (hoursSinceFeeding >= 24) {
                if (lastFoodAlertTime.isBefore(lastFeedingTime)) {
                    log.warn("Food timer expired! O-Lulu has not been fed for {} hours.", hoursSinceFeeding);
                    lastFoodAlertTime = now;
                }
            }
        }
    }
}
