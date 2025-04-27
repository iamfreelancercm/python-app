#!/bin/bash

# This script starts both the backend and frontend servers for the Financial Advisor application

echo "=== Starting Financial Advisor Platform ==="

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is required but not installed."
    exit 1
fi

# Create necessary directories
mkdir -p backend/sample_data

# Install backend dependencies
echo "Installing backend dependencies..."
cd backend
pip install -r requirements.txt
cd ..

# Generate sample data if it doesn't exist
if [ ! -f backend/sample_data/client_accounts.xlsx ]; then
    echo "Generating sample data..."
    cd backend
    python -c "from excel_handler import create_sample_excel; create_sample_excel()"
    cd ..
fi

# Start the backend server
echo "Starting backend server on port 8000..."
cd backend
python app.py &
BACKEND_PID=$!
cd ..

echo "Backend server started with PID: $BACKEND_PID"

# Give the backend time to start
sleep 2

# Start the frontend server
echo "Starting frontend server on port 5000..."
cd frontend
flutter run -d web-server --web-port=5000 --web-hostname=0.0.0.0 &
FRONTEND_PID=$!
cd ..

echo "Frontend server started with PID: $FRONTEND_PID"

# Function to handle shutdown
function cleanup {
    echo "Shutting down servers..."
    kill $BACKEND_PID
    kill $FRONTEND_PID
    exit 0
}

# Register the cleanup function for SIGINT (Ctrl+C) and SIGTERM
trap cleanup SIGINT SIGTERM

echo "=== Financial Advisor Platform is running ==="
echo "- Backend API: http://localhost:8000"
echo "- Frontend UI: http://localhost:5000"
echo "Press Ctrl+C to stop all servers"

# Wait for user to press Ctrl+C
wait
