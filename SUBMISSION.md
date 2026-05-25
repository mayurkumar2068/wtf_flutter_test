# Submission Guide — WTF Flutter Assessment

## What to send

| Item | Status |
|------|--------|
| GitHub repo (public or invite reviewer) | See below |
| ~3 min demo video | [DEMO_VIDEO_SCRIPT.md](DEMO_VIDEO_SCRIPT.md) |
| Run instructions | [README.md](README.md) |
| AI ledger + architecture | [AI_LEDGER.md](AI_LEDGER.md), [ARCHITECTURE.md](ARCHITECTURE.md) |

## 1. Push to GitHub

Repo is initialized on branch `main`. From `wtf_flutter_test/`:

```bash
# Create empty repo on GitHub: https://github.com/new
# Name example: wtf-flutter-assessment (no README — already local)

git remote add origin https://github.com/YOUR_USERNAME/wtf-flutter-assessment.git
git push -u origin main
```

SSH:

```bash
git remote add origin git@github.com:YOUR_USERNAME/wtf-flutter-assessment.git
git push -u origin main
```

After push, copy the repo URL for the submission form.

## 2. Record demo video (~3 min)

Follow **[DEMO_VIDEO_SCRIPT.md](DEMO_VIDEO_SCRIPT.md)** scene by scene.

**Before recording:**

```bash
./scripts/start_android_dev.sh
# Terminal 2: cd guru_app && flutter run
# Terminal 3: cd trainer_app && flutter run   # second device or emulator
```

**Recording (macOS):** QuickTime → File → New Screen Recording, or `Cmd+Shift+5` → Record Selected Portion.

Upload to Google Drive / Loom / YouTube (unlisted) and paste link in submission.

## 3. Email / form fields (template)

```
Project: WTF Flutter Assessment — Guru ↔ Trainer
Repo: https://github.com/YOUR_USERNAME/wtf-flutter-assessment
Video: https://...
Run: See README.md — token_server + adb reverse + flutter run (both apps)
Tests: cd shared && flutter test (31 tests)
Notes: 100ms runs in HMS_DEV_MODE (mock tokens). Real RTC: token_server/.env.example
```

## 4. Optional release APKs

```bash
cd guru_app && flutter build apk --release
cd ../trainer_app && flutter build apk --release
# APKs: build/app/outputs/flutter-apk/app-release.apk
```

## 5. Verify before submit

```bash
curl http://127.0.0.1:3000/health
cd shared && flutter test
cd ../guru_app && flutter test
cd ../trainer_app && flutter test
```
