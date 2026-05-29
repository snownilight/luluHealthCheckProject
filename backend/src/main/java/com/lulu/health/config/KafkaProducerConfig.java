package com.lulu.health.config;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaProducerConfig {

    public static final String PET_EVENTS_TOPIC = "pet-events";

    @Bean
    public NewTopic petEventsTopic() {
        return TopicBuilder.name(PET_EVENTS_TOPIC)
                .partitions(1)
                .replicas(1)
                .build();
    }
}
