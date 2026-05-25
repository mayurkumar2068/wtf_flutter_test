# Architecture Decision Records

## ADR-1: State management — Riverpod

**Decision:** Use `flutter_riverpod` for dependency injection and reactive reads.

**Rationale:** Lightweight providers map cleanly to services (`SyncClient`, `ChatService`, `CallService`). Less boilerplate than Bloc for a 6-hour assessment while remaining testable.

**Alternatives considered:** Bloc (more ceremony), Provider (less ergonomic for async).

---

## ADR-2: Storage — Hive + local sync server

**Decision:** Hive for per-app session/auth cache; Node `token_server` as shared data plane.

**Rationale:** Assessment requires two separate apps communicating on one device. Shared filesystem is not available across app sandboxes. A tiny local API matches "local-first without cloud backend" and keeps Firebase optional.

**Alternatives considered:** Firebase (faster realtime but external dependency), shared SQLite via content provider (heavy for timeline).

---

## ADR-3: RTC strategy — 100ms SDK + token server

**Decision:** `hmssdk_flutter` with custom in-call UI; tokens from `token_server`.

**Rationale:** Assessment mandates 100ms. Token generation must not ship secrets in the client. Server supports dev mock tokens and production 100ms Management API.

**Room lifecycle:** On trainer approve → `RoomMeta` with stable `hmsRoomId` → both clients fetch role-scoped token before join.

**Edge cases:** Reconnect via SDK callbacks; token refresh hook logged on `onHMSError`; permissions via `permission_handler`.

---

## ADR-4: UI design system

**Decision:** 8pt grid, Guru primary `#1769E0`, Trainer `#E50914`, shared components in `wtf_shared`.

**Motion:** 150–250ms page transitions; bubble slide-in via `TweenAnimationBuilder`.
