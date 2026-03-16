<template>
  <div class="section">
    <div class="container">
      <h2 class="section-title">我的派单</h2>
      <p class="section-desc">查看和管理已分配给您的取送订单</p>

      <n-tabs v-model:value="statusFilter" type="segment" style="margin-bottom:24px;max-width:500px;margin-left:auto;margin-right:auto" @update:value="loadAssignments">
        <n-tab-pane name="all" tab="全部" />
        <n-tab-pane name="ASSIGNED" tab="待接单" />
        <n-tab-pane name="ACCEPTED" tab="进行中" />
        <n-tab-pane name="COMPLETED" tab="已完成" />
      </n-tabs>

      <div v-if="loading" style="text-align:center;padding:60px 0">
        <n-spin size="large" />
      </div>

      <div v-else-if="!assignments.length" style="text-align:center;padding:60px 0">
        <n-empty description="暂无派单记录" />
      </div>

      <div v-else class="assignment-list">
        <div class="card assignment-card" v-for="item in assignments" :key="item.id">
          <div class="assignment-header">
            <n-tag :type="statusTag(item.status)" size="small">{{ statusText(item.status) }}</n-tag>
            <span class="assignment-id">派单号 #{{ item.id }}</span>
          </div>
          <div class="assignment-body">
            <div class="info-row">
              <span class="label">订单号</span>
              <span>{{ item.orderNumber || 'ORD-' + item.orderId }}</span>
            </div>
            <div class="info-row" v-if="item.pickupAddress">
              <span class="label">取件地址</span>
              <span>{{ item.pickupAddress }}</span>
            </div>
            <div class="info-row" v-if="item.deliveryAddress">
              <span class="label">送件地址</span>
              <span>{{ item.deliveryAddress }}</span>
            </div>
            <div class="info-row">
              <span class="label">创建时间</span>
              <span>{{ item.createdAt?.substring(0, 16) }}</span>
            </div>
          </div>
          <div class="assignment-actions">
            <n-button v-if="item.status === 'ASSIGNED'" type="primary" @click="handleAccept(item.id)" :loading="actionLoading === item.id">
              接受派单
            </n-button>
            <n-button v-if="item.status === 'ACCEPTED'" type="success" @click="handleComplete(item.id)" :loading="actionLoading === item.id">
              确认完成
            </n-button>
            <n-button v-if="item.status === 'COMPLETED'" quaternary disabled>已完成</n-button>
          </div>
        </div>
      </div>

      <div v-if="total > pageSize" style="text-align:center;margin-top:24px">
        <n-pagination v-model:page="page" :page-size="pageSize" :item-count="total" @update:page="loadAssignments" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getRiderAssignments, acceptAssignment, completeAssignment } from '@/api'

const assignments = ref<any[]>([])
const loading = ref(false)
const actionLoading = ref<number | null>(null)
const statusFilter = ref('all')
const page = ref(1)
const pageSize = 10
const total = ref(0)

const statusText = (s: string) => ({ ASSIGNED: '待接单', ACCEPTED: '进行中', COMPLETED: '已完成' }[s] || s)
const statusTag = (s: string): any => ({ ASSIGNED: 'warning', ACCEPTED: 'info', COMPLETED: 'success' }[s] || 'default')

async function loadAssignments() {
  loading.value = true
  try {
    const params: any = { page: page.value, size: pageSize }
    if (statusFilter.value !== 'all') params.status = statusFilter.value
    const res: any = await getRiderAssignments(params)
    assignments.value = res.data?.records || res.data || []
    total.value = res.data?.total || assignments.value.length
  } catch {} finally { loading.value = false }
}

async function handleAccept(id: number) {
  actionLoading.value = id
  try {
    await acceptAssignment(id)
    ;(window as any).$message?.success('接单成功！')
    await loadAssignments()
  } catch { (window as any).$message?.error('操作失败') } finally { actionLoading.value = null }
}

async function handleComplete(id: number) {
  actionLoading.value = id
  try {
    await completeAssignment(id)
    ;(window as any).$message?.success('已确认完成')
    await loadAssignments()
  } catch { (window as any).$message?.error('操作失败') } finally { actionLoading.value = null }
}

onMounted(() => loadAssignments())
</script>

<style scoped>
.assignment-list { max-width: 700px; margin: 0 auto; }
.assignment-card { padding: 20px; margin-bottom: 16px; }
.assignment-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.assignment-id { font-size: 13px; color: var(--text-muted); }
.assignment-body { margin-bottom: 16px; }
.info-row { display: flex; gap: 12px; padding: 6px 0; font-size: 14px; }
.info-row .label { color: var(--text-secondary); min-width: 70px; flex-shrink: 0; }
.assignment-actions { text-align: right; }
</style>
