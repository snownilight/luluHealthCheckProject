package com.lulu.health.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lulu.health.config.KafkaProducerConfig;
import com.lulu.health.dto.CareLogRequest;
import com.lulu.health.model.EventType;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.ImportAutoConfiguration;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.kafka.test.EmbeddedKafkaBroker;
import org.springframework.kafka.test.context.EmbeddedKafka;
import org.springframework.kafka.test.utils.KafkaTestUtils;
import org.springframework.boot.test.mock.mockito.MockBean;
import com.lulu.health.service.CareLogPersistenceService;
import com.lulu.health.service.HealthTrendService;
import com.lulu.health.service.RedisStateService;
import com.lulu.health.listener.RedisKeyExpirationListener;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Collections;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
    "spring.autoconfigure.exclude=" +
        "org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration," +
        "org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration," +
        "org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration," +
        "org.mybatis.spring.boot.autoconfigure.MybatisAutoConfiguration",
    "spring.cache.type=none", // disable Caffeine cache in tests to avoid dependency issues
    "spring.kafka.consumer.group-id=test-group"
})
@AutoConfigureMockMvc
@ActiveProfiles("test")
@EmbeddedKafka(partitions = 1, topics = {KafkaProducerConfig.PET_EVENTS_TOPIC})
public class CareLogControllerTest {

    @MockBean
    private CareLogPersistenceService careLogPersistenceService;

    @MockBean
    private HealthTrendService healthTrendService;

    @MockBean
    private RedisStateService redisStateService;

    @MockBean
    private RedisKeyExpirationListener redisKeyExpirationListener;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private EmbeddedKafkaBroker embeddedKafkaBroker;

    private Consumer<String, String> consumer;

    @BeforeEach
    public void setUp() {
        Map<String, Object> consumerProps = KafkaTestUtils.consumerProps("testGroup", "true", embeddedKafkaBroker);
        consumerProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        consumerProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        
        DefaultKafkaConsumerFactory<String, String> consumerFactory = new DefaultKafkaConsumerFactory<>(consumerProps);
        consumer = consumerFactory.createConsumer();
        embeddedKafkaBroker.consumeFromAnEmbeddedTopic(consumer, KafkaProducerConfig.PET_EVENTS_TOPIC);
    }

    @AfterEach
    public void tearDown() {
        if (consumer != null) {
            consumer.close();
        }
    }

    @Test
    public void testCreateCareLog_Success() throws Exception {
        CareLogRequest request = CareLogRequest.builder()
                .eventType(EventType.FEEDING)
                .operator("二姐")
                .value(50.0)
                .unit("g")
                .note("早餐")
                .build();

        mockMvc.perform(post("/api/v1/care-logs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value("Care log accepted and queued for processing"))
                .andExpect(jsonPath("$.data.eventId").exists())
                .andExpect(jsonPath("$.data.operator").value("二姐"))
                .andExpect(jsonPath("$.data.value").value(50.0));

        // Verify Kafka message was sent
        ConsumerRecord<String, String> record = KafkaTestUtils.getSingleRecord(consumer, KafkaProducerConfig.PET_EVENTS_TOPIC, java.time.Duration.ofSeconds(5));
        assertThat(record).isNotNull();
        assertThat(record.value()).contains("FEEDING");
        assertThat(record.value()).contains("二姐");
    }

    @Test
    public void testCreateCareLog_ValidationError() throws Exception {
        CareLogRequest request = CareLogRequest.builder()
                .eventType(null) // invalid
                .operator("") // invalid
                .value(-10.0) // invalid
                .build();

        mockMvc.perform(post("/api/v1/care-logs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.anyOf(
                        org.hamcrest.Matchers.containsString("eventType"),
                        org.hamcrest.Matchers.containsString("operator"),
                        org.hamcrest.Matchers.containsString("value")
                )));
    }

    @Test
    public void testGetAllCareLogs_Success() throws Exception {
        org.mockito.Mockito.when(careLogPersistenceService.getAllLogs()).thenReturn(java.util.Collections.emptyList());

        mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/api/v1/care-logs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value("Care logs retrieved successfully"))
                .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    public void testGetPetStatus_Success() throws Exception {
        com.lulu.health.model.PetStatus mockStatus = com.lulu.health.model.PetStatus.builder()
                .lastWeightKg(5.1)
                .todayWaterIntakeMl(200.0)
                .todayFoodIntakeG(120.0)
                .build();
        org.mockito.Mockito.when(redisStateService.getPetStatus()).thenReturn(mockStatus);

        mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/api/v1/care-logs/pet-status"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value("Fetched latest pet status successfully"))
                .andExpect(jsonPath("$.data.lastWeightKg").value(5.1))
                .andExpect(jsonPath("$.data.todayWaterIntakeMl").value(200.0))
                .andExpect(jsonPath("$.data.todayFoodIntakeG").value(120.0));
    }
}
