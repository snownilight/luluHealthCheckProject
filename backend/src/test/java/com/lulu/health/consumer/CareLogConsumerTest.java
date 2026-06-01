package com.lulu.health.consumer;

import com.lulu.health.model.CareLog;
import com.lulu.health.model.EventType;
import com.lulu.health.service.RedisStateService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class CareLogConsumerTest {

    @Mock
    private RedisStateService redisStateService;

    private CareLogConsumer careLogConsumer;

    @BeforeEach
    public void setUp() {
        careLogConsumer = new CareLogConsumer(redisStateService);
    }

    @Test
    public void testConsumeCareLog_NullEvent() {
        careLogConsumer.consumeCareLog(null);
        verifyNoInteractions(redisStateService);
    }

    @Test
    public void testConsumeCareLog_NullEventType() {
        CareLog log = CareLog.builder()
                .eventId("1")
                .eventType(null)
                .value(10.0)
                .build();

        careLogConsumer.consumeCareLog(log);
        verifyNoInteractions(redisStateService);
    }

    @Test
    public void testConsumeCareLog_Feeding_Success() {
        CareLog log = CareLog.builder()
                .eventId("event-123")
                .eventType(EventType.FEEDING)
                .value(50.0)
                .build();

        careLogConsumer.consumeCareLog(log);

        verify(redisStateService).incrementField("todayFoodIntakeG", 50.0);
        verify(redisStateService).setKeyWithTtl(CareLogConsumer.FOOD_TIMER_KEY, "active", CareLogConsumer.FOOD_TIMER_TTL_SECONDS);
    }

    @Test
    public void testConsumeCareLog_Feeding_NullValue() {
        CareLog log = CareLog.builder()
                .eventId("event-123")
                .eventType(EventType.FEEDING)
                .value(null)
                .build();

        careLogConsumer.consumeCareLog(log);

        verifyNoInteractions(redisStateService);
    }

    @Test
    public void testConsumeCareLog_Drinking_Success() {
        CareLog log = CareLog.builder()
                .eventId("event-456")
                .eventType(EventType.DRINKING)
                .value(80.0)
                .build();

        careLogConsumer.consumeCareLog(log);

        verify(redisStateService).incrementField("todayWaterIntakeMl", 80.0);
        verify(redisStateService).setKeyWithTtl(CareLogConsumer.WATER_TIMER_KEY, "active", CareLogConsumer.WATER_TIMER_TTL_SECONDS);
    }

    @Test
    public void testConsumeCareLog_Drinking_NullValue() {
        CareLog log = CareLog.builder()
                .eventId("event-456")
                .eventType(EventType.DRINKING)
                .value(null)
                .build();

        careLogConsumer.consumeCareLog(log);

        verifyNoInteractions(redisStateService);
    }

    @Test
    public void testConsumeCareLog_WeightUpdate_Success() {
        CareLog log = CareLog.builder()
                .eventId("event-789")
                .eventType(EventType.WEIGHT_UPDATE)
                .value(3.5)
                .build();

        careLogConsumer.consumeCareLog(log);

        verify(redisStateService).updateField("lastWeightKg", 3.5);
    }

    @Test
    public void testConsumeCareLog_WeightUpdate_NullValue() {
        CareLog log = CareLog.builder()
                .eventId("event-789")
                .eventType(EventType.WEIGHT_UPDATE)
                .value(null)
                .build();

        careLogConsumer.consumeCareLog(log);

        verifyNoInteractions(redisStateService);
    }

    @Test
    public void testConsumeCareLog_Activity_WithTimestamp() {
        LocalDateTime now = LocalDateTime.now();
        CareLog log = CareLog.builder()
                .eventId("event-abc")
                .eventType(EventType.ACTIVITY)
                .eventTimestamp(now)
                .build();

        careLogConsumer.consumeCareLog(log);

        verify(redisStateService).updateField("lastActiveTime", now);
    }

    @Test
    public void testConsumeCareLog_Activity_NullTimestamp() {
        CareLog log = CareLog.builder()
                .eventId("event-abc")
                .eventType(EventType.ACTIVITY)
                .eventTimestamp(null)
                .build();

        careLogConsumer.consumeCareLog(log);

        verify(redisStateService).updateField(eq("lastActiveTime"), any(LocalDateTime.class));
    }

    @Test
    public void testConsumeCareLog_Grooming_Ignored() {
        CareLog log = CareLog.builder()
                .eventId("event-groom")
                .eventType(EventType.GROOMING)
                .value(1.0)
                .build();

        careLogConsumer.consumeCareLog(log);

        verifyNoInteractions(redisStateService);
    }

    @Test
    public void testConsumeCareLog_ExceptionHandling() {
        CareLog log = CareLog.builder()
                .eventId("event-err")
                .eventType(EventType.FEEDING)
                .value(50.0)
                .build();

        doThrow(new RuntimeException("Redis connection error")).when(redisStateService).incrementField(anyString(), anyDouble());

        // Should handle exception without bubbling up
        careLogConsumer.consumeCareLog(log);

        verify(redisStateService).incrementField("todayFoodIntakeG", 50.0);
    }
}
