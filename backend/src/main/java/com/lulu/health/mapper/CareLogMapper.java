package com.lulu.health.mapper;

import com.lulu.health.model.CareLog;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface CareLogMapper {

    @Insert("INSERT INTO care_logs(event_id, event_type, operator, value, unit, note, event_timestamp) " +
            "VALUES(#{eventId}, #{eventType}, #{operator}, #{value}, #{unit}, #{note}, #{eventTimestamp})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(CareLog careLog);

    @Select("SELECT * FROM care_logs WHERE id = #{id}")
    CareLog findById(Long id);

    @Select("SELECT * FROM care_logs ORDER BY event_timestamp DESC")
    List<CareLog> findAll();
}
