#!/bin/bash
# Health probe script for t3.micro
# Keeps Cloud Run and Azure Container Apps warm

# Your service URLs (update after deployment)
GOOGLE_CLOUD_RUN_URL="https://graphcodebert-xxxxx-uc.a.run.app"
AZURE_CONTAINER_APP_URL="https://graphcodebert.xxxxx.eastus.azurecontainerapps.io"

# Probe Google Cloud Run
echo "[$(date)] Probing Google Cloud Run..."
if curl -s -f "${GOOGLE_CLOUD_RUN_URL}/health" > /dev/null; then
    echo "[$(date)] ✓ Google Cloud Run is healthy"
else
    echo "[$(date)] ✗ Google Cloud Run probe failed"
fi

# Probe Azure Container Apps
echo "[$(date)] Probing Azure Container Apps..."
if curl -s -f "${AZURE_CONTAINER_APP_URL}/health" > /dev/null; then
    echo "[$(date)] ✓ Azure Container Apps is healthy"
else
    echo "[$(date)] ✗ Azure Container Apps probe failed"
fi

# Optional: Log to file
# echo "[$(date)] Probe complete" >> /var/log/health-probes.log
