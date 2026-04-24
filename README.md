# AI Consulting Project

Fitness planning app with a FastAPI backend and an Expo React Native frontend.

## Project Structure

```text
consulting-BE/          FastAPI backend
consulting-FE/frontend/ Expo React Native app
```

## Backend Setup

```bash
cd consulting-BE
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python -m uvicorn app.main:app --reload
```

The API runs at:

```text
http://127.0.0.1:8000
```

Useful checks:

```bash
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/health/db
```

## Backend Environment

Create `consulting-BE/.env` with:

```env
OPENAI_API_KEY=your_openai_api_key
OPENAI_MODEL=gpt-5-nano
PLAN_WEEKS=4
SECRET_KEY=replace_with_a_long_random_secret

DATABASE_URL=postgresql://postgres.your-project-ref:your-password@your-supabase-pooler-host:5432/postgres
DB_SSLMODE=require
```

For Supabase, copy the database connection string from `Project Settings -> Database -> Connection string`.

## UUID Auth Flow

The iPhone frontend can send a user UUID instead of a bearer auth token.

Send this header:

```http
X-User-UUID: 550e8400-e29b-41d4-a716-446655440000
```

Example:

```bash
curl http://127.0.0.1:8000/auth/uuid/me \
  -H "X-User-UUID: 550e8400-e29b-41d4-a716-446655440000"
```

The backend still keeps the older `/auth/register` and `/auth/login` routes.

## Frontend Setup

```bash
cd consulting-FE/frontend
npm install
npx expo start -c
```

For iOS simulator, run:

```bash
npm run ios
```

## Notes

Never commit real `.env` secrets. If an API key or database password is exposed, revoke or reset it before continuing.
