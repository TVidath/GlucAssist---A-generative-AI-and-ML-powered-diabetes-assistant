# DiabetesApp

A diabetes management application with an integrated AI chatbot and ML-based early risk prediction.

## Features

- **AI Chatbot** — AI-powered chatbot using Google Gemini for diabetes management assistance
- **Risk Prediction** — ML-based early diabetes risk prediction from health data
- **Flutter App** — Cross-platform mobile application

## Project Structure

```
├── diabetiq_app/       # Flutter mobile application (DiabetesApp)
│   ├── lib/            # Dart source code
│   └── backend/        # FastAPI backend with Gemini chat chain
├── Streamlit/          # Standalone Streamlit chatbot
├── ML/                 # Machine learning pipeline
│   ├── Dataset/        # Training data
│   └── Preprocessing/  # Data preprocessing
├── .env                # API Keys (GOOGLE_API_KEY)
└── requirements.txt    # Python dependencies
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Python 3.8+
- Google Gemini API Key

### Setup
1. Create a `.env` file and add your API key: `GOOGLE_API_KEY="your-key-here"`
2. Install Python dependencies: `pip install -r requirements.txt`
3. Run the Streamlit chatbot: `streamlit run Streamlit/rag_chatbot.py`
4. Run the Flutter app: `cd diabetiq_app && flutter run`
"# GlucAssist---A-generative-AI-and-ML-powered-diabetes-assistant" 
