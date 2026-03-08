<template>
  <div class="section">
    <div class="container" style="max-width:800px">
      <n-spin :show="loading">
        <template v-if="detail.order">
          <n-card title="订单详情" style="margin-bottom:16px">
            <n-descriptions :column="2" label-placement="left" bordered>
              <n-descriptions-item label="订单编号">{{ detail.order.orderNo }}</n-descriptions-item>
              <n-descriptions-item label="状态"><span class="status-tag" :class="'status-' + statusClass(detail.order.status)">{{ statusMap[detail.order.status] }}</span></n-descriptions-item>
              <n-descriptions-item label="联系人">{{ detail.order.contactName }}</n-descriptions-item>
              <n-descriptions-item label="电话">{{ detail.order.contactPhone }}</n-descriptions-item>
              <n-descriptions-item label="地址" :span="2">{{ detail.order.addressDetail }}</n-descriptions-item>
              <n-descriptions-item label="取件时段">{{ detail.order.pickupDate }} {{ detail.order.pickupTime }}</n-descriptions-item>
              <n-descriptions-item label="总金额"><span class="price">¥{{ detail.order.totalAmount }}</span></n-descriptions-item>
              <n-descriptions-item label="备注" :span="2">{{ detail.order.remark || '无' }}</n-descriptions-item>
              <n-descriptions-item label="下单时间">{{ detail.order.createdAt }}</n-descriptions-item>
              <n-descriptions-item label="完成时间">{{ detail.order.completedAt || '-' }}</n-descriptions-item>
            </n-descriptions>
          </n-card>

          <n-card title="服务明细" style="margin-bottom:16px">
            <n-data-table :data="detail.items || []" :columns="itemColumns" :bordered="false" size="small" />
          </n-card>

          <n-card title="骑手信息" v-if="detail.assignments?.length">
            <div v-for="a in detail.assignments" :key="a.id" style="padding:8px 0;border-bottom:1px solid var(--border)">
              <span>骑手ID: {{ a.riderId }}</span> ·
              <span>{{ a.type === 'PICKUP' ? '取件' : '送回' }}</span> ·
              <span>状态: {{ a.status }}</span>
            </div>
          </n-card>
        </template>
      </n-spin>

      <n-space style="margin-top:24px" justify="center">
        <n-button @click="$router.push('/order/list')">返回订单列表</n-button>
      </n-space>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, h, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getOrderDetail } from '@/api'

const route = useRoute()
const loading = ref(true)
const detail = ref<any>({})

const statusMap: Record<string, string> = { PENDING_PAY: '待支付', PAID: '已支付', ASSIGNED: '已派单', PICKED_UP: '已取件', WASHING: '清洗中', WASHED: '已清洗', DELIVERING: '配送中', COMPLETED: '已完成', CANCELLED: '已取消' }
const statusClass = (s: string) => ({ PENDING_PAY: 'pending', PAID: 'paid', COMPLETED: 'completed', CANCELLED: 'cancelled' }[s] || 'processing')

const itemColumns = [
  { title: '服务项目', key: 'serviceName' },
  { title: '单价', key: 'price', render: (row: any) => h('span', {}, '¥' + row.price) },
  { title: '数量', key: 'quantity' },
  { title: '小计', key: 'subtotal', render: (row: any) => h('span', { class: 'price', style: 'font-size:14px' }, '¥' + row.subtotal) }
]

onMounted(async () => {
  try {
    const res: any = await getOrderDetail(Number(route.params.id))
    detail.value = res.data
  } catch {} finally { loading.value = false }
})
</script>
