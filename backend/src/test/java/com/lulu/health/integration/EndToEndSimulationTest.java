package com.lulu.health.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lulu.health.dto.CareLogRequest;
import com.lulu.health.model.CareLog;
import com.lulu.health.model.EventType;
import com.lulu.health.mapper.CareLogMapper;
import com.lulu.health.service.CareLogPersistenceService;
import com.lulu.health.service.HealthTrendService;
import com.lulu.health.service.NotificationService;
import com.lulu.health.scheduler.DehydrationAlertScheduler;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
    "spring.autoconfigure.exclude=" +
        "org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration," +
        "org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration," +
        "org.mybatis.spring.boot.autoconfigure.MybatisAutoConfiguration",
    "spring.cache.type=none"
})
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class EndToEndSimulationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private CareLogPersistenceService careLogPersistenceService;

    @MockBean
    private HealthTrendService healthTrendService;

    @MockBean
    private CareLogMapper careLogMapper;

    @MockBean
    private NotificationService notificationService;

    @Autowired
    private DehydrationAlertScheduler dehydrationAlertScheduler;

    @Test
    public void testFullSimulation_EventIngestionToDehydrationAlert() throws Exception {
        // 1. Simulate REST API posting a Care Event
        CareLogRequest request = CareLogRequest.builder()
                .eventType(EventType.DRINKING)
                .operator("Dad")
                .value(100.0)
                .note("Refilled fresh water bowl")
                .build();

        mockMvc.perform(post("/api/v1/care-logs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isAccepted());

        // Verify that the persistence service was invoked synchronously
        verify(careLogPersistenceService).persistSingle(any());

        // 2. Simulate scheduler detecting no drinking for 8+ hours
        CareLog oldDrinkingLog = CareLog.builder()
                .eventId("mock-event-id")
                .eventType(EventType.DRINKING)
                .operator("Dad")
                .value(100.0)
                .unit("ml")
                .note("Refilled fresh water bowl")
                .eventTimestamp(LocalDateTime.now().minusHours(9)) // 9 hours ago
                .build();

        when(careLogMapper.findAll()).thenReturn(List.of(oldDrinkingLog));

        // Invoke scheduler check manually
        dehydrationAlertScheduler.checkPetStatusTimers();

        // Verify that the dehydration alert notification was triggered
        verify(notificationService).sendDehydrationAlert();
    }
}
