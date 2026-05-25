# AI Ledger — WTF Flutter Assessment

Structured record of AI-assisted work (Cursor / Claude). Update commit SHAs after pushing to GitHub.

| # | Tool | Intent | Output / adaptation | Where used |
|---|------|--------|---------------------|------------|
| 1 | Cursor | Parse assessment `.docx` requirements | Extracted full spec: monorepo layout, UX scenarios, 100ms, AI ledger | Project scaffold |
| 2 | Cursor | Choose cross-app sync architecture | Local Node server + polling vs Firebase; documented in ADR-2 | `token_server/`, `ARCHITECTURE.md` |
| 3 | Cursor | Generate shared data models | User, Message, CallRequest, SessionLog, RoomMeta + JSON serde | `shared/lib/models/` |
| 4 | Cursor | Implement Riverpod providers | syncClient, auth, chat, call providers | `shared/lib/providers/` |
| 5 | Cursor | Build chat UX (bubbles, typing, ticks) | MessageBubble, ChatInputBar, ConversationScreen | `shared/lib/widgets/`, screens |
| 6 | Cursor | 100ms CallService + HMSUpdateListener | join/leave, mute/video, reconnect callbacks | `shared/lib/services/call_service.dart` |
| 7 | Cursor | Node token server + 100ms API | Express routes, mock dev tokens, approve→room | `token_server/src/index.js` |
| 8 | Cursor | Guru onboarding + schedule flow | 2-slide onboarding, DK profile, slot validation | `guru_app/lib/screens/` |
| 9 | Cursor | Trainer requests approve/decline | Inline actions + system messages | `trainer_app/.../requests_screen.dart` |
| 10 | Cursor | Unit tests per assessment §6 | Message serde, scheduler past/conflict, duration | `shared/test/` |
| 11 | Cursor | Debug HMS analyze errors | Fixed `onHMSError`, `CardThemeData`, deprecated toggle APIs | `call_service.dart` commit |
| 12 | Cursor | Docs + submission README | README, ARCHITECTURE, DECISIONS, run instructions | repo root |

## Debugging with AI

**Error:** `non_abstract_class_inherits_abstract_member` on `CallService` / missing `onHMSError`.

**AI steps:** Searched `hmssdk_flutter` source in pub-cache → added `onHMSError` implementation; removed invalid `HMSRoomUpdate.reconnecting` enum values; used `onReconnecting`/`onReconnected` instead.

## Refactor with AI

**Before:** Duplicate `isPastSlot` in scheduler_validator and time_utils.

**After:** Single export from `time_utils.dart`; validator imports it — reduces drift.

## Commit references

| SHA | Message | AI ledger items |
|-----|---------|-----------------|
| `1398bda` | feat: scaffold monorepo and shared package | #1–12 (monorepo: shared, token_server, both apps, tests, scripts) |
| `3daa329` | docs: submission guide, demo script, checklist | #12 + submission pack |

**Git:** branch `main`, repo root `wtf_flutter_test/`. Push: [SUBMISSION.md](SUBMISSION.md).

**Post-push:** replace `YOUR_USERNAME` in SUBMISSION email template with actual GitHub URL.
