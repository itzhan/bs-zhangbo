<template>
  <div class="p-4">
    <el-form :inline="true" class="mb-4"><el-form-item><el-button type="primary" @click="openForm()">新增服务</el-button></el-form-item></el-form>
    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="id" label="ID" width="60" />
      <el-table-column prop="name" label="服务名称" width="150" />
      <el-table-column prop="category" label="分类" width="100" />
      <el-table-column prop="price" label="单价" width="100"><template #default="{ row }">¥{{ row.price }}</template></el-table-column>
      <el-table-column prop="unit" label="单位" width="60" />
      <el-table-column prop="description" label="描述" show-overflow-tooltip />
      <el-table-column prop="status" label="状态" width="80"><template #default="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '上架' : '下架' }}</el-tag></template></el-table-column>
      <el-table-column label="操作" width="150" fixed="right">
        <template #default="{ row }"><el-button size="small" @click="openForm(row)">编辑</el-button><el-button size="small" type="danger" @click="del(row)">删除</el-button></template>
      </el-table-column>
    </el-table>
    <el-pagination v-model:current-page="page" :total="total" layout="total,prev,pager,next" @current-change="fetchData" style="margin-top: 16px; justify-content: flex-end" />
    <el-dialog v-model="formVisible" :title="formData.id ? '编辑服务' : '新增服务'" width="500px">
      <el-form :model="formData" label-width="80px">
        <el-form-item label="名称"><el-input v-model="formData.name" /></el-form-item>
        <el-form-item label="分类"><el-input v-model="formData.category" /></el-form-item>
        <el-form-item label="单价"><el-input-number v-model="formData.price" :min="0" :precision="2" /></el-form-item>
        <el-form-item label="单位"><el-input v-model="formData.unit" /></el-form-item>
        <el-form-item label="描述"><el-input v-model="formData.description" type="textarea" /></el-form-item>
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
defineOptions({ name: 'ServiceItems' })
const loading = ref(false), tableData = ref<any[]>([]), page = ref(1), total = ref(0)
const formVisible = ref(false), formData = reactive<any>({})
const fetchData = async () => { loading.value = true; try { const data = await http.get('/api/service-items/all', { page: page.value, size: 10 }); tableData.value = data.records; total.value = data.total } finally { loading.value = false } }
const openForm = (row?: any) => { Object.assign(formData, row || { id: null, name: '', category: '', price: 0, unit: '件', description: '', status: 1 }); formVisible.value = true }
const save = async () => { if (formData.id) { await http.put('/api/service-items/' + formData.id, formData) } else { await http.post('/api/service-items', formData) }; ElMessage.success('保存成功'); formVisible.value = false; fetchData() }
const del = async (row: any) => { await ElMessageBox.confirm('确认删除？'); await http.delete('/api/service-items/' + row.id); ElMessage.success('删除成功'); fetchData() }
onMounted(fetchData)
</script>
