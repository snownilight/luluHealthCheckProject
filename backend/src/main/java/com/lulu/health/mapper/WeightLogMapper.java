package com.lulu.health.mapper;

import com.lulu.health.model.WeightLog;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface WeightLogMapper {

    int insert(WeightLog weightLog);

    List<WeightLog> findAllOrderByRecordedAtDesc();
}
