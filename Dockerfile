
FROM python:3.11-slim

# Set work directory
WORKDIR /app

# Copy requirements first for better caching
COPY backend/requirements.txt backend/requirements.txt

# Install dependencies
RUN pip install --no-cache-dir -r backend/requirements.txt

# Copy all code
COPY . .

# Add backend directory to PYTHONPATH
ENV PYTHONPATH=/app

# Set environment variables
ENV FLASK_APP=backend.app_entry
ENV FLASK_ENV=production
ENV PORT=8000

# Expose the port
EXPOSE 8000

# Command to run the application
CMD ["python", "backend/app_entry.py"]

