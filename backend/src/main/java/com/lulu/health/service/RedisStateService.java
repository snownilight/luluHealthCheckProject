package com.lulu.health.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lulu.health.model.PetStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
@Profile("!test")
public class RedisStateService {

    public static final String PET_STATUS_KEY = "pet:status:current";

    private final RedisTemplate<String, Object> redisTemplate;
    private final ObjectMapper objectMapper;

    /**
     * Save the entire PetStatus to the Redis Hash.
     * Converts the POJO to a Map utilizing standard ObjectMapper serialization.
     */
    public void savePetStatus(PetStatus status) {
        if (status == null) {
            log.warn("Cannot save null PetStatus");
            return;
        }
        log.info("Saving PetStatus to Redis: {}", status);
        Map<String, Object> map = objectMapper.convertValue(status, Map.class);
        redisTemplate.opsForHash().putAll(PET_STATUS_KEY, map);
    }

    /**
     * Retrieve the entire PetStatus from the Redis Hash.
     * Fetches hash entries and deserializes back into a PetStatus POJO.
     */
    public PetStatus getPetStatus() {
        Map<Object, Object> entries = redisTemplate.opsForHash().entries(PET_STATUS_KEY);
        if (entries == null || entries.isEmpty()) {
            log.debug("PetStatus hash does not exist or is empty in Redis");
            return null;
        }
        return objectMapper.convertValue(entries, PetStatus.class);
    }

    /**
     * Update a single field in the Redis Hash.
     */
    public void updateField(String field, Object value) {
        log.info("Updating PetStatus field: {} = {}", field, value);
        redisTemplate.opsForHash().put(PET_STATUS_KEY, field, value);
    }

    /**
     * Get a single field from the Redis Hash.
     */
    public Object getField(String field) {
        return redisTemplate.opsForHash().get(PET_STATUS_KEY, field);
    }

    /**
     * Increment a double/float field in the Redis Hash atomically.
     */
    public Double incrementField(String field, double delta) {
        log.info("Incrementing PetStatus field: {} by {}", field, delta);
        return redisTemplate.opsForHash().increment(PET_STATUS_KEY, field, delta);
    }

    /**
     * Clear/Delete the PetStatus from Redis.
     */
    public void clearStatus() {
        log.info("Clearing PetStatus in Redis");
        redisTemplate.delete(PET_STATUS_KEY);
    }

    /**
     * Set a key with a value and a TTL in seconds.
     */
    public void setKeyWithTtl(String key, Object value, long ttlSeconds) {
        log.info("Setting key: {} to value: {} with TTL: {}s", key, value, ttlSeconds);
        redisTemplate.opsForValue().set(key, value, java.time.Duration.ofSeconds(ttlSeconds));
    }

    /**
     * Delete a key.
     */
    public void deleteKey(String key) {
        log.info("Deleting key: {}", key);
        redisTemplate.delete(key);
    }
}
