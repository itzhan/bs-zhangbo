import axios from 'axios'
import { useUserStore } from '@/stores/user'
import { useMessage } from 'naive-ui'

const http = axios.create({
  baseURL: '/api',
  timeout: 15000
})

http.interceptors.request.use(config => {
  const userStore = useUserStore()
  if (userStore.token) {
    config.headers.Authorization = `Bearer ${userStore.token}`
  }
  return config
})

http.interceptors.response.use(
  res => {
    const data = res.data
    if (data.code && data.code !== 200) {
      window.$message?.error(data.message || '请求失败')
      return Promise.reject(data)
    }
    return data
  },
  err => {
    if (err.response?.status === 401) {
      const userStore = useUserStore()
      userStore.logout()
      window.location.hash = '#/login'
      window.$message?.error('登录过期，请重新登录')
    } else {
      window.$message?.error(err.response?.data?.message || '网络错误')
    }
    return Promise.reject(err)
  }
)

export default http
