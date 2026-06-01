package com.lulu.health.consumer;

import com.lulu.health.model.CareLog;
import com.lulu.health.model.EventType;
import com.lulu.health.service.CareLogPersistenceService;
import com.lulu.health.service.RedisStateService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class CareLogConsumerTest {

    @Mock
    private RedisStateService redisStateService;

    @Mock
    private CareLogPersistenceService careLogPersistenceService;

    private CareLogConsumer careLogConsumer;

    @BeforeEach
    public void setUp() {
        careLogConsumer = new CareLogConsumer(redisStateService, careLogPersistenceService);
    }

    @Test
    public void testConsumeCareLog_NullEvent() {
        careLogConsumer.consumeCareLog(null);
        verifyNoInteractions(redisStateService, careLogPersistenceService);
        assertThat(careLogConsumer.getBuffer()).isEmpty();
    }

    @Test
    public void testConsumeCareLog_NullEventType() {
        CareLog log = CareLog.builder()
                .eventId("1")
                .eventType(null)
                .value(10.0)
                .build();

        careLogConsumer.consumeCareLog(log);
        verifyNoInteractions(redisStateService, careLogPersistenceService);
        assertThat(careLogConsumer.getBuffer()).isEmpty();
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
        
        assertThat(careLogConsumer.getBuffer()).hasSize(1);
        assertThat(careLogConsumer.getBuffer().peek()).isEqualTo(log);
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
        assertThat(careLogConsumer.getBuffer()).isEmpty();
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
        
        assertThat(careLogConsumer.getBuffer()).hasSize(1);
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
        assertThat(careLogConsumer.getBuffer()).isEmpty();
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
        assertThat(careLogConsumer.getBuffer()).hasSize(1);
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
        assertThat(careLogConsumer.getBuffer()).isEmpty();
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
        assertThat(careLogConsumer.getBuffer()).hasSize(1);
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
        assertThat(careLogConsumer.getBuffer()).hasSize(1);
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
        assertThat(careLogConsumer.getBuffer()).hasSize(1);
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
        assertThat(careLogConsumer.getBuffer()).isEmpty(); // Should not buffer if pre-processing failed
    }

    @Test
    public void testFlushBuffer_Success() {
        CareLog log1 = CareLog.builder().eventId("1").eventType(EventType.FEEDING).value(50.0).build();
        CareLog log2 = CareLog.builder().eventId("2").eventType(EventType.DRINKING).value(80.0).build();

        careLogConsumer.getBuffer().add(log1);
        careLogConsumer.getBuffer().add(log2);

        careLogConsumer.flushBuffer();

        verify(careLogPersistenceService).persistBatch(argThat(list -> 
                list.size() == 2 && 
                list.contains(log1) && 
                list.contains(log2)
        ));
        assertThat(careLogConsumer.getBuffer()).isEmpty();
    }

    @Test
    public void testFlushBuffer_FailureAndRetry() {
        CareLog logEntry = CareLog.builder().eventId("1").eventType(EventType.FEEDING).value(50.0).build();
        careLogConsumer.getBuffer().add(logEntry);

        doThrow(new RuntimeException("DB Connection Failed")).when(careLogPersistenceService).persistBatch(anyList());

        careLogConsumer.flushBuffer();

        // Verify batch was attempted
        verify(careLogPersistenceService).persistBatch(anyList());
        // Verify item was put back in the buffer to retry
        assertThat(careLogConsumer.getBuffer()).hasSize(1);
        assertThat(careLogConsumer.getBuffer().peek()).isEqualTo(logEntry);
    }
}
