import { AppRouteRecord } from '@/types/router'

export const systemRoutes: AppRouteRecord = {
  path: '/system',
  name: 'System',
  component: '/index/index',
  redirect: '/system/config',
  meta: {
    title: '系统管理',
    icon: 'ri:settings-3-line',
    roles: ['R_SUPER', 'R_ADMIN']
  },
  children: [
    {
      path: 'config',
      name: 'SystemConfig',
      component: '/system/config',
      meta: {
        title: '系统配置',
        icon: 'ri:tools-line',
        keepAlive: true,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'logs',
      name: 'OperationLogs',
      component: '/system/logs',
      meta: {
        title: '操作日志',
        icon: 'ri:file-list-2-line',
        keepAlive: true,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    }
  ]
}
