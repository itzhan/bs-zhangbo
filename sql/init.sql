-- ============================================================
-- 上门洗衣预约服务系统 - 数据库初始化脚本
-- ============================================================

CREATE DATABASE IF NOT EXISTS laundry_service DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE laundry_service;

SET NAMES utf8mb4;
SET CHARACTER_SET_CLIENT = utf8mb4;
SET CHARACTER_SET_RESULTS = utf8mb4;
SET CHARACTER_SET_CONNECTION = utf8mb4;

-- -----------------------------------------------------------
-- 1. 系统用户表（三角色统一）
-- -----------------------------------------------------------
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
    id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE COMMENT '用户名',
    password    VARCHAR(255) NOT NULL COMMENT '密码(BCrypt)',
    nickname    VARCHAR(50)  NULL COMMENT '昵称',
    phone       VARCHAR(20)  NULL COMMENT '手机号',
    avatar      VARCHAR(255) NULL COMMENT '头像URL',
    email       VARCHAR(100) NULL COMMENT '邮箱',
    gender      TINYINT      DEFAULT 0 COMMENT '性别 0未知 1男 2女',
    role        VARCHAR(20)  NOT NULL DEFAULT 'USER' COMMENT '角色: USER/RIDER/ADMIN',
    status      TINYINT      DEFAULT 1 COMMENT '状态 0禁用 1启用',
    id_card     VARCHAR(30)  NULL COMMENT '身份证号(骑手)',
    vehicle_no  VARCHAR(30)  NULL COMMENT '车牌号(骑手)',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at  DATETIME     NULL COMMENT '软删除时间',
    INDEX idx_role (role),
    INDEX idx_phone (phone),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

