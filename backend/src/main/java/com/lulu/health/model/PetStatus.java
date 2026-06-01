package com.lulu.health.model;

import lombok.*;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PetStatus {
    private Double lastWeightKg;
    private Double todayWaterIntakeMl;
    private Double todayFoodIntakeG;
    private LocalDateTime lastActiveTime;
}
