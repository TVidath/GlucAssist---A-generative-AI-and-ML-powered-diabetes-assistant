# DiabetIQ - System Architecture & Project Flow

DiabetIQ is a full-stack health platform that integrates **Machine Learning** for early diabetes risk prediction and **Generative AI** for conversational medical assistance.

This document outlines the system architecture, the step-by-step data flow, and complete instructions on how to run and deploy the project from start to finish.

---

## 🏗 System Architecture Overview

The system is composed of four primary layers:
1. **Frontend (Mobile)**: A cross-platform **Flutter** application utilizing `Provider` for global state management and a modern, cohesive UI.
2. **Frontend (Web)**: A standalone **Streamlit** web application for accessible, session-managed chatbot interactions.
3. **Backend API**: A **FastAPI** server that acts as the central hub, providing RESTful endpoints for the mobile client.
4. **Intelligence Layer**:
   - **Machine Learning**: An **XGBoost Classifier** (trained with **SMOTE** and normalized via **StandardScaler**) for predictive analytics.
   - **Generative AI**: A **LangChain LCEL** pipeline connected to the **Google Gemini API** for natural language understanding and generation.

---

## 🌊 Flow 1: Early Risk Prediction (Machine Learning)
*Goal: Assess a user's risk of diabetes based on biometric inputs.*

1. **User Input:** The user navigates to the `DiaTrack` screen in the Flutter Mobile App and submits a health questionnaire (age, BMI, blood pressure, glucose levels, etc.).
2. **Payload Transmission:** The Flutter app serializes the data into JSON and sends an asynchronous `POST /predict` request to the FastAPI backend.
3. **Data Preprocessing:** 
   - The backend receives the payload and applies the exact preprocessing transformations used during training.
   - Numerical features are scaled using the saved **StandardScaler** (`scaler.pkl`).
4. **Model Inference:** The normalized data is fed into the pre-trained **XGBoost Classifier** (`xgboost_model.pkl`).
5. **Prediction & Response:** The model outputs a probability risk prediction. The FastAPI server packages this result (`{"risk_level": 0.85}`) and transmits it back to the client.
6. **Data Visualization:** The Flutter app dynamically updates the `Result` screen, displaying a percentage, a color-coded risk badge (Low/Moderate/High), and a segmented risk meter bar.

---

## 🌊 Flow 2: AI Medical Chatbot (Generative AI)
*Goal: Provide localized, context-aware medical guidance based on strict medical guardrails.*

1. **User Inquiry:** The user types a diabetes-related question into the **Flutter Mobile App** (`DiaChat` screen).
2. **Prompt Construction:** The user's input is passed into a strict **LangChain PromptTemplate**. The prompt explicitly restricts the AI's persona to a diabetes management assistant.
3. **AI Generation:** The constructed prompt is transmitted securely to **Google Gemini (gemini-1.5-flash)** via the LangChain LCEL pipeline in the backend.
4. **Data Transformation:** The backend receives the raw string from Gemini, serializes it into a JSON response (`{"answer": "..."}`), and sends it via the `POST /ask` endpoint to the Flutter client.
5. **UI Rendering:** The client receives the data and dynamically deserializes it into a conversational message bubble interface.

---

## 🚀 How to Run Locally (Start to Finish)

### 1. Set Up Environment Variables
Create a `.env` file in the root directory (or inside `diabetiq_app/backend/app`) and add your Gemini API key:
```env
GEMINI_API_KEY=your_actual_api_key_here
```

### 2. Generate the ML Model Files (One-time step)
Navigate to the backend folder and run the model training script to generate `xgboost_model.pkl` and `scaler.pkl`:
```bash
cd diabetiq_app/backend/app
python ml_.model.py
```

### 3. Run the FastAPI Backend
Start the backend server on your local machine. Make sure you are in the correct folder:
```bash
cd diabetiq_app/backend/app
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
The API is now running at `http://localhost:8000`.

### 4. Run the Flutter Mobile App
In a new terminal window, run the Flutter application on an emulator or physical device:
```bash
cd diabetiq_app
flutter pub get
flutter run
```
*(Note: If testing on an Android emulator, `api_service.dart` uses `http://10.0.2.2:8000` to correctly route localhost traffic to your computer).*

---

## 🌍 How to Deploy to Production (Render)

When you are ready to make the app accessible to real-time users anywhere in the world, you must deploy the FastAPI backend to the cloud. We recommend **Render.com** for hosting the backend and **Aiven.io** or **Railway.app** for hosting the MySQL database.

