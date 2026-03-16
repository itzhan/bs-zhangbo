import { Login } from "@/api/interface/index";
import http from "@/api";

/**
 * @name 登录模块
 */
// 用户登录
export const loginApi = (params: Login.ReqLoginForm) => {
  return http.post<Login.ResLogin>(`/auth/login`, params, { loading: false });
};

// 获取菜单列表 - 使用本地JSON
export const getAuthMenuListApi = () => {
  // 使用本地静态菜单
  return import("@/assets/json/authMenuList.json").then(mod => mod.default);
};

// 获取按钮权限 - 返回全量权限
export const getAuthButtonListApi = () => {
  return import("@/assets/json/authButtonList.json").then(mod => mod.default);
};

// 获取用户信息
export const getUserInfoApi = () => {
  return http.get(`/auth/info`, {}, { loading: false });
};

// 用户退出登录
export const logoutApi = () => {
  return Promise.resolve(); // 前端直接清除token
};
