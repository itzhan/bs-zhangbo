<template>
  <div style="min-height:100vh;display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg,#EEF2FF,#E0F2FE)">
    <n-card style="width:400px;border-radius:16px" :bordered="false" :content-style="{padding:'40px'}">
      <h2 style="text-align:center;margin-bottom:8px;font-size:24px">欢迎回来</h2>
      <p style="text-align:center;color:var(--text-secondary);margin-bottom:32px">登录洁衣到家，享受便捷洗衣服务</p>
      <n-form ref="formRef" :model="form" :rules="rules">
        <n-form-item label="用户名" path="username"><n-input v-model:value="form.username" placeholder="请输入用户名" size="large" /></n-form-item>
        <n-form-item label="密码" path="password"><n-input v-model:value="form.password" type="password" show-password-on="click" placeholder="请输入密码" size="large" @keyup.enter="handleLogin" /></n-form-item>
        <n-button type="primary" block size="large" :loading="loading" @click="handleLogin" style="margin-top:8px">登 录</n-button>
      </n-form>
      <div style="text-align:center;margin-top:16px;color:var(--text-secondary);font-size:14px">
        还没有账号？<router-link to="/register" style="color:var(--primary);font-weight:500">立即注册</router-link>
      </div>
    </n-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { login } from '@/api'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const formRef = ref()
const loading = ref(false)
const form = reactive({ username: '', password: '' })
const rules = {
  username: { required: true, message: '请输入用户名', trigger: 'blur' },
  password: { required: true, message: '请输入密码', trigger: 'blur' }
}

async function handleLogin() {
  await formRef.value?.validate()
  loading.value = true
  try {
    const res: any = await login(form)
    userStore.setLogin(res.data.token, res.data.userInfo)
    window.$message?.success('登录成功')
    router.push((route.query.redirect as string) || '/')
  } catch {} finally { loading.value = false }
}
</script>
