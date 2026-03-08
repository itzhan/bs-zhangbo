<template>
  <div class="section">
    <div class="container" style="max-width:700px">
      <h2 class="section-title">我的评价</h2>

      <!-- 新增评价（从订单列表跳转过来） -->
      <n-card v-if="$route.query.orderId" title="发表评价" style="margin-bottom:24px">
        <p style="margin-bottom:12px;color:var(--text-secondary)">订单号：{{ $route.query.orderNo }}</p>
        <n-form-item label="评分"><n-rate v-model:value="newReview.rating" /></n-form-item>
        <n-form-item label="评价内容"><n-input v-model:value="newReview.content" type="textarea" :rows="4" placeholder="请分享您的使用体验" /></n-form-item>
        <n-button type="primary" @click="submitReview" :loading="submitting">提交评价</n-button>
      </n-card>

      <!-- 历史评价列表 -->
      <n-spin :show="loading">
        <n-empty v-if="!reviews.length && !loading" description="暂无评价记录" />
        <div v-for="r in reviews" :key="r.id" class="card" style="padding:16px;margin-bottom:12px">
          <n-space justify="space-between" align="center" style="margin-bottom:8px">
            <n-rate :value="r.rating" readonly size="small" />
            <span style="color:var(--text-muted);font-size:13px">{{ r.createdAt }}</span>
          </n-space>
          <p style="margin-bottom:8px">{{ r.content }}</p>
          <p style="font-size:13px;color:var(--text-muted)">订单号：{{ r.orderNo }}</p>
          <div v-if="r.reply" style="background:#F0F9FF;padding:12px;border-radius:8px;margin-top:8px;font-size:14px">
            <strong style="color:var(--primary)">商家回复：</strong>{{ r.reply }}
          </div>
        </div>
      </n-spin>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getReviews, addReview } from '@/api'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const submitting = ref(false)
const reviews = ref<any[]>([])
const newReview = reactive({ rating: 5, content: '' })

async function fetchReviews() {
  loading.value = true
  try { const r: any = await getReviews({ page: 1, size: 50 }); reviews.value = r.data?.records || [] } catch {} finally { loading.value = false }
}

async function submitReview() {
  if (!newReview.content) { window.$message?.warning('请填写评价内容'); return }
  submitting.value = true
  try {
    await addReview({ orderId: Number(route.query.orderId), rating: newReview.rating, content: newReview.content })
    window.$message?.success('评价成功')
    router.replace('/review')
    fetchReviews()
  } catch {} finally { submitting.value = false }
}

onMounted(fetchReviews)
</script>
