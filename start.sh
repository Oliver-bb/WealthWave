#!/bin/bash

echo "🚀 Starting WealthWave project..."

# --------------------------
# 启动 FastAPI 后端
# --------------------------
echo "🌐 Starting FastAPI backend..."
cd backend || { echo "❌ backend folder not found"; exit 1; }

# 安装 Python 依赖（只在没装过时需要）
if [ -f "requirements.txt" ]; then
  pip install -r requirements.txt
fi

uvicorn app.main:app --reload &
BACKEND_PID=$!

# 回到项目根目录
cd ..

# --------------------------
# 启动 Vue 前端
# --------------------------
echo "🖥️ Starting Vue frontend..."

# 确认 node_modules 存在，否则先安装
if [ ! -d "node_modules" ]; then
  echo "📦 Installing npm dependencies..."
  npm install
fi

# 确保 vite 有执行权限
if [ ! -x "node_modules/.bin/vite" ]; then
  chmod +x node_modules/.bin/vite
fi

npm run dev &

# --------------------------
# 退出时清理子进程
# --------------------------
trap "kill 0" EXIT

# 等待后端结束（前端会并行跑）
wait $BACKEND_PID
