import { AppRouteRecord } from '@/types/router'

export const serviceRoutes: AppRouteRecord = {
  name: 'Service',
  path: '/service',
  component: '/index/index',
  redirect: '/service/items',
  meta: {
    title: '服务管理',
    icon: 'ri:settings-4-line',
    roles: ['R_SUPER', 'R_ADMIN']
  },
  children: [
    {
      path: 'items',
      name: 'ServiceItems',
      component: '/service/items',
      meta: {
        title: '服务项目',
        icon: 'ri:price-tag-3-line',
        keepAlive: true
      }
    },
    {
      path: 'areas',
      name: 'ServiceAreas',
      component: '/service/areas',
      meta: {
        title: '服务区域',
        icon: 'ri:map-pin-line',
        keepAlive: true
      }
    },
    {
      path: 'timeslots',
      name: 'TimeSlots',
      component: '/service/timeslots',
      meta: {
        title: '时段管理',
        icon: 'ri:time-line',
        keepAlive: true
      }
    }
  ]
}
