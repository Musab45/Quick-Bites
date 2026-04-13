from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from database import get_db
from dependencies import get_current_user
from models import User, UserProfile
from schemas.auth import (
    LoginRequest,
    PasswordUpdateRequest,
    ProfileUpdateRequest,
    RefreshTokenRequest,
    RefreshTokenResponse,
    RegisterRequest,
    TokenResponse,
    UserProfileResponse,
    UserResponse,
)
from security import (
    InvalidTokenError,
    create_access_token,
    create_refresh_token,
    decode_refresh_token,
    hash_password,
    verify_password,
)

router = APIRouter(prefix="/auth", tags=["auth"])


def _issue_tokens(user_id: int) -> tuple[str, str]:
    subject = str(user_id)
    return create_access_token(subject), create_refresh_token(subject)


def _to_profile_response(user: User) -> UserProfileResponse:
    avatar_url = user.profile.avatar_url if user.profile is not None else None
    return UserProfileResponse(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        avatar_url=avatar_url,
        created_at=user.created_at,
    )


def _get_or_create_profile(db: Session, user: User) -> UserProfile:
    if user.profile is not None:
        return user.profile

    profile = UserProfile(user_id=user.id)
    db.add(profile)
    db.flush()
    return profile


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register(payload: RegisterRequest, db: Session = Depends(get_db)) -> User:
    existing_user = db.query(User).filter(User.email == payload.email).first()
    if existing_user is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")

    user = User(
        email=payload.email,
        full_name=payload.full_name,
        password_hash=hash_password(payload.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)) -> TokenResponse:
    user = db.query(User).filter(User.email == payload.email).first()
    if user is None or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    access_token, refresh_token = _issue_tokens(user.id)
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user=UserResponse.model_validate(user),
    )


@router.post("/refresh", response_model=RefreshTokenResponse)
def refresh_access_token(payload: RefreshTokenRequest, db: Session = Depends(get_db)) -> RefreshTokenResponse:
    try:
        token_payload = decode_refresh_token(payload.refresh_token)
        user_id = int(token_payload.get("sub", 0))
    except (InvalidTokenError, ValueError):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")

    access_token, refresh_token = _issue_tokens(user.id)
    return RefreshTokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
    )


@router.get("/me", response_model=UserProfileResponse)
def me(current_user: User = Depends(get_current_user)) -> UserProfileResponse:
    return _to_profile_response(current_user)


@router.patch("/profile", response_model=UserProfileResponse)
def update_profile(
    payload: ProfileUpdateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> UserProfileResponse:
    if payload.full_name is None and payload.email is None and payload.avatar_url is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No profile updates provided")

    if payload.full_name is not None:
        normalized_name = payload.full_name.strip()
        if not normalized_name:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Full name cannot be empty")
        current_user.full_name = normalized_name

    if payload.email is not None:
        normalized_email = payload.email.strip().lower()
        existing_user = db.query(User).filter(User.email == normalized_email).first()
        if existing_user is not None and existing_user.id != current_user.id:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")
        current_user.email = normalized_email

    if payload.avatar_url is not None:
        normalized_avatar_url = payload.avatar_url.strip()
        profile = _get_or_create_profile(db, current_user)
        profile.avatar_url = normalized_avatar_url or None

    db.commit()
    db.refresh(current_user)
    return _to_profile_response(current_user)


@router.patch("/password", status_code=status.HTTP_204_NO_CONTENT)
def update_password(
    payload: PasswordUpdateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Response:
    if not verify_password(payload.current_password, current_user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Current password is incorrect")

    if payload.current_password == payload.new_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="New password must be different from current password",
        )

    current_user.password_hash = hash_password(payload.new_password)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
