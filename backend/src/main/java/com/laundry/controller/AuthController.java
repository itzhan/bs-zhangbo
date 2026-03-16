package com.laundry.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.laundry.common.BusinessException;
import com.laundry.common.Result;
import com.laundry.dto.LoginDTO;
import com.laundry.dto.RegisterDTO;
import com.laundry.entity.SysUser;
import com.laundry.mapper.SysUserMapper;
import com.laundry.security.JwtUtil;
import com.laundry.security.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final SysUserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    @PostMapping("/login")
    public Result<?> login(@RequestBody @Valid LoginDTO dto) {
        String username = dto.getUsername().trim();
        SysUser user = userMapper.selectOne(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, username));
        if (user == null || !passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }
        if (user.getStatus() != 1) {
            throw new BusinessException("账号已被禁用");
        }
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("userInfo", buildUserInfo(user));
        return Result.success(data);
    }

    @PostMapping("/register")
    public Result<?> register(@RequestBody @Valid RegisterDTO dto) {
        Long count = userMapper.selectCount(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, dto.getUsername()));
        if (count > 0) {
            throw new BusinessException("用户名已存在");
        }
        SysUser user = new SysUser();
        user.setUsername(dto.getUsername());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setNickname(dto.getNickname() != null ? dto.getNickname() : dto.getUsername());
        user.setPhone(dto.getPhone());
        user.setRole(dto.getRole() != null ? dto.getRole() : "USER");
        user.setStatus(1);
        userMapper.insert(user);
        return Result.success("注册成功");
    }

    @GetMapping("/info")
    public Result<?> getUserInfo() {
        SysUser user = SecurityUtils.getCurrentUser();
        if (user == null) {
            throw new BusinessException(401, "未登录");
        }
        return Result.success(buildUserInfo(user));
    }

    @PutMapping("/profile")
    public Result<?> updateProfile(@RequestBody SysUser dto) {
        SysUser current = SecurityUtils.getCurrentUser();
        if (current == null) throw new BusinessException(401, "未登录");
        SysUser update = new SysUser();
        update.setId(current.getId());
        update.setNickname(dto.getNickname());
        update.setPhone(dto.getPhone());
        update.setEmail(dto.getEmail());
        update.setAvatar(dto.getAvatar());
        update.setGender(dto.getGender());
        userMapper.updateById(update);
        return Result.success("更新成功");
    }

    @PutMapping("/password")
    public Result<?> changePassword(@RequestBody Map<String, String> body) {
        SysUser current = SecurityUtils.getCurrentUser();
        if (current == null) throw new BusinessException(401, "未登录");
        String oldPwd = body.get("oldPassword");
        String newPwd = body.get("newPassword");
        SysUser dbUser = userMapper.selectById(current.getId());
        if (!passwordEncoder.matches(oldPwd, dbUser.getPassword())) {
            throw new BusinessException("原密码错误");
        }
        SysUser update = new SysUser();
        update.setId(current.getId());
        update.setPassword(passwordEncoder.encode(newPwd));
        userMapper.updateById(update);
        return Result.success("密码修改成功");
    }

    private Map<String, Object> buildUserInfo(SysUser user) {
        Map<String, Object> info = new HashMap<>();
        info.put("id", user.getId());
        info.put("username", user.getUsername());
        info.put("nickname", user.getNickname());
        info.put("phone", user.getPhone());
        info.put("email", user.getEmail());
        info.put("avatar", user.getAvatar());
        info.put("gender", user.getGender());
        info.put("role", user.getRole());
        info.put("status", user.getStatus());
        return info;
    }
}
