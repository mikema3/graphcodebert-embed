# Deploy GraphCodeBERT to Google Cloud Run

Complete guide to deploy your container to Google Cloud Run with $0 cost for experimentation.

## Prerequisites

1. **Google Cloud Account**
   - Sign up: https://cloud.google.com/
   - $300 free credit for new accounts (90 days)
   - Always-free tier (doesn't expire)

2. **Install Google Cloud SDK**
   ```powershell
   # Download and install from:
   # https://cloud.google.com/sdk/docs/install
   
   # Or use Cloud Shell (no install needed)
   # https://console.cloud.google.com/
   ```

3. **Docker Hub Account (free)**
   - Sign up: https://hub.docker.com/
   - For storing public images (free)

---

## Step 1: Push Image to Docker Hub

```powershell
# Login to Docker Hub
docker login

# Tag your local image
docker tag graphcodebert-embed:local YOUR_DOCKERHUB_USERNAME/graphcodebert-embed:latest

# Push to Docker Hub (this will take a few minutes - 8.76GB)
docker push YOUR_DOCKERHUB_USERNAME/graphcodebert-embed:latest
```

**Expected time:** 5-15 minutes depending on upload speed

---

## Step 2: Setup Google Cloud Project

```bash
# Login to Google Cloud
gcloud auth login

# Create a new project (or use existing)
gcloud projects create graphcodebert-project --name="GraphCodeBERT"

# Set as default project
gcloud config set project graphcodebert-project

# Enable Cloud Run API
gcloud services enable run.googleapis.com

# Set default region
gcloud config set run/region us-central1
```

---

## Step 3: Deploy to Cloud Run

### Basic Deployment (Scale to Zero)

```bash
gcloud run deploy graphcodebert \
  --image docker.io/YOUR_DOCKERHUB_USERNAME/graphcodebert-embed:latest \
  --platform managed \
  --region us-central1 \
  --memory 2Gi \
  --cpu 2 \
  --min-instances 0 \
  --max-instances 10 \
  --port 8000 \
  --allow-unauthenticated \
  --timeout 300
```

**Parameters explained:**
- `--image`: Your Docker Hub image
- `--memory 2Gi`: 2GB RAM (adjust if needed)
- `--cpu 2`: 2 vCPUs
- `--min-instances 0`: Scale to zero ($0 when idle)
- `--max-instances 10`: Max concurrent containers
- `--port 8000`: Container port
- `--allow-unauthenticated`: Public access
- `--timeout 300`: 5 min timeout for long requests

### Keep-Warm Deployment (Minimal Cost)

```bash
gcloud run deploy graphcodebert \
  --image docker.io/YOUR_DOCKERHUB_USERNAME/graphcodebert-embed:latest \
  --platform managed \
  --region us-central1 \
  --memory 2Gi \
  --cpu 2 \
  --min-instances 1 \
  --max-instances 10 \
  --port 8000 \
  --allow-unauthenticated
```

**Cost:** ~$3-5/month, but **zero cold starts**

---

## Step 4: Test Deployment

After deployment, you'll get a URL like:
```
https://graphcodebert-xxxxx-uc.a.run.app
```

### Test health endpoint:
```bash
curl https://graphcodebert-xxxxx-uc.a.run.app/health
```

### Test embedding:
```powershell
$url = "https://graphcodebert-xxxxx-uc.a.run.app/embed"
$body = @{
    texts = @(
        "def add(a, b): return a + b",
        "function multiply(x, y) { return x * y; }"
    )
} | ConvertTo-Json

Invoke-RestMethod -Uri $url -Method POST -Body $body -ContentType "application/json"
```

---

## Step 5: Setup Health Probes (Keep Warm - Free)

### Option A: Use UptimeRobot (Free)

1. Sign up at https://uptimerobot.com/ (free tier)
2. Add monitor:
   - Type: HTTP(s)
   - URL: `https://your-service-url/health`
   - Interval: 5 minutes
   - **Cost:** $0, uses only 8,640 of 2M free requests

### Option B: Use Google Cloud Scheduler

```bash
# Create a job to ping every 5 minutes
gcloud scheduler jobs create http keep-warm \
  --schedule="*/5 * * * *" \
  --uri="https://graphcodebert-xxxxx-uc.a.run.app/health" \
  --http-method=GET
```

**Cost:** Free tier = 3 jobs, plenty for one service

### Option C: Simple Cron (Linux/Mac)

```bash
# Add to crontab
*/5 * * * * curl -s https://your-service-url/health > /dev/null
```

---

## Management Commands

### View logs:
```bash
gcloud run services logs read graphcodebert --limit 50
```

### Update deployment:
```bash
# After pushing new image to Docker Hub
gcloud run deploy graphcodebert \
  --image docker.io/YOUR_DOCKERHUB_USERNAME/graphcodebert-embed:latest
```

### Scale configuration:
```bash
# Change memory/CPU
gcloud run services update graphcodebert --memory 4Gi --cpu 4

# Change scaling
gcloud run services update graphcodebert --min-instances 0 --max-instances 20
```

### Delete service:
```bash
gcloud run services delete graphcodebert
```

### Get service URL:
```bash
gcloud run services describe graphcodebert --format='value(status.url)'
```

---

## Cost Monitoring

### View current month costs:
```bash
# In Google Cloud Console:
# Billing → Reports → Filter by Cloud Run
```

### Set billing alerts:
```bash
# Console: Billing → Budgets & alerts
# Set alert at $1, $5, $10
```

---

## Environment Variables

### Set custom model or pooling:
```bash
gcloud run deploy graphcodebert \
  --set-env-vars MODEL_ID=microsoft/graphcodebert-base,POOLING=mean
```

### Update env vars only:
```bash
gcloud run services update graphcodebert \
  --set-env-vars MODEL_ID=different-model
```

---

## Custom Domain (Optional)

### Map custom domain:
```bash
# Add domain to Cloud Run
gcloud run domain-mappings create \
  --service graphcodebert \
  --domain api.yourdomain.com

# Follow DNS setup instructions
```

---

## Troubleshooting

### Service won't start:
```bash
# Check logs
gcloud run services logs read graphcodebert --limit 100

# Common issues:
# - Port 8000 not exposed
# - Container crashes on startup
# - Out of memory
```

### Cold starts too slow:
```bash
# Option 1: Set min-instances=1
gcloud run services update graphcodebert --min-instances 1

# Option 2: Reduce image size (see optimization guide)
```

### Out of memory:
```bash
# Increase memory
gcloud run services update graphcodebert --memory 4Gi
```

---

## Expected Costs

### Experimentation (no traffic):
```
Cost: $0/month
```

### Light usage (1K requests/day):
```
Requests: 30K/month (under 2M free tier)
Compute: ~10K CPU-seconds (under 360K free tier)
Cost: $0/month
```

### With health probes (every 5 min):
```
Health probes: 8,640/month
Your traffic: ~20K/month  
Total: ~29K/month (well under 2M free tier)
Cost: $0/month
```

### Medium production (10K requests/day):
```
Requests: 300K/month (under 2M free tier)
Compute: ~120K CPU-seconds (under 360K free tier)
Cost: $0-2/month (mostly free)
```

---

## Next Steps

1. **Deploy to Cloud Run** ✅
2. **Test the service** ✅
3. **Setup health probes** (optional, keeps warm)
4. **Monitor costs** (set alerts)
5. **Optimize if needed** (reduce image size)

---

## API Documentation

Once deployed, visit:
- **Swagger UI:** `https://your-service-url/docs`
- **ReDoc:** `https://your-service-url/redoc`
- **Health:** `https://your-service-url/health`

---

## PowerShell Test Script

Save as `test-cloudrun.ps1`:

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$ServiceUrl
)

Write-Host "Testing Cloud Run service: $ServiceUrl" -ForegroundColor Cyan

# Health check
Write-Host "`nTesting /health..." -ForegroundColor Yellow
$health = Invoke-RestMethod -Uri "$ServiceUrl/health"
Write-Host "✓ Health: $($health | ConvertTo-Json)" -ForegroundColor Green

# Embedding test
Write-Host "`nTesting /embed..." -ForegroundColor Yellow
$body = @{
    texts = @(
        "def hello(): print('Hello')",
        "function hello() { console.log('Hello'); }"
    )
} | ConvertTo-Json

$result = Invoke-RestMethod -Uri "$ServiceUrl/embed" -Method POST -Body $body -ContentType "application/json"
Write-Host "✓ Generated $($result.vectors.Count) embeddings" -ForegroundColor Green
Write-Host "  Dimension: $($result.vectors[0].Count)" -ForegroundColor Yellow

Write-Host "`n✓ All tests passed!" -ForegroundColor Green
```

Usage:
```powershell
.\test-cloudrun.ps1 -ServiceUrl "https://graphcodebert-xxxxx-uc.a.run.app"
```
