package com.laundry.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("review")
public class Review {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orderId;
    private String orderNo;
    private Long userId;
    private Integer rating;
    private String content;
    private String images;
    private String reply;
    private LocalDateTime repliedAt;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
