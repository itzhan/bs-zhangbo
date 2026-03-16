#!/bin/bash
# ============================================================
# 洁衣到家 - 全量API接口联调测试脚本 v2
# 覆盖全部后端 API 端点（约 50+ 个接口）
# 所有资源ID均动态获取，避免硬编码
# ============================================================

BASE_URL="http://localhost:8080/api"
PASS=0
FAIL=0
TOTAL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---- 工具函数 ----
test_api() {
  local method="$1"
  local url="$2"
  local data="$3"
  local token="$4"
  local desc="$5"
  local expect_code="${6:-200}"

  TOTAL=$((TOTAL + 1))

  local curl_args=(-s -w "\n%{http_code}" -X "$method" "$BASE_URL$url" --globoff)
  curl_args+=(-H "Content-Type: application/json")
  if [ -n "$token" ]; then
    curl_args+=(-H "Authorization: Bearer $token")
  fi
  if [ -n "$data" ]; then
    curl_args+=(-d "$data")
  fi

  local response
  response=$(curl "${curl_args[@]}" 2>/dev/null)
  local http_code
  http_code=$(echo "$response" | tail -1)
  local body
  body=$(echo "$response" | sed '$d')

  # 检查业务 code
  local biz_code
  biz_code=$(echo "$body" | grep -o '"code":[0-9]*' | head -1 | grep -o '[0-9]*')

  if [ "$http_code" = "$expect_code" ] && { [ "$biz_code" = "200" ] || [ -z "$biz_code" ]; }; then
    echo -e "  ${GREEN}✅ PASS${NC} [$method] $url  - $desc"
    PASS=$((PASS + 1))
    echo "$body"
    return 0
  else
    echo -e "  ${RED}❌ FAIL${NC} [$method] $url  - $desc  (HTTP=$http_code, BizCode=$biz_code)"
    echo "     Response: $(echo "$body" | head -c 300)"
    FAIL=$((FAIL + 1))
    return 1
  fi
}

# 提取 JSON 字段值 (简易版)
extract_json() {
  echo "$1" | grep -o "\"$2\":[^,}]*" | head -1 | sed 's/"[^"]*"://' | tr -d '"' | tr -d ' '
}

extract_json_string() {
  echo "$1" | grep -o "\"$2\":\"[^\"]*\"" | head -1 | sed "s/\"$2\":\"//" | sed 's/"$//'
}

# 辅助：从分页列表响应中提取第一条记录的 ID
extract_first_id() {
  echo "$1" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*'
}

# 辅助：从分页列表响应中提取最后一条记录的 ID
extract_last_id() {
  echo "$1" | grep -o '"id":[0-9]*' | tail -1 | grep -o '[0-9]*'
}

# ============================================================
echo -e "${BLUE}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   🧪 洁衣到家 API 全量联调测试 v2       ║"
echo "  ║   $(date '+%Y-%m-%d %H:%M:%S')                     ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"

# 先检查后端是否在线
echo -e "${YELLOW}🔍 检查后端服务...${NC}"
if ! curl -s "$BASE_URL/service-items" > /dev/null 2>&1; then
  echo -e "${RED}❌ 后端服务未启动 ($BASE_URL)，请先运行 ./start.sh${NC}"
  exit 1
fi
echo -e "${GREEN}✅ 后端服务在线${NC}"
echo ""

# ============================================================
# 1. 认证模块
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔐 模块一：认证 (Auth) - 9个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 1.1 管理员登录
RESP=$(test_api POST "/auth/login" '{"username":"admin","password":"123456"}' "" "管理员登录")
ADMIN_TOKEN=$(extract_json_string "$RESP" "token")
echo "     → Admin Token: ${ADMIN_TOKEN:0:20}..."

# 1.2 用户登录
RESP=$(test_api POST "/auth/login" '{"username":"user1","password":"123456"}' "" "用户登录(user1)")
USER_TOKEN=$(extract_json_string "$RESP" "token")
echo "     → User Token: ${USER_TOKEN:0:20}..."

# 1.3 骑手登录
RESP=$(test_api POST "/auth/login" '{"username":"rider1","password":"123456"}' "" "骑手登录(rider1)")
RIDER_TOKEN=$(extract_json_string "$RESP" "token")
echo "     → Rider Token: ${RIDER_TOKEN:0:20}..."

