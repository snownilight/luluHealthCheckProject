package com.lulu.health.listener;

import com.lulu.health.consumer.CareLogConsumer;
import com.lulu.health.service.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class RedisKeyExpirationListenerTest {

    @Mock
    private RedisMessageListenerContainer listenerContainer;

    @Mock
    private NotificationService notificationService;

    private RedisKeyExpirationListener expirationListener;

    @BeforeEach
    public void setUp() {
        expirationListener = new RedisKeyExpirationListener(listenerContainer, notificationService);
    }

    @Test
    public void testOnMessage_WaterTimerExpired() {
        Message mockMessage = mock(Message.class);
        when(mockMessage.toString()).thenReturn(CareLogConsumer.WATER_TIMER_KEY);

        expirationListener.onMessage(mockMessage, new byte[0]);

        verify(notificationService).sendDehydrationAlert();
    }

    @Test
    public void testOnMessage_FoodTimerExpired() {
        Message mockMessage = mock(Message.class);
        when(mockMessage.toString()).thenReturn(CareLogConsumer.FOOD_TIMER_KEY);

        expirationListener.onMessage(mockMessage, new byte[0]);

        verifyNoInteractions(notificationService);
    }

    @Test
    public void testOnMessage_OtherKeyExpired() {
        Message mockMessage = mock(Message.class);
        when(mockMessage.toString()).thenReturn("some:other:key");

        expirationListener.onMessage(mockMessage, new byte[0]);

        verifyNoInteractions(notificationService);
    }
}
