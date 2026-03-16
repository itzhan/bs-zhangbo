<template>
  <div class="login-container">
    <div class="login-left">
      <div class="left-content">
        <div class="brand-icon">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="56"
            height="56"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#fff"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M3 6h3" />
            <path d="M17 6h.01" />
            <rect width="18" height="20" x="3" y="2" rx="2" />
            <circle cx="12" cy="13" r="5" />
            <path d="M12 18a2.5 2.5 0 0 0 0-5 2.5 2.5 0 0 1 0-5" />
          </svg>
        </div>
        <h1 class="brand-title">洁衣到家</h1>
        <p class="brand-desc">上门洗衣预约服务管理系统</p>
        <div class="feature-list">
          <div class="feature-item">
            <div class="feature-dot" />
            <span>智能订单管理与调度</span>
          </div>
          <div class="feature-item">
            <div class="feature-dot" />
            <span>实时数据统计分析</span>
          </div>
          <div class="feature-item">
            <div class="feature-dot" />
            <span>骑手派单与轨迹跟踪</span>
          </div>
          <div class="feature-item">
            <div class="feature-dot" />
            <span>用户评价与投诉处理</span>
          </div>
        </div>
      </div>
    </div>
    <div class="login-right">
      <SwitchDark class="dark-switch" />
      <div class="login-form-wrap">
        <h2 class="form-title">欢迎回来</h2>
        <p class="form-subtitle">请登录管理后台</p>
        <LoginForm />
      </div>
      <div class="login-footer">© 2025 洁衣到家 · 毕业设计</div>
    </div>
  </div>
</template>

<script setup lang="ts" name="login">
import LoginForm from "./components/LoginForm.vue";
import SwitchDark from "@/components/SwitchDark/index.vue";
</script>

<style scoped lang="scss">
@import "./index.scss";
</style>
