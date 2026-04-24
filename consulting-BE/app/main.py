import json
from fastapi import FastAPI, HTTPException, Body
import os
#from tenacity import retry, stop_after_attempt, wait_exponential
from dotenv import load_dotenv
from openai import OpenAI
from app.fitness_scheme import FitnessResponse, FitnessPrompt, fitness_prompt, SYSTEM_MSG

# OpenAI API key check
load_dotenv()
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-5-nano")

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

app = FastAPI(title="AI Fitness Planner", version="0.1.0")


p = FitnessPrompt(
    physique={
        "height": 180,
        "weight": 85,
        "gender": "Male",
        "age": 35,
    },
    goalType="hypertrophy & weight cut",
    experience="Intermediate ~ advanced (2+ years consistent training)",
    hoursPerWeek=12,
    constraints="",
    preferences="",
    dietEffort="",
    startDate="2025-09-15",
    endDate="2025-09-22",
)

def call_openai(p: FitnessPrompt):
    response = client.responses.parse(
    model=OPENAI_MODEL,
    input=[
        {
            "role": "system", 
            "content": SYSTEM_MSG
        },
        {
            "role": "user",
            "content": fitness_prompt(p)
        }
    ],
    text_format=FitnessResponse,
    )
    return response

@app.get("/health")
def health():
    return {"ok": True}

@app.post("/test", response_model=FitnessResponse)
def generate_fitness_plan(prompt: FitnessPrompt = Body(...)):
    try:
        return call_openai(prompt).output_parsed
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))