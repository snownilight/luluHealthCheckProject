package com.lulu.health.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.lulu.health.model.PetStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class RedisStateServiceTest {

    @Mock
    private RedisTemplate<String, Object> redisTemplate;

    @Mock
    private HashOperations<String, Object, Object> hashOperations;

    private ObjectMapper objectMapper;
    private RedisStateService redisStateService;

    @BeforeEach
    public void setUp() {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        objectMapper.disable(com.fasterxml.jackson.databind.SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

        lenient().when(redisTemplate.opsForHash()).thenReturn(hashOperations);

        redisStateService = new RedisStateService(redisTemplate, objectMapper);
    }

    @Test
    public void testSavePetStatus() {
        PetStatus status = PetStatus.builder()
                .lastWeightKg(3.2)
                .todayWaterIntakeMl(180.0)
                .todayFoodIntakeG(120.0)
                .lastActiveTime(LocalDateTime.of(2026, 5, 29, 12, 0, 0))
                .build();

        redisStateService.savePetStatus(status);

        verify(hashOperations).putAll(eq(RedisStateService.PET_STATUS_KEY), any(Map.class));
    }

    @Test
    public void testGetPetStatus_Success() {
        Map<Object, Object> mockEntries = new HashMap<>();
        mockEntries.put("lastWeightKg", 3.2);
        mockEntries.put("todayWaterIntakeMl", 180.0);
        mockEntries.put("todayFoodIntakeG", 120.0);
        mockEntries.put("lastActiveTime", "2026-05-29T12:00:00");

        when(hashOperations.entries(RedisStateService.PET_STATUS_KEY)).thenReturn(mockEntries);

        PetStatus status = redisStateService.getPetStatus();

        assertThat(status).isNotNull();
        assertThat(status.getLastWeightKg()).isEqualTo(3.2);
        assertThat(status.getTodayWaterIntakeMl()).isEqualTo(180.0);
        assertThat(status.getTodayFoodIntakeG()).isEqualTo(120.0);
        assertThat(status.getLastActiveTime()).isEqualTo(LocalDateTime.of(2026, 5, 29, 12, 0, 0));
    }

    @Test
    public void testGetPetStatus_Empty() {
        when(hashOperations.entries(RedisStateService.PET_STATUS_KEY)).thenReturn(new HashMap<>());

        PetStatus status = redisStateService.getPetStatus();

        assertThat(status).isNull();
    }

    @Test
    public void testUpdateField() {
        redisStateService.updateField("lastWeightKg", 3.5);
        verify(hashOperations).put(RedisStateService.PET_STATUS_KEY, "lastWeightKg", 3.5);
    }

    @Test
    public void testGetField() {
        when(hashOperations.get(RedisStateService.PET_STATUS_KEY, "lastWeightKg")).thenReturn(3.2);

        Object val = redisStateService.getField("lastWeightKg");

        assertThat(val).isEqualTo(3.2);
        verify(hashOperations).get(RedisStateService.PET_STATUS_KEY, "lastWeightKg");
    }

    @Test
    public void testIncrementField() {
        when(hashOperations.increment(RedisStateService.PET_STATUS_KEY, "todayWaterIntakeMl", 50.0)).thenReturn(230.0);

        Double result = redisStateService.incrementField("todayWaterIntakeMl", 50.0);

        assertThat(result).isEqualTo(230.0);
        verify(hashOperations).increment(RedisStateService.PET_STATUS_KEY, "todayWaterIntakeMl", 50.0);
    }

    @Test
    public void testClearStatus() {
        redisStateService.clearStatus();
        verify(redisTemplate).delete(RedisStateService.PET_STATUS_KEY);
    }
}
