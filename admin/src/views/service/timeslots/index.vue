<template>
  <div class="p-4">
    <el-form :inline="true" class="mb-4"><el-form-item><el-button type="primary" @click="openForm()">新增时段</el-button></el-form-item></el-form>
    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="id" label="ID" width="60" />
      <el-table-column prop="slotDate" label="日期" width="120" />
      <el-table-column prop="startTime" label="开始" width="80" />
      <el-table-column prop="endTime" label="结束" width="80" />
      <el-table-column prop="capacity" label="容量" width="80" />
      <el-table-column prop="bookedCount" label="已预约" width="80" />
      <el-table-column prop="areaId" label="区域ID" min-width="80" />
      <el-table-column prop="status" label="状态" width="80"><template #default="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '启用' : '禁用' }}</el-tag></template></el-table-column>
      <el-table-column label="操作" width="150"><template #default="{ row }"><el-button size="small" @click="openForm(row)">编辑</el-button><el-button size="small" type="danger" @click="del(row)">删除</el-button></template></el-table-column>
    </el-table>
    <el-pagination v-model:current-page="page" :total="total" layout="total,prev,pager,next" @current-change="fetchData" style="margin-top: 16px; justify-content: flex-end" />
    <el-dialog v-model="formVisible" :title="formData.id ? '编辑时段' : '新增时段'" width="500px">
      <el-form :model="formData" label-width="80px">
        <el-form-item label="日期"><el-date-picker v-model="formData.slotDate" type="date" value-format="YYYY-MM-DD" /></el-form-item>
        <el-form-item label="开始时间"><el-input v-model="formData.startTime" placeholder="如 09:00" /></el-form-item>
        <el-form-item label="结束时间"><el-input v-model="formData.endTime" placeholder="如 11:00" /></el-form-item>
        <el-form-item label="容量"><el-input-number v-model="formData.capacity" :min="1" /></el-form-item>
        <el-form-item label="区域ID"><el-input-number v-model="formData.areaId" :min="1" /></el-form-item>
        <el-form-item label="状态"><el-switch v-model="formData.status" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="formVisible = false">取消</el-button><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>
  </div>
</template>
<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import http from '@/api/http'
import { ElMessage, ElMessageBox } from 'element-plus'
defineOptions({ name: 'TimeSlots' })
const loading = ref(false), tableData = ref<any[]>([]), page = ref(1), total = ref(0)
const formVisible = ref(false), formData = reactive<any>({})
const fetchData = async () => { loading.value = true; try { const data = await http.get('/api/time-slots/all', { page: page.value, size: 10 }); tableData.value = data.records; total.value = data.total } finally { loading.value = false } }
const openForm = (row?: any) => { Object.assign(formData, row || { id: null, slotDate: '', startTime: '', endTime: '', capacity: 10, areaId: 1, status: 1 }); formVisible.value = true }
const save = async () => { if (formData.id) { await http.put('/api/time-slots/' + formData.id, formData) } else { await http.post('/api/time-slots', formData) }; ElMessage.success('保存成功'); formVisible.value = false; fetchData() }
const del = async (row: any) => { await ElMessageBox.confirm('确认删除？'); await http.delete('/api/time-slots/' + row.id); ElMessage.success('删除成功'); fetchData() }
onMounted(fetchData)
</script>
