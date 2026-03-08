<template>
  <n-config-provider :theme-overrides="themeOverrides">
    <n-message-provider>
      <n-dialog-provider>
        <MessageApi />
        <header class="app-header">
          <div class="header-inner">
            <router-link to="/" class="logo">
              <span class="logo-icon">🧺</span>
              <span>洁衣到家</span>
            </router-link>
            <nav>
              <router-link to="/">首页</router-link>
              <router-link to="/services">服务项目</router-link>
              <router-link to="/order/create" v-if="userStore.isLoggedIn">在线预约</router-link>
              <router-link to="/order/list" v-if="userStore.isLoggedIn">我的订单</router-link>
            </nav>
            <div class="header-actions">
              <template v-if="userStore.isLoggedIn">
                <n-dropdown :options="userMenuOptions" @select="handleUserMenu">
                  <n-button quaternary>
                    <n-avatar :size="28" round style="margin-right:6px;background:#2563EB">{{ (userStore.userInfo.nickname || userStore.userInfo.username || 'U')[0] }}</n-avatar>
                    {{ userStore.userInfo.nickname || userStore.userInfo.username }}
                  </n-button>
                </n-dropdown>
              </template>
              <template v-else>
                <n-button @click="$router.push('/login')" quaternary>登录</n-button>
                <n-button @click="$router.push('/register')" type="primary" size="small">注册</n-button>
              </template>
            </div>
          </div>
        </header>
        <main style="min-height: calc(100vh - 200px)">
          <router-view />
        </main>
        <footer class="app-footer">
          <div class="container">
            <div class="footer-brand">洁衣到家</div>
            <p>专业上门洗衣预约服务平台，让洗衣更轻松</p>
            <div class="footer-links">
              <router-link to="/">首页</router-link>
              <router-link to="/services">服务项目</router-link>
              <router-link to="/complaint">投诉建议</router-link>
            </div>
            <div class="copyright">© 2025 洁衣到家 - 基于 Spring Boot 的上门洗衣预约服务系统</div>
          </div>
        </footer>
      </n-dialog-provider>
    </n-message-provider>
  </n-config-provider>
</template>

<script setup lang="ts">
import { h, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useMessage, type GlobalThemeOverrides } from 'naive-ui'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const themeOverrides: GlobalThemeOverrides = {
  common: {
    primaryColor: '#2563EB',
    primaryColorHover: '#3B82F6',
    primaryColorPressed: '#1D4ED8',
    borderRadius: '8px'
  }
}

const userMenuOptions = computed(() => [
  { label: '个人中心', key: 'profile' },
  { label: '地址管理', key: 'address' },
  { label: '我的评价', key: 'review' },
  { label: '投诉反馈', key: 'complaint' },
  { type: 'divider', key: 'd1' },
  { label: '退出登录', key: 'logout' }
])

function handleUserMenu(key: string) {
  if (key === 'logout') {
    userStore.logout()
    router.push('/')
  } else if (key === 'profile') {
    router.push('/user/profile')
  } else if (key === 'address') {
    router.push('/user/address')
  } else if (key === 'review') {
    router.push('/review')
  } else if (key === 'complaint') {
    router.push('/complaint')
  }
}
</script>

<script lang="ts">
import { defineComponent } from 'vue'
import { useMessage as useMsg } from 'naive-ui'
const MessageApi = defineComponent({
  setup() {
    (window as any).$message = useMsg()
    return () => null
  }
})
export default { components: { MessageApi } }
</script>
