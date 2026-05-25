# WTF Assessment — Feature Checklist

Run with: `token_server` + `adb reverse tcp:3000 tcp:3000` + both apps.

**Automated:** `cd shared && flutter test` (covers most rows below — see `test/checklist_scenarios_test.dart`)  
**Device E2E:** manual script at bottom

Legend: **Auto** = `flutter test` | **Manual** = real phone + server

## A. First-run & Auth

| # | Scenario | Guru | Trainer | Auto test file | Manual |
|---|----------|------|---------|----------------|--------|
| A1 | First run onboarding (2 slides) | Manual | N/A | — | ☐ |
| A2 | Choose trainer Aarav | Auto | N/A | `models_roundtrip_test` | ☐ |
| A3 | Trainer mock login | N/A | Auto | `auth_service_test`, `trainer_home_widget_test` | ☐ |
| A4 | Reinstall → onboarding again | Auto | Auto | `auth_service_test` clearSession | ☐ |
| A5 | Return visit → home (no onboarding) | Auto | Auto | `auth_service_test`, `guru_home_widget_test` | ☐ |

## B. Chat

| # | Scenario | Guru | Trainer | Auto test file | Manual |
|---|----------|------|---------|----------------|--------|
| B1 | DK sends message | Auto | Auto | `message_test`, `models_roundtrip_test` | ☐ |
| B2 | Trainer sees unread badge | Manual | Manual | `widgets_smoke_test` (badge UI) | ☐ |
| B3 | Trainer replies | Manual | Manual | — | ☐ |
| B4 | Read receipts (double tick) | Auto | Auto | `models_roundtrip_test` | ☐ |
| B5 | Typing indicator | Manual | Manual | — | ☐ |
| B6 | Quick replies chips | Auto | Auto | `app_strings_test` | ☐ |
| B7 | System message on approve | Manual | Manual | — (server) | ☐ |
| B8 | Empty chat CTA | Auto | Auto | `app_strings_test` | ☐ |

## C. Schedule & Calls

| # | Scenario | Guru | Trainer | Auto test file | Manual |
|---|----------|------|---------|----------------|--------|
| C1 | Schedule future slot | Auto | N/A | `scheduler_validator_test`, `time_utils_test` | ☐ |
| C2 | Conflict error same slot | Auto | N/A | `scheduler_validator_test` | ☐ |
| C3 | Toast "Call requested..." | Auto | N/A | `app_strings_test` | ☐ |
| C4 | Trainer sees pending | Manual | Manual | `models_roundtrip_test` | ☐ |
| C5 | Approve request | N/A | Manual | `models_roundtrip_test` | ☐ |
| C6 | Decline with reason | N/A | Auto | `models_roundtrip_test` | ☐ |
| C7 | Join within 10 min window | Auto | Auto | `time_utils_test` | ☐ |
| C8 | Pre-join device check | Manual | Manual | — | ☐ |
| C9 | In-call mute/video/flip | Manual | Manual | — | ☐ |
| C10 | End call → session log | Manual | Manual | `duration_test` | ☐ |
| C11 | DK rates session | Manual | N/A | — | ☐ |
| C12 | Trainer notes | N/A | Manual | — | ☐ |

## D. Sessions

| # | Scenario | Guru | Trainer | Auto test file | Manual |
|---|----------|------|---------|----------------|--------|
| D1 | List after call | Auto | Auto | `models_roundtrip_test` | ☐ |
| D2 | Filters All / 7d / Month | Manual | Manual | — | ☐ |
| D3 | Detail modal | Manual | Manual | — | ☐ |
| D4 | Share export | Manual | Manual | — | ☐ |

## E. Architecture & Quality

| # | Item | Status |
|---|------|--------|
| E1 | `AppStrings` central copy | ✅ `app_strings_test` |
| E2 | `AppRouter` navigation | ✅ code + widget tests |
| E3 | Riverpod providers | ✅ providers + `checklist_scenarios_test` |
| E4 | Conversation controller | ✅ `checklist_scenarios_test` |
| E5 | Polling 2s | ✅ code |
| E6 | `flutter analyze` clean | ✅ run `flutter analyze` |
| E7 | Unit tests `shared/test` | ✅ `flutter test` (30+ tests) |
| E8 | DevPanel + logs | ✅ `widgets` + manual |

## Run all automated tests

```bash
cd shared && flutter test
cd ../guru_app && flutter test
cd ../trainer_app && flutter test
```

## Manual test script (reviewer)

1. `./scripts/start_android_dev.sh`
2. Trainer login → Guru onboarding DK
3. DK: "Hi Coach 👋" → Trainer reply
4. DK schedule today +10 min, note "Macros review"
5. Trainer approve → system message both sides
6. Both Join Call → end → rate/notes
7. Sessions list latest on top

Tick **Manual** column ☐ after device run.
