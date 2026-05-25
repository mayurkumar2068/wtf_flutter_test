# WTF Flutter Assessment — Guru ↔ Trainer Chat + Video (100ms)

Two Flutter apps (Member **DK** + Trainer **Aarav**) with real-time chat, call scheduling, **100ms** video calls, and session logs — running locally via a shared sync/token server.

## Structure

```
wtf_flutter_test/
├── README.md
├── AI_LEDGER.md
├── ARCHITECTURE.md
├── DECISIONS.md
├── token_server/     # Node: 100ms tokens + chat/call sync API
├── shared/           # wtf_shared package (models, services, UI)
├── guru_app/         # Member app (blue #1769E0)
└── trainer_app/      # Trainer app (red #E50914)
```

## Quick start

### 1. Start sync + token server

**Real Android phone (USB)** — recommended:

```bash
./scripts/start_android_dev.sh
```

Starts `token_server` + `adb reverse tcp:3000 tcp:3000` (phone uses `127.0.0.1:3000`).

**Manual / emulator:**

```bash
cd token_server && npm install && npm start
adb reverse tcp:3000 tcp:3000   # real phone only
```

| Device | App URL |
|--------|---------|
| Emulator | `http://10.0.2.2:3000` |
| Real phone + adb reverse | `http://127.0.0.1:3000` |
| Wi‑Fi only | `flutter run --dart-define=SYNC_HOST=YOUR_MAC_LAN_IP` |

### 2. Run Guru app (Member DK)

```bash
cd guru_app
flutter pub get
flutter run
```

### 3. Run Trainer app (Aarav)

Second terminal / second device:

```bash
cd trainer_app
flutter pub get
flutter run
```

## Manual test flow (reviewer script)

1. Start `token_server`, then Trainer app → login as **Aarav**.
2. Start Guru app → onboarding → profile **DK** → assign Aarav.
3. DK sends **"Hi Coach 👋"** → Trainer sees unread → replies.
4. DK schedules call (today 6:00 PM, note: "Macros review").
5. Trainer **Requests** → Approve → DK sees system message.
6. Within join window, both tap **Join Call** → pre-join → in-call controls.
7. End call → DK rates 5★, Trainer adds notes.
8. **Sessions** list shows latest log with duration/rating.

## 100ms setup (production RTC)

1. Create project at [dashboard.100ms.live](https://dashboard.100ms.live)
2. Template roles: `member`, `trainer`
3. Set `.env` in `token_server` and `HMS_DEV_MODE=false`
4. See [token_server/README.md](token_server/README.md)

## Tests

Automated coverage maps to [CHECKLIST.md](CHECKLIST.md) (Auto column).

```bash
cd shared && flutter test          # 31 tests — models, auth, schedule, UI smoke
cd guru_app && flutter test        # home widget + scheduler
cd trainer_app && flutter test     # home widget + message
cd shared && flutter analyze
cd guru_app && flutter analyze
cd trainer_app && flutter analyze
```

**Manual only** (need server + 2 devices): cross-app chat sync, 100ms call, onboarding slides UI, session filters, share.

## Docs

- [ARCHITECTURE.md](ARCHITECTURE.md) — system design & RTC flow
- [DECISIONS.md](DECISIONS.md) — ADRs (state, storage, RTC)
- [AI_LEDGER.md](AI_LEDGER.md) — AI-native workflow evidence

## Demo video

Record a ~3 min screen capture of the manual test flow above for submission.
