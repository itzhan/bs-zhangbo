package com.laundry.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("operation_log")
public class OperationLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String username;
    private String module;
    private String action;
    private String description;
    private String method;
    private String url;
    private String ip;
    private String requestBody;
    private String responseBody;
    private Long costTime;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
