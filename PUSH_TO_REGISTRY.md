# Push to Docker Hub - Quick Guide

## Prerequisites

1. Docker Hub account (free): https://hub.docker.com/signup
2. Local image: `graphcodebert-embed:local`

## Step 1: Login to Docker Hub

```powershell
docker login
# Enter username and password when prompted
```

## Step 2: Tag Image

```powershell
# Replace YOUR_USERNAME with your Docker Hub username
docker tag graphcodebert-embed:local YOUR_USERNAME/graphcodebert-embed:latest

# Optional: Also tag with version
docker tag graphcodebert-embed:local YOUR_USERNAME/graphcodebert-embed:v1.0
```

## Step 3: Push to Docker Hub

```powershell
# Push latest tag
docker push YOUR_USERNAME/graphcodebert-embed:latest

# Push version tag (optional)
docker push YOUR_USERNAME/graphcodebert-embed:v1.0
```

**Expected time:** 5-15 minutes (uploading 8.76GB)

## Step 4: Verify

Visit: `https://hub.docker.com/r/YOUR_USERNAME/graphcodebert-embed`

You should see your image listed.

## Step 5: Use in Cloud Deployments

### Google Cloud Run:
```bash
gcloud run deploy graphcodebert \
  --image docker.io/YOUR_USERNAME/graphcodebert-embed:latest \
  --platform managed \
  --region us-central1 \
  --memory 2Gi \
  --cpu 2 \
  --min-instances 0 \
  --max-instances 10 \
  --port 8000 \
  --allow-unauthenticated
```

### Azure Container Apps:
```bash
az containerapp create \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  --environment graphcodebert-env \
  --image docker.io/YOUR_USERNAME/graphcodebert-embed:latest \
  --target-port 8000 \
  --ingress external \
  --cpu 2 \
  --memory 4Gi \
  --min-replicas 0 \
  --max-replicas 10
```

---

## Alternative: Push to GitHub Container Registry

If you prefer GitHub:

### Step 1: Create Personal Access Token

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token with `write:packages` scope
3. Copy token

### Step 2: Login to GitHub Registry

```powershell
# Replace YOUR_TOKEN with your GitHub token
echo YOUR_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

### Step 3: Tag for GitHub

```powershell
# Replace YOUR_GITHUB_USERNAME
docker tag graphcodebert-embed:local ghcr.io/YOUR_GITHUB_USERNAME/graphcodebert-embed:latest
```

### Step 4: Push to GitHub

```powershell
docker push ghcr.io/YOUR_GITHUB_USERNAME/graphcodebert-embed:latest
```

### Step 5: Make Package Public

1. Go to: https://github.com/YOUR_USERNAME?tab=packages
2. Click on `graphcodebert-embed`
3. Package settings → Change visibility → Public

### Step 6: Use in Cloud Deployments

```bash
# Google Cloud Run
gcloud run deploy graphcodebert \
  --image ghcr.io/YOUR_GITHUB_USERNAME/graphcodebert-embed:latest \
  ...

# Azure Container Apps
az containerapp create \
  --image ghcr.io/YOUR_GITHUB_USERNAME/graphcodebert-embed:latest \
  ...
```

---

## Comparison Quick Reference

### Docker Hub (Recommended)
```powershell
# Login
docker login

# Tag & Push
docker tag graphcodebert-embed:local YOUR_USERNAME/graphcodebert-embed:latest
docker push YOUR_USERNAME/graphcodebert-embed:latest

# Use in cloud
--image docker.io/YOUR_USERNAME/graphcodebert-embed:latest
```

### GitHub Container Registry
```powershell
# Login (need token)
echo YOUR_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# Tag & Push
docker tag graphcodebert-embed:local ghcr.io/YOUR_USERNAME/graphcodebert-embed:latest
docker push ghcr.io/YOUR_USERNAME/graphcodebert-embed:latest

# Make public (manual step in GitHub UI)

# Use in cloud
--image ghcr.io/YOUR_USERNAME/graphcodebert-embed:latest
```

---

## One-Line Push Scripts

### Docker Hub:
```powershell
# Set your username
$DOCKER_USER = "your-username"

# Login, tag, push
docker login
docker tag graphcodebert-embed:local ${DOCKER_USER}/graphcodebert-embed:latest
docker push ${DOCKER_USER}/graphcodebert-embed:latest
```

### GitHub:
```powershell
# Set your details
$GITHUB_USER = "your-username"
$GITHUB_TOKEN = "your-token"

# Login, tag, push
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USER --password-stdin
docker tag graphcodebert-embed:local ghcr.io/${GITHUB_USER}/graphcodebert-embed:latest
docker push ghcr.io/${GITHUB_USER}/graphcodebert-embed:latest
```

---

## After Pushing

Both cloud providers will pull your image automatically when you deploy!

No additional steps needed - just use the image URL in your deployment commands.
