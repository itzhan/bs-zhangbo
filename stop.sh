#!/bin/bash
# ============================================
# 洁衣到家 - 一键停止脚本
# ============================================

echo "🛑 正在停止所有服务..."

# 停止后端
BACKEND_PID=$(lsof -ti:8080 2>/dev/null)
if [ -n "$BACKEND_PID" ]; then
  kill $BACKEND_PID 2>/dev/null
  echo "✅ 后端已停止 (PID: $BACKEND_PID)"
else
  echo "⏭️  后端未运行"
fi

# 停止管理端
ADMIN_PID=$(lsof -ti:8848 2>/dev/null)
if [ -n "$ADMIN_PID" ]; then
  kill $ADMIN_PID 2>/dev/null
  echo "✅ 管理端已停止 (PID: $ADMIN_PID)"
else
  echo "⏭️  管理端未运行"
fi

# 停止用户端
FRONTEND_PID=$(lsof -ti:3000 2>/dev/null)
if [ -n "$FRONTEND_PID" ]; then
  kill $FRONTEND_PID 2>/dev/null
  echo "✅ 用户端已停止 (PID: $FRONTEND_PID)"
else
  echo "⏭️  用户端未运行"
fi

echo "🎉 所有服务已停止"
