package com.laundry.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.laundry.common.BusinessException;
import com.laundry.common.Result;
import com.laundry.entity.UserAddress;
import com.laundry.mapper.UserAddressMapper;
import com.laundry.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/addresses")
@RequiredArgsConstructor
public class AddressController {

    private final UserAddressMapper mapper;

    @GetMapping
    public Result<?> list() {
        Long userId = SecurityUtils.getCurrentUserId();
        return Result.success(mapper.selectList(
                new LambdaQueryWrapper<UserAddress>()
                        .eq(UserAddress::getUserId, userId)
                        .orderByDesc(UserAddress::getIsDefault)
                        .orderByDesc(UserAddress::getCreatedAt)));
    }

    @GetMapping("/{id}")
    public Result<?> detail(@PathVariable Long id) {
        UserAddress addr = mapper.selectById(id);
        if (addr == null || !addr.getUserId().equals(SecurityUtils.getCurrentUserId())) {
            throw new BusinessException("地址不存在");
        }
        return Result.success(addr);
    }

    @PostMapping
    public Result<?> create(@RequestBody UserAddress address) {
        address.setUserId(SecurityUtils.getCurrentUserId());
        if (address.getIsDefault() != null && address.getIsDefault() == 1) {
            clearDefault(address.getUserId());
        }
        mapper.insert(address);
        return Result.success("创建成功");
    }

    @PutMapping("/{id}")
    public Result<?> update(@PathVariable Long id, @RequestBody UserAddress address) {
        UserAddress exist = mapper.selectById(id);
        if (exist == null || !exist.getUserId().equals(SecurityUtils.getCurrentUserId())) {
            throw new BusinessException("地址不存在");
        }
        address.setId(id);
        address.setUserId(exist.getUserId());
        if (address.getIsDefault() != null && address.getIsDefault() == 1) {
            clearDefault(exist.getUserId());
        }
        mapper.updateById(address);
        return Result.success("更新成功");
    }

    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        UserAddress exist = mapper.selectById(id);
        if (exist == null || !exist.getUserId().equals(SecurityUtils.getCurrentUserId())) {
            throw new BusinessException("地址不存在");
        }
        mapper.deleteById(id);
        return Result.success("删除成功");
    }

    private void clearDefault(Long userId) {
        UserAddress clear = new UserAddress();
        clear.setIsDefault(0);
        mapper.update(clear, new LambdaQueryWrapper<UserAddress>()
                .eq(UserAddress::getUserId, userId)
                .eq(UserAddress::getIsDefault, 1));
    }
}
