package com.lulu.health.mapper;

import com.lulu.health.model.WeightLog;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface WeightLogMapper {

    @Insert("INSERT INTO weight_logs(weight_kg, recorded_at) VALUES(#{weightKg}, #{recordedAt})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(WeightLog weightLog);

    @Select("SELECT * FROM weight_logs ORDER BY recorded_at DESC")
    List<WeightLog> findAllOrderByRecordedAtDesc();
}
