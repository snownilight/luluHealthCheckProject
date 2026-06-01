package com.lulu.health.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.lulu.health.config.FirebaseConfig;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final FirebaseConfig firebaseConfig;

    /**
     * Sends a dehydration alert notification to the default 'pet-alerts' FCM topic.
     */
    public void sendDehydrationAlert() {
        sendNotification(
            "Dehydration Warning",
            "⚠️ ALERT: Dehydration Warning! O-Lulu has not drank water in the last 8 hours!",
            "dehydration_warning",
            "pet-alerts"
        );
    }

    /**
     * Send notification helper.
     * Uses FCM when firebaseConfig.isMockEnabled() is false, otherwise logs notification details.
     */
    public void sendNotification(String title, String body, String icon, String topic) {
        log.info("Preparing push notification - Topic: {}, Title: '{}', Body: '{}', Icon: '{}'", topic, title, body, icon);

        if (firebaseConfig.isMockEnabled()) {
            log.info("📢 [MOCK FCM ALERT] Sent push notification successfully!");
            log.info("   -> Topic: {}", topic);
            log.info("   -> Title: {}", title);
            log.info("   -> Body: {}", body);
            log.info("   -> Data Payload: [alertText='{}', icon='{}', click_action='FLUTTER_NOTIFICATION_CLICK', timestamp='{}']", 
                    body, icon, LocalDateTime.now());
            return;
        }

        try {
            Notification notification = Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build();

            Message message = Message.builder()
                    .setNotification(notification)
                    .putData("alertText", body)
                    .putData("icon", icon)
                    .putData("click_action", "FLUTTER_NOTIFICATION_CLICK")
                    .putData("timestamp", LocalDateTime.now().toString())
                    .setTopic(topic)
                    .build();

            log.info("Sending actual FCM message to topic: {}", topic);
            String response = FirebaseMessaging.getInstance().send(message);
            log.info("Successfully sent FCM message; response ID: {}", response);
        } catch (Exception e) {
            log.error("❌ Failed to send FCM message to topic: {}", topic, e);
        }
    }
}
