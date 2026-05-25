# Submission Guide — WTF Flutter Assessment

## Submitted links

| Item | Link |
|------|------|
| **GitHub repo** | https://github.com/mayurkumar2068/wtf_flutter_test |
| **Demo video** | https://drive.google.com/file/d/1eDxgZ-xrh_oyuwPrGon87p9C2Q6Kjl0g/view?usp=sharing |
| **Assessment doc** | https://docs.google.com/document/d/1Qxr40N_neoHbrelAFiGVh1x03FA5EHbP303O5JdNBFc/edit?usp=sharing |

## Copy-paste for form / email

```
Project: WTF Flutter Assessment — Guru ↔ Trainer
Repo: https://github.com/mayurkumar2068/wtf_flutter_test
Video: https://drive.google.com/file/d/1eDxgZ-xrh_oyuwPrGon87p9C2Q6Kjl0g/view?usp=sharing
Run: See README.md — token_server + adb reverse + flutter run (both apps)
Tests: cd shared && flutter test (31 tests)
Notes: 100ms runs in HMS_DEV_MODE (mock tokens). Real RTC: token_server/.env.example
```

## What to send

| Item | Status |
|------|--------|
| GitHub repo | ✅ Published |
| ~3 min demo video | ✅ [Google Drive](https://drive.google.com/file/d/1eDxgZ-xrh_oyuwPrGon87p9C2Q6Kjl0g/view?usp=sharing) |
| Run instructions | [README.md](README.md) |
| AI ledger + architecture | [AI_LEDGER.md](AI_LEDGER.md), [ARCHITECTURE.md](ARCHITECTURE.md) |

## Run locally (reviewer)

```bash
./scripts/start_android_dev.sh
# Terminal 2: cd guru_app && flutter run
# Terminal 3: cd trainer_app && flutter run
```

Real phone: `adb reverse tcp:3000 tcp:3000`

## Verify

```bash
curl http://127.0.0.1:3000/health
cd shared && flutter test
cd ../guru_app && flutter test
cd ../trainer_app && flutter test
```

## Optional release APKs

```bash
cd guru_app && flutter build apk --release
cd ../trainer_app && flutter build apk --release
```
