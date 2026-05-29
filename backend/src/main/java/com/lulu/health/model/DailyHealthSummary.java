package com.lulu.health.model;

import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailyHealthSummary {
    private Long id;
    private LocalDate date;
    private Double totalWaterIntakeMl;
    private Double totalFoodIntakeG;
    private Double averageWeightKg;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
