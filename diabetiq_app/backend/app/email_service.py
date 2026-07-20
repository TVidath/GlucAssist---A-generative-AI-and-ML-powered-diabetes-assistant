import os
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType
from dotenv import load_dotenv

load_dotenv()

conf = ConnectionConfig(
    MAIL_USERNAME = os.getenv("SMTP_USERNAME", "dummy@example.com"),
    MAIL_PASSWORD = os.getenv("SMTP_PASSWORD", ""),
    MAIL_FROM = os.getenv("MAIL_FROM", "dummy@example.com"),
    MAIL_PORT = int(os.getenv("SMTP_PORT", 587)),
    MAIL_SERVER = os.getenv("SMTP_HOST", "smtp.gmail.com"),
    MAIL_STARTTLS = True,
    MAIL_SSL_TLS = False,
    USE_CREDENTIALS = True,
    VALIDATE_CERTS = True
)

async def send_otp_email(email: str, otp: str):
    html = f"""
    <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
        <h2>DiabetIQ Password Reset</h2>
        <p>You requested a password reset. Your OTP code is:</p>
        <h1 style="color: #1565C0; letter-spacing: 5px;">{otp}</h1>
        <p>This code will expire in 10 minutes.</p>
        <p>If you did not request this, please ignore this email.</p>
    </div>
    """
    
    message = MessageSchema(
        subject="DiabetIQ - Password Reset OTP",
        recipients=[email],
        body=html,
        subtype=MessageType.html
    )
    
    fm = FastMail(conf)
    await fm.send_message(message)
