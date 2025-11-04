# Deploy GraphCodeBERT to Azure Container Apps

Complete guide to deploy your container to Azure Container Apps with $0 cost for experimentation.

## Prerequisites

1. **Azure Account**
   - Sign up: https://azure.microsoft.com/free/
   - $200 free credit for new accounts (30 days)
   - Free tier doesn't expire

2. **Install Azure CLI**
   ```powershell
   # Download and install from:
   # https://aka.ms/installazurecliwindows
   
   # Or use Azure Cloud Shell (no install needed)
   # https://shell.azure.com/
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

## Step 2: Setup Azure Resources

```bash
# Login to Azure
az login

# Set subscription (if you have multiple)
az account set --subscription "Your Subscription Name"

# Create resource group
az group create \
  --name graphcodebert-rg \
  --location eastus

# Create Container Apps environment
az containerapp env create \
  --name graphcodebert-env \
  --resource-group graphcodebert-rg \
  --location eastus
```

---

## Step 3: Deploy to Azure Container Apps

### Basic Deployment (Scale to Zero)

```bash
az containerapp create \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --environment graphcodebert-env \
  --image docker.io/YOUR_DOCKERHUB_USERNAME/graphcodebert-embed:latest \
  --target-port 8000 \
  --ingress external \
  --cpu 2 \
  --memory 4Gi \
  --min-replicas 0 \
  --max-replicas 10
```

**Parameters explained:**
- `--image`: Your Docker Hub image
- `--target-port 8000`: Container port
- `--ingress external`: Public access
- `--cpu 2`: 2 vCPUs
- `--memory 4Gi`: 4GB RAM
- `--min-replicas 0`: Scale to zero ($0 when idle)
- `--max-replicas 10`: Max concurrent containers

### Keep-Warm Deployment (Minimal Cost)

```bash
az containerapp create \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --environment graphcodebert-env \
  --image docker.io/YOUR_DOCKERHUB_USERNAME/graphcodebert-embed:latest \
  --target-port 8000 \
  --ingress external \
  --cpu 2 \
  --memory 4Gi \
  --min-replicas 1 \
  --max-replicas 10
```

**Cost:** ~$3-5/month, but **zero cold starts**

---

## Step 4: Get Service URL

```bash
# Get the FQDN (URL)
az containerapp show \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --query properties.configuration.ingress.fqdn \
  --output tsv
```

Output will be like: `graphcodebert.nicebeach-xxxxx.eastus.azurecontainerapps.io`

---

## Step 5: Test Deployment

### Test health endpoint:
```bash
curl https://graphcodebert.nicebeach-xxxxx.eastus.azurecontainerapps.io/health
```

### Test embedding:
```powershell
$url = "https://graphcodebert.nicebeach-xxxxx.eastus.azurecontainerapps.io/embed"
$body = @{
    texts = @(
        "def add(a, b): return a + b",
        "function multiply(x, y) { return x * y; }"
    )
} | ConvertTo-Json

Invoke-RestMethod -Uri $url -Method POST -Body $body -ContentType "application/json"
```

---

## Step 6: Setup Health Probes

### Built-in Health Probes (Free)

```bash
# Update with health probe
az containerapp update \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --set-env-vars "ENABLE_HEALTH_PROBE=true"

# Configure probe (optional, probes don't count toward quota)
az containerapp update \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --health-probe-type liveness \
  --health-probe-path /health \
  --health-probe-interval 300
```

### External Monitoring (UptimeRobot - Free)

1. Sign up at https://uptimerobot.com/
2. Add monitor:
   - Type: HTTP(s)
   - URL: `https://your-service-url/health`
   - Interval: 5 minutes
   - **Cost:** $0, uses only 8,640 of 2M free requests

---

## Management Commands

### View logs:
```bash
# Real-time logs
az containerapp logs show \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --follow

# Recent logs
az containerapp logs show \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --tail 50
```

### Update deployment:
```bash
# After pushing new image to Docker Hub
az containerapp update \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --image docker.io/YOUR_DOCKERHUB_USERNAME/graphcodebert-embed:latest
```

### Scale configuration:
```bash
# Change CPU/Memory
az containerapp update \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --cpu 4 \
  --memory 8Gi

# Change replica count
az containerapp update \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --min-replicas 0 \
  --max-replicas 20
```

### Delete service:
```bash
# Delete container app
az containerapp delete \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --yes

# Delete entire resource group (removes everything)
az group delete \
  --name graphcodebert-rg \
  --yes
```

### Get service info:
```bash
# Get all details
az containerapp show \
  --name graphcodebert \
  --resource-group graphcodebert-rg

# Just the URL
az containerapp show \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --query properties.configuration.ingress.fqdn \
  --output tsv
```

---

## Environment Variables

