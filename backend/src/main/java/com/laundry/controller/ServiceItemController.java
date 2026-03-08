package com.laundry.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.laundry.common.Result;
import com.laundry.entity.ServiceItem;
import com.laundry.mapper.ServiceItemMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/service-items")
@RequiredArgsConstructor
public class ServiceItemController {

    private final ServiceItemMapper mapper;

    @GetMapping
    public Result<?> list(@RequestParam(required = false) String category,
                          @RequestParam(required = false) String keyword) {
        LambdaQueryWrapper<ServiceItem> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ServiceItem::getStatus, 1);
        if (category != null) wrapper.eq(ServiceItem::getCategory, category);
        if (keyword != null && !keyword.isEmpty()) wrapper.like(ServiceItem::getName, keyword);
        wrapper.orderByAsc(ServiceItem::getSortOrder);
        return Result.success(mapper.selectList(wrapper));
    }

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> listAll(@RequestParam(defaultValue = "1") int page,
                             @RequestParam(defaultValue = "10") int size,
                             @RequestParam(required = false) String keyword) {
        LambdaQueryWrapper<ServiceItem> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isEmpty()) wrapper.like(ServiceItem::getName, keyword);
        wrapper.orderByAsc(ServiceItem::getSortOrder);
        return Result.success(mapper.selectPage(new Page<>(page, size), wrapper));
    }

    @GetMapping("/{id}")
    public Result<?> detail(@PathVariable Long id) {
        return Result.success(mapper.selectById(id));
    }

    @GetMapping("/categories")
    public Result<?> categories() {
        List<ServiceItem> items = mapper.selectList(
                new LambdaQueryWrapper<ServiceItem>().eq(ServiceItem::getStatus, 1)
                        .select(ServiceItem::getCategory).groupBy(ServiceItem::getCategory));
        return Result.success(items.stream().map(ServiceItem::getCategory).distinct().toList());
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody ServiceItem item) {
        mapper.insert(item);
        return Result.success("创建成功");
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody ServiceItem item) {
        item.setId(id);
        mapper.updateById(item);
        return Result.success("更新成功");
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        mapper.deleteById(id);
        return Result.success("删除成功");
    }
}
