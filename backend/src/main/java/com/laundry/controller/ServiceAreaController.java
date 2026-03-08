package com.laundry.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.laundry.common.Result;
import com.laundry.entity.ServiceArea;
import com.laundry.mapper.ServiceAreaMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/service-areas")
@RequiredArgsConstructor
public class ServiceAreaController {

    private final ServiceAreaMapper mapper;

    @GetMapping
    public Result<?> list() {
        return Result.success(mapper.selectList(
                new LambdaQueryWrapper<ServiceArea>().eq(ServiceArea::getStatus, 1)));
    }

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> listAll(@RequestParam(defaultValue = "1") int page,
                             @RequestParam(defaultValue = "10") int size) {
        return Result.success(mapper.selectPage(new Page<>(page, size), null));
    }

    @GetMapping("/{id}")
    public Result<?> detail(@PathVariable Long id) {
        return Result.success(mapper.selectById(id));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody ServiceArea area) {
        mapper.insert(area);
        return Result.success("创建成功");
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody ServiceArea area) {
        area.setId(id);
        mapper.updateById(area);
        return Result.success("更新成功");
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        mapper.deleteById(id);
        return Result.success("删除成功");
    }
}
