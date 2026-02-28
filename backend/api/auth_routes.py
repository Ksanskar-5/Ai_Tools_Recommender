from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, field_validator
from backend.utils.db import register_user, verify_user
from backend.utils.auth import create_token

router = APIRouter()

class Register(BaseModel):
    name: str
    email: str
    password: str

    @field_validator("password")
    @classmethod
    def password_strength(cls, v):
        if len(v) < 6:
            raise ValueError("Password must be at least 6 characters")
        return v

class Login(BaseModel):
    email: str
    password: str

# /api/auth/signup   (after prefix)
@router.post("/signup")
def register_user_route(user: Register):
    user_id = register_user(user.name, user.email, user.password)
    if not user_id:
        raise HTTPException(status_code=400, detail="User already exists or registration failed")
    token = create_token(user_id, user.email)
    return {
        "user_id": user_id,
        "email": user.email,
        "token": token,
        "message": "Registration successful"
    }

# /api/auth/login   (after prefix)
@router.post("/login")
def login_user_route(user: Login):
    user_data = verify_user(user.email, user.password)
    if not user_data:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_token(user_data["user_id"], user.email)
    return {
        "user_id": user_data["user_id"],
        "email": user.email,
        "token": token,
        "message": "Login successful"
    }
