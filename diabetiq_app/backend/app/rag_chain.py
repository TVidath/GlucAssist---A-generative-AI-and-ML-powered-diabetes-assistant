import os
from dotenv import load_dotenv
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate

# --- Environment Setup ---
load_dotenv()

class DiabetesAppRAG:
    def __init__(self):
        self.rag_chain = self._setup_chat_chain()

    def _setup_chat_chain(self):
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

    def ask(self, question):
        """Public method to ask a question."""
        try:
            return self.rag_chain.invoke(question)
        except Exception as e:
            return f"An error occurred while answering: {e}. Please ensure your GOOGLE_API_KEY is set correctly."
