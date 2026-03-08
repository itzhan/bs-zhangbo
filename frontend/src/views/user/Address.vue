<template>
  <div class="section">
    <div class="container" style="max-width:700px">
      <h2 class="section-title">地址管理</h2>
      <n-button type="primary" style="margin-bottom:16px" @click="openForm()">+ 新增地址</n-button>
      <n-spin :show="loading">
        <n-empty v-if="!addresses.length && !loading" description="暂无地址" />
        <div v-for="addr in addresses" :key="addr.id" class="card" style="padding:16px;margin-bottom:12px">
          <n-space justify="space-between" align="center">
            <div>
              <strong>{{ addr.contactName }}</strong> {{ addr.contactPhone }}
              <n-tag v-if="addr.isDefault===1" size="tiny" type="success" style="margin-left:6px">默认</n-tag>
              <div style="color:var(--text-secondary);font-size:14px;margin-top:4px">{{ addr.province }}{{ addr.city }}{{ addr.district }}{{ addr.detail }}</div>
            </div>
            <n-space>
              <n-button size="small" @click="openForm(addr)">编辑</n-button>
              <n-button size="small" type="error" @click="handleDelete(addr.id)">删除</n-button>
            </n-space>
          </n-space>
        </div>
      </n-spin>

      <n-modal v-model:show="formVisible" preset="card" :title="editId?'编辑地址':'新增地址'" style="width:500px">
        <n-form :model="form" label-width="80px" label-placement="left">
          <n-form-item label="联系人"><n-input v-model:value="form.contactName" /></n-form-item>
          <n-form-item label="手机号"><n-input v-model:value="form.contactPhone" /></n-form-item>
          <n-form-item label="省份"><n-input v-model:value="form.province" /></n-form-item>
          <n-form-item label="城市"><n-input v-model:value="form.city" /></n-form-item>
          <n-form-item label="区县"><n-input v-model:value="form.district" /></n-form-item>
          <n-form-item label="详细地址"><n-input v-model:value="form.detail" type="textarea" /></n-form-item>
          <n-form-item label="默认地址"><n-switch v-model:value="isDefault" /></n-form-item>
          <n-space justify="end"><n-button @click="formVisible=false">取消</n-button><n-button type="primary" @click="saveAddress" :loading="saving">保存</n-button></n-space>
        </n-form>
      </n-modal>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { getAddresses, addAddress, updateAddress, deleteAddress } from '@/api'

const loading = ref(false)
const saving = ref(false)
const addresses = ref<any[]>([])
const formVisible = ref(false)
const editId = ref<number | null>(null)
const isDefault = ref(false)
const form = reactive({ contactName: '', contactPhone: '', province: '', city: '', district: '', detail: '' })

async function fetchAddresses() {
  loading.value = true
  try { const r: any = await getAddresses(); addresses.value = r.data || [] } catch {} finally { loading.value = false }
}

function openForm(addr?: any) {
  if (addr) {
    editId.value = addr.id
    Object.assign(form, { contactName: addr.contactName, contactPhone: addr.contactPhone, province: addr.province, city: addr.city, district: addr.district, detail: addr.detail })
    isDefault.value = addr.isDefault === 1
  } else {
    editId.value = null
    Object.assign(form, { contactName: '', contactPhone: '', province: '', city: '', district: '', detail: '' })
    isDefault.value = false
  }
  formVisible.value = true
}

async function saveAddress() {
  saving.value = true
  try {
    const data = { ...form, isDefault: isDefault.value ? 1 : 0 }
    if (editId.value) await updateAddress(editId.value, data)
    else await addAddress(data)
    window.$message?.success('保存成功')
    formVisible.value = false; fetchAddresses()
  } catch {} finally { saving.value = false }
}

async function handleDelete(id: number) {
  try { await deleteAddress(id); window.$message?.success('删除成功'); fetchAddresses() } catch {}
}

onMounted(fetchAddresses)
</script>
