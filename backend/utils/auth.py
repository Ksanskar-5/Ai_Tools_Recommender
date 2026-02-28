"""
JWT Authentication utilities for AI Recommender.
- create_token: generates a signed JWT for a user
- verify_token: validates and decodes a JWT
- get_current_user: FastAPI dependency for protected routes
- get_optional_user: FastAPI dependency for optional auth
"""

import os
import jwt
from datetime import datetime, timedelta, timezone
from fastapi import Request, HTTPException
from typing import Optional, Dict, Any
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.environ.get("JWT_SECRET", "change-me-in-production")
ALGORITHM = "HS256"
TOKEN_EXPIRE_HOURS = 24


def create_token(user_id: int, email: str) -> str:
    """Create a signed JWT token."""
    now = datetime.now(timezone.utc)
    payload = {
        "user_id": user_id,
        "email": email,
        "exp": now + timedelta(hours=TOKEN_EXPIRE_HOURS),
        "iat": now,
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def verify_token(token: str) -> Dict[str, Any]:
    """Verify and decode a JWT token. Raises HTTPException on failure."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


def _extract_token(request: Request) -> Optional[str]:
    """Extract Bearer token from Authorization header."""
    auth_header = request.headers.get("Authorization", "")
    if auth_header.startswith("Bearer "):
        return auth_header[7:]
    return None


def get_current_user(request: Request) -> Dict[str, Any]:
    """
    FastAPI dependency: requires valid JWT.
    Usage: user = Depends(get_current_user)
    """
    token = _extract_token(request)
    if not token:
        raise HTTPException(status_code=401, detail="Authentication required")
    return verify_token(token)


def get_optional_user(request: Request) -> Optional[Dict[str, Any]]:
    """
    FastAPI dependency: returns user if JWT present, None otherwise.
    Usage: user = Depends(get_optional_user)
    """
    token = _extract_token(request)
    if not token:
        return None
    try:
        return verify_token(token)
    except HTTPException:
        return None
