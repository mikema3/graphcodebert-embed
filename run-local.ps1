# PowerShell script to build and run GraphCodeBERT container locally
# Usage: .\run-local.ps1 [build|run|test|stop|logs]

param(
    [Parameter(Position=0)]
    [string]$Action = "help"
)

$ImageName = "graphcodebert-embed:local"
$ContainerName = "graphcodebert"
$Port = 8000

function Show-Help {
    Write-Host "GraphCodeBERT Local Container Manager" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\run-local.ps1 [action]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Actions:" -ForegroundColor Green
    Write-Host "  build    - Build the Docker image"
    Write-Host "  run      - Run the container (foreground)"
    Write-Host "  start    - Start container in background"
    Write-Host "  test     - Test the health endpoint"
    Write-Host "  embed    - Test the embed endpoint"
    Write-Host "  stop     - Stop the running container"
    Write-Host "  logs     - Show container logs"
    Write-Host "  clean    - Remove container and image"
    Write-Host "  help     - Show this help message"
    Write-Host ""
}

function Build-Image {
    Write-Host "Building Docker image..." -ForegroundColor Cyan
    docker build -t $ImageName .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Image built successfully!" -ForegroundColor Green
    } else {
        Write-Host "✗ Build failed!" -ForegroundColor Red
        exit 1
    }
}

function Run-Container {
    Write-Host "Running container on port $Port..." -ForegroundColor Cyan
    docker run --rm -p ${Port}:8000 --name $ContainerName $ImageName
}

function Start-ContainerBackground {
    Write-Host "Starting container in background on port $Port..." -ForegroundColor Cyan
    docker run -d -p ${Port}:8000 --name $ContainerName $ImageName
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Container started!" -ForegroundColor Green
        Write-Host "Access at: http://localhost:$Port" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        Test-Health
    }
}

function Test-Health {
    Write-Host "Testing health endpoint..." -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$Port/health" -Method GET
        Write-Host "✓ Service is healthy!" -ForegroundColor Green
        Write-Host "Model: $($response.model)" -ForegroundColor Yellow
        Write-Host "Device: $($response.device)" -ForegroundColor Yellow
    } catch {
        Write-Host "✗ Health check failed!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Test-Embed {
    Write-Host "Testing embed endpoint..." -ForegroundColor Cyan
    $body = @{
        texts = @(
            "def add(a, b): return a + b",
            "public class HelloWorld { }"
        )
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$Port/embed" -Method POST -Body $body -ContentType "application/json"
        Write-Host "✓ Embedding successful!" -ForegroundColor Green
        Write-Host "Generated $($response.vectors.Count) embeddings" -ForegroundColor Yellow
        Write-Host "Vector dimension: $($response.vectors[0].Count)" -ForegroundColor Yellow
    } catch {
        Write-Host "✗ Embedding failed!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Stop-Container {
    Write-Host "Stopping container..." -ForegroundColor Cyan
    docker stop $ContainerName 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Container stopped!" -ForegroundColor Green
    } else {
        Write-Host "No container running" -ForegroundColor Yellow
    }
}

function Show-Logs {
    Write-Host "Showing container logs..." -ForegroundColor Cyan
    docker logs $ContainerName
}

function Clean-All {
    Write-Host "Cleaning up..." -ForegroundColor Cyan
    docker stop $ContainerName 2>$null
    docker rm $ContainerName 2>$null
    docker rmi $ImageName 2>$null
    Write-Host "✓ Cleanup complete!" -ForegroundColor Green
}

# Main script logic
switch ($Action.ToLower()) {
    "build" { Build-Image }
    "run" { Run-Container }
    "start" { Start-ContainerBackground }
    "test" { Test-Health }
    "embed" { Test-Embed }
    "stop" { Stop-Container }
    "logs" { Show-Logs }
    "clean" { Clean-All }
    default { Show-Help }
}
