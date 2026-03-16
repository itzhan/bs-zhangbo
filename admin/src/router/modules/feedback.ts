import { AppRouteRecord } from '@/types/router'

export const feedbackRoutes: AppRouteRecord = {
  name: 'Feedback',
  path: '/feedback',
  component: '/index/index',
  redirect: '/feedback/reviews',
  meta: {
    title: '评价投诉',
    icon: 'ri:chat-3-line',
    roles: ['R_SUPER', 'R_ADMIN']
  },
  children: [
    {
      path: 'reviews',
      name: 'Reviews',
      component: '/feedback/reviews',
      meta: {
        title: '评价管理',
        icon: 'ri:star-line',
        keepAlive: true
      }
    },
    {
      path: 'complaints',
      name: 'Complaints',
      component: '/feedback/complaints',
      meta: {
        title: '投诉处理',
        icon: 'ri:alarm-warning-line',
        keepAlive: true
      }
    }
  ]
}
