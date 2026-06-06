package com.lulu.health.service;

import com.lulu.health.mapper.DailyHealthSummaryMapper;
import com.lulu.health.mapper.WeightLogMapper;
import com.lulu.health.model.DailyHealthSummary;
import com.lulu.health.model.WeightLog;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.cache.CacheManager;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@SpringBootTest(properties = {
    "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration,org.mybatis.spring.boot.autoconfigure.MybatisAutoConfiguration",
    "spring.kafka.consumer.group-id=test-group"
})
@ActiveProfiles("test")
public class HealthTrendServiceCachingTest {

    @Autowired
    private HealthTrendService healthTrendService;

    @Autowired
    private CacheManager cacheManager;

    @MockBean
    private WeightLogMapper weightLogMapper;

    @MockBean
    private DailyHealthSummaryMapper dailyHealthSummaryMapper;

    @MockBean
    private CareLogPersistenceService careLogPersistenceService;

    @MockBean
    private com.lulu.health.scheduler.DehydrationAlertScheduler dehydrationAlertScheduler;

    @BeforeEach
    public void setUp() {
        if (cacheManager != null) {
            cacheManager.getCacheNames().forEach(name -> {
                var cache = cacheManager.getCache(name);
                if (cache != null) {
                    cache.clear();
                }
            });
        }
    }

    @Test
    public void testWeeklyWeightTrend_Caching() {
        WeightLog logEntry = WeightLog.builder().weightKg(3.5).build();
        List<WeightLog> logs = Collections.singletonList(logEntry);
        
        when(weightLogMapper.findAllOrderByRecordedAtDesc()).thenReturn(logs);

        // First call - cache miss
        List<WeightLog> result1 = healthTrendService.getWeeklyWeightTrend();
        
        // Second call - cache hit
        List<WeightLog> result2 = healthTrendService.getWeeklyWeightTrend();

        assertThat(result1).isEqualTo(logs);
        assertThat(result2).isEqualTo(logs);

        // Verify mapper is only called once
        verify(weightLogMapper, times(1)).findAllOrderByRecordedAtDesc();
    }

    @Test
    public void testMonthlyDailySummary_Caching() {
        DailyHealthSummary summary = DailyHealthSummary.builder().totalFoodIntakeG(100.0).build();
        List<DailyHealthSummary> summaries = Collections.singletonList(summary);
        
        when(dailyHealthSummaryMapper.findRange(any(LocalDate.class), any(LocalDate.class))).thenReturn(summaries);

        // First call - cache miss
        List<DailyHealthSummary> result1 = healthTrendService.getMonthlyDailySummary();
        
        // Second call - cache hit
        List<DailyHealthSummary> result2 = healthTrendService.getMonthlyDailySummary();

        assertThat(result1).isEqualTo(summaries);
        assertThat(result2).isEqualTo(summaries);

        // Verify mapper is only called once
        verify(dailyHealthSummaryMapper, times(1)).findRange(any(LocalDate.class), any(LocalDate.class));
    }
}
