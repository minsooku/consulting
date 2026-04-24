import os
from dotenv import load_dotenv
from openai import OpenAI
from fitness_scheme import FitnessResponse, FitnessPrompt, fitness_prompt, SYSTEM_MSG

# OpenAI API key check
load_dotenv()
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-5-nano")

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


# **** OpenAI Testing Step 2: Edit this SYSTEM_MSG (this engineers the model system) ****


# **** OpenAI Testing Step 3: Build FitnessPrompt (this engineers the model system) ****
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


# Pydantic Structured Input only
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
    # **** OpenAI Testing Step 3: Edit this Structured Output format ****
    text_format=FitnessResponse,
)

print(response.output_parsed)

