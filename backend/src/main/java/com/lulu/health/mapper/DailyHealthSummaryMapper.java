package com.lulu.health.mapper;

import com.lulu.health.model.DailyHealthSummary;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.time.LocalDate;
import java.util.List;

@Mapper
public interface DailyHealthSummaryMapper {

    int insert(DailyHealthSummary summary);

    int update(DailyHealthSummary summary);

    DailyHealthSummary findByDate(LocalDate date);

    List<DailyHealthSummary> findRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
}
