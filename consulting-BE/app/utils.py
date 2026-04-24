# app/utils.py

import os
from datetime import datetime, timedelta
from jose import jwt  # pip install python-jose

# --------------------------
# JWT Settings
# --------------------------
SECRET_KEY = os.getenv("SECRET_KEY", "supersecretkey")  # use strong key in production
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60  # 1 hour

# --------------------------
# Helper Functions
# --------------------------
def create_access_token(data: dict, expires_delta: timedelta | None = None):
    """Generate a JWT token."""
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def example_helper():
    return "This is a helper function"