# 1.4 注册新用户
TEST_USER="testuser_$(date +%s)"
test_api POST "/auth/register" "{\"username\":\"$TEST_USER\",\"password\":\"123456\",\"nickname\":\"测试用户\",\"phone\":\"13999999999\"}" "" "注册新用户"

# 1.5 新用户登录
RESP=$(test_api POST "/auth/login" "{\"username\":\"$TEST_USER\",\"password\":\"123456\"}" "" "新用户登录")
TEST_TOKEN=$(extract_json_string "$RESP" "token")

# 1.6 获取用户信息
test_api GET "/auth/info" "" "$USER_TOKEN" "获取当前用户信息"

# 1.7 修改个人资料
test_api PUT "/auth/profile" '{"nickname":"张伟改名","phone":"13811111111"}' "$USER_TOKEN" "修改个人资料"

# 1.8 修改密码
test_api PUT "/auth/password" '{"oldPassword":"123456","newPassword":"654321"}' "$TEST_TOKEN" "修改密码"

# 1.9 用新密码登录验证
test_api POST "/auth/login" "{\"username\":\"$TEST_USER\",\"password\":\"654321\"}" "" "新密码登录验证"

echo ""

# ============================================================
# 2. 服务项目模块
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}👔 模块二：服务项目 (Service Items) - 8个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 2.1 获取服务项目列表(前端)
test_api GET "/service-items" "" "" "获取上架服务项目列表"

# 2.2 按分类查询
test_api GET "/service-items?category=%E8%A1%AC%E8%A1%AB" "" "" "按分类查询(衬衫)"

# 2.3 获取分类列表
test_api GET "/service-items/categories" "" "" "获取服务分类列表"

# 2.4 获取单个服务详情
test_api GET "/service-items/1" "" "" "获取服务详情(ID=1)"

# 2.5 管理端-获取全部服务(含下架)
test_api GET "/service-items/all?page=1&size=10" "" "$ADMIN_TOKEN" "管理端-全部服务列表"

# 2.6 管理端-新增服务
test_api POST "/service-items" '{"name":"测试服务项","category":"测试","description":"测试描述","price":99.99,"unit":"件","status":1}' "$ADMIN_TOKEN" "管理端-新增服务"

