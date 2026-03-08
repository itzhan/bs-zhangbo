package com.laundry.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.laundry.entity.LaundryOrder;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface LaundryOrderMapper extends BaseMapper<LaundryOrder> {
}
