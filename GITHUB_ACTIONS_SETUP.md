# GitHub Actions Setup for Docker Build & Push

## Prerequisites

1. **GitHub Repository** with your code
2. **Docker Hub Account** (free)
3. **Docker Hub Access Token**

---

## Step 1: Create Docker Hub Access Token

1. Go to: https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Name: `github-actions`
4. Permissions: **Read, Write, Delete**
5. Click "Generate"
6. **Copy the token** (you won't see it again!)

---

## Step 2: Add Secrets to GitHub

1. Go to your GitHub repo: `https://github.com/YOUR_USERNAME/YOUR_REPO`
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"

**Add these two secrets:**

**Secret 1:**
- Name: `DOCKERHUB_USERNAME`
- Value: Your Docker Hub username (e.g., `john`)

**Secret 2:**
- Name: `DOCKERHUB_TOKEN`
- Value: The access token you copied in Step 1

---

## Step 3: Create GitHub Actions Workflow

The workflow file has been created at:
```
.github/workflows/docker-build.yml
```

---

## Step 4: Push to GitHub

```powershell
# Initialize git if not already
cd C:\my1\huggingface\graphcodebert
git init

# Add files
git add .

# Commit
git commit -m "Add GraphCodeBERT container with GitHub Actions build"

# Add remote (replace with your repo URL)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Push to GitHub
git push -u origin main
```

---

## Step 5: Watch the Build

1. Go to your GitHub repo
2. Click "Actions" tab
3. You'll see the workflow running
4. Click on it to watch progress

**Build time:** ~10-15 minutes (first time)
**Subsequent builds:** ~5-10 minutes (with caching)

---

## What Happens Automatically

When you push code to GitHub:

1. ✅ GitHub Actions triggers
2. ✅ Builds Docker image on GitHub runners
3. ✅ Pushes to Docker Hub
4. ✅ Tags with `latest` + commit SHA
5. ✅ Caches layers for faster future builds

---

## Workflow Triggers

The workflow runs when:

1. **Push to main/master branch** (automatic)
2. **Manual trigger** (click "Run workflow" button)
3. **Changes in graphcodebert/** folder

---

## Manual Trigger

You can also trigger builds manually:

1. Go to: Actions → Build and Push Docker Image
2. Click "Run workflow"
3. Select branch
4. Click "Run workflow" button

---

## View Built Images

After successful build, check:
- **Docker Hub:** `https://hub.docker.com/r/YOUR_USERNAME/graphcodebert-embed`
- **Tags:** `latest`, `main-abc123` (commit SHA)

---

## Use the Image

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

## Advanced: Auto-Deploy After Build

Want to auto-deploy to Cloud Run after build? Add this to the workflow:

```yaml
      - name: Deploy to Cloud Run
        if: github.ref == 'refs/heads/main'
        run: |
          gcloud run deploy graphcodebert \
            --image docker.io/${{ secrets.DOCKERHUB_USERNAME }}/${{ env.DOCKER_IMAGE_NAME }}:latest \
            --platform managed \
            --region us-central1 \
            --project YOUR_PROJECT_ID
        env:
          GOOGLE_APPLICATION_CREDENTIALS: ${{ secrets.GCP_SA_KEY }}
```

(Requires GCP service account key in GitHub secrets)

---

## Workflow Features

### Automatic Tagging:
- `latest` - Always points to newest build
- `main-abc123` - Specific commit SHA
- `main` - Latest from main branch

### Layer Caching:
- Uses GitHub Actions cache
- Speeds up subsequent builds
- Shares layers between builds

### Multi-platform (Optional):
Add this to build for ARM too:
```yaml
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          platforms: linux/amd64,linux/arm64
          # ... rest of config
```

---

## Cost

**GitHub Actions (Public Repo):**
- ✅ 2,000 minutes/month FREE
- Your build: ~10-15 minutes
- **You can build ~130 times/month for FREE**

**GitHub Actions (Private Repo):**
- Free tier: 2,000 minutes/month
- After: $0.008/minute
- Still very cheap!

---

## Troubleshooting

### Build fails:
```
Check Actions logs for details
Common issues:
- Wrong Docker Hub credentials
- Dockerfile path incorrect
- Out of disk space (rare)
```

### Secrets not working:
```
Make sure secrets are named exactly:
- DOCKERHUB_USERNAME
- DOCKERHUB_TOKEN
```

### Image not pushing:
```
Check Docker Hub token has Write permissions
Verify username is correct
```

---

## Compare: Local vs GitHub Actions

| Method | Upload Time | Build Time | Bandwidth | Reproducible |
|--------|-------------|------------|-----------|--------------|
| **Local Build** | 10-20 min (8.76GB) | 5-10 min | High (upload) | ❌ No |
| **GitHub Actions** | 0 min | 10-15 min | None (local) | ✅ Yes |

**GitHub Actions wins!** No upload, reproducible builds, free.

---

## Next Steps

1. ✅ Create Docker Hub access token
2. ✅ Add secrets to GitHub
3. ✅ Push code to GitHub
4. ✅ Watch the build in Actions
5. ✅ Use the image in Cloud Run/Azure

Your image will be built and pushed automatically! 🚀