### Step 1: Set Up a Cloud Database
Since you are using MySQL, you cannot use a local database (like localhost) for production.
1. Create a free MySQL database on a provider like [Aiven](https://aiven.io/) or [Railway](https://railway.app/).
2. Keep the Host, Port, User, and Password handy for the next steps.

### Step 2: Push to GitHub
1. Ensure your entire project is committed and pushed to a GitHub repository.
2. **IMPORTANT**: Do NOT push your `.env` file to GitHub! Keep your passwords and API keys secret.

### Step 3: Create a Web Service on Render
1. Go to [Render.com](https://render.com/) and create a free account.
2. Click **New +** and select **Web Service**.
3. Connect your GitHub account and select your DiabetIQ repository.

### Step 4: Configure Render Settings
Fill out the service details:
- **Name**: `diabetiq-backend` (or whatever you prefer)
- **Language**: `Python 3`
- **Root Directory**: `diabetiq_app/backend/app` (This tells Render where your backend code lives).
- **Build Command**: `pip install -r ../../../requirements.txt`
- **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### Step 5: Add Environment Variables
Scroll down to **Environment Variables** and add everything from your local `.env` file into Render:
- `GOOGLE_API_KEY` = (Your Gemini API Key)
- `DB_HOST` = (Cloud Database Host from Step 1)
- `DB_PORT` = (Cloud Database Port)
- `DB_USER` = (Cloud Database User)
- `DB_PASSWORD` = (Cloud Database Password)
- `DB_NAME` = (Cloud Database Name)
- `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_HOST`, `SMTP_PORT`, `MAIL_FROM` = (Your Email Settings)

### Step 6: Deploy and Connect Flutter App
1. Click **Create Web Service**. Render will deploy your server and provide a live URL (e.g., `https://diabetiq-backend.onrender.com`).
2. Open your Flutter project (`diabetiq_app/lib/services/api_service.dart`) and change the `baseUrl`:
   ```dart
   static const String baseUrl = "https://diabetiq-backend.onrender.com";
   ```
3. Build the final app: `flutter build apk`
4. Distribute this APK to your users!

### 🔄 Pushing Future Changes (Real-Time Updates)
**Will future changes reflect for real-time users?**
- **Backend Changes (Python/FastAPI)**: **YES.** Because Render is connected to your GitHub, any time you push new Python backend code to GitHub, Render will automatically detect it, rebuild the server, and all real-time users will instantly interact with the updated logic.
- **Frontend Changes (Flutter UI)**: **NO.** Because the Flutter app is physically installed on the user's phone, you must compile a new APK (`flutter build apk`) and distribute it as an update (like on the Google Play Store). Users must download the new version to see UI changes.

---

## 📦 Comprehensive Project Details

### Core Features
- **AI Chatbot**: An intelligent conversational agent powered by Google Gemini, designed specifically for diabetes management, diet planning, and general health queries.
- **Risk Prediction**: A Machine Learning pipeline leveraging an XGBoost classifier (trained with SMOTE to handle data imbalance) to predict early diabetes risk based on user biometrics.
- **User Authentication & Profiles**: Secure JWT-based authentication with editable user profiles and an integrated email-based OTP password recovery flow.
- **Health Records Management**: Fully persistent and editable tracking of ML-generated diabetes risk predictions and health metrics.
- **Cross-Platform Mobile App**: Built with Flutter, offering a seamless user experience across iOS and Android with modern state management (`Provider`) and local storage (`shared_preferences`).
- **Web Interface**: A standalone Streamlit web application providing an alternative, accessible chatbot interface.
- **Robust API Backend**: A scalable FastAPI server handling ML model inference, AI conversation routing, database management, and email dispatching for OTPs.

### Tech Stack
- **Frontend (Mobile)**: Flutter, Dart, Provider, Shared Preferences
- **Frontend (Web)**: Streamlit, Python
- **Backend API**: FastAPI, Python, Uvicorn, FastAPI-Mail
- **Database & ORM**: MySQL, PyMySQL, SQLAlchemy
- **Authentication & Security**: PyJWT, Passlib (Bcrypt)
- **Machine Learning**: XGBoost, Scikit-learn, Pandas, Imbalanced-learn (SMOTE), Joblib
- **Generative AI**: Google Gemini API, LangChain

### Detailed Project Structure
```text
DiabetIQ-main/
├── diabetiq_app/       # Main Flutter mobile application
│   ├── lib/            # Dart source code (UI screens, State management, API Services)
│   ├── windows/        # Windows desktop build files
│   ├── web/            # Web platform build files
│   └── backend/        # FastAPI backend handling ML inference & Gemini AI
├── Streamlit/          # Standalone Streamlit chatbot implementation
├── ML/                 # Machine learning pipeline and modeling
│   ├── Dataset/        # Raw and processed training data for risk prediction
│   └── Preprocessing/  # Scripts for data cleaning, scaling, and model training
├── .env                # Environment variables configuration (e.g., GEMINI_API_KEY)
└── requirements.txt    # Global Python dependencies for Backend, Streamlit & ML
```

### Prerequisites for Development
- **Flutter SDK** (>= 3.0.0) for compiling the mobile application.
- **Python** (3.8+) for running the FastAPI backend, Streamlit web app, and ML scripts.
- **Google Gemini API Key** for enabling the generative AI medical assistant.
- **MySQL Server** for database storage.
- **SMTP Credentials** (e.g., Gmail App Password) for sending OTP emails.


# 1. MySQL Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=diabetiq

# 2. Email / SMTP Configuration (for sending OTPs)
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
MAIL_FROM=your_email@gmail.com


