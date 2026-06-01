package com.lulu.health.service;

import com.lulu.health.config.FirebaseConfig;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class NotificationServiceTest {

    @Mock
    private FirebaseConfig firebaseConfig;

    private NotificationService notificationService;

    @BeforeEach
    public void setUp() {
        notificationService = new NotificationService(firebaseConfig);
    }

    @Test
    public void testSendNotification_MockEnabled() {
        when(firebaseConfig.isMockEnabled()).thenReturn(true);

        notificationService.sendDehydrationAlert();

        verify(firebaseConfig, atLeastOnce()).isMockEnabled();
    }

    @Test
    public void testSendNotification_RealFcm_HandlesExceptionGracefully() {
        // When mock is disabled, FirebaseMessaging will try to get the instance which will fail because 
        // FirebaseApp is not initialized in the test runtime. We want to make sure it catches the 
        // initialization exception and logs/handles it gracefully without crashing.
        when(firebaseConfig.isMockEnabled()).thenReturn(false);

        notificationService.sendDehydrationAlert();

        verify(firebaseConfig, atLeastOnce()).isMockEnabled();
    }
}
