#!/bin/bash

# This script starts the backend for the Financial Advisor application

echo "=== Starting Financial Advisor Platform Backend ==="

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed."
    exit 1
fi

# Create necessary directories
mkdir -p backend/sample_data
mkdir -p backend/uploads

# Install backend dependencies
echo "Installing backend dependencies..."
cd backend
pip install -r requirements.txt
cd ..

# Start the backend server
echo "Starting backend server on port 5000..."
cd backend
python app.py &
BACKEND_PID=$!
cd ..

echo "Backend server started with PID: $BACKEND_PID"

# Function to handle shutdown
function cleanup {
    echo "Shutting down server..."
    kill $BACKEND_PID
    exit 0
}

# Register the cleanup function for SIGINT (Ctrl+C) and SIGTERM
trap cleanup SIGINT SIGTERM

echo "=== Financial Advisor Platform Backend is running ==="
echo "- Backend API: http://localhost:5000"
echo "Press Ctrl+C to stop the server"

# Wait for user to press Ctrl+C
wait