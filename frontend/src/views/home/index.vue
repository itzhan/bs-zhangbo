<template>
  <div>
    <!-- Hero 区域 -->
    <section class="hero-section">
      <div class="container">
        <h1>专业上门洗衣，一键预约到家</h1>
        <p>告别洗衣烦恼，专业团队上门取送，高品质清洗，让您的衣物焕然一新</p>
        <n-space justify="center" :size="16">
          <n-button type="primary" size="large" @click="$router.push('/order/create')" round strong>
            立即预约
          </n-button>
          <n-button size="large" @click="$router.push('/services')" round>
            查看服务
          </n-button>
        </n-space>
      </div>
    </section>

    <!-- 服务流程 -->
    <section class="section">
      <div class="container">
        <h2 class="section-title">服务流程</h2>
        <p class="section-desc">四步完成洗衣，省时又省心</p>
        <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:24px;text-align:center">
          <div class="card" style="padding:32px 20px" v-for="(step, i) in steps" :key="i">
            <div style="font-size:48px;margin-bottom:12px">{{ step.icon }}</div>
            <div style="background:var(--primary);color:#fff;width:28px;height:28px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;margin-bottom:10px">{{ i + 1 }}</div>
            <h3 style="font-size:17px;font-weight:600;margin-bottom:6px">{{ step.title }}</h3>
            <p style="font-size:14px;color:var(--text-secondary)">{{ step.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- 热门服务 -->
    <section class="section" style="background:#fff">
      <div class="container">
        <h2 class="section-title">热门服务</h2>
        <p class="section-desc">精选专业清洗项目，满足您的各类需求</p>
        <div class="service-grid">
          <div class="card service-card" v-for="item in hotServices" :key="item.id" @click="$router.push('/services')">
            <div class="card-icon">{{ getCategoryIcon(item.category) }}</div>
            <h3>{{ item.name }}</h3>
            <p class="desc">{{ item.description }}</p>
            <div><span class="price">¥{{ item.price }}</span><span class="price-unit">/{{ item.unit }}</span></div>
          </div>
        </div>
      </div>
    </section>

    <!-- 数据展示 -->
    <section class="section">
      <div class="container">
        <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:24px;text-align:center">
          <div class="card" style="padding:32px" v-for="stat in stats" :key="stat.label">
            <div style="font-size:36px;font-weight:700;color:var(--primary);margin-bottom:8px">{{ stat.value }}</div>
            <div style="color:var(--text-secondary);font-size:15px">{{ stat.label }}</div>
          </div>
        </div>
      </div>
    </section>

    <!-- 公告 -->
    <section class="section" style="background:#fff" v-if="announcements.length">
      <div class="container">
        <h2 class="section-title">最新公告</h2>
        <div style="max-width:800px;margin:24px auto 0">
          <div class="card" style="padding:20px;margin-bottom:12px" v-for="ann in announcements" :key="ann.id">
            <n-space justify="space-between" align="center">
              <div>
                <n-tag size="small" :type="ann.type==='PROMOTION'?'warning':'info'" style="margin-right:8px">{{ {NOTICE:'通知',PROMOTION:'促销',SYSTEM:'系统'}[ann.type] || ann.type }}</n-tag>
                <strong>{{ ann.title }}</strong>
              </div>
              <span style="color:var(--text-muted);font-size:13px">{{ ann.publishAt?.substring(0, 10) }}</span>
            </n-space>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getServiceItems, getAnnouncements } from '@/api'

const steps = [
  { icon: '📱', title: '在线预约', desc: '选择服务项目，填写取件信息' },
  { icon: '🚗', title: '上门取件', desc: '专业骑手准时上门收取衣物' },
  { icon: '👔', title: '专业清洗', desc: '标准化洗护流程，精心处理' },
  { icon: '📦', title: '送衣到家', desc: '清洗完成后及时送回上门' }
]

const stats = [
  { value: '10,000+', label: '服务用户' },
  { value: '50,000+', label: '完成订单' },
  { value: '4.9', label: '平均评分' },
  { value: '98%', label: '好评率' }
]

const hotServices = ref<any[]>([])
const announcements = ref<any[]>([])

const categoryIcons: Record<string, string> = { '日常洗涤': '👕', '干洗护理': '🧥', '特殊处理': '👗', '家纺清洗': '🛏️' }
const getCategoryIcon = (cat: string) => categoryIcons[cat] || '🧹'

onMounted(async () => {
  try {
    const res: any = await getServiceItems()
    hotServices.value = (res.data || []).slice(0, 8)
  } catch {}
  try {
    const res: any = await getAnnouncements({ page: 1, size: 3 })
    announcements.value = res.data?.records || []
  } catch {}
})
</script>
