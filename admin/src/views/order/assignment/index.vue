<template>
  <div class="p-4">
    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="id" label="ID" width="60" />
      <el-table-column prop="orderNo" label="订单编号" width="180" />
      <el-table-column prop="riderId" label="骑手ID" width="80" />
      <el-table-column prop="type" label="类型" width="100">
        <template #default="{ row }"><el-tag>{{ row.type === 'PICKUP' ? '取件' : '送回' }}</el-tag></template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="row.status === 'COMPLETED' ? 'success' : row.status === 'PENDING' ? 'warning' : ''">{{ { PENDING: '待接单', ACCEPTED: '已接单', COMPLETED: '已完成' }[row.status] || row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="assignedAt" label="派单时间" width="170" />
      <el-table-column prop="acceptedAt" label="接单时间" width="170" />
      <el-table-column prop="completedAt" label="完成时间" width="170" />
      <el-table-column prop="remark" label="备注" show-overflow-tooltip />
    </el-table>
    <el-pagination v-model:current-page="page" :total="total" layout="total,prev,pager,next" @current-change="fetchData" style="margin-top: 16px; justify-content: flex-end" />
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import http from '@/api/http'

defineOptions({ name: 'OrderAssignment' })

const loading = ref(false)
const tableData = ref<any[]>([])
const page = ref(1)
const total = ref(0)

const fetchData = async () => {
  loading.value = true
  try {
    // 获取所有骑手的派单记录
    const data = await http.get('/api/orders/admin/assignments', { page: page.value, size: 20 })
    if (data && data.records) {
      tableData.value = data.records
      total.value = data.total
    } else if (Array.isArray(data)) {
      tableData.value = data
      total.value = data.length
    }
  } catch (e) {
    // 如果后端没有 admin/assignments 接口，回退到按状态查订单
    try {
      const data = await http.get('/api/orders', { page: page.value, size: 20, status: 'ASSIGNED' })
      tableData.value = (data.records || []).map((order: any) => ({
        id: order.id,
        orderNo: order.orderNo,
        riderId: order.riderId || '-',
        type: 'PICKUP',
        status: 'PENDING',
        assignedAt: order.updatedAt || order.createdAt,
        acceptedAt: null,
        completedAt: null,
        remark: order.remark
      }))
      total.value = data.total
    } catch (e2) {
      console.error('获取派单数据失败', e2)
    }
  } finally { loading.value = false }
}

onMounted(fetchData)
</script>
