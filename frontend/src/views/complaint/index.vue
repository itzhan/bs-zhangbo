<template>
  <div class="section">
    <div class="container" style="max-width:700px">
      <h2 class="section-title">投诉反馈</h2>

      <n-card title="提交投诉" style="margin-bottom:24px">
        <n-form :model="form" label-placement="left" label-width="80px">
          <n-form-item label="关联订单"><n-input v-model:value="form.orderNo" placeholder="订单编号（选填）" /></n-form-item>
          <n-form-item label="投诉类型">
            <n-select v-model:value="form.type" :options="typeOptions" placeholder="请选择类型" />
          </n-form-item>
          <n-form-item label="投诉内容"><n-input v-model:value="form.content" type="textarea" :rows="4" placeholder="请详细描述您的问题" /></n-form-item>
          <n-form-item><n-button type="primary" @click="submitComplaint" :loading="submitting">提交投诉</n-button></n-form-item>
        </n-form>
      </n-card>

      <h3 style="margin-bottom:12px;font-weight:600">投诉记录</h3>
      <n-spin :show="loading">
        <n-empty v-if="!complaints.length && !loading" description="暂无投诉记录" />
        <div v-for="c in complaints" :key="c.id" class="card" style="padding:16px;margin-bottom:12px">
          <n-space justify="space-between" align="center" style="margin-bottom:8px">
            <div>
              <span style="font-weight:600">{{ c.complaintNo }}</span>
              <span class="status-tag" :class="{
                'status-pending': c.status==='PENDING',
                'status-processing': c.status==='PROCESSING',
                'status-completed': c.status==='RESOLVED',
                'status-cancelled': c.status==='CLOSED'
              }" style="margin-left:8px">{{ {PENDING:'待处理',PROCESSING:'处理中',RESOLVED:'已解决',CLOSED:'已关闭'}[c.status] }}</span>
            </div>
            <span style="color:var(--text-muted);font-size:13px">{{ c.createdAt }}</span>
          </n-space>
          <p style="margin-bottom:4px">{{ c.content }}</p>
          <div v-if="c.handleResult" style="background:#F0FDF4;padding:12px;border-radius:8px;margin-top:8px;font-size:14px">
            <strong style="color:var(--success)">处理结果：</strong>{{ c.handleResult }}
          </div>
        </div>
      </n-spin>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { getComplaints, addComplaint } from '@/api'

const loading = ref(false)
const submitting = ref(false)
const complaints = ref<any[]>([])
const form = reactive({ orderNo: '', type: 'SERVICE', content: '' })
const typeOptions = [
  { label: '服务问题', value: 'SERVICE' },
  { label: '骑手问题', value: 'RIDER' },
  { label: '质量问题', value: 'QUALITY' },
  { label: '其他', value: 'OTHER' }
]

async function fetchComplaints() {
  loading.value = true
  try { const r: any = await getComplaints({ page: 1, size: 50 }); complaints.value = r.data?.records || [] } catch {} finally { loading.value = false }
}

async function submitComplaint() {
  if (!form.content) { window.$message?.warning('请填写投诉内容'); return }
  submitting.value = true
  try {
    await addComplaint(form)
    window.$message?.success('投诉提交成功')
    form.content = ''; form.orderNo = ''
    fetchComplaints()
  } catch {} finally { submitting.value = false }
}

onMounted(fetchComplaints)
</script>
