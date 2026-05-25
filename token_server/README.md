# WTF Token & Sync Server

Local HTTP server for:
- **100ms auth tokens** — `GET /token?userId=&role=&roomId=`
- **Cross-app sync** — chat, call requests, sessions (Guru + Trainer apps)

## Setup

```bash
cd token_server
cp .env.example .env
npm install
npm start
```

Server runs at `http://localhost:3000`.

- **Android emulator**: apps use `10.0.2.2:3000` automatically
- **iOS simulator / desktop**: `localhost:3000`

## 100ms credentials

1. Register at [dashboard.100ms.live](https://dashboard.100ms.live/register)
2. Create a template with roles `trainer` and `member`
3. Add to `.env`:
   - `HMS_APP_ACCESS_KEY`
   - `HMS_APP_SECRET`
   - `HMS_TEMPLATE_ID`
4. Set `HMS_DEV_MODE=false` for real tokens

With `HMS_DEV_MODE=true` (default), mock JWT tokens are issued for local UI testing. For full RTC, use real credentials and dashboard template roles matching `member` / `trainer`.

## API overview

| Endpoint | Description |
|----------|-------------|
| `GET /health` | Health check |
| `GET /token` | 100ms join token |
| `GET /api/users` | Seeded users (DK, Aarav) |
| `GET/POST /api/messages` | Chat |
| `GET/POST/PATCH /api/call-requests` | Scheduling |
| `GET /api/rooms` | Room meta after approve |
| `GET/POST/PATCH /api/sessions` | Session logs |

Data persists in `data/store.json`.
