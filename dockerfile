# Use official Python image as the base
FROM python:3.9-slim

# Set working directory inside the container
WORKDIR /app

# Copy the current directory into the container at /app
COPY . /app

# Install necessary dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 5000 (Flask default port)
EXPOSE 5000

# Command to run the Flask app
CMD ["python", "app.py"]
