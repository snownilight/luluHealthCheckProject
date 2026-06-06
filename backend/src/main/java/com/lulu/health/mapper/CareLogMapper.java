package com.lulu.health.mapper;

import com.lulu.health.model.CareLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface CareLogMapper {

    int insert(CareLog careLog);

    CareLog findById(Long id);

    List<CareLog> findAll();

    List<CareLog> findByTimestampRange(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);
}
