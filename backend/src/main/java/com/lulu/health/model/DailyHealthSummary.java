package com.lulu.health.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "daily_health_summaries")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailyHealthSummary {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private LocalDate date;

    @Column(name = "total_water_intake_ml")
    private Double totalWaterIntakeMl;

    @Column(name = "total_food_intake_g")
    private Double totalFoodIntakeG;

    @Column(name = "average_weight_kg")
    private Double averageWeightKg;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private LocalDateTime updatedAt;
}