### Set custom model or pooling:
```bash
az containerapp update \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --set-env-vars MODEL_ID=microsoft/graphcodebert-base POOLING=mean
```

---

## Auto-scaling Rules

### Scale based on HTTP requests:
```bash
az containerapp update \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --scale-rule-name http-rule \
  --scale-rule-type http \
  --scale-rule-http-concurrency 50
```

This means: Add replica when >50 concurrent requests

### Scale based on CPU:
```bash
az containerapp update \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --scale-rule-name cpu-rule \
  --scale-rule-type cpu \
  --scale-rule-metadata cpu=70
```

This means: Add replica when CPU > 70%

---

## Cost Monitoring

### View costs:
```bash
# In Azure Portal:
# Cost Management + Billing → Cost analysis
# Filter by Resource Group: graphcodebert-rg
```

### Set budget alerts:
```bash
# In Azure Portal:
# Cost Management + Billing → Budgets
# Create budget for $1, $5, $10
```

---

## Custom Domain (Optional)

### Add custom domain:
```bash
# Add domain
az containerapp hostname add \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --hostname api.yourdomain.com

# Get certificate info (for DNS setup)
az containerapp hostname list \
  --name graphcodebert \
  --resource-group graphcodebert-rg
```

---

## Troubleshooting

### Service won't start:
```bash
# Check logs
az containerapp logs show \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --tail 100

# Check revision status
az containerapp revision list \
  --name graphcodebert \
  --resource-group graphcodebert-rg
```

### Cold starts too slow:
```bash
# Set min-replicas=1
az containerapp update \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --min-replicas 1
```

### Out of memory:
```bash
# Increase memory
az containerapp update \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --memory 8Gi
```

---

## Expected Costs

### Experimentation (no traffic):
```
Cost: $0/month (scale to zero)
```

### Light usage (1K requests/day):
```
Requests: 30K/month (under free tier)
Compute: ~10K CPU-seconds (under free tier)
Cost: $0/month
```

### With health probes (every 5 min):
```
Health probes: 8,640/month (built-in probes free)
Your traffic: ~20K/month  
Cost: $0/month
```

### Medium production (10K requests/day):
```
Requests: 300K/month (under 2M free tier)
Compute: ~120K CPU-seconds (under free tier)
Cost: $0-2/month (mostly free)
```

---

## Comparison: Azure vs Google

| Feature | Azure Container Apps | Google Cloud Run |
|---------|---------------------|------------------|
| **Scale to zero** | ✅ Yes (~2-5 min) | ✅ Yes (~15 min) |
| **Cold start** | ~2-4s | ~2-3s |
| **Free tier** | 180K CPU-sec, 360K GB-sec | 360K CPU-sec, 360K GB-sec |
| **Built-in probes** | ✅ Free | ⚠️ Count as requests |
| **CLI complexity** | Medium | Easier |
| **UI/Portal** | Good | Better |
| **Auto-scaling** | KEDA-based | Native |
| **Min cost (1 replica)** | ~$3-5/month | ~$3-5/month |

**Both are excellent choices!** Pick based on:
- Azure if you prefer Microsoft ecosystem
- Google if you want simpler CLI/UI

---

## PowerShell Test Script

Save as `test-azure.ps1`:

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$ServiceUrl
)

# Ensure URL has https://
if (-not $ServiceUrl.StartsWith("http")) {
    $ServiceUrl = "https://$ServiceUrl"
}

Write-Host "Testing Azure Container Apps service: $ServiceUrl" -ForegroundColor Cyan

# Health check
Write-Host "`nTesting /health..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$ServiceUrl/health"
    Write-Host "✓ Health: $($health | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "✗ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Embedding test
Write-Host "`nTesting /embed..." -ForegroundColor Yellow
$body = @{
    texts = @(
        "def hello(): print('Hello')",
        "function hello() { console.log('Hello'); }"
    )
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri "$ServiceUrl/embed" -Method POST -Body $body -ContentType "application/json"
    Write-Host "✓ Generated $($result.vectors.Count) embeddings" -ForegroundColor Green
    Write-Host "  Dimension: $($result.vectors[0].Count)" -ForegroundColor Yellow
} catch {
    Write-Host "✗ Embedding failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n✓ All tests passed!" -ForegroundColor Green
```

Usage:
```powershell
.\test-azure.ps1 -ServiceUrl "graphcodebert.nicebeach-xxxxx.eastus.azurecontainerapps.io"
```

---

## Next Steps

1. **Deploy to Azure Container Apps** ✅
2. **Test the service** ✅
3. **Setup health probes** (optional)
4. **Monitor costs** (set alerts)
5. **Compare with Google Cloud Run**

---

## API Documentation

Once deployed, visit:
- **Swagger UI:** `https://your-service-url/docs`
- **ReDoc:** `https://your-service-url/redoc`
- **Health:** `https://your-service-url/health`
