package com.laundry.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.laundry.common.BusinessException;
import com.laundry.common.Result;
import com.laundry.entity.Review;
import com.laundry.entity.LaundryOrder;
import com.laundry.mapper.ReviewMapper;
import com.laundry.mapper.LaundryOrderMapper;
import com.laundry.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewMapper mapper;
    private final LaundryOrderMapper orderMapper;

    @GetMapping
    public Result<?> list(@RequestParam(defaultValue = "1") int page,
                          @RequestParam(defaultValue = "10") int size,
                          @RequestParam(required = false) Long orderId) {
        LambdaQueryWrapper<Review> wrapper = new LambdaQueryWrapper<>();
        if (orderId != null) wrapper.eq(Review::getOrderId, orderId);
        if (!SecurityUtils.isAdmin()) {
            wrapper.eq(Review::getUserId, SecurityUtils.getCurrentUserId());
        }
        wrapper.orderByDesc(Review::getCreatedAt);
        return Result.success(mapper.selectPage(new Page<>(page, size), wrapper));
    }

    @PostMapping
    public Result<?> create(@RequestBody Review review) {
        Long userId = SecurityUtils.getCurrentUserId();
        LaundryOrder order = orderMapper.selectById(review.getOrderId());
        if (order == null || !order.getUserId().equals(userId)) {
            throw new BusinessException("订单不存在");
        }
        if (!"COMPLETED".equals(order.getStatus())) {
            throw new BusinessException("只有已完成订单才能评价");
        }
        review.setUserId(userId);
        review.setOrderNo(order.getOrderNo());
        mapper.insert(review);
        return Result.success("评价成功");
    }

    @PutMapping("/{id}/reply")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> reply(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Review review = mapper.selectById(id);
        if (review == null) throw new BusinessException("评价不存在");
        review.setReply(body.get("reply"));
        review.setRepliedAt(LocalDateTime.now());
        mapper.updateById(review);
        return Result.success("回复成功");
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<?> delete(@PathVariable Long id) {
        mapper.deleteById(id);
        return Result.success("删除成功");
    }
}
