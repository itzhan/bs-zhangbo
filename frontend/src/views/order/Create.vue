<template>
  <div class="section">
    <div class="container" style="max-width:800px">
      <h2 class="section-title">在线预约</h2>
      <p class="section-desc">选择服务、地址和时段，一键下单</p>

      <n-card title="① 选择服务项目" style="margin-bottom:16px">
        <div class="service-grid" style="grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:12px">
          <div v-for="item in serviceItems" :key="item.id" class="card" style="padding:16px;cursor:pointer;border:2px solid transparent" :style="isSelected(item.id)?{borderColor:'var(--primary)',background:'#EFF6FF'}:{}" @click="toggleItem(item)">
            <div style="font-weight:600;margin-bottom:4px">{{ item.name }}</div>
            <div style="font-size:13px;color:var(--text-secondary);margin-bottom:6px">{{ item.category }}</div>
            <div><span class="price" style="font-size:16px">¥{{ item.price }}</span><span class="price-unit">/{{ item.unit }}</span></div>
            <n-input-number v-if="isSelected(item.id)" :value="getQty(item.id)" @update:value="v=>setQty(item.id,v)" :min="1" :max="99" size="small" style="margin-top:8px;width:100px" />
          </div>
        </div>
      </n-card>

      <n-card title="② 选择收件地址" style="margin-bottom:16px">
        <n-empty v-if="!addresses.length" description="暂无地址">
          <template #extra><n-button size="small" @click="$router.push('/user/address')">去添加</n-button></template>
        </n-empty>
        <n-radio-group v-model:value="form.addressId" v-else>
          <n-space vertical>
            <n-radio v-for="addr in addresses" :key="addr.id" :value="addr.id">
              {{ addr.contactName }} {{ addr.contactPhone }} - {{ addr.province }}{{ addr.city }}{{ addr.district }}{{ addr.detail }}
              <n-tag v-if="addr.isDefault===1" size="tiny" type="success" style="margin-left:6px">默认</n-tag>
            </n-radio>
          </n-space>
        </n-radio-group>
      </n-card>

      <n-card title="③ 选择取件时段" style="margin-bottom:16px">
        <n-empty v-if="!timeSlots.length" description="暂无可用时段" />
        <n-radio-group v-model:value="form.timeSlotId" v-else>
          <n-space>
            <n-radio v-for="slot in timeSlots" :key="slot.id" :value="slot.id" :disabled="slot.bookedCount>=slot.capacity">
              {{ slot.slotDate }} {{ slot.startTime }}-{{ slot.endTime }}
              <span style="color:var(--text-muted);font-size:12px;margin-left:4px">(余{{ slot.capacity - slot.bookedCount }})</span>
            </n-radio>
          </n-space>
        </n-radio-group>
      </n-card>

      <n-card title="④ 备注" style="margin-bottom:16px">
        <n-input v-model:value="form.remark" type="textarea" placeholder="请填写备注信息（选填）" :rows="3" />
      </n-card>

      <n-card style="margin-bottom:24px">
        <n-space justify="space-between" align="center">
          <div>已选 <strong>{{ selectedItems.length }}</strong> 项，预估总价：<span class="price">¥{{ totalPrice.toFixed(2) }}</span></div>
          <n-button type="primary" size="large" :loading="submitting" @click="submitOrder" :disabled="!canSubmit">提交订单</n-button>
        </n-space>
      </n-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getServiceItems, getAddresses, getTimeSlots, createOrder } from '@/api'

const router = useRouter()
const serviceItems = ref<any[]>([])
const addresses = ref<any[]>([])
const timeSlots = ref<any[]>([])
const submitting = ref(false)
const selectedItems = ref<{ id: number; quantity: number }[]>([])
const form = reactive({ addressId: null as number | null, timeSlotId: null as number | null, remark: '' })

const isSelected = (id: number) => selectedItems.value.some(i => i.id === id)
const getQty = (id: number) => selectedItems.value.find(i => i.id === id)?.quantity || 1
const setQty = (id: number, v: number) => { const item = selectedItems.value.find(i => i.id === id); if (item) item.quantity = v; }
const toggleItem = (item: any) => {
  const idx = selectedItems.value.findIndex(i => i.id === item.id)
  if (idx >= 0) selectedItems.value.splice(idx, 1)
  else selectedItems.value.push({ id: item.id, quantity: 1 })
}

const totalPrice = computed(() => {
  return selectedItems.value.reduce((sum, si) => {
    const item = serviceItems.value.find(s => s.id === si.id)
    return sum + (item ? item.price * si.quantity : 0)
  }, 0)
})

const canSubmit = computed(() => selectedItems.value.length > 0 && form.addressId && form.timeSlotId)

async function submitOrder() {
  submitting.value = true
  try {
    await createOrder({
      addressId: form.addressId,
      timeSlotId: form.timeSlotId,
      remark: form.remark,
      items: selectedItems.value.map(i => ({ serviceItemId: i.id, quantity: i.quantity }))
    })
    window.$message?.success('下单成功！')
    router.push('/order/list')
  } catch {} finally { submitting.value = false }
}

onMounted(async () => {
  try { const r: any = await getServiceItems(); serviceItems.value = r.data || [] } catch {}
  try { const r: any = await getAddresses(); addresses.value = r.data || [] } catch {}
  try { const r: any = await getTimeSlots(); timeSlots.value = r.data || [] } catch {}

  const defaultAddr = addresses.value.find(a => a.isDefault === 1)
  if (defaultAddr) form.addressId = defaultAddr.id
})
</script>
