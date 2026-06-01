package com.lulu.health.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class NotificationService {

    public void sendDehydrationAlert() {
        log.warn("⚠️ ALERT: Dehydration Warning! O-Lulu has not drank water in the last 8 hours!");
    }
}
