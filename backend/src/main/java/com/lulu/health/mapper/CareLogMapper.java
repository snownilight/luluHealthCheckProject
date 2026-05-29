package com.lulu.health.mapper;

import com.lulu.health.model.CareLog;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface CareLogMapper {

    int insert(CareLog careLog);

    CareLog findById(Long id);

    List<CareLog> findAll();
}
