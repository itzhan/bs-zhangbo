package com.laundry.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.laundry.common.Result;
import com.laundry.entity.TimeSlot;
import com.laundry.mapper.TimeSlotMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/time-slots")
@RequiredArgsConstructor
public class TimeSlotController {

    private final TimeSlotMapper mapper;

    @GetMapping
    public Result<?> list(@RequestParam(required = false) String date,
                          @RequestParam(required = false) Long areaId) {
        LambdaQueryWrapper<TimeSlot> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TimeSlot::getStatus, 1);
        if (date != null) wrapper.eq(TimeSlot::getSlotDate, LocalDate.parse(date));
        if (areaId != null) wrapper.eq(TimeSlot::getAreaId, areaId);
        wrapper.ge(TimeSlot::getSlotDate, LocalDate.now());
        wrapper.orderByAsc(TimeSlot::getSlotDate).orderByAsc(TimeSlot::getStartTime);
        return Result.success(mapper.selectList(wrapper));
    }

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> listAll(@RequestParam(defaultValue = "1") int page,
                             @RequestParam(defaultValue = "10") int size,
                             @RequestParam(required = false) Long areaId) {
        LambdaQueryWrapper<TimeSlot> wrapper = new LambdaQueryWrapper<>();
        if (areaId != null) wrapper.eq(TimeSlot::getAreaId, areaId);
        wrapper.orderByDesc(TimeSlot::getSlotDate).orderByAsc(TimeSlot::getStartTime);
        return Result.success(mapper.selectPage(new Page<>(page, size), wrapper));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody TimeSlot slot) {
        mapper.insert(slot);
        return Result.success("创建成功");
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody TimeSlot slot) {
        slot.setId(id);
        mapper.updateById(slot);
        return Result.success("更新成功");
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        mapper.deleteById(id);
        return Result.success("删除成功");
    }
}
