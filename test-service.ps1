# Test script for GraphCodeBERT embedding service
# This script tests various code snippets

param(
    [string]$BaseUrl = "http://localhost:8000"
)

function Test-Endpoint {
    param(
        [string]$Name,
        [array]$Texts
    )
    
    Write-Host "`n=== Testing: $Name ===" -ForegroundColor Cyan
    
    $body = @{ texts = $Texts } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/embed" -Method POST -Body $body -ContentType "application/json"
        Write-Host "✓ Success!" -ForegroundColor Green
        Write-Host "  Embeddings: $($response.vectors.Count)" -ForegroundColor Yellow
        Write-Host "  Dimensions: $($response.vectors[0].Count)" -ForegroundColor Yellow
        
        # Calculate similarity between first two if we have at least 2
        if ($response.vectors.Count -ge 2) {
            $similarity = Calculate-CosineSimilarity $response.vectors[0] $response.vectors[1]
            Write-Host "  Similarity (1st vs 2nd): $([math]::Round($similarity, 4))" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "✗ Failed!" -ForegroundColor Red
        Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Calculate-CosineSimilarity {
    param($vec1, $vec2)
    
    $dot = 0
    for ($i = 0; $i -lt $vec1.Count; $i++) {
        $dot += $vec1[$i] * $vec2[$i]
    }
    return $dot
}

Write-Host "GraphCodeBERT Embedding Service Test Suite" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl" -ForegroundColor Yellow

# Test 1: Python functions
Test-Endpoint -Name "Python Functions" -Texts @(
    "def add(a, b): return a + b",
    "def sum(x, y): return x + y",
    "def multiply(a, b): return a * b"
)

# Test 2: Java classes
Test-Endpoint -Name "Java Classes" -Texts @(
    "public class Calculator { public int add(int a, int b) { return a + b; } }",
    "public class MathUtil { public static int sum(int x, int y) { return x + y; } }"
)

# Test 3: JavaScript functions
Test-Endpoint -Name "JavaScript Functions" -Texts @(
    "function add(a, b) { return a + b; }",
    "const multiply = (a, b) => a * b;"
)

# Test 4: Mixed languages
Test-Endpoint -Name "Mixed Languages" -Texts @(
    "def hello(): print('Hello from Python')",
    "console.log('Hello from JavaScript')",
    "System.out.println(""Hello from Java"");"
)

# Test 5: Empty and edge cases
Test-Endpoint -Name "Single Input" -Texts @(
    "// This is a comment"
)

Write-Host "`n=== All Tests Complete ===" -ForegroundColor Green
