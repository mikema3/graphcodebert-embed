# Quick Start Guide - GraphCodeBERT Container

## Prerequisites
✅ Docker Desktop installed and **running**

## Quick Commands

### 1. Build the image
```powershell
.\run-local.ps1 build
```

### 2. Start the service (background)
```powershell
.\run-local.ps1 start
```

### 3. Test it works
```powershell
.\run-local.ps1 test
```

### 4. Test embeddings
```powershell
.\run-local.ps1 embed
```

### 5. Run comprehensive tests
```powershell
.\test-service.ps1
```

### 6. View logs
```powershell
.\run-local.ps1 logs
```

### 7. Stop the service
```powershell
.\run-local.ps1 stop
```

## Manual Docker Commands

```powershell
# Build
docker build -t graphcodebert-embed:local .

# Run (foreground)
docker run --rm -p 8000:8000 graphcodebert-embed:local

# Run (background)
docker run -d --name graphcodebert -p 8000:8000 graphcodebert-embed:local

# Stop
docker stop graphcodebert

# Logs
docker logs graphcodebert

# Remove
docker rm graphcodebert
```

## Access Points

- **Health Check**: http://localhost:8000/health
- **API Docs**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## Test with curl (Git Bash/WSL)

```bash
# Health
curl http://localhost:8000/health

# Embed
curl -X POST http://localhost:8000/embed \
  -H "content-type: application/json" \
  -d '{"texts": ["def add(a,b): return a+b"]}'
```

## Next: Push to Registry for RunPod

```powershell
# Tag for Docker Hub
docker tag graphcodebert-embed:local yourusername/graphcodebert-embed:latest

# Push to Docker Hub
docker push yourusername/graphcodebert-embed:latest
```

## Troubleshooting

**"Cannot connect to Docker daemon"**
→ Start Docker Desktop

**Port 8000 already in use**
→ `docker run -p 8080:8000 ...` (use different port)

**Container crashes**
→ `docker logs graphcodebert`
