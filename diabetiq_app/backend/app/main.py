from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import BaseModel
from rag_chain import DiabetesAppRAG
from models import (
    PredictRequest, PredictResponse, UserCreate, UserResponse, Token,
    ForgotPasswordRequest, VerifyOTPRequest, ResetPasswordRequest,
    ProfileUpdateRequest, HealthRecordResponse
)
import uvicorn
import joblib
import os
import numpy as np
import random
from datetime import datetime, timedelta
from typing import Optional, List

# Import DB and Auth modules
from database import engine, Base, get_db, User, HealthRecord, OTPRecord
from email_service import send_otp_email
from auth import (
    get_password_hash,
    verify_password,
    create_access_token,
    get_current_user,
    get_current_user_optional,
)

# Initialize Database
Base.metadata.create_all(bind=engine)

app = FastAPI(title="DiabetesApp API", version="1.0.0")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize RAG model
rag_model = DiabetesAppRAG()

# Load ML model and scaler
model_path = os.path.join(os.path.dirname(__file__), 'xgboost_model.pkl')
scaler_path = os.path.join(os.path.dirname(__file__), 'scaler.pkl')
xgb_clf = joblib.load(model_path)
scaler = joblib.load(scaler_path)

class QuestionRequest(BaseModel):
    question: str

class AnswerResponse(BaseModel):
    answer: str

@app.get("/")
def read_root():
    return {"message": "DiabetesApp API is running"}

# --- AUTHENTICATION ENDPOINTS ---

@app.post("/signup", response_model=UserResponse)
def signup(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_password = get_password_hash(user.password)
    new_user = User(name=user.name, email=user.email, hashed_password=hashed_password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@app.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/me", response_model=UserResponse)
def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user

@app.get("/profile", response_model=UserResponse)
def read_profile(current_user: User = Depends(get_current_user)):
    return current_user

@app.put("/profile", response_model=UserResponse)
def update_profile(profile: ProfileUpdateRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if profile.name is not None: current_user.name = profile.name
    if profile.dob is not None: current_user.dob = profile.dob
    if profile.phone is not None: current_user.phone = profile.phone
    if profile.address is not None: current_user.address = profile.address
    db.commit()
    db.refresh(current_user)
    return current_user

@app.post("/forgot-password")
async def forgot_password(request: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user: raise HTTPException(status_code=404, detail="User not found")
    otp_code = str(random.randint(100000, 999999))
    expires_at = datetime.utcnow() + timedelta(minutes=10)
    db.query(OTPRecord).filter(OTPRecord.user_id == user.id).delete()
    db.add(OTPRecord(user_id=user.id, otp_code=otp_code, expires_at=expires_at))
    db.commit()
    try: await send_otp_email(user.email, otp_code)
    except Exception as e: raise HTTPException(status_code=500, detail=str(e))
    return {"message": "OTP sent"}

@app.post("/verify-otp")
def verify_otp(request: VerifyOTPRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user: raise HTTPException(status_code=404, detail="User not found")
    otp = db.query(OTPRecord).filter(OTPRecord.user_id == user.id, OTPRecord.otp_code == request.otp).first()
    if not otp or otp.expires_at < datetime.utcnow(): raise HTTPException(status_code=400, detail="Invalid/expired OTP")
    return {"message": "OTP verified"}

@app.post("/reset-password")
def reset_password(request: ResetPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user: raise HTTPException(status_code=404, detail="User not found")
    otp = db.query(OTPRecord).filter(OTPRecord.user_id == user.id, OTPRecord.otp_code == request.otp).first()
    if not otp or otp.expires_at < datetime.utcnow(): raise HTTPException(status_code=400, detail="Invalid/expired OTP")
    user.hashed_password = get_password_hash(request.new_password)
    db.query(OTPRecord).filter(OTPRecord.user_id == user.id).delete()
    db.commit()
    return {"message": "Password updated"}

# --- MAIN ENDPOINTS ---

@app.post("/ask", response_model=AnswerResponse)
async def ask_question(request: QuestionRequest):
    try:
        answer = rag_model.ask(request.question)
        return {"answer": answer}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/predict", response_model=PredictResponse)
async def predict_diabetes(
    request: PredictRequest, 
    db: Session = Depends(get_db), 
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    try:
        # Format the request into a numpy array (1, 14) following dataset columns order
        features = np.array([[
            request.age,
            request.gender,
            request.pulse_rate,
            request.systolic_bp,
            request.diastolic_bp,
            request.glucose,
            request.height,
            request.weight,
            request.bmi,
            request.family_diabetes,
            request.hypertensive,
            request.family_hypertension,
            request.cardiovascular_disease,
            request.stroke
        ]])
        
        # Scale the features
        features_scaled = scaler.transform(features)
        
        # Predict probability of being diabetic (class 1)
        prob = xgb_clf.predict_proba(features_scaled)[0][1]
        risk_level = float(prob)
        
        # If user is logged in, save the prediction history
        if current_user:
            record = HealthRecord(
                user_id=current_user.id,
                bmi=request.bmi,
                glucose=request.glucose,
                systolic_bp=request.systolic_bp,
                diastolic_bp=request.diastolic_bp,
                risk_level=risk_level
            )
            db.add(record)
            db.commit()
        
        return {"risk_level": risk_level}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health-records", response_model=List[HealthRecordResponse])
def get_health_records(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return db.query(HealthRecord).filter(HealthRecord.user_id == current_user.id).order_by(HealthRecord.created_at.desc()).all()

@app.put("/health-records/{record_id}", response_model=HealthRecordResponse)
def update_health_record(record_id: int, request: dict, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    record = db.query(HealthRecord).filter(HealthRecord.id == record_id, HealthRecord.user_id == current_user.id).first()
    if not record: raise HTTPException(status_code=404, detail="Record not found")
    for key, value in request.items():
        if hasattr(record, key):
            setattr(record, key, value)
    db.commit()
    db.refresh(record)
    return record

@app.delete("/health-records/{record_id}")
def delete_health_record(record_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    record = db.query(HealthRecord).filter(HealthRecord.id == record_id, HealthRecord.user_id == current_user.id).first()
    if not record: raise HTTPException(status_code=404, detail="Record not found")
    db.delete(record)
    db.commit()
    return {"message": "Record deleted"}

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