-- -----------------------------------------------------------
-- 2. 用户地址表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS user_address;
CREATE TABLE user_address (
    id            BIGINT       AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT       NOT NULL COMMENT '用户ID',
    contact_name  VARCHAR(50)  NOT NULL COMMENT '联系人姓名',
    contact_phone VARCHAR(20)  NOT NULL COMMENT '联系电话',
    province      VARCHAR(50)  NULL COMMENT '省',
    city          VARCHAR(50)  NULL COMMENT '市',
    district      VARCHAR(50)  NULL COMMENT '区',
    detail        VARCHAR(255) NOT NULL COMMENT '详细地址',
    is_default    TINYINT      DEFAULT 0 COMMENT '是否默认 0否 1是',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户地址表';

-- -----------------------------------------------------------
-- 3. 服务项目表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS service_item;
CREATE TABLE service_item (
    id          BIGINT        AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)  NOT NULL COMMENT '服务名称',
    category    VARCHAR(50)   NULL COMMENT '分类(衬衫/外套/裤装/床品/特殊)',
    description VARCHAR(500)  NULL COMMENT '服务描述',
    price       DECIMAL(10,2) NOT NULL COMMENT '单价(元)',
    unit        VARCHAR(20)   DEFAULT '件' COMMENT '计量单位',
    image       VARCHAR(255)  NULL COMMENT '服务图片',
    sort_order  INT           DEFAULT 0 COMMENT '排序',
    status      TINYINT       DEFAULT 1 COMMENT '状态 0下架 1上架',
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务项目表';

-- -----------------------------------------------------------
-- 4. 服务区域表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS service_area;
CREATE TABLE service_area (
    id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL COMMENT '区域名称',
    city        VARCHAR(50)  NULL COMMENT '所属城市',
    district    VARCHAR(50)  NULL COMMENT '所属区县',
    description VARCHAR(255) NULL COMMENT '区域描述',
    status      TINYINT      DEFAULT 1 COMMENT '状态 0停用 1启用',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务区域表';

-- -----------------------------------------------------------
-- 5. 时段容量表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS time_slot;
CREATE TABLE time_slot (
    id           BIGINT      AUTO_INCREMENT PRIMARY KEY,
    slot_date    DATE        NOT NULL COMMENT '日期',
    start_time   VARCHAR(10) NOT NULL COMMENT '开始时间(如 09:00)',
    end_time     VARCHAR(10) NOT NULL COMMENT '结束时间(如 11:00)',
    capacity     INT         NOT NULL DEFAULT 10 COMMENT '最大可接单量',
    booked_count INT         NOT NULL DEFAULT 0 COMMENT '已预约数量',
    area_id      BIGINT      NULL COMMENT '关联区域ID',
    status       TINYINT     DEFAULT 1 COMMENT '状态 0禁用 1启用',
    created_at   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_date (slot_date),
    INDEX idx_area (area_id),
    UNIQUE INDEX uk_date_time_area (slot_date, start_time, end_time, area_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='时段容量表';

-- -----------------------------------------------------------
-- 6. 订单主表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS laundry_order;
CREATE TABLE laundry_order (
    id              BIGINT        AUTO_INCREMENT PRIMARY KEY,
    order_no        VARCHAR(32)   NOT NULL UNIQUE COMMENT '订单编号',
    user_id         BIGINT        NOT NULL COMMENT '下单用户ID',
    address_id      BIGINT        NOT NULL COMMENT '取衣地址ID',
    address_detail  VARCHAR(500)  NULL COMMENT '地址快照',
    contact_name    VARCHAR(50)   NULL COMMENT '联系人快照',
    contact_phone   VARCHAR(20)   NULL COMMENT '联系电话快照',
    time_slot_id    BIGINT        NULL COMMENT '预约时段ID',
    pickup_date     DATE          NULL COMMENT '预约取件日期',
    pickup_time     VARCHAR(20)   NULL COMMENT '预约取件时段',
    total_amount    DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '总金额',
    pay_amount      DECIMAL(10,2) NULL COMMENT '实付金额',
    status          VARCHAR(20)   NOT NULL DEFAULT 'PENDING_PAY' COMMENT '订单状态',
    remark          VARCHAR(500)  NULL COMMENT '用户备注',
    cancel_reason   VARCHAR(255)  NULL COMMENT '取消原因',
    completed_at    DATETIME      NULL COMMENT '完成时间',
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at),
    INDEX idx_order_no (order_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单主表';

-- -----------------------------------------------------------
-- 7. 订单项表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS order_item;
CREATE TABLE order_item (
    id              BIGINT        AUTO_INCREMENT PRIMARY KEY,
    order_id        BIGINT        NOT NULL COMMENT '订单ID',
    service_item_id BIGINT        NOT NULL COMMENT '服务项目ID',
    service_name    VARCHAR(100)  NULL COMMENT '服务名称快照',
    price           DECIMAL(10,2) NOT NULL COMMENT '单价快照',
    quantity        INT           NOT NULL DEFAULT 1 COMMENT '数量',
    subtotal        DECIMAL(10,2) NOT NULL COMMENT '小计',
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单项表';

-- -----------------------------------------------------------
-- 8. 支付流水表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS payment;
CREATE TABLE payment (
    id            BIGINT        AUTO_INCREMENT PRIMARY KEY,
    payment_no    VARCHAR(32)   NOT NULL UNIQUE COMMENT '支付流水号',
    order_id      BIGINT        NOT NULL COMMENT '订单ID',
    order_no      VARCHAR(32)   NULL COMMENT '订单编号',
    user_id       BIGINT        NOT NULL COMMENT '用户ID',
    amount        DECIMAL(10,2) NOT NULL COMMENT '支付金额',
    pay_method    VARCHAR(20)   DEFAULT 'WECHAT' COMMENT '支付方式(WECHAT/ALIPAY/CASH)',
    status        VARCHAR(20)   DEFAULT 'PENDING' COMMENT '支付状态(PENDING/SUCCESS/FAILED/REFUNDED)',
    paid_at       DATETIME      NULL COMMENT '支付时间',
    refunded_at   DATETIME      NULL COMMENT '退款时间',
    created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_id (order_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付流水表';

-- -----------------------------------------------------------
-- 9. 骑手派单记录表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS rider_assignment;
CREATE TABLE rider_assignment (
    id            BIGINT      AUTO_INCREMENT PRIMARY KEY,
    order_id      BIGINT      NOT NULL COMMENT '订单ID',
    order_no      VARCHAR(32) NULL COMMENT '订单编号',
    rider_id      BIGINT      NOT NULL COMMENT '骑手ID',
    type          VARCHAR(20) NOT NULL DEFAULT 'PICKUP' COMMENT '类型: PICKUP取件/DELIVER送回',
    status        VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态: PENDING/ACCEPTED/COMPLETED',
    assigned_at   DATETIME    NULL COMMENT '派单时间',
    accepted_at   DATETIME    NULL COMMENT '接单时间',
    completed_at  DATETIME    NULL COMMENT '完成时间',
    remark        VARCHAR(255) NULL COMMENT '备注',
    created_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_id (order_id),
    INDEX idx_rider_id (rider_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='骑手派单记录表';

-- -----------------------------------------------------------
-- 10. 评价表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS review;
CREATE TABLE review (
    id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
    order_id    BIGINT       NOT NULL COMMENT '订单ID',
    order_no    VARCHAR(32)  NULL COMMENT '订单编号',
    user_id     BIGINT       NOT NULL COMMENT '用户ID',
    rating      TINYINT      NOT NULL DEFAULT 5 COMMENT '评分 1-5',
    content     VARCHAR(500) NULL COMMENT '评价内容',
    images      VARCHAR(1000) NULL COMMENT '评价图片(逗号分隔)',
    reply       VARCHAR(500) NULL COMMENT '管理员回复',
    replied_at  DATETIME     NULL COMMENT '回复时间',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_order_id (order_id),
    INDEX idx_user_id (user_id),
    INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评价表';

-- -----------------------------------------------------------
-- 11. 投诉工单表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS complaint;
CREATE TABLE complaint (
    id            BIGINT       AUTO_INCREMENT PRIMARY KEY,
    complaint_no  VARCHAR(32)  NOT NULL UNIQUE COMMENT '投诉编号',
    order_id      BIGINT       NULL COMMENT '关联订单ID',
    order_no      VARCHAR(32)  NULL COMMENT '关联订单编号',
    user_id       BIGINT       NOT NULL COMMENT '投诉人ID',
    type          VARCHAR(30)  NULL COMMENT '投诉类型(服务质量/取送延迟/价格争议/其他)',
    content       VARCHAR(1000) NOT NULL COMMENT '投诉内容',
    images        VARCHAR(1000) NULL COMMENT '投诉图片(逗号分隔)',
    status        VARCHAR(20)  DEFAULT 'PENDING' COMMENT '状态: PENDING/PROCESSING/RESOLVED/CLOSED',
    handler_id    BIGINT       NULL COMMENT '处理人ID',
    handle_result VARCHAR(500) NULL COMMENT '处理结果',
    handled_at    DATETIME     NULL COMMENT '处理时间',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_order_id (order_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='投诉工单表';

-- -----------------------------------------------------------
-- 12. 系统公告表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS announcement;
CREATE TABLE announcement (
    id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
    title       VARCHAR(200) NOT NULL COMMENT '公告标题',
    content     TEXT         NOT NULL COMMENT '公告内容',
    type        VARCHAR(20)  DEFAULT 'NOTICE' COMMENT '类型: NOTICE/PROMOTION/SYSTEM',
    is_top      TINYINT      DEFAULT 0 COMMENT '是否置顶 0否 1是',
    status      TINYINT      DEFAULT 1 COMMENT '状态 0草稿 1发布',
    publish_at  DATETIME     NULL COMMENT '发布时间',
    created_by  BIGINT       NULL COMMENT '创建人ID',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_publish (publish_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统公告表';

-- -----------------------------------------------------------
-- 13. 系统配置表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS system_config;
CREATE TABLE system_config (
    id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
    config_key  VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键',
    config_value VARCHAR(500) NOT NULL COMMENT '配置值',
    description VARCHAR(255) NULL COMMENT '配置说明',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

-- -----------------------------------------------------------
-- 14. 操作审计日志表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS operation_log;
CREATE TABLE operation_log (
    id           BIGINT       AUTO_INCREMENT PRIMARY KEY,
    user_id      BIGINT       NULL COMMENT '操作人ID',
    username     VARCHAR(50)  NULL COMMENT '操作人用户名',
    module       VARCHAR(50)  NULL COMMENT '操作模块',
    action       VARCHAR(50)  NULL COMMENT '操作动作',
    description  VARCHAR(500) NULL COMMENT '操作描述',
    method       VARCHAR(10)  NULL COMMENT 'HTTP方法',
    url          VARCHAR(255) NULL COMMENT '请求URL',
    ip           VARCHAR(50)  NULL COMMENT '请求IP',
    request_body TEXT         NULL COMMENT '请求参数',
    response_body TEXT        NULL COMMENT '响应结果',
    cost_time    BIGINT       NULL COMMENT '耗时(ms)',
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_module (module),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作审计日志表';

-- -----------------------------------------------------------
-- 15. 骑手收入统计表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS rider_income;
CREATE TABLE rider_income (
    id             BIGINT        AUTO_INCREMENT PRIMARY KEY,
    rider_id       BIGINT        NOT NULL COMMENT '骑手ID',
    `year_month`   VARCHAR(7)    NOT NULL COMMENT '年月(2026-02)',
    total_orders   INT           DEFAULT 0 COMMENT '完成订单数',
    total_income   DECIMAL(10,2) DEFAULT 0 COMMENT '总收入',
    created_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uk_rider_month (rider_id, `year_month`),
    INDEX idx_rider_id (rider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='骑手收入统计表';
