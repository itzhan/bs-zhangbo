/**
 * 业务请求辅助工具
 * 封装 art-design-pro 的 HTTP 模块，提供更简单的调用方式
 */
import api from '@/utils/http'

const http = {
  get<T = any>(url: string, params?: object) {
    return api.get<T>({ url, params })
  },
  post<T = any>(url: string, data?: object) {
    return api.post<T>({ url, data })
  },
  put<T = any>(url: string, data?: object) {
    return api.put<T>({ url, data })
  },
  delete<T = any>(url: string, params?: object) {
    return api.del<T>({ url, params })
  }
}

export default http
