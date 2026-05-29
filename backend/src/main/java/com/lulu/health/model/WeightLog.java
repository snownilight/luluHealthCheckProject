package com.lulu.health.model;

import lombok.*;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeightLog {
    private Long id;
    private Double weightKg;
    private LocalDateTime recordedAt;
    private LocalDateTime createdAt;
}
