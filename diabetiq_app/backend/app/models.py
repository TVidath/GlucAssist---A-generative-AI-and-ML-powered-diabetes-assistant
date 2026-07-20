from pydantic import BaseModel

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

class Token(BaseModel):
    access_token: str
    token_type: str
