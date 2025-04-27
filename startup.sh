#!/bin/bash

# Navigate to application directory
cd /home/site/wwwroot

# Set up environment
export FLASK_APP=backend.app_entry
export FLASK_ENV=production

# Start the application with Gunicorn
gunicorn --bind=0.0.0.0:8000 --timeout 600 backend.app_entry:app