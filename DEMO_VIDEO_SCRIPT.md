# Demo Video Script (~3 minutes)

Record both apps side by side (split screen) or cut between Trainer → Guru. Speak briefly or use on-screen text.

| Time | App | Action | Show on screen |
|------|-----|--------|----------------|
| 0:00 | — | Title card / terminal | `npm start` or `./scripts/start_android_dev.sh`, `curl .../health` → ok |
| 0:15 | Trainer | Open app → Login **Aarav** | Dashboard with 4 tiles |
| 0:30 | Guru | Fresh install / clear data → Onboarding 2 slides → **DK** → assign Aarav | Home workspace, blue theme |
| 0:50 | Guru | Chats → send **"Hi Coach 👋"** | Message sent |
| 1:00 | Trainer | Chats → unread badge → open DK → reply | Badge clears, double ticks |
| 1:15 | Guru | Schedule → today +10 min, note **"Macros review"** | Toast "Call requested..." |
| 1:25 | Trainer | Requests → **Approve** | Pending → approved |
| 1:35 | Both | Chat shows **system message** (approved) | Same thread both sides |
| 1:45 | Both | **Join Call** (within window) → pre-join mic/cam → in-call mute/video | Dev mode call UI |
| 2:15 | Both | End call | Post-call sheets |
| 2:25 | Guru | Rate **5★** | Rating saved |
| 2:30 | Trainer | Session notes | Notes on log |
| 2:40 | Both | **Sessions** tab → latest on top, duration | Filter optional |
| 2:50 | Guru | Optional: send **photo** in chat → tap → preview/download | Server upload URL |
| 3:00 | — | End card | Repo URL + `flutter test` passing |

## Tips

- Keep **server online** entire recording (`adb reverse tcp:3000 tcp:3000` on real phone).
- If call join fails, schedule slot **now + 5 minutes** and wait until join window opens.
- DevPanel (shake/long-press if enabled) — only if you want to show logs; not required.

## One-liner for video description

```
WTF Assessment: Member DK + Trainer Aarav — chat, schedule, 100ms video (dev), sessions.
Repo: https://github.com/mayurkumar2068/wtf_flutter_test
Video: https://drive.google.com/file/d/1eDxgZ-xrh_oyuwPrGon87p9C2Q6Kjl0g/view?usp=sharing
```
