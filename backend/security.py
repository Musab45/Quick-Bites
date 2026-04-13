import os
from datetime import datetime, timedelta, timezone

from jose import JWTError, jwt
from passlib.context import CryptContext

JWT_SECRET = os.getenv("JWT_SECRET", "change-me")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", "14"))

pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")


class InvalidTokenError(Exception):
    pass


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def _create_token(*, subject: str, expires_delta: timedelta, token_type: str) -> str:
    expire = datetime.now(timezone.utc) + expires_delta
    payload = {"sub": subject, "exp": expire, "type": token_type}
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def create_access_token(subject: str) -> str:
    expires_delta = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    return _create_token(subject=subject, expires_delta=expires_delta, token_type="access")


def create_refresh_token(subject: str) -> str:
    expires_delta = timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    return _create_token(subject=subject, expires_delta=expires_delta, token_type="refresh")


def _decode_token(token: str, expected_type: str) -> dict:
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
    except JWTError as exc:
        raise InvalidTokenError("Invalid token") from exc

    token_type = payload.get("type")
    # Older access tokens might not include a token type claim.
    if expected_type == "access" and token_type is None:
        token_type = "access"
    if token_type != expected_type:
        raise InvalidTokenError("Invalid token type")

    subject = payload.get("sub")
    if not isinstance(subject, str) or not subject.strip():
        raise InvalidTokenError("Invalid token subject")

    return payload


def decode_access_token(token: str) -> dict:
    return _decode_token(token, expected_type="access")


def decode_refresh_token(token: str) -> dict:
    return _decode_token(token, expected_type="refresh")
