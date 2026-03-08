package com.laundry.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.laundry.common.BusinessException;
import com.laundry.common.Result;
import com.laundry.entity.Complaint;
import com.laundry.mapper.ComplaintMapper;
import com.laundry.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.Random;

@RestController
@RequestMapping("/api/complaints")
@RequiredArgsConstructor
public class ComplaintController {

    private final ComplaintMapper mapper;

    @GetMapping
    public Result<?> list(@RequestParam(defaultValue = "1") int page,
                          @RequestParam(defaultValue = "10") int size,
                          @RequestParam(required = false) String status) {
        LambdaQueryWrapper<Complaint> wrapper = new LambdaQueryWrapper<>();
        if (status != null) wrapper.eq(Complaint::getStatus, status);
        if (!SecurityUtils.isAdmin()) {
            wrapper.eq(Complaint::getUserId, SecurityUtils.getCurrentUserId());
        }
        wrapper.orderByDesc(Complaint::getCreatedAt);
        return Result.success(mapper.selectPage(new Page<>(page, size), wrapper));
    }

    @GetMapping("/{id}")
    public Result<?> detail(@PathVariable Long id) {
        return Result.success(mapper.selectById(id));
    }

    @PostMapping
    public Result<?> create(@RequestBody Complaint complaint) {
        complaint.setUserId(SecurityUtils.getCurrentUserId());
        complaint.setComplaintNo("CP" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", new Random().nextInt(10000)));
        complaint.setStatus("PENDING");
        mapper.insert(complaint);
        return Result.success("投诉提交成功");
    }

    @PutMapping("/{id}/handle")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> handle(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Complaint c = mapper.selectById(id);
        if (c == null) throw new BusinessException("投诉不存在");
        c.setStatus(body.getOrDefault("status", "RESOLVED"));
        c.setHandlerId(SecurityUtils.getCurrentUserId());
        c.setHandleResult(body.get("handleResult"));
        c.setHandledAt(LocalDateTime.now());
        mapper.updateById(c);
        return Result.success("处理成功");
    }
}
