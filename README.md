# QuickBite Monorepo

QuickBite is a portfolio-grade food delivery app built with:
- `mobile/` — Flutter (Riverpod, GoRouter, Dio)
- `backend/` — FastAPI (JWT auth, SQLAlchemy, SQLite)

## Prerequisites
- Flutter stable SDK
- Python 3.11+
- Android SDK + `adb` (for physical Android device workflows)

## Repository Structure
- `mobile/` Flutter app
- `backend/` FastAPI backend
- `tests/` consolidated test docs/reporting

## Quick Start (Fresh Clone)

### 1) Backend Setup and Run
```bash
cd backend
python3 -m venv ../.venv
source ../.venv/bin/activate
pip install -r requirements.txt
python seed.py
python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

Backend health check (new terminal):
```bash
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/restaurants
```

### 2) Mobile Setup and Run
```bash
cd mobile
flutter pub get
flutter run
```

### 3) Android Physical Device Networking
If using a USB-connected Android device, run this before `flutter run`:
```bash
$HOME/Android/Sdk/platform-tools/adb reverse tcp:8000 tcp:8000
$HOME/Android/Sdk/platform-tools/adb reverse --list
```

The app uses `http://127.0.0.1:8000` by default; `adb reverse` maps device localhost to your laptop backend.

## Authentication
- Register in-app via `Register` screen, or login with seeded demo credentials:
	- Email: `demo@quickbite.dev`
	- Password: `DemoPass123`
- Protected routes include checkout, order confirmation/tracking, and profile.

## QA Commands

### Backend
```bash
cd backend
../.venv/bin/python -m pytest tests -q
```

### Mobile
```bash
cd mobile
flutter analyze
flutter test -r compact
```

## Environment
Copy `.env.example` to `.env` and adjust values as needed.
