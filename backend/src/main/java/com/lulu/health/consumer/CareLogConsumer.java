package com.lulu.health.consumer;

import com.lulu.health.config.KafkaProducerConfig;
import com.lulu.health.model.CareLog;
import com.lulu.health.service.RedisStateService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.lulu.health.service.CareLogPersistenceService;
import org.springframework.scheduling.annotation.Scheduled;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

@Slf4j
@Service
@RequiredArgsConstructor
@ConditionalOnBean(value = {RedisConnectionFactory.class, CareLogPersistenceService.class})
public class CareLogConsumer {

    public static final String WATER_TIMER_KEY = "pet:health:water:timer";
    public static final String FOOD_TIMER_KEY = "pet:health:food:timer";
    
    public static final long WATER_TIMER_TTL_SECONDS = 28800L; // 8 hours
    public static final long FOOD_TIMER_TTL_SECONDS = 86400L;  // 24 hours

    private final RedisStateService redisStateService;
    private final CareLogPersistenceService careLogPersistenceService;
    private final Queue<CareLog> buffer = new ConcurrentLinkedQueue<>();

    @KafkaListener(topics = KafkaProducerConfig.PET_EVENTS_TOPIC, groupId = "${spring.kafka.consumer.group-id}")
    public void consumeCareLog(CareLog careLog) {
        if (careLog == null) {
            log.warn("Received null CareLog event");
            return;
        }

        log.info("Received care log event from Kafka: eventId={}, eventType={}, value={}",
                careLog.getEventId(), careLog.getEventType(), careLog.getValue());

        try {
            if (careLog.getEventType() == null) {
                log.warn("CareLog eventType is null, skipping update: {}", careLog.getEventId());
                return;
            }

            switch (careLog.getEventType()) {
                case FEEDING:
                    if (careLog.getValue() != null) {
                        redisStateService.incrementField("todayFoodIntakeG", careLog.getValue());
                        redisStateService.setKeyWithTtl(FOOD_TIMER_KEY, "active", FOOD_TIMER_TTL_SECONDS);
                    } else {
                        log.warn("Feeding event value is null: {}", careLog.getEventId());
                        return;
                    }
                    break;

                case DRINKING:
                    if (careLog.getValue() != null) {
                        redisStateService.incrementField("todayWaterIntakeMl", careLog.getValue());
                        redisStateService.setKeyWithTtl(WATER_TIMER_KEY, "active", WATER_TIMER_TTL_SECONDS);
                    } else {
                        log.warn("Drinking event value is null: {}", careLog.getEventId());
                        return;
                    }
                    break;

                case WEIGHT_UPDATE:
                    if (careLog.getValue() != null) {
                        redisStateService.updateField("lastWeightKg", careLog.getValue());
                    } else {
                        log.warn("Weight update event value is null: {}", careLog.getEventId());
                        return;
                    }
                    break;

                case ACTIVITY:
                    LocalDateTime activeTime = careLog.getEventTimestamp() != null 
                            ? careLog.getEventTimestamp() 
                            : LocalDateTime.now();
                    redisStateService.updateField("lastActiveTime", activeTime);
                    break;

                default:
                    log.info("Event type {} has no mapping to PetStatus fields: {}", 
                            careLog.getEventType(), careLog.getEventId());
                    break;
            }

            // Buffer for write-behind persistence
            buffer.add(careLog);
            log.debug("Buffered care log: {}. Current buffer size: {}", careLog.getEventId(), buffer.size());

        } catch (Exception e) {
            log.error("Error processing care log event: {}", careLog.getEventId(), e);
        }
    }

    @Scheduled(fixedDelay = 5000)
    public void flushBuffer() {
        if (buffer.isEmpty()) {
            return;
        }

        log.info("Scheduled flush: processing {} items in buffer", buffer.size());
        List<CareLog> batch = new ArrayList<>();
        CareLog logEntry;
        while ((logEntry = buffer.poll()) != null) {
            batch.add(logEntry);
        }

        if (!batch.isEmpty()) {
            try {
                careLogPersistenceService.persistBatch(batch);
            } catch (Exception e) {
                log.error("Failed to persist batch, returning events to buffer to retry", e);
                buffer.addAll(batch);
            }
        }
    }

    public Queue<CareLog> getBuffer() {
        return this.buffer;
    }
}
