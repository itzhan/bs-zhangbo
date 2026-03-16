import { AppRouteRecord } from '@/types/router'

export const userRoutes: AppRouteRecord = {
  name: 'UserManage',
  path: '/user',
  component: '/index/index',
  redirect: '/user/list',
  meta: {
    title: '用户管理',
    icon: 'ri:user-3-line',
    roles: ['R_SUPER', 'R_ADMIN']
  },
  children: [
    {
      path: 'list',
      name: 'UserList',
      component: '/user/list',
      meta: {
        title: '用户列表',
        icon: 'ri:user-line',
        keepAlive: true
      }
    },
    {
      path: 'rider',
      name: 'RiderList',
      component: '/user/rider',
      meta: {
        title: '骑手管理',
        icon: 'ri:riding-line',
        keepAlive: true
      }
    }
  ]
}
