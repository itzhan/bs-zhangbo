<template>
  <div class="section">
    <div class="container">
      <h2 class="section-title">服务项目</h2>
      <p class="section-desc">我们提供多种专业洗衣服务，满足您的各类需求</p>
      <n-space style="margin-bottom:24px" justify="center">
        <n-button :type="activeCategory===''?'primary':'default'" @click="activeCategory='';filterItems()" quaternary>全部</n-button>
        <n-button v-for="cat in categories" :key="cat" :type="activeCategory===cat?'primary':'default'" @click="activeCategory=cat;filterItems()" quaternary>{{ cat }}</n-button>
      </n-space>
      <div class="service-grid">
        <div class="card service-card" v-for="item in filteredItems" :key="item.id">
          <div v-if="item.image" class="card-img-wrap">
            <img :src="item.image" :alt="item.name" @error="(e: any) => e.target.style.display='none'" />
          </div>
          <div v-else class="card-icon-svg">
            <component :is="getCategoryIconComponent(item.category)" :size="32" :stroke-width="1.6" />
          </div>
          <h3>{{ item.name }}</h3>
          <p class="desc">{{ item.description || '专业清洗，品质保证' }}</p>
          <div style="display:flex;justify-content:space-between;align-items:center;margin-top:8px">
            <div><span class="price">¥{{ item.price }}</span><span class="price-unit">/{{ item.unit }}</span></div>
            <n-button type="primary" size="small" @click="$router.push('/order/create')">立即预约</n-button>
          </div>
        </div>
      </div>
      <n-empty v-if="!filteredItems.length && !loading" description="暂无服务项目" style="margin-top:60px" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, markRaw, type Component } from 'vue'
import { getServiceItems, getServiceCategories } from '@/api'
import { Shirt, ShieldCheck, Sparkles, Bed, Paintbrush } from 'lucide-vue-next'

const loading = ref(false)
const allItems = ref<any[]>([])
const filteredItems = ref<any[]>([])
const categories = ref<string[]>([])
const activeCategory = ref('')

const categoryIconMap: Record<string, Component> = {
  '衬衫': markRaw(Shirt),
  '上装': markRaw(Shirt),
  '外套': markRaw(ShieldCheck),
  '套装': markRaw(ShieldCheck),
  '裤装': markRaw(Shirt),
  '裙装': markRaw(Sparkles),
  '床品': markRaw(Bed),
  '特殊': markRaw(Paintbrush)
}
const getCategoryIconComponent = (cat: string) => categoryIconMap[cat] || markRaw(Shirt)

const filterItems = () => {
  filteredItems.value = activeCategory.value ? allItems.value.filter(i => i.category === activeCategory.value) : [...allItems.value]
}

onMounted(async () => {
  loading.value = true
  try {
    const res: any = await getServiceItems()
    allItems.value = res.data || []
    filteredItems.value = [...allItems.value]
    const catRes: any = await getServiceCategories()
    categories.value = catRes.data || []
  } catch {} finally { loading.value = false }
})
</script>

<style scoped>
.card-img-wrap {
  width: 100%;
  height: 140px;
  border-radius: 10px;
  overflow: hidden;
  margin-bottom: 12px;
}
.card-img-wrap img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.card-icon-svg {
  width: 60px;
  height: 60px;
  margin: 0 auto 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #e0edff 0%, #f0f7ff 100%);
  border-radius: 14px;
  color: var(--primary);
}
</style>
