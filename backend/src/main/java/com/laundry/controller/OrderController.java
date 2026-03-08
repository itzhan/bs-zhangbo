package com.laundry.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.laundry.common.BusinessException;
import com.laundry.common.Result;
import com.laundry.dto.OrderCreateDTO;
import com.laundry.entity.*;
import com.laundry.mapper.*;
import com.laundry.security.SecurityUtils;
import com.laundry.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    private final LaundryOrderMapper orderMapper;
    private final RiderAssignmentMapper assignmentMapper;

    @PostMapping
    public Result<?> create(@RequestBody @Valid OrderCreateDTO dto) {
        return Result.success(orderService.createOrder(dto));
    }

    @GetMapping
    public Result<?> list(@RequestParam(defaultValue = "1") int page,
                          @RequestParam(defaultValue = "10") int size,
                          @RequestParam(required = false) String status) {
        Long userId = SecurityUtils.isAdmin() ? null : SecurityUtils.getCurrentUserId();
        return Result.success(orderService.pageOrders(page, size, status, userId));
    }

    @GetMapping("/{id}")
    public Result<?> detail(@PathVariable Long id) {
        return Result.success(orderService.getOrderDetail(id));
    }

    @PostMapping("/{id}/pay")
    public Result<?> pay(@PathVariable Long id) {
        orderService.payOrder(id);
        return Result.success("支付成功");
    }

    @PostMapping("/{id}/cancel")
    public Result<?> cancel(@PathVariable Long id, @RequestBody(required = false) Map<String, String> body) {
        String reason = body != null ? body.get("reason") : null;
        orderService.cancelOrder(id, reason);
        return Result.success("取消成功");
    }

    @PutMapping("/{id}/status")
    @PreAuthorize("hasAnyRole('ADMIN', 'RIDER')")
    public Result<?> updateStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        orderService.updateOrderStatus(id, body.get("status"));
        return Result.success("状态更新成功");
    }

    @PostMapping("/{id}/assign")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> assign(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        LaundryOrder order = orderMapper.selectById(id);
        if (order == null) throw new BusinessException("订单不存在");
        if (!"PAID".equals(order.getStatus())) throw new BusinessException("只有已支付订单可以派单");

        Long riderId = Long.valueOf(body.get("riderId").toString());
        RiderAssignment assignment = new RiderAssignment();
        assignment.setOrderId(id);
        assignment.setOrderNo(order.getOrderNo());
        assignment.setRiderId(riderId);
        assignment.setType("PICKUP");
        assignment.setStatus("PENDING");
        assignment.setAssignedAt(LocalDateTime.now());
        assignmentMapper.insert(assignment);

        order.setStatus("ASSIGNED");
        orderMapper.updateById(order);
        return Result.success("派单成功");
    }

    // 骑手相关接口
    @GetMapping("/rider/my")
    @PreAuthorize("hasRole('RIDER')")
    public Result<?> riderOrders(@RequestParam(defaultValue = "1") int page,
                                 @RequestParam(defaultValue = "10") int size,
                                 @RequestParam(required = false) String status) {
        Long riderId = SecurityUtils.getCurrentUserId();
        IPage<RiderAssignment> assignments = assignmentMapper.selectPage(
                new Page<>(page, size),
                new LambdaQueryWrapper<RiderAssignment>()
                        .eq(RiderAssignment::getRiderId, riderId)
                        .eq(status != null, RiderAssignment::getStatus, status)
                        .orderByDesc(RiderAssignment::getCreatedAt));
        return Result.success(assignments);
    }

    @PutMapping("/rider/assignment/{id}/accept")
    @PreAuthorize("hasRole('RIDER')")
    public Result<?> acceptAssignment(@PathVariable Long id) {
        RiderAssignment assignment = assignmentMapper.selectById(id);
        if (assignment == null) throw new BusinessException("派单不存在");
        if (!assignment.getRiderId().equals(SecurityUtils.getCurrentUserId())) {
            throw new BusinessException("无权操作");
        }
        assignment.setStatus("ACCEPTED");
        assignment.setAcceptedAt(LocalDateTime.now());
        assignmentMapper.updateById(assignment);

        // 更新订单状态为已取件
        LaundryOrder order = orderMapper.selectById(assignment.getOrderId());
        if (order != null && "ASSIGNED".equals(order.getStatus()) && "PICKUP".equals(assignment.getType())) {
            order.setStatus("PICKED_UP");
            orderMapper.updateById(order);
        }
        return Result.success("接单成功");
    }

    @PutMapping("/rider/assignment/{id}/complete")
    @PreAuthorize("hasRole('RIDER')")
    public Result<?> completeAssignment(@PathVariable Long id) {
        RiderAssignment assignment = assignmentMapper.selectById(id);
        if (assignment == null) throw new BusinessException("派单不存在");
        if (!assignment.getRiderId().equals(SecurityUtils.getCurrentUserId())) {
            throw new BusinessException("无权操作");
        }
        assignment.setStatus("COMPLETED");
        assignment.setCompletedAt(LocalDateTime.now());
        assignmentMapper.updateById(assignment);
        return Result.success("完成操作");
    }
}
