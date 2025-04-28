
#try:
#    from backend.main import app, db
#    from backend.models import *  # This will register the models with the app
#except ImportError as e:
#    try:
#        from main import app, db
#        from models import *  # This will register the models with the app
#    except ImportError:
#        print(f"Failed to import required modules: {str(e)}")
#        raise

from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import os

# Import the app and routes
#from app import app
# Import the app and db from app.py
from app import app, db

# Initialize the database if running directly
if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    
    # Run the app
    app.run(host='0.0.0.0', port=8000, debug=True)