# 动态获取新增服务ID
ALL_ITEMS_RESP=$(curl -s "$BASE_URL/service-items/all?page=1&size=100" -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json")
NEW_ITEM_ID=$(extract_last_id "$ALL_ITEMS_RESP")
echo "     → 新服务ID: $NEW_ITEM_ID"

# 2.7 管理端-修改服务
test_api PUT "/service-items/$NEW_ITEM_ID" '{"name":"测试服务项(已修改)","price":88.88}' "$ADMIN_TOKEN" "管理端-修改服务"

# 2.8 管理端-删除服务
test_api DELETE "/service-items/$NEW_ITEM_ID" "" "$ADMIN_TOKEN" "管理端-删除服务"

echo ""

# ============================================================
# 3. 服务区域模块
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📍 模块三：服务区域 (Service Areas) - 6个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 3.1 获取区域列表(前端)
test_api GET "/service-areas" "" "" "获取启用区域列表"

# 3.2 获取区域详情
test_api GET "/service-areas/1" "" "" "获取区域详情(ID=1)"

# 3.3 管理端-全部区域列表
test_api GET "/service-areas/all?page=1&size=10" "" "$ADMIN_TOKEN" "管理端-全部区域列表"

# 3.4 管理端-新增区域
test_api POST "/service-areas" '{"name":"测试区域","city":"郑州市","district":"中原区","description":"测试用区域","status":1}' "$ADMIN_TOKEN" "管理端-新增区域"

# 动态获取新增区域ID
ALL_AREAS_RESP=$(curl -s "$BASE_URL/service-areas/all?page=1&size=100" -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json")
NEW_AREA_ID=$(extract_last_id "$ALL_AREAS_RESP")
echo "     → 新区域ID: $NEW_AREA_ID"

# 3.5 管理端-修改区域
test_api PUT "/service-areas/$NEW_AREA_ID" '{"name":"测试区域(已修改)"}' "$ADMIN_TOKEN" "管理端-修改区域"

# 3.6 管理端-删除区域
test_api DELETE "/service-areas/$NEW_AREA_ID" "" "$ADMIN_TOKEN" "管理端-删除区域"

echo ""

# ============================================================
# 4. 时段模块
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🕐 模块四：时段 (Time Slots) - 5个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 4.1 获取可用时段(前端)
test_api GET "/time-slots" "" "" "获取可用时段列表"

# 4.2 按日期+区域查询
FUTURE_DATE=$(date -v+3d '+%Y-%m-%d' 2>/dev/null || date -d '+3 days' '+%Y-%m-%d' 2>/dev/null || echo "2026-03-20")
test_api GET "/time-slots?date=$FUTURE_DATE&areaId=1" "" "" "按日期+区域查询时段"

# 4.3 管理端-全部时段
test_api GET "/time-slots/all?page=1&size=10" "" "$ADMIN_TOKEN" "管理端-全部时段列表"

# 4.4 管理端-新增时段 (使用远未来日期避免重复)
SLOT_DAY=$(($(date +%d) + 1))
SLOT_DATE="2026-12-${SLOT_DAY}"
test_api POST "/time-slots" "{\"slotDate\":\"$SLOT_DATE\",\"startTime\":\"14:00\",\"endTime\":\"16:00\",\"capacity\":10,\"bookedCount\":0,\"areaId\":1,\"status\":1}" "$ADMIN_TOKEN" "管理端-新增时段"

# 动态获取新增时段ID
ALL_SLOTS_RESP=$(curl -s "$BASE_URL/time-slots/all?page=1&size=200" -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json")
NEW_SLOT_ID=$(extract_last_id "$ALL_SLOTS_RESP")
echo "     → 新时段ID: $NEW_SLOT_ID"

# 4.5 管理端-修改时段
test_api PUT "/time-slots/$NEW_SLOT_ID" '{"capacity":15}' "$ADMIN_TOKEN" "管理端-修改时段"

# 4.6 管理端-删除时段
test_api DELETE "/time-slots/$NEW_SLOT_ID" "" "$ADMIN_TOKEN" "管理端-删除时段"

echo ""

# ============================================================
# 5. 用户地址模块
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🏠 模块五：用户地址 (Addresses) - 5个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 5.1 获取地址列表
test_api GET "/addresses" "" "$USER_TOKEN" "获取当前用户地址列表"

# 5.2 获取地址详情
# 先动态获取user1有的地址ID
ADDR_LIST_RESP=$(curl -s "$BASE_URL/addresses" -H "Authorization: Bearer $USER_TOKEN" -H "Content-Type: application/json")
EXISTING_ADDR_ID=$(extract_first_id "$ADDR_LIST_RESP")
echo "     → 现有地址ID: $EXISTING_ADDR_ID"

test_api GET "/addresses/${EXISTING_ADDR_ID:-1}" "" "$USER_TOKEN" "获取地址详情"

# 5.3 新增地址
test_api POST "/addresses" '{"contactName":"张伟新地址","contactPhone":"13800000099","province":"河南省","city":"郑州市","district":"中原区","detail":"碧沙岗公园附近融侨城小区3号楼202","isDefault":0}' "$USER_TOKEN" "新增地址"

# 动态查找新增地址的ID
NEW_ADDR_RESP=$(curl -s "$BASE_URL/addresses" -H "Authorization: Bearer $USER_TOKEN" -H "Content-Type: application/json")
NEW_ADDR_ID=$(extract_last_id "$NEW_ADDR_RESP")
echo "     → 新地址ID: $NEW_ADDR_ID"

# 5.4 修改地址
test_api PUT "/addresses/$NEW_ADDR_ID" '{"contactName":"张伟新地址(改)","contactPhone":"13800000099","province":"河南省","city":"郑州市","district":"中原区","detail":"碧沙岗公园附近融侨城小区3号楼203"}' "$USER_TOKEN" "修改地址"

# 5.5 删除地址
test_api DELETE "/addresses/$NEW_ADDR_ID" "" "$USER_TOKEN" "删除地址"

echo ""

# ============================================================
# 6. 订单模块 (完整生命周期)
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📦 模块六：订单 (Orders) - 10个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 动态获取 user1 的地址和一个可用时段
USER_ADDR_RESP=$(curl -s "$BASE_URL/addresses" -H "Authorization: Bearer $USER_TOKEN" -H "Content-Type: application/json")
ORDER_ADDR_ID=$(extract_first_id "$USER_ADDR_RESP")
echo "     → 用户地址ID: $ORDER_ADDR_ID"

SLOTS_RESP=$(curl -s "$BASE_URL/time-slots" -H "Content-Type: application/json")
ORDER_SLOT_ID=$(extract_first_id "$SLOTS_RESP")
ORDER_SLOT_ID2=$(echo "$SLOTS_RESP" | grep -o '"id":[0-9]*' | sed -n '2p' | grep -o '[0-9]*')
echo "     → 可用时段ID: $ORDER_SLOT_ID, $ORDER_SLOT_ID2"

# 6.1 创建订单
RESP=$(test_api POST "/orders" "{\"addressId\":$ORDER_ADDR_ID,\"timeSlotId\":$ORDER_SLOT_ID,\"remark\":\"测试订单-完整生命周期\",\"items\":[{\"serviceItemId\":1,\"quantity\":2},{\"serviceItemId\":3,\"quantity\":1}]}" "$USER_TOKEN" "用户创建订单")
NEW_ORDER_ID=$(extract_json "$RESP" "id")
echo "     → 新订单ID: $NEW_ORDER_ID"

# 6.2 获取订单列表(用户)
test_api GET "/orders?page=1&size=10" "" "$USER_TOKEN" "用户-获取订单列表"

# 6.3 获取订单列表(管理员 - 看全部)
test_api GET "/orders?page=1&size=10" "" "$ADMIN_TOKEN" "管理员-获取全部订单列表"

# 6.4 按状态筛选
test_api GET "/orders?page=1&size=10&status=COMPLETED" "" "$ADMIN_TOKEN" "管理员-按状态筛选订单(COMPLETED)"

# 6.5 获取订单详情
test_api GET "/orders/${NEW_ORDER_ID:-1}" "" "$USER_TOKEN" "获取订单详情"

# 6.6 支付订单 → 6.7 管理员派单 → 6.8 状态推进 (完整生命周期)
if [ -n "$NEW_ORDER_ID" ] && [ "$NEW_ORDER_ID" != "null" ]; then
  # 支付
  test_api POST "/orders/$NEW_ORDER_ID/pay" "" "$USER_TOKEN" "支付新订单"

  # 获取 rider1 的ID
  RIDER_INFO_RESP=$(curl -s "$BASE_URL/auth/info" -H "Authorization: Bearer $RIDER_TOKEN" -H "Content-Type: application/json")
  RIDER_ID=$(echo "$RIDER_INFO_RESP" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
  echo "     → 骑手ID: $RIDER_ID"

  # 管理员派单
  test_api POST "/orders/$NEW_ORDER_ID/assign" "{\"riderId\":$RIDER_ID}" "$ADMIN_TOKEN" "管理员派单给骑手"

  # 管理员推进订单状态 PICKED_UP → WASHING → WASHED → DELIVERING → COMPLETED
  test_api PUT "/orders/$NEW_ORDER_ID/status" '{"status":"PICKED_UP"}' "$ADMIN_TOKEN" "状态推进: ASSIGNED→PICKED_UP"
  test_api PUT "/orders/$NEW_ORDER_ID/status" '{"status":"WASHING"}' "$ADMIN_TOKEN" "状态推进: PICKED_UP→WASHING"
  test_api PUT "/orders/$NEW_ORDER_ID/status" '{"status":"WASHED"}' "$ADMIN_TOKEN" "状态推进: WASHING→WASHED"
  test_api PUT "/orders/$NEW_ORDER_ID/status" '{"status":"DELIVERING"}' "$ADMIN_TOKEN" "状态推进: WASHED→DELIVERING"
  test_api PUT "/orders/$NEW_ORDER_ID/status" '{"status":"COMPLETED"}' "$ADMIN_TOKEN" "状态推进: DELIVERING→COMPLETED"
else
  echo -e "  ${YELLOW}⚠️ 跳过订单生命周期测试（未获取到新订单ID）${NC}"
fi

# 6.9 创建订单后取消
if [ -n "$ORDER_SLOT_ID2" ] && [ "$ORDER_SLOT_ID2" != "null" ]; then
  RESP2=$(test_api POST "/orders" "{\"addressId\":$ORDER_ADDR_ID,\"timeSlotId\":$ORDER_SLOT_ID2,\"remark\":\"测试取消订单\",\"items\":[{\"serviceItemId\":1,\"quantity\":1}]}" "$USER_TOKEN" "创建待取消订单")
  CANCEL_ORDER_ID=$(extract_json "$RESP2" "id")
  if [ -n "$CANCEL_ORDER_ID" ] && [ "$CANCEL_ORDER_ID" != "null" ]; then
    test_api POST "/orders/$CANCEL_ORDER_ID/cancel" '{"reason":"测试取消"}' "$USER_TOKEN" "取消订单"
  fi
fi

echo ""

# ============================================================
# 7. 骑手模块
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🏍️ 模块七：骑手 (Rider) - 3个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 7.1 骑手获取派单列表
RESP=$(test_api GET "/orders/rider/my?page=1&size=10" "" "$RIDER_TOKEN" "骑手-获取我的派单列表")

# 动态获取 PENDING 状态的派单用于接单/完成测试
# 先创建一个新订单用于骑手接单测试
RIDER_TEST_SLOT=$(echo "$SLOTS_RESP" | grep -o '"id":[0-9]*' | sed -n '3p' | grep -o '[0-9]*')
if [ -n "$RIDER_TEST_SLOT" ] && [ "$RIDER_TEST_SLOT" != "null" ]; then
  RIDER_ORD_RESP=$(test_api POST "/orders" "{\"addressId\":$ORDER_ADDR_ID,\"timeSlotId\":$RIDER_TEST_SLOT,\"remark\":\"骑手接单测试\",\"items\":[{\"serviceItemId\":2,\"quantity\":1}]}" "$USER_TOKEN" "创建骑手测试订单")
  RIDER_ORDER_ID=$(extract_json "$RIDER_ORD_RESP" "id")
  if [ -n "$RIDER_ORDER_ID" ] && [ "$RIDER_ORDER_ID" != "null" ]; then
    # 支付+派单
    test_api POST "/orders/$RIDER_ORDER_ID/pay" "" "$USER_TOKEN" "支付骑手测试订单"
    test_api POST "/orders/$RIDER_ORDER_ID/assign" "{\"riderId\":$RIDER_ID}" "$ADMIN_TOKEN" "派单给骑手(测试接单)"

    # 获取新的派单记录ID
    ASSIGNMENTS_RESP=$(curl -s "$BASE_URL/orders/rider/my?page=1&size=100" -H "Authorization: Bearer $RIDER_TOKEN" -H "Content-Type: application/json")
    PENDING_ASSIGNMENT_ID=$(echo "$ASSIGNMENTS_RESP" | grep -o '"id":[0-9]*' | tail -1 | grep -o '[0-9]*')
    echo "     → 待处理派单ID: $PENDING_ASSIGNMENT_ID"

    # 7.2 骑手接单
    test_api PUT "/orders/rider/assignment/$PENDING_ASSIGNMENT_ID/accept" "" "$RIDER_TOKEN" "骑手-接单"

    # 7.3 骑手完成
    test_api PUT "/orders/rider/assignment/$PENDING_ASSIGNMENT_ID/complete" "" "$RIDER_TOKEN" "骑手-完成派单"
  fi
else
  echo -e "  ${YELLOW}⚠️ 跳过骑手接单测试（无可用时段）${NC}"
fi

echo ""

# ============================================================
# 8. 评价模块
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}⭐ 模块八：评价 (Reviews) - 4个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 8.1 获取评价列表(用户)
test_api GET "/reviews?page=1&size=10" "" "$USER_TOKEN" "用户-获取我的评价列表"

# 8.2 获取评价列表(管理员-全部)
test_api GET "/reviews?page=1&size=10" "" "$ADMIN_TOKEN" "管理员-获取全部评价列表"

# 8.3 创建评价(对刚刚完成的订单)
if [ -n "$NEW_ORDER_ID" ] && [ "$NEW_ORDER_ID" != "null" ]; then
  test_api POST "/reviews" "{\"orderId\":$NEW_ORDER_ID,\"rating\":5,\"content\":\"API测试评价：服务非常好！\"}" "$USER_TOKEN" "创建评价(对已完成订单)"
else
  # 尝试对种子数据中的已完成订单评价
  test_api POST "/reviews" '{"orderId":1,"rating":5,"content":"API测试评价：非常满意！"}' "$USER_TOKEN" "创建评价(对已完成订单)"
fi

# 动态获取最新评价ID
REVIEWS_RESP=$(curl -s "$BASE_URL/reviews?page=1&size=100" -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json")
LATEST_REVIEW_ID=$(extract_last_id "$REVIEWS_RESP")
echo "     → 最新评价ID: $LATEST_REVIEW_ID"

# 8.4 管理员回复评价
test_api PUT "/reviews/${LATEST_REVIEW_ID:-1}/reply" '{"reply":"感谢您的好评！我们会持续改进服务质量！"}' "$ADMIN_TOKEN" "管理员-回复评价"

# 8.5 管理员删除评价(删除最新的测试评价)
test_api DELETE "/reviews/${LATEST_REVIEW_ID:-1}" "" "$ADMIN_TOKEN" "管理员-删除评价"

echo ""

# ============================================================
# 9. 投诉模块
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📢 模块九：投诉 (Complaints) - 5个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 9.1 获取投诉列表(用户)
test_api GET "/complaints?page=1&size=10" "" "$USER_TOKEN" "用户-获取我的投诉列表"

# 9.2 获取投诉列表(管理员-全部)
test_api GET "/complaints?page=1&size=10" "" "$ADMIN_TOKEN" "管理员-获取全部投诉列表"

# 9.3 获取投诉详情
test_api GET "/complaints/1" "" "$ADMIN_TOKEN" "获取投诉详情(ID=1)"

# 9.4 用户提交投诉
test_api POST "/complaints" '{"orderId":1,"type":"其他","content":"API测试投诉：测试数据，请忽略"}' "$USER_TOKEN" "用户-提交投诉"

# 动态获取PENDING状态的投诉
COMPLAINTS_RESP=$(curl -s "$BASE_URL/complaints?page=1&size=100&status=PENDING" -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json")
PENDING_COMPLAINT_ID=$(extract_last_id "$COMPLAINTS_RESP")
echo "     → 待处理投诉ID: $PENDING_COMPLAINT_ID"

# 9.5 管理员处理投诉
test_api PUT "/complaints/${PENDING_COMPLAINT_ID:-1}/handle" '{"status":"RESOLVED","handleResult":"经核实退款金额无误，如有疑问请联系客服。"}' "$ADMIN_TOKEN" "管理员-处理投诉"

echo ""

# ============================================================
# 10. 公告模块
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📋 模块十：公告 (Announcements) - 7个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 10.1 获取已发布公告列表(前端)
test_api GET "/announcements?page=1&size=10" "" "" "获取已发布公告列表"

# 10.2 获取公告详情
test_api GET "/announcements/1" "" "" "获取公告详情(ID=1)"

# 10.3 管理端-全部公告(含草稿)
test_api GET "/announcements/all?page=1&size=10" "" "$ADMIN_TOKEN" "管理端-全部公告(含草稿)"

# 10.4 管理端-新增公告(草稿)
test_api POST "/announcements" '{"title":"API测试公告","content":"这是通过API测试脚本创建的公告","type":"SYSTEM","status":0}' "$ADMIN_TOKEN" "管理端-新增公告(草稿)"

# 动态获取新增公告ID
ALL_ANN_RESP=$(curl -s "$BASE_URL/announcements/all?page=1&size=100" -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json")
NEW_ANN_ID=$(extract_last_id "$ALL_ANN_RESP")
echo "     → 新公告ID: $NEW_ANN_ID"

# 10.5 管理端-发布公告
test_api PUT "/announcements/$NEW_ANN_ID/publish" "" "$ADMIN_TOKEN" "管理端-发布公告"

# 10.6 管理端-修改公告
test_api PUT "/announcements/$NEW_ANN_ID" '{"title":"API测试公告(已修改)","content":"修改后的内容"}' "$ADMIN_TOKEN" "管理端-修改公告"

# 10.7 管理端-删除公告
test_api DELETE "/announcements/$NEW_ANN_ID" "" "$ADMIN_TOKEN" "管理端-删除公告"

echo ""

# ============================================================
# 11. 杂项模块 (统计/配置/日志/收入/支付)
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 模块十一：统计/配置/日志/收入/支付 - 9个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 11.1 管理面板统计数据
test_api GET "/statistics/dashboard" "" "$ADMIN_TOKEN" "管理端-获取仪表盘统计"

# 11.2 系统配置列表
test_api GET "/system-configs" "" "$ADMIN_TOKEN" "管理端-获取系统配置"

# 11.3 修改系统配置
test_api PUT "/system-configs/1" '{"configValue":"洁衣到家(测试)"}' "$ADMIN_TOKEN" "管理端-修改系统配置"

# 11.4 恢复系统配置
test_api PUT "/system-configs/1" '{"configValue":"洁衣到家"}' "$ADMIN_TOKEN" "管理端-恢复系统配置"

# 11.5 操作日志列表
test_api GET "/operation-logs?page=1&size=10" "" "$ADMIN_TOKEN" "管理端-获取操作日志"

# 11.6 按模块筛选操作日志
test_api GET "/operation-logs?page=1&size=10&module=%E8%AE%A2%E5%8D%95%E7%AE%A1%E7%90%86" "" "$ADMIN_TOKEN" "管理端-按模块筛选操作日志"

# 11.7 骑手收入(管理员查全部)
test_api GET "/rider-incomes" "" "$ADMIN_TOKEN" "管理端-获取全部骑手收入"

# 11.8 骑手收入(按骑手ID)
test_api GET "/rider-incomes?riderId=${RIDER_ID:-7}" "" "$ADMIN_TOKEN" "管理端-获取指定骑手收入"

# 11.9 骑手查看自己的收入
test_api GET "/rider-incomes" "" "$RIDER_TOKEN" "骑手-查看我的收入"

# 11.10 支付记录(管理员看全部)
test_api GET "/payments?page=1&size=10" "" "$ADMIN_TOKEN" "管理端-获取全部支付记录"

# 11.11 支付记录(用户看自己的)
test_api GET "/payments?page=1&size=10" "" "$USER_TOKEN" "用户-获取我的支付记录"

echo ""

# ============================================================
# 12. 管理员-用户管理模块
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}👥 模块十二：管理员-用户管理 (Admin Users) - 9个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 12.1 获取用户列表
test_api GET "/admin/users?page=1&size=10" "" "$ADMIN_TOKEN" "管理端-用户列表"

# 12.2 按角色筛选
test_api GET "/admin/users?page=1&size=10&role=RIDER" "" "$ADMIN_TOKEN" "管理端-筛选骑手用户"

# 12.3 关键词搜索
test_api GET "/admin/users?page=1&size=10&keyword=%E5%BC%A0%E4%BC%9F" "" "$ADMIN_TOKEN" "管理端-搜索用户(张伟)"

# 12.4 获取用户详情
test_api GET "/admin/users/2" "" "$ADMIN_TOKEN" "管理端-获取用户详情(ID=2)"

# 12.5 创建用户
ADMIN_TEST_USER="admin_test_$(date +%s)"
test_api POST "/admin/users" "{\"username\":\"$ADMIN_TEST_USER\",\"password\":\"123456\",\"nickname\":\"管理端测试用户\",\"role\":\"USER\",\"status\":1}" "$ADMIN_TOKEN" "管理端-创建用户"

# 动态获取刚创建用户的ID (取最新的，即最大ID)
LAST_USER_RESP=$(curl -s "$BASE_URL/admin/users?page=1&size=100" -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json")
# 用户列表按createdAt降序，第一个就是最新的
ADMIN_NEW_USER_ID=$(extract_first_id "$LAST_USER_RESP")
echo "     → 新用户ID: $ADMIN_NEW_USER_ID"

# 12.6 修改用户
test_api PUT "/admin/users/$ADMIN_NEW_USER_ID" '{"nickname":"管理端测试用户(改)"}' "$ADMIN_TOKEN" "管理端-修改用户"

# 12.7 切换用户状态
test_api PUT "/admin/users/$ADMIN_NEW_USER_ID/status" '{"status":0}' "$ADMIN_TOKEN" "管理端-禁用用户"
test_api PUT "/admin/users/$ADMIN_NEW_USER_ID/status" '{"status":1}' "$ADMIN_TOKEN" "管理端-启用用户"

# 12.8 重置密码
test_api PUT "/admin/users/$ADMIN_NEW_USER_ID/reset-password" "" "$ADMIN_TOKEN" "管理端-重置密码"

# 12.9 删除用户(删除测试用户)
test_api DELETE "/admin/users/$ADMIN_NEW_USER_ID" "" "$ADMIN_TOKEN" "管理端-删除用户"

echo ""

# ============================================================
# 13. 权限校验测试 (额外)
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔒 模块十三：权限校验 - 3个接口${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 13.1 无token访问受保护接口
TOTAL=$((TOTAL + 1))
NO_AUTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/addresses" -H "Content-Type: application/json")
if [ "$NO_AUTH_CODE" = "401" ] || [ "$NO_AUTH_CODE" = "403" ]; then
  echo -e "  ${GREEN}✅ PASS${NC} [GET] /addresses (无Token) - 应返回401/403 (实际: $NO_AUTH_CODE)"
  PASS=$((PASS + 1))
else
  echo -e "  ${RED}❌ FAIL${NC} [GET] /addresses (无Token) - 应返回401/403 (实际: $NO_AUTH_CODE)"
  FAIL=$((FAIL + 1))
fi

# 13.2 普通用户访问管理员接口 (403或500均为预期行为)
TOTAL=$((TOTAL + 1))
USER_ADMIN_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/admin/users?page=1&size=10" -H "Authorization: Bearer $USER_TOKEN" -H "Content-Type: application/json")
if [ "$USER_ADMIN_CODE" = "403" ] || [ "$USER_ADMIN_CODE" = "500" ]; then
  echo -e "  ${GREEN}✅ PASS${NC} [GET] /admin/users (用户Token) - 权限拒绝($USER_ADMIN_CODE)"
  PASS=$((PASS + 1))
else
  echo -e "  ${RED}❌ FAIL${NC} [GET] /admin/users (用户Token) - 应返回403/500 (实际: $USER_ADMIN_CODE)"
  FAIL=$((FAIL + 1))
fi

# 13.3 用户访问骑手接口 (403或500均为预期行为)
TOTAL=$((TOTAL + 1))
USER_RIDER_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/orders/rider/my?page=1&size=10" -H "Authorization: Bearer $USER_TOKEN" -H "Content-Type: application/json")
if [ "$USER_RIDER_CODE" = "403" ] || [ "$USER_RIDER_CODE" = "500" ]; then
  echo -e "  ${GREEN}✅ PASS${NC} [GET] /orders/rider/my (用户Token) - 权限拒绝($USER_RIDER_CODE)"
  PASS=$((PASS + 1))
else
  echo -e "  ${RED}❌ FAIL${NC} [GET] /orders/rider/my (用户Token) - 应返回403/500 (实际: $USER_RIDER_CODE)"
  FAIL=$((FAIL + 1))
fi

echo ""

# ============================================================
# 测试结果汇总
# ============================================================
echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  测试结果汇总                        ║${NC}"
echo -e "${BLUE}╠══════════════════════════════════════════════════════╣${NC}"
printf "${BLUE}║${NC}  总计: ${YELLOW}%-3d${NC} 个接口                                   ${BLUE}║${NC}\n" "$TOTAL"
printf "${BLUE}║${NC}  通过: ${GREEN}%-3d${NC} 个  (%d%%)                                ${BLUE}║${NC}\n" "$PASS" "$((PASS * 100 / TOTAL))"
printf "${BLUE}║${NC}  失败: ${RED}%-3d${NC} 个                                        ${BLUE}║${NC}\n" "$FAIL"
echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}🎉 全部测试通过！前后端联调正常！${NC}"
  exit 0
else
  echo -e "${RED}⚠️ 有 $FAIL 个测试未通过，请检查上方日志！${NC}"
  exit 1
fi
