package com.laundry.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("laundry_order")
public class LaundryOrder {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String orderNo;
    private Long userId;
    private Long addressId;
    private String addressDetail;
    private String contactName;
    private String contactPhone;
    private Long timeSlotId;
    private LocalDate pickupDate;
    private String pickupTime;
    private BigDecimal totalAmount;
    private BigDecimal payAmount;
    private String status;
    private String remark;
    private String cancelReason;
    private LocalDateTime completedAt;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
