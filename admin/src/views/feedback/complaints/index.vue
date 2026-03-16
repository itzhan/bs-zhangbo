<template>
  <div class="p-4">
    <el-form :inline="true" class="mb-4">
      <el-form-item label="状态">
        <el-select v-model="search.status" placeholder="全部" clearable style="width: 120px">
          <el-option label="待处理" value="PENDING" /><el-option label="处理中" value="PROCESSING" /><el-option label="已解决" value="RESOLVED" /><el-option label="已关闭" value="CLOSED" />
        </el-select>
      </el-form-item>
      <el-form-item><el-button type="primary" @click="fetchData">查询</el-button></el-form-item>
    </el-form>
    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="complaintNo" label="投诉编号" width="180" />
      <el-table-column prop="orderNo" label="关联订单" width="180" />
      <el-table-column prop="type" label="类型" width="100" />
      <el-table-column prop="content" label="投诉内容" show-overflow-tooltip />
      <el-table-column prop="status" label="状态" width="90">
        <template #default="{ row }"><el-tag :type="({ PENDING: 'warning', PROCESSING: '', RESOLVED: 'success', CLOSED: 'info' } as any)[row.status] || ''">{{ { PENDING: '待处理', PROCESSING: '处理中', RESOLVED: '已解决', CLOSED: '已关闭' }[row.status] || row.status }}</el-tag></template>
      </el-table-column>
      <el-table-column prop="handleResult" label="处理结果" show-overflow-tooltip />
      <el-table-column prop="createdAt" label="投诉时间" width="170" />
      <el-table-column label="操作" width="100" fixed="right">
        <template #default="{ row }"><el-button size="small" type="primary" @click="openHandle(row)" v-if="row.status === 'PENDING' || row.status === 'PROCESSING'">处理</el-button></template>
      </el-table-column>
    </el-table>
    <el-pagination v-model:current-page="page" :total="total" layout="total,prev,pager,next" @current-change="fetchData" style="margin-top: 16px; justify-content: flex-end" />
    <el-dialog v-model="handleVisible" title="处理投诉" width="500px">
      <el-form label-width="80px">
        <el-form-item label="处理结果"><el-input v-model="handleResult" type="textarea" rows="4" /></el-form-item>
        <el-form-item label="状态"><el-select v-model="handleStatus"><el-option label="已解决" value="RESOLVED" /><el-option label="已关闭" value="CLOSED" /></el-select></el-form-item>
      </el-form>
      <template #footer><el-button @click="handleVisible = false">取消</el-button><el-button type="primary" @click="doHandle">提交</el-button></template>
    </el-dialog>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import http from '@/api/http'
import { ElMessage } from 'element-plus'
defineOptions({ name: 'Complaints' })
const loading = ref(false), tableData = ref<any[]>([]), page = ref(1), total = ref(0), search = ref({ status: '' })
const handleVisible = ref(false), handleResult = ref(''), handleStatus = ref('RESOLVED'), currentId = ref(0)
const fetchData = async () => { loading.value = true; try { const data = await http.get('/api/complaints', { page: page.value, size: 10, status: search.value.status || undefined }); tableData.value = data.records; total.value = data.total } finally { loading.value = false } }
const openHandle = (row: any) => { currentId.value = row.id; handleResult.value = ''; handleStatus.value = 'RESOLVED'; handleVisible.value = true }
const doHandle = async () => { await http.put('/api/complaints/' + currentId.value + '/handle', { handleResult: handleResult.value, status: handleStatus.value }); ElMessage.success('处理成功'); handleVisible.value = false; fetchData() }
onMounted(fetchData)
</script>
