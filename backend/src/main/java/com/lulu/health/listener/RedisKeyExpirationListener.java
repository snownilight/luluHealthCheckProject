package com.lulu.health.listener;

import com.lulu.health.consumer.CareLogConsumer;
import com.lulu.health.service.NotificationService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.listener.KeyExpirationEventMessageListener;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@Profile("!test")
public class RedisKeyExpirationListener extends KeyExpirationEventMessageListener {

    private final NotificationService notificationService;

    public RedisKeyExpirationListener(RedisMessageListenerContainer listenerContainer, 
                                      NotificationService notificationService) {
        super(listenerContainer);
        this.notificationService = notificationService;
    }

    @Override
    public void onMessage(Message message, byte[] pattern) {
        String expiredKey = message.toString();
        log.info("Redis key expired event captured: {}", expiredKey);

        if (CareLogConsumer.WATER_TIMER_KEY.equals(expiredKey)) {
            log.warn("Water timer expired! Sending dehydration alert.");
            notificationService.sendDehydrationAlert();
        } else if (CareLogConsumer.FOOD_TIMER_KEY.equals(expiredKey)) {
            log.warn("Food timer expired! O-Lulu has not been fed recently.");
        }
    }
}
