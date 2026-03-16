<template>
  <div class="p-4">
    <el-table :data="tableData" border stripe v-loading="loading">
      <el-table-column prop="id" label="ID" width="60" />
      <el-table-column prop="orderNo" label="订单号" width="180" />
      <el-table-column prop="userId" label="用户ID" width="80" />
      <el-table-column prop="rating" label="评分" width="140"><template #default="{ row }"><el-rate :model-value="row.rating" disabled /></template></el-table-column>
      <el-table-column prop="content" label="评价内容" show-overflow-tooltip />
      <el-table-column prop="reply" label="回复" show-overflow-tooltip />
      <el-table-column prop="createdAt" label="评价时间" width="170" />
      <el-table-column label="操作" width="150" fixed="right">
        <template #default="{ row }">
          <el-button size="small" @click="openReply(row)" v-if="!row.reply">回复</el-button>
          <el-button size="small" type="danger" @click="del(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination v-model:current-page="page" :total="total" layout="total,prev,pager,next" @current-change="fetchData" style="margin-top: 16px; justify-content: flex-end" />
    <el-dialog v-model="replyVisible" title="回复评价" width="500px">
      <el-input v-model="replyContent" type="textarea" rows="4" placeholder="输入回复内容" />
      <template #footer><el-button @click="replyVisible = false">取消</el-button><el-button type="primary" @click="doReply">提交</el-button></template>
    </el-dialog>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import http from '@/api/http'
import { ElMessage, ElMessageBox } from 'element-plus'
defineOptions({ name: 'Reviews' })
const loading = ref(false), tableData = ref<any[]>([]), page = ref(1), total = ref(0)
const replyVisible = ref(false), replyContent = ref(''), currentId = ref(0)
const fetchData = async () => { loading.value = true; try { const data = await http.get('/api/reviews', { page: page.value, size: 10 }); tableData.value = data.records; total.value = data.total } finally { loading.value = false } }
const openReply = (row: any) => { currentId.value = row.id; replyContent.value = ''; replyVisible.value = true }
const doReply = async () => { await http.put('/api/reviews/' + currentId.value + '/reply', { reply: replyContent.value }); ElMessage.success('回复成功'); replyVisible.value = false; fetchData() }
const del = async (row: any) => { await ElMessageBox.confirm('确认删除？'); await http.delete('/api/reviews/' + row.id); ElMessage.success('删除成功'); fetchData() }
onMounted(fetchData)
</script>
