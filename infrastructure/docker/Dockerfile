# Cloud Run Jobs Container
# Unified container for dlt + dbt + ML jobs

FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy pyproject.toml and README.md for dependency installation
COPY pyproject.toml README.md ./

# Copy application code
COPY src/ ./src/

# Install dependencies and package
RUN uv pip install --system .

# Create necessary directories
RUN mkdir -p /app/logs /app/data /app/temp

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Default command - can be overridden by Cloud Run Jobs
# Examples:
# - python src/toltek/jobs/extraction/run_google_sheets.py
# - python src/toltek/jobs/transformation/run_dbt.py  
# - python src/toltek/jobs/ml/train_forecasting.py
CMD ["python", "--version"]