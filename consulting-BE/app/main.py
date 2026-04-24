import os
from datetime import date, timedelta
from fastapi import Body, FastAPI, Header, HTTPException
from dotenv import load_dotenv
from openai import OpenAI

from app.fitness_scheme import FitnessResponse, FitnessPrompt, fitness_prompt, SYSTEM_MSG
from app import auth, routes
from app.auth import normalize_uuid
from app.database import Base, check_database_connection, engine, ensure_user_uuid_column

load_dotenv()
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-5-nano")
PLAN_WEEKS = int(os.getenv("PLAN_WEEKS", "4"))

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

app = FastAPI(title="AI Fitness Planner", version="0.1.0")

Base.metadata.create_all(bind=engine)
ensure_user_uuid_column()

app.include_router(auth.router)
app.include_router(routes.router)


def call_openai(p: FitnessPrompt, start_date: date, end_date: date):
    return client.responses.parse(
        model=OPENAI_MODEL,
        input=[
            {"role": "system", "content": SYSTEM_MSG},
            {"role": "user", "content": fitness_prompt(p, start_date, end_date)},
        ],
        text_format=FitnessResponse,
    )


@app.get("/health")
def health():
    return {"ok": True}


@app.get("/health/db")
def database_health():
    try:
        check_database_connection()
        return {"ok": True, "database": "connected"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Database connection failed: {e}")


@app.post("/test", response_model=FitnessResponse)
def generate_fitness_plan(
    prompt: FitnessPrompt = Body(...),
    x_user_uuid: str | None = Header(default=None, alias="X-User-UUID"),
):
    if x_user_uuid:
        normalize_uuid(x_user_uuid)

    start = date.today()
    end = start + timedelta(weeks=PLAN_WEEKS) - timedelta(days=1)
    try:
        return call_openai(prompt, start, end).output_parsed
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
