package com.lulu.health.producer;

import com.lulu.health.config.KafkaProducerConfig;
import com.lulu.health.model.CareLog;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class CareLogProducer {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    public void sendCareLogEvent(CareLog careLog) {
        log.info("Publishing care log event: {}", careLog.getEventId());
        
        kafkaTemplate.send(KafkaProducerConfig.PET_EVENTS_TOPIC, careLog.getEventId(), careLog)
                .whenComplete((result, ex) -> {
                    if (ex == null) {
                        log.info("Successfully published care log event: {} [Topic: {}, Partition: {}, Offset: {}]", 
                                careLog.getEventId(), 
                                result.getRecordMetadata().topic(),
                                result.getRecordMetadata().partition(),
                                result.getRecordMetadata().offset());
                    } else {
                        log.error("Failed to publish care log event: {}", careLog.getEventId(), ex);
                    }
                });
    }
}
