from pydantic import BaseModel, Field
from typing import Literal, Optional, List
from datetime import date


# Fitness Categories -----------------------------------------------------------------

class ChecklistItem(BaseModel):
    label: str
    targetValue: Optional[float | str] = None
    unit: Optional[str] = None
    done: bool = False

class PlanBlock(BaseModel):
    title: str
    category: Literal["workout", "nutrition", "habit", "recovery"]
    duration_min: int = Field(ge=1)
    details: Optional[str] = None
    checklist: List[ChecklistItem] = []

class DayPlan(BaseModel):
    date: date
    blocks: List[PlanBlock]

class WeekOverview(BaseModel):
    week_number: int
    theme: str
    notes: str

class PlanResponse(BaseModel):
    weekly_overview: List[WeekOverview]
    days: List[DayPlan]
    personalization_rationale: str

# User input to the endpoint
class PlanRequest(BaseModel):
    goalType: str
    experience: str
    hoursPerWeek: int
    constraints: str = ""
    preferences: str = ""
    dietEffort: str = ""
    startDate: date

# ------------------------------------------------------------------------------------