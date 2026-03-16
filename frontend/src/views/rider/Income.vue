<template>
  <div class="section">
    <div class="container">
      <h2 class="section-title">收入查询</h2>
      <p class="section-desc">按月查看您的派单收入统计</p>

      <div v-if="loading" style="text-align:center;padding:60px 0">
        <n-spin size="large" />
      </div>

      <div v-else-if="!incomes.length" style="text-align:center;padding:60px 0">
        <n-empty description="暂无收入记录" />
      </div>

      <template v-else>
        <!-- 统计卡片 -->
        <div class="stat-row">
          <div class="card stat-card">
            <div class="stat-value" style="color:#2563eb">{{ totalOrders }}</div>
            <div class="stat-label">累计完成订单</div>
          </div>
          <div class="card stat-card">
            <div class="stat-value" style="color:#10b981">¥{{ totalIncome }}</div>
            <div class="stat-label">累计收入</div>
          </div>
          <div class="card stat-card">
            <div class="stat-value" style="color:#f59e0b">¥{{ avgIncome }}</div>
            <div class="stat-label">月均收入</div>
          </div>
        </div>

        <!-- 月度明细 -->
        <div class="income-list">
          <div class="card income-card" v-for="item in incomes" :key="item.id">
            <div class="income-month">{{ item.yearMonth }}</div>
            <div class="income-detail">
              <div class="income-item">
                <span class="label">完成订单</span>
                <span class="value">{{ item.totalOrders }} 单</span>
              </div>
              <div class="income-item">
                <span class="label">当月收入</span>
                <span class="value income-amount">¥{{ item.totalIncome }}</span>
              </div>
            </div>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { getRiderIncomes } from '@/api'

const incomes = ref<any[]>([])
const loading = ref(false)

const totalOrders = computed(() => incomes.value.reduce((s, i) => s + (i.totalOrders || 0), 0))
const totalIncome = computed(() => incomes.value.reduce((s, i) => s + Number(i.totalIncome || 0), 0).toFixed(2))
const avgIncome = computed(() => {
  const len = incomes.value.length
  return len ? (Number(totalIncome.value) / len).toFixed(2) : '0.00'
})

onMounted(async () => {
  loading.value = true
  try {
    const res: any = await getRiderIncomes()
    incomes.value = res.data?.records || res.data || []
  } catch {} finally { loading.value = false }
})
</script>

<style scoped>
.stat-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  max-width: 700px;
  margin: 0 auto 32px;
}
.stat-card {
  text-align: center;
  padding: 24px 16px;
}
.stat-value {
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 6px;
}
.stat-label {
  font-size: 14px;
  color: var(--text-secondary);
}
.income-list {
  max-width: 700px;
  margin: 0 auto;
}
.income-card {
  padding: 20px;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.income-month {
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary);
  min-width: 100px;
}
.income-detail {
  display: flex;
  gap: 32px;
}
.income-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.income-item .label {
  font-size: 13px;
  color: var(--text-secondary);
  margin-bottom: 4px;
}
.income-item .value {
  font-size: 16px;
  font-weight: 600;
}
.income-amount {
  color: #10b981;
}
</style>
