package com.lulu.health.dto;

import com.lulu.health.model.EventType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CareLogRequest {

    @NotNull(message = "Event type is required")
    private EventType eventType;

    @NotBlank(message = "Operator name is required")
    private String operator;

    @Positive(message = "Value must be positive")
    private Double value;

    private String unit;

    private String note;

    private LocalDateTime eventTimestamp;
}
