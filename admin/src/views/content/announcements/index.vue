<template>
  <div class="p-4">
    <el-form :inline="true" class="mb-4"><el-form-item><el-button type="primary" @click="openForm()">新增公告</el-button></el-form-item></el-form>
    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="id" label="ID" width="60" />
      <el-table-column prop="title" label="标题" show-overflow-tooltip />
      <el-table-column prop="type" label="类型" width="100"><template #default="{ row }"><el-tag>{{ { NOTICE: '通知', PROMOTION: '促销', SYSTEM: '系统' }[row.type] || row.type }}</el-tag></template></el-table-column>
      <el-table-column prop="isTop" label="置顶" width="70"><template #default="{ row }"><el-tag v-if="row.isTop === 1" type="danger">是</el-tag><span v-else>否</span></template></el-table-column>
      <el-table-column prop="status" label="状态" width="80"><template #default="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '已发布' : '草稿' }}</el-tag></template></el-table-column>
      <el-table-column prop="publishAt" label="发布时间" width="170" />
      <el-table-column label="操作" width="230" fixed="right">
        <template #default="{ row }">
          <el-button size="small" @click="openForm(row)">编辑</el-button>
          <el-button size="small" type="success" v-if="row.status === 0" @click="publish(row)">发布</el-button>
          <el-button size="small" type="danger" @click="del(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination v-model:current-page="page" :total="total" layout="total,prev,pager,next" @current-change="fetchData" style="margin-top: 16px; justify-content: flex-end" />
    <el-dialog v-model="formVisible" :title="formData.id ? '编辑公告' : '新增公告'" width="600px">
      <el-form :model="formData" label-width="80px">
        <el-form-item label="标题"><el-input v-model="formData.title" /></el-form-item>
        <el-form-item label="类型"><el-select v-model="formData.type"><el-option label="通知" value="NOTICE" /><el-option label="促销" value="PROMOTION" /><el-option label="系统" value="SYSTEM" /></el-select></el-form-item>
        <el-form-item label="内容"><el-input v-model="formData.content" type="textarea" rows="6" /></el-form-item>
        <el-form-item label="置顶"><el-switch v-model="formData.isTop" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="formVisible = false">取消</el-button><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>
  </div>
</template>
<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import http from '@/api/http'
import { ElMessage, ElMessageBox } from 'element-plus'
defineOptions({ name: 'Announcements' })
const loading = ref(false), tableData = ref<any[]>([]), page = ref(1), total = ref(0)
const formVisible = ref(false), formData = reactive<any>({})
const fetchData = async () => { loading.value = true; try { const data = await http.get('/api/announcements/all', { page: page.value, size: 10 }); tableData.value = data.records; total.value = data.total } finally { loading.value = false } }
const openForm = (row?: any) => { Object.assign(formData, row || { id: null, title: '', content: '', type: 'NOTICE', isTop: 0, status: 0 }); formVisible.value = true }
const save = async () => { if (formData.id) { await http.put('/api/announcements/' + formData.id, formData) } else { await http.post('/api/announcements', formData) }; ElMessage.success('保存成功'); formVisible.value = false; fetchData() }
const publish = async (row: any) => { await http.put('/api/announcements/' + row.id + '/publish'); ElMessage.success('发布成功'); fetchData() }
const del = async (row: any) => { await ElMessageBox.confirm('确认删除？'); await http.delete('/api/announcements/' + row.id); ElMessage.success('删除成功'); fetchData() }
onMounted(fetchData)
</script>
