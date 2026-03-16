import { AppRouteRecord } from '@/types/router'

export const contentRoutes: AppRouteRecord = {
  name: 'Content',
  path: '/content',
  component: '/index/index',
  redirect: '/content/announcements',
  meta: {
    title: '内容管理',
    icon: 'ri:megaphone-line',
    roles: ['R_SUPER', 'R_ADMIN']
  },
  children: [
    {
      path: 'announcements',
      name: 'Announcements',
      component: '/content/announcements',
      meta: {
        title: '公告管理',
        icon: 'ri:notification-3-line',
        keepAlive: true
      }
    }
  ]
}
