import { createRouter, createWebHashHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes = [
  { path: '/', name: 'Home', component: () => import('@/views/home/index.vue'), meta: { title: '首页' } },
  { path: '/services', name: 'Services', component: () => import('@/views/services/index.vue'), meta: { title: '服务项目' } },
  { path: '/login', name: 'Login', component: () => import('@/views/user/Login.vue'), meta: { title: '登录', guest: true } },
  { path: '/register', name: 'Register', component: () => import('@/views/user/Register.vue'), meta: { title: '注册', guest: true } },
  { path: '/order/create', name: 'OrderCreate', component: () => import('@/views/order/Create.vue'), meta: { title: '预约下单', auth: true } },
  { path: '/order/list', name: 'OrderList', component: () => import('@/views/order/List.vue'), meta: { title: '我的订单', auth: true } },
  { path: '/order/:id', name: 'OrderDetail', component: () => import('@/views/order/Detail.vue'), meta: { title: '订单详情', auth: true } },
  { path: '/user/profile', name: 'Profile', component: () => import('@/views/user/Profile.vue'), meta: { title: '个人中心', auth: true } },
  { path: '/user/address', name: 'Address', component: () => import('@/views/user/Address.vue'), meta: { title: '地址管理', auth: true } },
  { path: '/review', name: 'Review', component: () => import('@/views/review/index.vue'), meta: { title: '我的评价', auth: true } },
  { path: '/complaint', name: 'Complaint', component: () => import('@/views/complaint/index.vue'), meta: { title: '投诉反馈', auth: true } },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})

router.beforeEach((to, from, next) => {
  document.title = (to.meta.title as string || '洁衣到家') + ' - 洁衣到家'
  const userStore = useUserStore()
  if (to.meta.auth && !userStore.isLoggedIn) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
  } else {
    next()
  }
})

export default router
