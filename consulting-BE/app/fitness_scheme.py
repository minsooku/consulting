from pydantic import BaseModel, Field
from typing import Literal, Optional, List
from datetime import date

# SYSTEM ------------------------------------------\

SYSTEM_MSG = (
    "You are CoachGPT, a careful and pragmatic planning assistant. "
    "Return STRICT JSON only, no extra text. "
    "Safety rules: no medical advice or supplements. "
    "Respect time budgets and include recovery and nutrition checklists."
)


# Prompt ------------------------------------------\

class Physique(BaseModel):
    height: int
    weight: int
    gender: Literal["Male", "Female"]
    age: int

class FitnessPrompt(BaseModel):
    name: str
    physique: Physique
    goalType: str
    experience: str
    daysPerWeek: int = Field(ge=1, le=7)
    diet: bool


def fitness_prompt(p: FitnessPrompt, start_date: date, end_date: date) -> str:
    return f"""
User name: {p.name}
Physique:
    Height: {p.physique.height} cm
    Weight: {p.physique.weight} kg
    Gender: {p.physique.gender}
    Age: {p.physique.age}
Goal type: {p.goalType}
Experience: {p.experience}
Workout days per week: {p.daysPerWeek}
Include diet plan: {"yes" if p.diet else "no"}
Plan window: {start_date} to {end_date}
Rules:
- Produce exactly ({p.daysPerWeek}) workout days per 7-day week; the remaining days are rest/recovery.
- {"Include daily nutrition blocks and weekly nutrition checklists." if p.diet else "Do NOT include any nutrition or diet blocks. Skip nutrition category entirely."}
"""


# Response ----------------------------------------\

class ChecklistItem(BaseModel):
    label: str
    target_value: Optional[float | str] = None
    unit: Optional[str] = None
    done: bool = False

class DailyPlanBlock(BaseModel):
    title: str
    category: Literal["workout", "nutrition", "habit", "recovery"]
    duration_min: int = Field(ge=1)
    #details: Optional[str] = None
    details: List[ChecklistItem] = []

class Daily(BaseModel):
    date: date
    blocks: List[DailyPlanBlock]

# class WeeklyPlanBlock(BaseModel):
#     title: str
#     category: Literal["workout", "nutrition", "habit", "recovery"]
#     duration_min: int = Field(ge=1)
#     #details: Optional[str] = None
#     weekly_workout: List[ChecklistItem] = []

class Weekly(BaseModel):
    #first_day_date: date
    week_number: int
    theme: str
    notes: str
    details: List[ChecklistItem]

class FitnessResponse(BaseModel):
    daily: List[Daily]
    weekly: List[Weekly]
