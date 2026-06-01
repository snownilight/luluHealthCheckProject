package com.lulu.health.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lulu.health.config.KafkaProducerConfig;
import com.lulu.health.consumer.CareLogConsumer;
import com.lulu.health.dto.CareLogRequest;
import com.lulu.health.listener.RedisKeyExpirationListener;
import com.lulu.health.model.CareLog;
import com.lulu.health.model.EventType;
import com.lulu.health.service.CareLogPersistenceService;
import com.lulu.health.service.HealthTrendService;
import com.lulu.health.service.NotificationService;
import com.lulu.health.service.RedisStateService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.redis.connection.Message;
import org.springframework.http.MediaType;
import org.springframework.kafka.test.context.EmbeddedKafka;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
    "spring.autoconfigure.exclude=" +
        "org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration," +
        "org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration," +
        "org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration," +
        "org.mybatis.spring.boot.autoconfigure.MybatisAutoConfiguration",
    "spring.cache.type=none",
    "spring.kafka.consumer.group-id=simulation-group"
})
@AutoConfigureMockMvc
@ActiveProfiles("test")
@EmbeddedKafka(partitions = 1, topics = {KafkaProducerConfig.PET_EVENTS_TOPIC})
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
    private RedisStateService redisStateService;

    @MockBean
    private NotificationService notificationService;

    @Autowired
    private CareLogConsumer careLogConsumer;

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

        // 2. Simulate consumer processing the event (e.g. from Kafka)
        CareLog eventLog = CareLog.builder()
                .eventId("mock-event-id")
                .eventType(EventType.DRINKING)
                .operator("Dad")
                .value(100.0)
                .unit("ml")
                .note("Refilled fresh water bowl")
                .build();

        careLogConsumer.consumeCareLog(eventLog);

        // Verify that the Redis state service was invoked to record status updates and timers
        verify(redisStateService).incrementField("todayWaterIntakeMl", 100.0);
        verify(redisStateService).setKeyWithTtl(CareLogConsumer.WATER_TIMER_KEY, "active", CareLogConsumer.WATER_TIMER_TTL_SECONDS);

        // 3. Simulate water timer expiration (Redis keyspace event)
        Message expirationMessage = mock(Message.class);
        when(expirationMessage.toString()).thenReturn(CareLogConsumer.WATER_TIMER_KEY);

        RedisKeyExpirationListener listener = new RedisKeyExpirationListener(
                mock(org.springframework.data.redis.listener.RedisMessageListenerContainer.class),
                notificationService
        );
        listener.onMessage(expirationMessage, new byte[0]);

        // Verify that the dehydration alert notification was successfully triggered
        verify(notificationService).sendDehydrationAlert();
    }
}
