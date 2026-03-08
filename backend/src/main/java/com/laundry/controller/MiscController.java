package com.laundry.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.laundry.common.Result;
import com.laundry.entity.*;
import com.laundry.mapper.*;
import com.laundry.security.SecurityUtils;
import com.laundry.service.StatisticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class MiscController {

    private final SystemConfigMapper configMapper;
    private final OperationLogMapper logMapper;
    private final RiderIncomeMapper incomeMapper;
    private final PaymentMapper paymentMapper;
    private final StatisticsService statisticsService;

    // ==================== 统计 ====================
    @GetMapping("/statistics/dashboard")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> dashboard() {
        return Result.success(statisticsService.getDashboard());
    }

    // ==================== 系统配置 ====================
    @GetMapping("/system-configs")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> listConfigs() {
        return Result.success(configMapper.selectList(null));
    }

    @PutMapping("/system-configs/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> updateConfig(@PathVariable Long id, @RequestBody SystemConfig config) {
        config.setId(id);
        configMapper.updateById(config);
        return Result.success("更新成功");
    }

    // ==================== 操作日志 ====================
    @GetMapping("/operation-logs")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> listLogs(@RequestParam(defaultValue = "1") int page,
                              @RequestParam(defaultValue = "10") int size,
                              @RequestParam(required = false) String module) {
        LambdaQueryWrapper<OperationLog> wrapper = new LambdaQueryWrapper<>();
        if (module != null) wrapper.eq(OperationLog::getModule, module);
        wrapper.orderByDesc(OperationLog::getCreatedAt);
        return Result.success(logMapper.selectPage(new Page<>(page, size), wrapper));
    }

    // ==================== 骑手收入 ====================
    @GetMapping("/rider-incomes")
    public Result<?> riderIncomes(@RequestParam(required = false) Long riderId) {
        LambdaQueryWrapper<RiderIncome> wrapper = new LambdaQueryWrapper<>();
        if (SecurityUtils.isRider()) {
            wrapper.eq(RiderIncome::getRiderId, SecurityUtils.getCurrentUserId());
        } else if (riderId != null) {
            wrapper.eq(RiderIncome::getRiderId, riderId);
        }
        wrapper.orderByDesc(RiderIncome::getYearMonth);
        return Result.success(incomeMapper.selectList(wrapper));
    }

    // ==================== 支付记录 ====================
    @GetMapping("/payments")
    public Result<?> payments(@RequestParam(defaultValue = "1") int page,
                              @RequestParam(defaultValue = "10") int size) {
        LambdaQueryWrapper<Payment> wrapper = new LambdaQueryWrapper<>();
        if (!SecurityUtils.isAdmin()) {
            wrapper.eq(Payment::getUserId, SecurityUtils.getCurrentUserId());
        }
        wrapper.orderByDesc(Payment::getCreatedAt);
        return Result.success(paymentMapper.selectPage(new Page<>(page, size), wrapper));
    }
}
