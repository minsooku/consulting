# AI-Consulting-Project-Serv

AI consulting project server-side.

## Supabase setup

1. Copy the environment example:

```bash
cp .env.example .env
```

2. In Supabase, open `Project Settings -> Database -> Connection string`.

3. Paste the Postgres connection string into `DATABASE_URL` in `.env`.

4. Keep SSL enabled:

```env
DB_SSLMODE=require
```

5. Create a virtual environment, install dependencies, and run the API:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python -m uvicorn app.main:app --reload
```

6. Confirm the connection:

```bash
curl http://127.0.0.1:8000/health/db
```

The app uses SQLAlchemy against Supabase Postgres. Tables are created on startup from the models in `app/models.py`.
