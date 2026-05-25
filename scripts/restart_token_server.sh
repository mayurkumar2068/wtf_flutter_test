#!/bin/bash
# Stop anything on 3000 and start fresh token_server (needed after code changes).
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT=3000

PIDS=$(lsof -ti :$PORT 2>/dev/null || true)
if [ -n "$PIDS" ]; then
  echo "→ Stopping process on port $PORT ($PIDS)"
  kill $PIDS 2>/dev/null || true
  sleep 1
fi

cd "$ROOT/token_server"
if [ ! -d node_modules ]; then npm install; fi
echo "→ Starting token_server..."
npm start
