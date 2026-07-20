from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class PredictRequest(BaseModel):
    age: float
    gender: int
    pulse_rate: float
    systolic_bp: float
    diastolic_bp: float
    glucose: float
    height: float
    weight: float
    bmi: float
    family_diabetes: int
    hypertensive: int
    family_hypertension: int
    cardiovascular_disease: int
    stroke: int

class PredictResponse(BaseModel):
    risk_level: float

class UserCreate(BaseModel):
    name: str
    email: str
    password: str

class UserResponse(BaseModel):
    name: str
    email: str
    dob: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None

class Token(BaseModel):
    access_token: str
    token_type: str

class ForgotPasswordRequest(BaseModel):
    email: str

class VerifyOTPRequest(BaseModel):
    email: str
    otp: str

class ResetPasswordRequest(BaseModel):
    email: str
    otp: str
    new_password: str

class ProfileUpdateRequest(BaseModel):
    name: Optional[str] = None
    dob: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None

class HealthRecordResponse(BaseModel):
    id: int
    bmi: float
    glucose: float
    systolic_bp: float
    diastolic_bp: float
    risk_level: float
    created_at: datetime

    class Config:
        from_attributes = True
