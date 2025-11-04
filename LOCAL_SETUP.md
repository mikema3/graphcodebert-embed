# Running GraphCodeBERT Container Locally

This guide will help you build and run the GraphCodeBERT embedding service as a Docker container locally using WSL2/Docker Desktop.

## Prerequisites

1. **Docker Desktop** must be installed and running
   - Download from: https://www.docker.com/products/docker-desktop/
   - Make sure WSL2 backend is enabled in Docker Desktop settings
   - Verify Docker is running: `docker --version`

2. **WSL2** (if running commands from WSL)
   - Docker Desktop automatically integrates with WSL2 distributions

## Step 1: Build the Docker Image

Open a terminal (PowerShell, CMD, or WSL2) and navigate to the graphcodebert directory:

```bash
cd c:\my1\huggingface\graphcodebert
```

Build the Docker image:

```bash
docker build -t graphcodebert-embed:local .
```

This will:
- Use Python 3.11 slim base image
- Install FastAPI, Uvicorn, Transformers, and PyTorch
- Copy your `app.py` file
- Set up the container to run on port 8000

**Expected build time**: 2-5 minutes (depending on internet speed)

## Step 2: Run the Container

### Basic run (CPU only):

```bash
docker run --rm -p 8000:8000 graphcodebert-embed:local
```

### Run with custom model or pooling:

```bash
docker run --rm -p 8000:8000 \
  -e MODEL_ID="microsoft/graphcodebert-base" \
  -e POOLING="mean" \
  graphcodebert-embed:local
```

### Run in background (detached mode):

```bash
docker run -d --name graphcodebert -p 8000:8000 graphcodebert-embed:local
```

### Run with GPU support (if you have NVIDIA GPU):

```bash
docker run --rm --gpus all -p 8000:8000 graphcodebert-embed:local
```

**Note**: For GPU support, you need:
- NVIDIA GPU
- NVIDIA Container Toolkit installed
- Docker configured for GPU access

## Step 3: Test the Service

### Health Check:

```bash
curl http://localhost:8000/health
```

Expected response:
```json
{"ok":true,"model":"microsoft/graphcodebert-base","device":"cpu"}
```

### Embedding Request (PowerShell):

```powershell
$body = @{
    texts = @(
        "def add(a,b): return a+b",
        "public class A {}"
    )
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/embed" -Method POST -Body $body -ContentType "application/json"
```

### Embedding Request (WSL/Linux/Git Bash):

```bash
curl -X POST http://localhost:8000/embed \
  -H "content-type: application/json" \
  -d '{"texts": ["def add(a,b): return a+b", "public class A {}"]}'
```

### With jq for formatted output:

```bash
curl -s -X POST http://localhost:8000/embed \
  -H "content-type: application/json" \
  -d '{"texts": ["def add(a,b): return a+b", "public class A {}"]}' | jq .
```

## Step 4: Managing the Container

### View running containers:

```bash
docker ps
```

### View logs (if running in background):

```bash
docker logs graphcodebert
```

### Follow logs in real-time:

```bash
docker logs -f graphcodebert
```

### Stop the container:

```bash
docker stop graphcodebert
```

### Remove the container:

```bash
docker rm graphcodebert
```

## Troubleshooting

### Issue: "Cannot connect to Docker daemon"
- **Solution**: Make sure Docker Desktop is running

### Issue: Container starts but crashes
- **Solution**: Check logs with `docker logs <container_id>`

### Issue: Port 8000 already in use
- **Solution**: 
  - Use a different port: `docker run --rm -p 8080:8000 graphcodebert-embed:local`
  - Or stop the process using port 8000

### Issue: Model download takes too long
- **Solution**: The first run downloads the model (~500MB). Subsequent runs will be faster as the model is cached inside the container.

### Issue: Out of memory
- **Solution**: 
  - Increase Docker memory limit in Docker Desktop settings
  - Recommended: At least 4GB RAM for this model

## Next Steps: RunPod Serverless

Once you've verified the container works locally, you'll be ready to:
1. Push the image to a container registry (Docker Hub or RunPod's registry)
2. Configure RunPod Serverless endpoint
3. Set up autoscaling and GPU support

## Performance Notes

- **CPU Mode**: Works but slower for inference (~500ms-2s per request)
- **GPU Mode**: Much faster (~50-200ms per request)
- **First Request**: Slower due to model loading (cold start)
- **Subsequent Requests**: Fast as model stays in memory

## API Documentation

Once running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
