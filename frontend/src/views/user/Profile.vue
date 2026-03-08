<template>
  <div class="section">
    <div class="container" style="max-width:700px">
      <h2 class="section-title">个人中心</h2>
      <n-card title="基本信息" style="margin-bottom:16px">
        <n-form :model="profileForm" label-width="80px" label-placement="left">
          <n-form-item label="用户名"><n-input :value="userStore.userInfo.username" disabled /></n-form-item>
          <n-form-item label="昵称"><n-input v-model:value="profileForm.nickname" /></n-form-item>
          <n-form-item label="手机号"><n-input v-model:value="profileForm.phone" /></n-form-item>
          <n-form-item label="邮箱"><n-input v-model:value="profileForm.email" /></n-form-item>
          <n-form-item><n-button type="primary" @click="saveProfile" :loading="saving">保存修改</n-button></n-form-item>
        </n-form>
      </n-card>

      <n-card title="修改密码">
        <n-form :model="pwdForm" label-width="80px" label-placement="left">
          <n-form-item label="原密码"><n-input v-model:value="pwdForm.oldPassword" type="password" show-password-on="click" /></n-form-item>
          <n-form-item label="新密码"><n-input v-model:value="pwdForm.newPassword" type="password" show-password-on="click" /></n-form-item>
          <n-form-item><n-button type="warning" @click="savePwd" :loading="changingPwd">修改密码</n-button></n-form-item>
        </n-form>
      </n-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useUserStore } from '@/stores/user'
import { updateProfile, changePassword } from '@/api'

const userStore = useUserStore()
const saving = ref(false)
const changingPwd = ref(false)

const profileForm = reactive({
  nickname: userStore.userInfo.nickname || '',
  phone: userStore.userInfo.phone || '',
  email: userStore.userInfo.email || ''
})

const pwdForm = reactive({ oldPassword: '', newPassword: '' })

async function saveProfile() {
  saving.value = true
  try {
    await updateProfile(profileForm)
    userStore.userInfo.nickname = profileForm.nickname
    userStore.userInfo.phone = profileForm.phone
    userStore.userInfo.email = profileForm.email
    localStorage.setItem('userInfo', JSON.stringify(userStore.userInfo))
    window.$message?.success('修改成功')
  } catch {} finally { saving.value = false }
}

async function savePwd() {
  if (!pwdForm.oldPassword || !pwdForm.newPassword) { window.$message?.warning('请填写完整'); return }
  changingPwd.value = true
  try {
    await changePassword(pwdForm)
    window.$message?.success('密码修改成功')
    pwdForm.oldPassword = ''; pwdForm.newPassword = ''
  } catch {} finally { changingPwd.value = false }
}
</script>
