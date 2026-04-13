import pytest

from security import (
    InvalidTokenError,
    create_access_token,
    create_refresh_token,
    decode_access_token,
    decode_refresh_token,
    hash_password,
    verify_password,
)


def test_password_hash_and_verify() -> None:
    hashed = hash_password("SecretPass123")
    assert hashed != "SecretPass123"
    assert verify_password("SecretPass123", hashed)


def test_token_encode_decode() -> None:
    token = create_access_token("42")
    payload = decode_access_token(token)
    assert payload["sub"] == "42"


def test_refresh_token_encode_decode() -> None:
    token = create_refresh_token("42")
    payload = decode_refresh_token(token)
    assert payload["sub"] == "42"


def test_refresh_token_rejected_by_access_decoder() -> None:
    refresh_token = create_refresh_token("42")
    with pytest.raises(InvalidTokenError):
        decode_access_token(refresh_token)
