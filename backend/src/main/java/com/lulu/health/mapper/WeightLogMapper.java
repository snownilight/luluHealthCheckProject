package com.lulu.health.mapper;

import com.lulu.health.model.WeightLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface WeightLogMapper {

    int insert(WeightLog weightLog);

    List<WeightLog> findAllOrderByRecordedAtDesc();

    List<WeightLog> findByRecordedAtRange(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);
}
