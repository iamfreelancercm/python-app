# Use an official Python image
FROM python:3.11-slim

# Set work directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your app code
COPY . .

# Optionally set environment variables from .env if you want (handled by app usually)
# ENV MY_VAR=value  <-- Better to use .env + python-dotenv inside the app

# Command to run your app
#CMD ["python", "main.py"]
CMD ["tail", "-f", "/dev/null"]
