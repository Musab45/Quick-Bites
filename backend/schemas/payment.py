from datetime import datetime

from pydantic import BaseModel, Field, field_validator


class PaymentCardCreateRequest(BaseModel):
    card_number: str = Field(min_length=12, max_length=25)
    expiry_month: int = Field(ge=1, le=12)
    expiry_year: int = Field(ge=2000, le=2100)
    cvv: str = Field(min_length=3, max_length=4)
    cardholder_name: str | None = Field(default=None, max_length=120)
    set_as_default: bool = False

    @field_validator("card_number")
    @classmethod
    def validate_card_number(cls, value: str) -> str:
        digits = "".join(char for char in value if char.isdigit())
        if len(digits) < 12 or len(digits) > 19:
            raise ValueError("Card number must be 12-19 digits")
        return value

    @field_validator("cvv")
    @classmethod
    def validate_cvv(cls, value: str) -> str:
        if not value.isdigit():
            raise ValueError("CVV must contain digits only")
        return value


class PaymentCardResponse(BaseModel):
    id: int
    token: str
    brand: str
    last4: str
    expiry_month: int
    expiry_year: int
    cardholder_name: str | None
    is_default: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class WalletResponse(BaseModel):
    user_id: int
    balance: float
    updated_at: datetime

    model_config = {"from_attributes": True}


class WalletTopUpRequest(BaseModel):
    amount: float = Field(gt=0, le=5000)