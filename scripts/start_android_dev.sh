#!/bin/bash
# Run on Mac before flutter run on a REAL Android phone (USB)
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT=3000

if curl -sf "http://localhost:$PORT/health" >/dev/null 2>&1; then
  echo "✓ token_server already running on port $PORT"
else
  echo "→ Starting token server..."
  cd "$ROOT/token_server"
  if [ ! -d node_modules ]; then npm install; fi
  npm start &
  SERVER_PID=$!
  sleep 2
  if ! curl -sf "http://localhost:$PORT/health" >/dev/null 2>&1; then
    echo "✗ Server failed to start. If port in use, run: lsof -i :$PORT"
    exit 1
  fi
  echo "✓ Started server (pid $SERVER_PID)"
fi

echo "→ adb reverse (phone localhost:$PORT → Mac localhost:$PORT)"
adb reverse tcp:$PORT tcp:$PORT

echo ""
echo "✓ Ready: http://localhost:$PORT (phone → http://127.0.0.1:$PORT)"
echo "Next: cd guru_app && flutter run  → then press R on app if needed"
