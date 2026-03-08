package com.laundry.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("rider_income")
public class RiderIncome {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long riderId;
    private String yearMonth;
    private Integer totalOrders;
    private BigDecimal totalIncome;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
