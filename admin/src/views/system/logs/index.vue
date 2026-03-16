<template>
  <div class="p-4">
    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="id" label="ID" width="60" />
      <el-table-column prop="username" label="操作人" width="100" />
      <el-table-column prop="module" label="模块" width="100" />
      <el-table-column prop="action" label="动作" width="80" />
      <el-table-column prop="description" label="描述" show-overflow-tooltip />
      <el-table-column prop="method" label="方法" width="70" />
      <el-table-column prop="url" label="URL" show-overflow-tooltip />
      <el-table-column prop="ip" label="IP" width="120" />
      <el-table-column prop="costTime" label="耗时(ms)" width="90" />
      <el-table-column prop="createdAt" label="时间" width="170" />
    </el-table>
    <el-pagination v-model:current-page="page" :total="total" layout="total,prev,pager,next" @current-change="fetchData" style="margin-top: 16px; justify-content: flex-end" />
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import http from '@/api/http'
defineOptions({ name: 'OperationLogs' })
const loading = ref(false), tableData = ref<any[]>([]), page = ref(1), total = ref(0)
const fetchData = async () => { loading.value = true; try { const data = await http.get('/api/operation-logs', { page: page.value, size: 10 }); tableData.value = data.records; total.value = data.total } finally { loading.value = false } }
onMounted(fetchData)
</script>
