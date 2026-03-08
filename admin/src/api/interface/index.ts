// 请求响应参数（不包含data）
export interface Result {
  code: number;
  message: string;
}

// 请求响应参数（包含data）
export interface ResultData<T = any> extends Result {
  data: T;
}

// 分页响应参数（MyBatis-Plus IPage 格式）
export interface ResPage<T> {
  records: T[];
  current: number;
  size: number;
  total: number;
  pages: number;
}

// 分页请求参数
export interface ReqPage {
  page: number;
  size: number;
}

// 文件上传模块
export namespace Upload {
  export interface ResFileUrl {
    fileUrl: string;
  }
}

// 登录模块
export namespace Login {
  export interface ReqLoginForm {
    username: string;
    password: string;
  }
  export interface ResLogin {
    token: string;
    userInfo: {
      id: number;
      username: string;
      nickname: string;
      phone: string;
      email: string;
      avatar: string;
      gender: number;
      role: string;
      status: number;
    };
  }
  export interface ResAuthButtons {
    [key: string]: string[];
  }
}

// 用户管理模块
export namespace User {
  export interface ReqUserParams extends ReqPage {
    username?: string;
    role?: string;
    keyword?: string;
    status?: number;
  }
  export interface ResUserList {
    id: number;
    username: string;
    nickname: string;
    phone: string;
    email: string;
    avatar: string;
    gender: number;
    role: string;
    status: number;
    idCard: string;
    vehicleNo: string;
    createdAt: string;
  }
}
