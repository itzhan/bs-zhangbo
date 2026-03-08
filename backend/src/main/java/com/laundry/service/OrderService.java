package com.laundry.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.laundry.common.BusinessException;
import com.laundry.dto.OrderCreateDTO;
import com.laundry.entity.*;
import com.laundry.mapper.*;
import com.laundry.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final LaundryOrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final ServiceItemMapper serviceItemMapper;
    private final UserAddressMapper addressMapper;
    private final TimeSlotMapper timeSlotMapper;
    private final PaymentMapper paymentMapper;
    private final RiderAssignmentMapper assignmentMapper;

    @Transactional
    public LaundryOrder createOrder(OrderCreateDTO dto) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) throw new BusinessException(401, "未登录");

        // 查地址
        UserAddress address = addressMapper.selectById(dto.getAddressId());
        if (address == null || !address.getUserId().equals(userId)) {
            throw new BusinessException("地址不存在");
        }

        // 查时段
        TimeSlot slot = timeSlotMapper.selectById(dto.getTimeSlotId());
        if (slot == null || slot.getStatus() != 1) {
            throw new BusinessException("时段不存在或不可用");
        }
        if (slot.getBookedCount() >= slot.getCapacity()) {
            throw new BusinessException("该时段已满，请选择其他时段");
        }

        // 生成订单号
        String orderNo = "LD" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", new Random().nextInt(10000));

        // 计算总价并创建订单项
        BigDecimal totalAmount = BigDecimal.ZERO;
        List<OrderItem> items = new ArrayList<>();
        for (OrderCreateDTO.OrderItemDTO itemDto : dto.getItems()) {
            ServiceItem si = serviceItemMapper.selectById(itemDto.getServiceItemId());
            if (si == null || si.getStatus() != 1) {
                throw new BusinessException("服务项目 " + itemDto.getServiceItemId() + " 不存在或已下架");
            }
            OrderItem oi = new OrderItem();
            oi.setServiceItemId(si.getId());
            oi.setServiceName(si.getName());
            oi.setPrice(si.getPrice());
            oi.setQuantity(itemDto.getQuantity());
            oi.setSubtotal(si.getPrice().multiply(BigDecimal.valueOf(itemDto.getQuantity())));
            totalAmount = totalAmount.add(oi.getSubtotal());
            items.add(oi);
        }

        // 创建订单
        LaundryOrder order = new LaundryOrder();
        order.setOrderNo(orderNo);
        order.setUserId(userId);
        order.setAddressId(address.getId());
        order.setAddressDetail(address.getProvince() + address.getCity() + address.getDistrict() + address.getDetail());
        order.setContactName(address.getContactName());
        order.setContactPhone(address.getContactPhone());
        order.setTimeSlotId(slot.getId());
        order.setPickupDate(slot.getSlotDate());
        order.setPickupTime(slot.getStartTime() + "-" + slot.getEndTime());
        order.setTotalAmount(totalAmount);
        order.setStatus("PENDING_PAY");
        order.setRemark(dto.getRemark());
        orderMapper.insert(order);

        // 保存订单项
        for (OrderItem item : items) {
            item.setOrderId(order.getId());
            orderItemMapper.insert(item);
        }

        // 更新时段已预约数
        slot.setBookedCount(slot.getBookedCount() + 1);
        timeSlotMapper.updateById(slot);

        return order;
    }

    @Transactional
    public void payOrder(Long orderId) {
        Long userId = SecurityUtils.getCurrentUserId();
        LaundryOrder order = orderMapper.selectById(orderId);
        if (order == null || !order.getUserId().equals(userId)) {
            throw new BusinessException("订单不存在");
        }
        if (!"PENDING_PAY".equals(order.getStatus())) {
            throw new BusinessException("订单状态不允许支付");
        }

        // 更新订单状态
        order.setStatus("PAID");
        order.setPayAmount(order.getTotalAmount());
        orderMapper.updateById(order);

        // 创建支付记录
        Payment payment = new Payment();
        payment.setPaymentNo("PAY" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", new Random().nextInt(10000)));
        payment.setOrderId(order.getId());
        payment.setOrderNo(order.getOrderNo());
        payment.setUserId(userId);
        payment.setAmount(order.getTotalAmount());
        payment.setPayMethod("WECHAT");
        payment.setStatus("SUCCESS");
        payment.setPaidAt(LocalDateTime.now());
        paymentMapper.insert(payment);
    }

    @Transactional
    public void cancelOrder(Long orderId, String reason) {
        Long userId = SecurityUtils.getCurrentUserId();
        LaundryOrder order = orderMapper.selectById(orderId);
        if (order == null) throw new BusinessException("订单不存在");

        // 管理员可取消任何订单，用户只能取消自己的
        if (!SecurityUtils.isAdmin() && !order.getUserId().equals(userId)) {
            throw new BusinessException("无权操作");
        }

        Set<String> cancellable = Set.of("PENDING_PAY", "PAID", "ASSIGNED");
        if (!cancellable.contains(order.getStatus())) {
            throw new BusinessException("当前状态不允许取消");
        }

        // 如果已支付，创建退款记录
        if (!"PENDING_PAY".equals(order.getStatus())) {
            Payment pay = paymentMapper.selectOne(
                    new LambdaQueryWrapper<Payment>()
                            .eq(Payment::getOrderId, orderId)
                            .eq(Payment::getStatus, "SUCCESS"));
            if (pay != null) {
                pay.setStatus("REFUNDED");
                pay.setRefundedAt(LocalDateTime.now());
                paymentMapper.updateById(pay);
            }
        }

        order.setStatus("CANCELLED");
        order.setCancelReason(reason);
        orderMapper.updateById(order);

        // 释放时段
        if (order.getTimeSlotId() != null) {
            TimeSlot slot = timeSlotMapper.selectById(order.getTimeSlotId());
            if (slot != null && slot.getBookedCount() > 0) {
                slot.setBookedCount(slot.getBookedCount() - 1);
                timeSlotMapper.updateById(slot);
            }
        }
    }

    public void updateOrderStatus(Long orderId, String newStatus) {
        LaundryOrder order = orderMapper.selectById(orderId);
        if (order == null) throw new BusinessException("订单不存在");

        // 状态机校验
        Map<String, Set<String>> transitions = new HashMap<>();
        transitions.put("PAID", Set.of("ASSIGNED"));
        transitions.put("ASSIGNED", Set.of("PICKED_UP"));
        transitions.put("PICKED_UP", Set.of("WASHING"));
        transitions.put("WASHING", Set.of("WASHED"));
        transitions.put("WASHED", Set.of("DELIVERING"));
        transitions.put("DELIVERING", Set.of("COMPLETED"));

        Set<String> allowed = transitions.get(order.getStatus());
        if (allowed == null || !allowed.contains(newStatus)) {
            throw new BusinessException("不允许从 " + order.getStatus() + " 转换到 " + newStatus);
        }

        order.setStatus(newStatus);
        if ("COMPLETED".equals(newStatus)) {
            order.setCompletedAt(LocalDateTime.now());
        }
        orderMapper.updateById(order);
    }

    public IPage<LaundryOrder> pageOrders(int page, int size, String status, Long userId) {
        LambdaQueryWrapper<LaundryOrder> wrapper = new LambdaQueryWrapper<>();
        if (userId != null) wrapper.eq(LaundryOrder::getUserId, userId);
        if (status != null && !status.isEmpty()) wrapper.eq(LaundryOrder::getStatus, status);
        wrapper.orderByDesc(LaundryOrder::getCreatedAt);
        return orderMapper.selectPage(new Page<>(page, size), wrapper);
    }

    public Map<String, Object> getOrderDetail(Long orderId) {
        LaundryOrder order = orderMapper.selectById(orderId);
        if (order == null) throw new BusinessException("订单不存在");

        List<OrderItem> items = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, orderId));

        List<RiderAssignment> assignments = assignmentMapper.selectList(
                new LambdaQueryWrapper<RiderAssignment>().eq(RiderAssignment::getOrderId, orderId));

        Map<String, Object> result = new HashMap<>();
        result.put("order", order);
        result.put("items", items);
        result.put("assignments", assignments);
        return result;
    }
}
