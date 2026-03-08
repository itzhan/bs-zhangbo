package com.laundry.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.laundry.common.BusinessException;
import com.laundry.common.Result;
import com.laundry.entity.*;
import com.laundry.mapper.*;
import com.laundry.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminController {

    private final SysUserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    // ==================== 用户管理 ====================
    @GetMapping("/users")
    public Result<?> listUsers(@RequestParam(defaultValue = "1") int page,
                               @RequestParam(defaultValue = "10") int size,
                               @RequestParam(required = false) String role,
                               @RequestParam(required = false) String keyword) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        if (role != null) wrapper.eq(SysUser::getRole, role);
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(SysUser::getUsername, keyword)
                    .or().like(SysUser::getNickname, keyword)
                    .or().like(SysUser::getPhone, keyword));
        }
        wrapper.orderByDesc(SysUser::getCreatedAt);
        return Result.success(userMapper.selectPage(new Page<>(page, size), wrapper));
    }

    @GetMapping("/users/{id}")
    public Result<?> getUser(@PathVariable Long id) {
        return Result.success(userMapper.selectById(id));
    }

    @PostMapping("/users")
    public Result<?> createUser(@RequestBody SysUser user) {
        Long count = userMapper.selectCount(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, user.getUsername()));
        if (count > 0) throw new BusinessException("用户名已存在");
        user.setPassword(passwordEncoder.encode(user.getPassword() != null ? user.getPassword() : "123456"));
        if (user.getStatus() == null) user.setStatus(1);
        userMapper.insert(user);
        return Result.success("创建成功");
    }

    @PutMapping("/users/{id}")
    public Result<?> updateUser(@PathVariable Long id, @RequestBody SysUser user) {
        user.setId(id);
        user.setPassword(null); // 不通过此接口修改密码
        userMapper.updateById(user);
        return Result.success("更新成功");
    }

    @DeleteMapping("/users/{id}")
    public Result<?> deleteUser(@PathVariable Long id) {
        if (id.equals(SecurityUtils.getCurrentUserId())) {
            throw new BusinessException("不能删除自己");
        }
        userMapper.deleteById(id);
        return Result.success("删除成功");
    }

    @PutMapping("/users/{id}/status")
    public Result<?> toggleUserStatus(@PathVariable Long id, @RequestBody SysUser body) {
        SysUser update = new SysUser();
        update.setId(id);
        update.setStatus(body.getStatus());
        userMapper.updateById(update);
        return Result.success("状态更新成功");
    }

    @PutMapping("/users/{id}/reset-password")
    public Result<?> resetPassword(@PathVariable Long id) {
        SysUser update = new SysUser();
        update.setId(id);
        update.setPassword(passwordEncoder.encode("123456"));
        userMapper.updateById(update);
        return Result.success("密码已重置为 123456");
    }
}
