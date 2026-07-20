import os
from dotenv import load_dotenv
import streamlit as st
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate

# --- Environment Setup ---
load_dotenv()

@st.cache_resource
def setup_chat_chain():
    """Sets up the chat chain directly with Gemini."""
    llm = ChatGoogleGenerativeAI(model="gemini-3.5-flash")  # Ensure GOOGLE_API_KEY is in .env

    prompt_template = """
    You are DiabetesApp, an AI assistant specializing in diabetes management.
    Answer the following question about diabetes management concisely but specifically.
    Always conclude your response by strongly advising the user to consult a healthcare professional or registered dietitian for personalized medical advice tailored to their specific situation.

    Question: {question}

    Answer:
    """

    prompt = PromptTemplate.from_template(prompt_template)

    chat_chain = (
        {"question": RunnablePassthrough()}
        | prompt
        | llm
        | StrOutputParser()
    )
    return chat_chain

# --- Streamlit Application ---
st.set_page_config(page_title="DiabetesApp", page_icon=":hospital:")

st.title("DiabetesApp: Your Diabetes Management Assistant")
st.markdown("Hello! I am DiabetesApp, an AI assistant here to help you understand diabetes management.")
st.markdown("Please note: **I am an AI and cannot provide medical advice. Always consult a healthcare professional for personalized guidance.**")

# --- Setup Chat Chain ---
chat_chain = setup_chat_chain()

# --- Chat Interface ---
if "messages" not in st.session_state:
    st.session_state.messages = []

# Display chat messages from history
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Handle new user input
if prompt := st.chat_input("Ask a question about diabetes management (e.g., 'Can I eat sweets?'):"):
    st.chat_message("user").markdown(prompt)
    st.session_state.messages.append({"role": "user", "content": prompt})

    with st.spinner("Thinking..."):
        try:
            response = chat_chain.invoke(prompt)
            with st.chat_message("assistant"):
                st.markdown(response)
            st.session_state.messages.append({"role": "assistant", "content": response})
        except Exception as e:
            error_msg = f"An error occurred: {e}. Please ensure your GOOGLE_API_KEY is set correctly."
            st.error(error_msg)
            st.session_state.messages.append({"role": "assistant", "content": error_msg})
