<template>
  <div class="section">
    <div class="container" style="max-width:900px">
      <h2 class="section-title">我的订单</h2>
      <n-tabs v-model:value="activeTab" type="line" @update:value="fetchOrders" style="margin-bottom:16px">
        <n-tab name="">全部</n-tab>
        <n-tab name="PENDING_PAY">待支付</n-tab>
        <n-tab name="PAID">已支付</n-tab>
        <n-tab name="ASSIGNED">已派单</n-tab>
        <n-tab name="WASHING">清洗中</n-tab>
        <n-tab name="COMPLETED">已完成</n-tab>
      </n-tabs>

      <n-spin :show="loading">
        <n-empty v-if="!orders.length && !loading" description="暂无订单" style="margin-top:60px" />
        <div v-for="order in orders" :key="order.id" class="card" style="padding:20px;margin-bottom:16px">
          <n-space justify="space-between" align="center" style="margin-bottom:12px">
            <div>
              <span style="font-weight:600">{{ order.orderNo }}</span>
              <span class="status-tag" :class="'status-' + statusClass(order.status)" style="margin-left:12px">{{ statusMap[order.status] || order.status }}</span>
            </div>
            <span style="color:var(--text-muted);font-size:13px">{{ order.createdAt }}</span>
          </n-space>
          <div style="color:var(--text-secondary);font-size:14px;margin-bottom:8px">
            {{ order.contactName }} {{ order.contactPhone }} · {{ order.addressDetail }}
          </div>
          <n-space justify="space-between" align="center">
            <div class="price">¥{{ order.totalAmount }}</div>
            <n-space>
              <n-button size="small" @click="$router.push('/order/' + order.id)">查看详情</n-button>
              <n-button size="small" type="primary" v-if="order.status==='PENDING_PAY'" @click="handlePay(order)">立即支付</n-button>
              <n-button size="small" type="error" v-if="['PENDING_PAY','PAID'].includes(order.status)" @click="handleCancel(order)">取消</n-button>
              <n-button size="small" type="success" v-if="order.status==='COMPLETED'" @click="goReview(order)">去评价</n-button>
            </n-space>
          </n-space>
        </div>
      </n-spin>

      <n-pagination v-if="total > 10" v-model:page="page" :page-count="Math.ceil(total/10)" @update:page="fetchOrders" style="margin-top:16px;justify-content:center" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getOrders, payOrder, cancelOrder } from '@/api'

const router = useRouter()
const loading = ref(false)
const orders = ref<any[]>([])
const page = ref(1)
const total = ref(0)
const activeTab = ref('')

const statusMap: Record<string, string> = {
  PENDING_PAY: '待支付', PAID: '已支付', ASSIGNED: '已派单', PICKED_UP: '已取件',
  WASHING: '清洗中', WASHED: '已清洗', DELIVERING: '配送中', COMPLETED: '已完成',
  CANCELLED: '已取消', REVIEWED: '已评价'
}
const statusClass = (s: string) => ({ PENDING_PAY: 'pending', PAID: 'paid', ASSIGNED: 'processing', PICKED_UP: 'processing', WASHING: 'processing', WASHED: 'processing', DELIVERING: 'processing', COMPLETED: 'completed', CANCELLED: 'cancelled' }[s] || 'pending')

async function fetchOrders() {
  loading.value = true
  try {
    const res: any = await getOrders({ page: page.value, size: 10, status: activeTab.value || undefined })
    orders.value = res.data?.records || []
    total.value = res.data?.total || 0
  } catch {} finally { loading.value = false }
}

async function handlePay(order: any) {
  try { await payOrder(order.id); window.$message?.success('支付成功'); fetchOrders() } catch {}
}
async function handleCancel(order: any) {
  try { await cancelOrder(order.id, '用户取消'); window.$message?.success('已取消'); fetchOrders() } catch {}
}
function goReview(order: any) { router.push({ path: '/review', query: { orderId: order.id, orderNo: order.orderNo } }) }

onMounted(fetchOrders)
</script>
