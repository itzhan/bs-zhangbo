import { AppRouteRecord } from '@/types/router'
import { dashboardRoutes } from './dashboard'
import { orderRoutes } from './order'
import { userRoutes } from './user'
import { serviceRoutes } from './service'
import { feedbackRoutes } from './feedback'
import { contentRoutes } from './content'

/**
 * 导出所有模块化路由
 */
export const routeModules: AppRouteRecord[] = [
  dashboardRoutes,
  orderRoutes,
  userRoutes,
  serviceRoutes,
  feedbackRoutes,
  contentRoutes
]
