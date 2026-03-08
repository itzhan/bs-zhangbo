package com.laundry.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.laundry.entity.*;
import com.laundry.mapper.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StatisticsService {

    private final LaundryOrderMapper orderMapper;
    private final PaymentMapper paymentMapper;
    private final ReviewMapper reviewMapper;
    private final RiderAssignmentMapper assignmentMapper;
    private final SysUserMapper userMapper;

    public Map<String, Object> getDashboard() {
        Map<String, Object> data = new HashMap<>();

        // 总订单数
        long totalOrders = orderMapper.selectCount(null);
        data.put("totalOrders", totalOrders);

        // 今日订单
        long todayOrders = orderMapper.selectCount(new LambdaQueryWrapper<LaundryOrder>()
                .ge(LaundryOrder::getCreatedAt, LocalDate.now().atStartOfDay()));
        data.put("todayOrders", todayOrders);

        // 总收入(GMV)
        List<Payment> payments = paymentMapper.selectList(
                new LambdaQueryWrapper<Payment>().eq(Payment::getStatus, "SUCCESS"));
        BigDecimal totalGMV = payments.stream()
                .map(Payment::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        data.put("totalGMV", totalGMV);

        // 总用户数
        long totalUsers = userMapper.selectCount(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getRole, "USER"));
        data.put("totalUsers", totalUsers);

        // 总骑手数
        long totalRiders = userMapper.selectCount(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getRole, "RIDER"));
        data.put("totalRiders", totalRiders);

        // 平均评分
        List<Review> reviews = reviewMapper.selectList(null);
        double avgRating = reviews.stream().mapToInt(Review::getRating).average().orElse(0);
        data.put("avgRating", BigDecimal.valueOf(avgRating).setScale(1, RoundingMode.HALF_UP));

        // 待处理订单
        long pendingOrders = orderMapper.selectCount(
                new LambdaQueryWrapper<LaundryOrder>().in(LaundryOrder::getStatus, "PAID", "ASSIGNED"));
        data.put("pendingOrders", pendingOrders);

        // 订单状态分布
        List<LaundryOrder> orders = orderMapper.selectList(null);
        Map<String, Long> statusDist = orders.stream()
                .collect(Collectors.groupingBy(LaundryOrder::getStatus, Collectors.counting()));
        data.put("statusDistribution", statusDist);

        // 最近7天订单趋势
        List<Map<String, Object>> trend = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            long count = orderMapper.selectCount(new LambdaQueryWrapper<LaundryOrder>()
                    .ge(LaundryOrder::getCreatedAt, date.atStartOfDay())
                    .lt(LaundryOrder::getCreatedAt, date.plusDays(1).atStartOfDay()));
            Map<String, Object> item = new HashMap<>();
            item.put("date", date.toString());
            item.put("count", count);
            trend.add(item);
        }
        data.put("orderTrend", trend);

        // 评分分布
        Map<Integer, Long> ratingDist = reviews.stream()
                .collect(Collectors.groupingBy(Review::getRating, Collectors.counting()));
        data.put("ratingDistribution", ratingDist);

        return data;
    }
}
