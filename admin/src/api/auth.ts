import request from '@/utils/http'

/**
 * 登录
 * @param params 登录参数
 * @returns 登录响应
 */
export function fetchLogin(params: Api.Auth.LoginParams) {
  return request.post<Api.Auth.LoginResponse>({
    url: '/api/auth/login',
    params
  })
}

/**
 * 获取用户信息
 * 将后端返回的字段映射为框架所需的格式
 * @returns 用户信息
 */
export async function fetchGetUserInfo(): Promise<Api.Auth.UserInfo> {
  const data = await request.get<any>({
    url: '/api/auth/info'
  })
  // 后端返回 { id, username, nickname, phone, email, avatar, gender, role, status }
  // 框架需要 { userId, userName, roles, buttons }
  return {
    id: data.id,
    userId: data.id,
    username: data.username,
    userName: data.nickname || data.username,
    nickname: data.nickname || data.username,
    phone: data.phone || '',
    email: data.email || '',
    avatar: data.avatar,
    gender: data.gender,
    role: data.role,
    roles: ['R_SUPER'],
    buttons: [],
    status: data.status || 1
  }
}
