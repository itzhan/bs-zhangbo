import http from './http'

// 认证
export const login = (data: any) => http.post('/auth/login', data)
export const register = (data: any) => http.post('/auth/register', data)
export const getUserInfo = () => http.get('/auth/info')
export const updateProfile = (data: any) => http.put('/auth/profile', data)
export const changePassword = (data: any) => http.put('/auth/password', data)

// 服务项目
export const getServiceItems = (params?: any) => http.get('/service-items', { params })
export const getServiceCategories = () => http.get('/service-items/categories')

// 服务区域
export const getServiceAreas = () => http.get('/service-areas')

// 时段
export const getTimeSlots = (params?: any) => http.get('/time-slots', { params })

// 地址
export const getAddresses = () => http.get('/addresses')
export const addAddress = (data: any) => http.post('/addresses', data)
export const updateAddress = (id: number, data: any) => http.put(`/addresses/${id}`, data)
export const deleteAddress = (id: number) => http.delete(`/addresses/${id}`)

// 订单
export const createOrder = (data: any) => http.post('/orders', data)
export const getOrders = (params: any) => http.get('/orders', { params })
export const getOrderDetail = (id: number) => http.get(`/orders/${id}`)
export const payOrder = (id: number) => http.post(`/orders/${id}/pay`)
export const cancelOrder = (id: number, reason?: string) => http.post(`/orders/${id}/cancel`, { reason })

// 评价
export const getReviews = (params: any) => http.get('/reviews', { params })
export const addReview = (data: any) => http.post('/reviews', data)

// 投诉
export const getComplaints = (params: any) => http.get('/complaints', { params })
export const addComplaint = (data: any) => http.post('/complaints', data)

// 公告
export const getAnnouncements = (params?: any) => http.get('/announcements', { params })

// 骑手
export const getRiderAssignments = (params: any) => http.get('/orders/rider/my', { params })
export const acceptAssignment = (id: number) => http.put(`/orders/rider/assignment/${id}/accept`)
export const completeAssignment = (id: number) => http.put(`/orders/rider/assignment/${id}/complete`)
export const getRiderIncomes = (params?: any) => http.get('/rider-incomes', { params })
