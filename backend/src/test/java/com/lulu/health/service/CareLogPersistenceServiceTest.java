package com.lulu.health.service;

import com.lulu.health.mapper.CareLogMapper;
import com.lulu.health.mapper.DailyHealthSummaryMapper;
import com.lulu.health.mapper.WeightLogMapper;
import com.lulu.health.model.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class CareLogPersistenceServiceTest {

    @Mock
    private CareLogMapper careLogMapper;

    @Mock
    private WeightLogMapper weightLogMapper;

    @Mock
    private DailyHealthSummaryMapper dailyHealthSummaryMapper;

    private CareLogPersistenceService persistenceService;

    @BeforeEach
    public void setUp() {
        persistenceService = new CareLogPersistenceService(careLogMapper, weightLogMapper, dailyHealthSummaryMapper);
    }

    @Test
    public void testPersistBatch_EmptyBatch() {
        persistenceService.persistBatch(null);
        persistenceService.persistBatch(Collections.emptyList());

        verifyNoInteractions(careLogMapper, weightLogMapper, dailyHealthSummaryMapper);
    }

    @Test
    public void testPersistBatch_Success() {
        LocalDate date = LocalDate.of(2026, 6, 1);
        LocalDateTime timestamp = date.atTime(12, 0);

        CareLog log1 = CareLog.builder()
                .eventId("event-1")
                .eventType(EventType.FEEDING)
                .value(100.0)
                .eventTimestamp(timestamp)
                .build();

        CareLog log2 = CareLog.builder()
                .eventId("event-2")
                .eventType(EventType.DRINKING)
                .value(150.0)
                .eventTimestamp(timestamp)
                .build();

        CareLog log3 = CareLog.builder()
                .eventId("event-3")
                .eventType(EventType.WEIGHT_UPDATE)
                .value(3.2)
                .eventTimestamp(timestamp)
                .build();

        List<CareLog> batch = Arrays.asList(log1, log2, log3);

        // Mock DB returns
        List<CareLog> mockAllLogs = new ArrayList<>(batch);
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.plusDays(1).atStartOfDay();
        when(careLogMapper.findByTimestampRange(startOfDay, endOfDay)).thenReturn(mockAllLogs);

        WeightLog mockWeightLog = WeightLog.builder()
                .weightKg(3.2)
                .recordedAt(timestamp)
                .build();
        when(weightLogMapper.findByRecordedAtRange(startOfDay, endOfDay)).thenReturn(Collections.singletonList(mockWeightLog));
        when(dailyHealthSummaryMapper.findByDate(date)).thenReturn(null);

        // Execute
        persistenceService.persistBatch(batch);

        // Verification
        verify(careLogMapper).insert(log1);
        verify(careLogMapper).insert(log2);
        verify(careLogMapper).insert(log3);
        verify(weightLogMapper).insert(any(WeightLog.class));
        verify(dailyHealthSummaryMapper).insert(argThat(summary -> 
                summary.getDate().equals(date) &&
                summary.getTotalFoodIntakeG() == 100.0 &&
                summary.getTotalWaterIntakeMl() == 150.0 &&
                summary.getAverageWeightKg() == 3.2
        ));
    }

    @Test
    public void testPersistBatch_SeparatesSummariesAcrossMidnight() {
        LocalDate firstDate = LocalDate.of(2026, 6, 1);
        LocalDate secondDate = LocalDate.of(2026, 6, 2);
        LocalDateTime firstTimestamp = firstDate.atTime(23, 59);
        LocalDateTime secondTimestamp = secondDate.atStartOfDay();

        CareLog waterBeforeMidnight = CareLog.builder()
                .eventId("water-before-midnight")
                .eventType(EventType.DRINKING)
                .value(100.0)
                .eventTimestamp(firstTimestamp)
                .build();
        CareLog foodAtMidnight = CareLog.builder()
                .eventId("food-at-midnight")
                .eventType(EventType.FEEDING)
                .value(40.0)
                .eventTimestamp(secondTimestamp)
                .build();

        when(careLogMapper.findByTimestampRange(firstDate.atStartOfDay(), secondDate.atStartOfDay()))
                .thenReturn(Collections.singletonList(waterBeforeMidnight));
        when(careLogMapper.findByTimestampRange(secondDate.atStartOfDay(), secondDate.plusDays(1).atStartOfDay()))
                .thenReturn(Collections.singletonList(foodAtMidnight));
        when(weightLogMapper.findByRecordedAtRange(any(LocalDateTime.class), any(LocalDateTime.class)))
                .thenReturn(Collections.emptyList());
        when(dailyHealthSummaryMapper.findByDate(firstDate)).thenReturn(null);
        when(dailyHealthSummaryMapper.findByDate(secondDate)).thenReturn(null);

        persistenceService.persistBatch(List.of(waterBeforeMidnight, foodAtMidnight));

        verify(dailyHealthSummaryMapper).insert(argThat(summary ->
                summary.getDate().equals(firstDate) &&
                summary.getTotalWaterIntakeMl() == 100.0 &&
                summary.getTotalFoodIntakeG() == 0.0
        ));
        verify(dailyHealthSummaryMapper).insert(argThat(summary ->
                summary.getDate().equals(secondDate) &&
                summary.getTotalWaterIntakeMl() == 0.0 &&
                summary.getTotalFoodIntakeG() == 40.0
        ));
    }

    @Test
    public void testPersistBatch_NullTimestampPersistsCareLogButSkipsSummaryUpdate() {
        CareLog noTimestamp = CareLog.builder()
                .eventId("no-timestamp")
                .eventType(EventType.DRINKING)
                .value(100.0)
                .eventTimestamp(null)
                .build();

        persistenceService.persistBatch(Collections.singletonList(noTimestamp));

        verify(careLogMapper).insert(noTimestamp);
        verifyNoInteractions(weightLogMapper, dailyHealthSummaryMapper);
    }

    @Test
    public void testPersistBatch_DbErrorRollback() {
        CareLog logEntry = CareLog.builder()
                .eventId("event-1")
                .eventType(EventType.FEEDING)
                .value(100.0)
                .eventTimestamp(LocalDateTime.now())
                .build();

        doThrow(new RuntimeException("Database error")).when(careLogMapper).insert(any(CareLog.class));

        assertThatThrownBy(() -> persistenceService.persistBatch(Collections.singletonList(logEntry)))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("Database error");
    }
}
