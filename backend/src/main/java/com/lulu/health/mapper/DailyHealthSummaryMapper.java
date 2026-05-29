package com.lulu.health.mapper;

import com.lulu.health.model.DailyHealthSummary;
import org.apache.ibatis.annotations.Mapper;
import java.time.LocalDate;

@Mapper
public interface DailyHealthSummaryMapper {

    int insert(DailyHealthSummary summary);

    int update(DailyHealthSummary summary);

    DailyHealthSummary findByDate(LocalDate date);
}
