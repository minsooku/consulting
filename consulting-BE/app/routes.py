from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import models, schemas, auth, database
from app.auth import get_current_user_uuid

router = APIRouter(tags=["auth"])

# Dependency to get DB session
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/register", response_model=schemas.UserOut)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    # Check if user already exists
    existing_user = db.query(models.User).filter(models.User.email == user.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Hash password using auth helper
    hashed_pw = auth.pwd_context.hash(user.password)
    db_user = models.User(
        email=user.email,
        hashed_password=hashed_pw,
        full_name=user.full_name
    )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return db_user

@router.get("/protected")
def read_protected_route(user_uuid: str = Depends(get_current_user_uuid)):
    return {"message": "You are authenticated with UUID.", "uuid": user_uuid}
