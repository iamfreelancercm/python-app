try:
    # Try relative import path for Azure 
    from backend.main import app, db
    import backend.models as models  # This will register the models with the app
    from backend.app import *  # This imports all the routes
except ImportError as e:
    try:
        # Fallback to direct import for local development
        from main import app, db
        import models  # This will register the models with the app
        from app import *  # This imports all the routes
    except ImportError:
        print(f"Failed to import required modules: {str(e)}")
        raise

# Initialize the database if running directly
if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    
    # Run the app
    app.run(host='0.0.0.0', port=5000, debug=True)