<template>
  <div class="p-4">
    <el-form :inline="true" class="mb-4">
      <el-form-item label="关键词"><el-input v-model="search.keyword" placeholder="姓名/手机号" clearable style="width: 200px" /></el-form-item>
      <el-form-item><el-button type="primary" @click="fetchData">查询</el-button></el-form-item>
    </el-form>
    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="id" label="ID" width="60" />
      <el-table-column prop="username" label="账号" width="120" />
      <el-table-column prop="nickname" label="姓名" min-width="120" />
      <el-table-column prop="phone" label="手机号" width="130" />
      <el-table-column label="身份证号" width="200">
        <template #default="{ row }">{{ row.idCard || '-' }}</template>
      </el-table-column>
      <el-table-column label="车牌号" width="120">
        <template #default="{ row }">{{ row.vehicleNo || '-' }}</template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="80">
        <template #default="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'danger'">{{ row.status === 1 ? '在岗' : '停用' }}</el-tag></template>
      </el-table-column>
      <el-table-column label="操作" width="100" fixed="right">
        <template #default="{ row }"><el-button size="small" :type="row.status === 1 ? 'danger' : 'success'" @click="toggleStatus(row)">{{ row.status === 1 ? '停用' : '启用' }}</el-button></template>
      </el-table-column>
    </el-table>
    <el-pagination v-model:current-page="page" :total="total" layout="total,prev,pager,next" @current-change="fetchData" style="margin-top: 16px; justify-content: flex-end" />
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import http from '@/api/http'
import { ElMessage } from 'element-plus'

defineOptions({ name: 'RiderList' })

const loading = ref(false), tableData = ref<any[]>([]), page = ref(1), total = ref(0), search = ref({ keyword: '' })
const fetchData = async () => {
  loading.value = true
  try {
    const data = await http.get('/api/admin/users', { page: page.value, size: 10, role: 'RIDER', keyword: search.value.keyword || undefined })
    tableData.value = data.records; total.value = data.total
  } finally { loading.value = false }
}
const toggleStatus = async (row: any) => { await http.put('/api/admin/users/' + row.id + '/status', { status: row.status === 1 ? 0 : 1 }); ElMessage.success('操作成功'); fetchData() }
onMounted(fetchData)
</script>
