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

When you are ready to make the app accessible to real-time users anywhere in the world, deploy the FastAPI backend to Render.com.

### Step 1: Push to GitHub
1. Ensure your entire project is committed and pushed to a GitHub repository.
2. Make sure `requirements.txt` is in your repository and contains `fastapi[standard]`, `uvicorn`, `joblib`, `xgboost`, `scikit-learn`, `langchain`, `langchain-google-genai`, etc.

### Step 2: Create a Web Service on Render
1. Go to [Render.com](https://render.com/) and create a free account.
2. Click **New +** and select **Web Service**.
3. Connect your GitHub account and select your DiabetIQ repository.

### Step 3: Configure Render Settings
Fill out the service details:
- **Name**: `diabetiq-backend` (or whatever you prefer)
- **Language**: `Python 3`
- **Root Directory**: `diabetiq_app/backend/app` (This is crucial! Tell Render where the code lives).
- **Build Command**: `pip install -r ../../../requirements.txt` (Adjust path if you moved requirements to the root directory).
- **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### Step 4: Add Environment Variables
1. Scroll down to **Environment Variables** and click **Add Environment Variable**.
2. Key: `GEMINI_API_KEY`
3. Value: `your_actual_api_key_here`

### Step 5: Deploy and Update App
1. Click **Create Web Service**. Render will now build and deploy your Python server. It usually takes 2-5 minutes.
2. Once successful, Render will give you a live URL (e.g., `https://diabetiq-backend.onrender.com`).
3. **Crucial Final Step:** Open your Flutter project (`diabetiq_app/lib/services/api_service.dart`) and change the `baseUrl`:
   ```dart
   static const String baseUrl = "https://diabetiq-backend.onrender.com";
   ```
4. Build the final APK: `flutter build apk`
5. Share the APK with your users! The app will now communicate with the live Render server.
