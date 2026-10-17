# Use an official lightweight Python image
FROM python:3.14.0

# Set the working directory inside the container
WORKDIR /workspace

# Install system dependencies if needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file and install python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the rest of your project code into the container
COPY . /workspace/

# Set default command to run your medical AI agent
CMD ["python", "agent/medical_agent.py"]