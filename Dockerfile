FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UVICORN_HOST=0.0.0.0 \
    UVICORN_PORT=8000

# Faster installs & smaller image
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Expose HTTP port
EXPOSE 8000

# MODEL_ID and POOLING can be overridden at runtime via env vars
ENV MODEL_ID="microsoft/graphcodebert-base" \
    POOLING="mean"

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
