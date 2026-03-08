<template>
  <div style="min-height:100vh;display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg,#EEF2FF,#E0F2FE)">
    <n-card style="width:420px;border-radius:16px" :bordered="false" :content-style="{padding:'40px'}">
      <h2 style="text-align:center;margin-bottom:8px;font-size:24px">创建账号</h2>
      <p style="text-align:center;color:var(--text-secondary);margin-bottom:32px">注册洁衣到家，开启便捷洗衣体验</p>
      <n-form ref="formRef" :model="form" :rules="rules">
        <n-form-item label="用户名" path="username"><n-input v-model:value="form.username" placeholder="请输入用户名" size="large" /></n-form-item>
        <n-form-item label="密码" path="password"><n-input v-model:value="form.password" type="password" show-password-on="click" placeholder="请输入密码" size="large" /></n-form-item>
        <n-form-item label="昵称"><n-input v-model:value="form.nickname" placeholder="请输入昵称（选填）" size="large" /></n-form-item>
        <n-form-item label="手机号"><n-input v-model:value="form.phone" placeholder="请输入手机号（选填）" size="large" /></n-form-item>
        <n-button type="primary" block size="large" :loading="loading" @click="handleRegister" style="margin-top:8px">注 册</n-button>
      </n-form>
      <div style="text-align:center;margin-top:16px;color:var(--text-secondary);font-size:14px">
        已有账号？<router-link to="/login" style="color:var(--primary);font-weight:500">立即登录</router-link>
      </div>
    </n-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { register } from '@/api'

const router = useRouter()
const formRef = ref()
const loading = ref(false)
const form = reactive({ username: '', password: '', nickname: '', phone: '' })
const rules = {
  username: { required: true, message: '请输入用户名', trigger: 'blur' },
  password: { required: true, message: '请输入密码', trigger: 'blur' }
}

async function handleRegister() {
  await formRef.value?.validate()
  loading.value = true
  try {
    await register(form)
    window.$message?.success('注册成功，请登录')
    router.push('/login')
  } catch {} finally { loading.value = false }
}
</script>
