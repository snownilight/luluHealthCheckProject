package com.lulu.health.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lulu.health.dto.CareLogRequest;
import com.lulu.health.model.EventType;
import com.lulu.health.model.PetStatus;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.boot.test.mock.mockito.MockBean;
import com.lulu.health.service.CareLogPersistenceService;
import com.lulu.health.service.HealthTrendService;
import com.lulu.health.scheduler.DehydrationAlertScheduler;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.when;
import static org.mockito.ArgumentMatchers.any;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
    "spring.autoconfigure.exclude=" +
        "org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration," +
        "org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration," +
        "org.mybatis.spring.boot.autoconfigure.MybatisAutoConfiguration",
    "spring.cache.type=none" // disable Caffeine cache in tests to avoid dependency issues
})
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class CareLogControllerTest {

    @MockBean
    private CareLogPersistenceService careLogPersistenceService;

    @MockBean
    private HealthTrendService healthTrendService;

    @MockBean
    private DehydrationAlertScheduler dehydrationAlertScheduler;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    public void testCreateCareLog_Success() throws Exception {
        CareLogRequest request = CareLogRequest.builder()
                .eventType(EventType.FEEDING)
                .operator("二姐")
                .value(50.0)
                .unit("g")
                .note("早餐")
                .build();

        PetStatus mockStatus = PetStatus.builder()
                .lastWeightKg(4.8)
                .todayWaterIntakeMl(0.0)
                .todayFoodIntakeG(50.0)
                .build();
        when(careLogPersistenceService.getPetStatus()).thenReturn(mockStatus);

        mockMvc.perform(post("/api/v1/care-logs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value("Care log processed successfully"))
                .andExpect(jsonPath("$.data.eventId").exists())
                .andExpect(jsonPath("$.data.operator").value("二姐"))
                .andExpect(jsonPath("$.data.value").value(50.0));

        // Verify direct synchronous persistence is called
        verify(careLogPersistenceService).persistSingle(any());
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
    public void testCreateCareLog_BlankOperatorWithWhitespaceOnly() throws Exception {
        CareLogRequest request = CareLogRequest.builder()
                .eventType(EventType.DRINKING)
                .operator("   ")
                .value(1.0)
                .unit("ml")
                .build();

        mockMvc.perform(post("/api/v1/care-logs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("operator")));

        verify(careLogPersistenceService, never()).persistSingle(any());
    }

    @Test
    public void testCreateCareLog_ZeroValueRejected() throws Exception {
        CareLogRequest request = CareLogRequest.builder()
                .eventType(EventType.FEEDING)
                .operator("Tester")
                .value(0.0)
                .unit("g")
                .build();

        mockMvc.perform(post("/api/v1/care-logs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("value")));

        verify(careLogPersistenceService, never()).persistSingle(any());
    }

    @Test
    public void testCreateCareLog_UnknownEventTypeRejectedAsBadRequest() throws Exception {
        String body = """
                {
                  "eventType": "UNKNOWN_EVENT",
                  "operator": "Tester",
                  "value": 1.0,
                  "unit": "g"
                }
                """;

        mockMvc.perform(post("/api/v1/care-logs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("Malformed request body"));

        verify(careLogPersistenceService, never()).persistSingle(any());
    }

    @Test
    public void testGetAllCareLogs_Success() throws Exception {
        when(careLogPersistenceService.getAllLogs()).thenReturn(java.util.Collections.emptyList());

        mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/api/v1/care-logs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value("Care logs retrieved successfully"))
                .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    public void testGetPetStatus_Success() throws Exception {
        PetStatus mockStatus = PetStatus.builder()
                .lastWeightKg(5.1)
                .todayWaterIntakeMl(200.0)
                .todayFoodIntakeG(120.0)
                .build();
        when(careLogPersistenceService.getPetStatus()).thenReturn(mockStatus);

        mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/api/v1/care-logs/pet-status"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value("Fetched latest pet status successfully"))
                .andExpect(jsonPath("$.data.lastWeightKg").value(5.1))
                .andExpect(jsonPath("$.data.todayWaterIntakeMl").value(200.0))
                .andExpect(jsonPath("$.data.todayFoodIntakeG").value(120.0));
    }
}
