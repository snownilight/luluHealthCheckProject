package com.lulu.health.model;

import lombok.*;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CareLog {
    private Long id;
    private String eventId;
    private EventType eventType;
    private String operator;
    private Double value;
    private String unit;
    private String note;
    private LocalDateTime eventTimestamp;
    private LocalDateTime createdAt;
}
