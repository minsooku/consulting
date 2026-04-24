import os
from datetime import date, timedelta
from fastapi import FastAPI, HTTPException, Body
from dotenv import load_dotenv
from openai import OpenAI

from app.fitness_scheme import FitnessResponse, FitnessPrompt, fitness_prompt, SYSTEM_MSG
from app import auth, routes
from app.database import Base, engine

load_dotenv()
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-5-nano")
PLAN_WEEKS = int(os.getenv("PLAN_WEEKS", "4"))

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

app = FastAPI(title="AI Fitness Planner", version="0.1.0")

Base.metadata.create_all(bind=engine)

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


@app.post("/test", response_model=FitnessResponse)
def generate_fitness_plan(prompt: FitnessPrompt = Body(...)):
    start = date.today()
    end = start + timedelta(weeks=PLAN_WEEKS) - timedelta(days=1)
    try:
        return call_openai(prompt, start, end).output_parsed
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))