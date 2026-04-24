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
    notes: Optional[str] = None

class FitnessPrompt(BaseModel):
    physique: Physique
    goalType: str
    experience: str
    hoursPerWeek: int
    constraints: str = ""
    preferences: str = ""
    dietEffort: str = ""
    startDate: date
    endDate: date
    notes: Optional[str] = None


def fitness_prompt(p: FitnessPrompt) -> str:
    # Plain-text prompt plus schema (the schema is enforced via response_format too)
    return f"""
Physique: {p.physique}
    Height: {p.physique.height} cm
    Weight: {p.physique.weight} kg
    Gender: {p.physique.gender}
    Age: {p.physique.age}
    Notes: {p.physique.notes}
Goal type: {p.goalType}
Experience: {p.experience}
Time budget: {p.hoursPerWeek} hours/week
Constraints: {p.constraints}
Preferences: {p.preferences}
Diet willingness: {p.dietEffort}
Start date: {p.startDate}
End date: {p.endDate}
Notes: {p.notes}
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
