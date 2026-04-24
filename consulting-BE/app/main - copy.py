from fastapi import FastAPI
from app.routes import router as api_router
from app.auth import router as auth_router  # import auth router separately
from app.database import Base, engine
import os
from dotenv import load_dotenv

# Create tables (only if not already created)
Base.metadata.create_all(bind=engine)

app = FastAPI(title="AI Consulting Backend")

# Include main routes
app.include_router(api_router)

# Include auth routes
app.include_router(auth_router)

@app.get("/")
def root():
    return {"message": "Backend is working!"}

