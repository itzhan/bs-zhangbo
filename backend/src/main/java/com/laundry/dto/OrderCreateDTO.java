package com.laundry.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.util.List;

@Data
public class OrderCreateDTO {
    @NotNull(message = "地址ID不能为空")
    private Long addressId;
    @NotNull(message = "时段ID不能为空")
    private Long timeSlotId;
    private String remark;
    @NotEmpty(message = "订单项不能为空")
    private List<OrderItemDTO> items;

    @Data
    public static class OrderItemDTO {
        @NotNull(message = "服务项目ID不能为空")
        private Long serviceItemId;
        @NotNull(message = "数量不能为空")
        private Integer quantity;
    }
}
