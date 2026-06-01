package com.lulu.health.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;

import jakarta.annotation.PostConstruct;
import java.io.InputStream;

@Slf4j
@Configuration
public class FirebaseConfig {

    @Value("${app.firebase.config-path:classpath:firebase-service-account.json}")
    private String configPath;

    @Value("${app.firebase.mock-enabled:true}")
    @Getter
    private boolean mockEnabled;

    private final ResourceLoader resourceLoader;

    public FirebaseConfig(ResourceLoader resourceLoader) {
        this.resourceLoader = resourceLoader;
    }

    @PostConstruct
    public void initialize() {
        if (mockEnabled) {
            log.info("🔥 Firebase initialized in MOCK mode (local dev/testing). Real push notifications will not be sent.");
            return;
        }

        try {
            log.info("🔥 Initializing Firebase from config path: {}", configPath);
            Resource resource = resourceLoader.getResource(configPath);
            if (!resource.exists()) {
                log.warn("⚠️ Firebase configuration file not found at path: {}. Falling back to MOCK mode.", configPath);
                this.mockEnabled = true;
                return;
            }

            try (InputStream serviceAccount = resource.getInputStream()) {
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();

                if (FirebaseApp.getApps().isEmpty()) {
                    FirebaseApp.initializeApp(options);
                    log.info("🔥 Firebase App successfully initialized.");
                } else {
                    log.info("🔥 Firebase App already initialized.");
                }
            }
        } catch (Exception e) {
            log.error("❌ Failed to initialize Firebase App. Falling back to MOCK mode.", e);
            this.mockEnabled = true;
        }
    }
}
