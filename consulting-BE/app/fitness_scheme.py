from pydantic import BaseModel, Field
from typing import Literal, Optional, List
from datetime import date

# SYSTEM ------------------------------------------\

SYSTEM_MSG = (
    "You are CoachGPT, a careful and pragmatic planning assistant. "
    "Return STRICT JSON only, no extra text. "
    "Safety rules: no medical advice or supplements. "
    "Respect time budgets and include recovery and nutrition checklists. "
    "When a checklist item is a machine-based workout, set its machine field "
    "to an exact filename from the allowed machine list. Use null only for "
    "non-machine items or bodyweight/free-weight exercises."
)

MACHINE_IMAGE_FILENAMES = [
    "Iso-Lateral High Row.png",
    "Iso-Lateral Horizontal Bench Press.png",
    "Iso-Lateral Incline Press.png",
    "Iso-Lateral Kneeling Leg Curl.png",
    "Iso-Lateral Low Row.png",
    "Iso-Lateral Row.png",
    "Iso-Lateral Shoulder Press.png",
    "Iso-Lateral Wide Chest.png",
    "Axiom Series Hip Abductor Adductor.png",
    "Axiom Series Lat Pulldown.png",
    "Axiom Series Leg Curl.png",
    "Axiom Series Leg Extension_Leg Curl.png",
    "Axiom Series Leg Extension.png",
    "Axiom Series Shoulder Press.png",
    "Insignia Series Biceps Curl.png",
    "Insignia Series Lateral Raise.png",
    "Insignia Series Pulldown.png",
    "Biceps Curl.png",
    "Converging Chest Press.png",
    "Converging Shoulder Press.png",
    "Inner Thigh.png",
    "Leg Extension.png",
    "Outer Thigh.png",
    "Prone Leg Curl.png",
    "Rear Delt Pec Fly.png",
    "Seated Leg Curl.png",
    "Triceps Extension.png",
]


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
- For workout checklist items, prefer machine exercises from the allowed machine list below.
- Set details[].machine to the exact matching filename, including capitalization, spaces, hyphens, and ".png".
- Do not invent machine filenames. Use null only if no allowed machine fits the exercise.
- For nutrition, habit, and recovery items, machine must be null.

Allowed machine filenames:
{chr(10).join(f"- {filename}" for filename in MACHINE_IMAGE_FILENAMES)}
"""


# Response ----------------------------------------\

class ChecklistItem(BaseModel):
    label: str
    target_value: Optional[float | str] = None
    unit: Optional[str] = None
    done: bool = False
    machine: Optional[str] = None

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
