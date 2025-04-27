# app.py (in project root)
import os
import sys

# Print debugging information
print(f"Current directory: {os.getcwd()}")
print(f"Directory listing: {os.listdir('.')}")
print(f"Python path: {sys.path}")

try:
    # Try importing from backend
    from backend.app_entry import app
    print("Successfully imported app from backend!")
except ImportError as e:
    # Create a fallback app if import fails
    from flask import Flask
    app = Flask(__name__)
    
    @app.route('/')
    def home():
        return f"""
        <h1>Import Error</h1>
        <p>Error: {str(e)}</p>
        <p>Current directory: {os.getcwd()}</p>
        <p>Directory contents: {os.listdir('.')}</p>
        <p>Python path: {sys.path}</p>
        """

# No need for app.run() since gunicorn will handle this