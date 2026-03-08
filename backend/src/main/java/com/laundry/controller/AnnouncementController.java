package com.laundry.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.laundry.common.Result;
import com.laundry.entity.Announcement;
import com.laundry.mapper.AnnouncementMapper;
import com.laundry.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/announcements")
@RequiredArgsConstructor
public class AnnouncementController {

    private final AnnouncementMapper mapper;

    @GetMapping
    public Result<?> list(@RequestParam(defaultValue = "1") int page,
                          @RequestParam(defaultValue = "10") int size) {
        return Result.success(mapper.selectPage(new Page<>(page, size),
                new LambdaQueryWrapper<Announcement>()
                        .eq(Announcement::getStatus, 1)
                        .orderByDesc(Announcement::getIsTop)
                        .orderByDesc(Announcement::getPublishAt)));
    }

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> listAll(@RequestParam(defaultValue = "1") int page,
                             @RequestParam(defaultValue = "10") int size) {
        return Result.success(mapper.selectPage(new Page<>(page, size),
                new LambdaQueryWrapper<Announcement>().orderByDesc(Announcement::getCreatedAt)));
    }

    @GetMapping("/{id}")
    public Result<?> detail(@PathVariable Long id) {
        return Result.success(mapper.selectById(id));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> create(@RequestBody Announcement ann) {
        ann.setCreatedBy(SecurityUtils.getCurrentUserId());
        if (ann.getStatus() != null && ann.getStatus() == 1) {
            ann.setPublishAt(LocalDateTime.now());
        }
        mapper.insert(ann);
        return Result.success("创建成功");
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> update(@PathVariable Long id, @RequestBody Announcement ann) {
        ann.setId(id);
        mapper.updateById(ann);
        return Result.success("更新成功");
    }

    @PutMapping("/{id}/publish")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> publish(@PathVariable Long id) {
        Announcement ann = new Announcement();
        ann.setId(id);
        ann.setStatus(1);
        ann.setPublishAt(LocalDateTime.now());
        mapper.updateById(ann);
        return Result.success("发布成功");
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        mapper.deleteById(id);
        return Result.success("删除成功");
    }
}
