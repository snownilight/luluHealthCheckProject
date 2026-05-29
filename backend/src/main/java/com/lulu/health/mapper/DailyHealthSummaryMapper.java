package com.lulu.health.mapper;

import com.lulu.health.model.DailyHealthSummary;
import org.apache.ibatis.annotations.*;
import java.time.LocalDate;
import java.util.Optional;

@Mapper
public interface DailyHealthSummaryMapper {

    @Insert("INSERT INTO daily_health_summaries(date, total_water_intake_ml, total_food_intake_g, average_weight_kg) " +
            "VALUES(#{date}, #{totalWaterIntakeMl}, #{totalFoodIntakeG}, #{averageWeightKg})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(DailyHealthSummary summary);

    @Update("UPDATE daily_health_summaries SET " +
            "total_water_intake_ml = #{totalWaterIntakeMl}, " +
            "total_food_intake_g = #{totalFoodIntakeG}, " +
            "average_weight_kg = #{averageWeightKg} " +
            "WHERE id = #{id}")
    int update(DailyHealthSummary summary);

    @Select("SELECT * FROM daily_health_summaries WHERE date = #{date}")
    DailyHealthSummary findByDate(LocalDate date);
}
