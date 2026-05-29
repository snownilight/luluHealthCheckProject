package com.lulu.health.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "care_logs")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CareLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "event_id", unique = true, nullable = false, length = 50)
    private String eventId;

    @Enumerated(EnumType.STRING)
    @Column(name = "event_type", nullable = false, length = 20)
    private EventType eventType;

    @Column(nullable = false, length = 50)
    private String operator;

    private Double value;

    @Column(length = 10)
    private String unit;

    @Column(length = 255)
    private String note;

    @Column(name = "event_timestamp", nullable = false)
    private LocalDateTime eventTimestamp;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;
}
