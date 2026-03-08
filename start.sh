#!/bin/bash
# ============================================
# 洁衣到家 - 一键启动脚本
# ============================================
# 后端:    http://localhost:8080
# 管理端:  http://localhost:8848
# 用户端:  http://localhost:3000
# ============================================

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKEND_PID=""
ADMIN_PID=""
FRONTEND_PID=""

cleanup() {
  echo ""
  echo -e "${YELLOW}🛑 正在停止所有服务...${NC}"
  [ -n "$BACKEND_PID" ] && kill "$BACKEND_PID" 2>/dev/null
  [ -n "$ADMIN_PID" ] && kill "$ADMIN_PID" 2>/dev/null
  [ -n "$FRONTEND_PID" ] && kill "$FRONTEND_PID" 2>/dev/null
  # 也按端口清理
  lsof -ti:8080 | xargs kill 2>/dev/null
  lsof -ti:8848 | xargs kill 2>/dev/null
  lsof -ti:3000 | xargs kill 2>/dev/null
  echo -e "${GREEN}✅ 所有服务已停止${NC}"
  exit 0
}

trap cleanup SIGINT SIGTERM

echo -e "${BLUE}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║       🧺  洁衣到家 启动中...        ║"
echo "  ║   上门洗衣预约服务系统 一键启动      ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"

# ---- 1. 启动后端 ----
echo -e "${YELLOW}[1/3] 启动后端服务 (Spring Boot :8080)...${NC}"
cd "$PROJECT_DIR/backend"
if [ ! -f "pom.xml" ]; then
  echo -e "${RED}❌ 未找到 backend/pom.xml，请检查项目结构${NC}"
  exit 1
fi
mvn spring-boot:run -q > "$PROJECT_DIR/.backend.log" 2>&1 &
BACKEND_PID=$!
echo -e "${GREEN}   后端已启动 (PID: $BACKEND_PID)，日志: .backend.log${NC}"

# 等待后端就绪
echo -n "   等待后端启动"
for i in $(seq 1 30); do
  if curl -s http://localhost:8080/api/service-items > /dev/null 2>&1; then
    echo ""
    echo -e "${GREEN}   ✅ 后端已就绪!${NC}"
    break
  fi
  echo -n "."
  sleep 2
done
echo ""

# ---- 2. 启动管理端 ----
echo -e "${YELLOW}[2/3] 启动管理端 (Geeker-Admin :8848)...${NC}"
cd "$PROJECT_DIR/admin"
if [ ! -d "node_modules" ]; then
  echo -e "${YELLOW}   📦 首次运行，安装管理端依赖...${NC}"
  pnpm install 2>&1 | tail -3
fi
pnpm dev > "$PROJECT_DIR/.admin.log" 2>&1 &
ADMIN_PID=$!
echo -e "${GREEN}   管理端已启动 (PID: $ADMIN_PID)，日志: .admin.log${NC}"

# ---- 3. 启动用户端 ----
echo -e "${YELLOW}[3/3] 启动用户端 (Vue3+NaiveUI :3000)...${NC}"
cd "$PROJECT_DIR/frontend"
if [ ! -d "node_modules" ]; then
  echo -e "${YELLOW}   📦 首次运行，安装用户端依赖...${NC}"
  pnpm install 2>&1 | tail -3
fi
pnpm dev > "$PROJECT_DIR/.frontend.log" 2>&1 &
FRONTEND_PID=$!
echo -e "${GREEN}   用户端已启动 (PID: $FRONTEND_PID)，日志: .frontend.log${NC}"

# ---- 完成 ----
sleep 2
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${GREEN}🎉 所有服务启动完成！${NC}                       ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}                                              ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}  📡 后端API:  ${GREEN}http://localhost:8080${NC}          ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}  🔧 管理端:   ${GREEN}http://localhost:8848${NC}          ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}  🌐 用户端:   ${GREEN}http://localhost:3000${NC}          ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}                                              ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}  管理员账号: admin / 123456                  ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}  按 ${RED}Ctrl+C${NC} 停止所有服务                     ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
echo ""

# 保持脚本运行，等待用户 Ctrl+C
wait
