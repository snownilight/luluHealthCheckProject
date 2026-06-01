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

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
@ConditionalOnBean(RedisConnectionFactory.class)
public class CareLogConsumer {

    public static final String WATER_TIMER_KEY = "pet:health:water:timer";
    public static final String FOOD_TIMER_KEY = "pet:health:food:timer";
    
    public static final long WATER_TIMER_TTL_SECONDS = 28800L; // 8 hours
    public static final long FOOD_TIMER_TTL_SECONDS = 86400L;  // 24 hours

    private final RedisStateService redisStateService;

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
                    }
                    break;

                case DRINKING:
                    if (careLog.getValue() != null) {
                        redisStateService.incrementField("todayWaterIntakeMl", careLog.getValue());
                        redisStateService.setKeyWithTtl(WATER_TIMER_KEY, "active", WATER_TIMER_TTL_SECONDS);
                    } else {
                        log.warn("Drinking event value is null: {}", careLog.getEventId());
                    }
                    break;

                case WEIGHT_UPDATE:
                    if (careLog.getValue() != null) {
                        redisStateService.updateField("lastWeightKg", careLog.getValue());
                    } else {
                        log.warn("Weight update event value is null: {}", careLog.getEventId());
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
        } catch (Exception e) {
            log.error("Error processing care log event: {}", careLog.getEventId(), e);
        }
    }
}
