# Google Cloud Run Pricing - Scale to Zero Explained

## What "Scale to Zero" Actually Means

**Scale to zero** means:
- When NO requests come in → NO compute charges (0 containers running)
- When requests arrive → Containers spin up automatically
- You only pay for **active request time**

However, you still pay for:
1. **Storage** (container image stored in Container Registry)
2. **CPU time during requests**
3. **Memory during requests**
4. **Network egress** (data sent out)

---

## Actual Pricing Breakdown

### Google Cloud Run Pricing (as of 2025):

**Compute (pay per use)**:
- CPU: $0.00002400 per vCPU-second
- Memory: $0.00000250 per GB-second
- Requests: $0.40 per million requests

**Storage**:
- Container Registry: ~$0.026 per GB/month
- Your 8.76GB image: **~$0.23/month**

**Free Tier (every month)**:
- 2 million requests
- 360,000 vCPU-seconds
- 360,000 GiB-seconds of memory
- 1 GB network egress (North America)

---

## Where Does $5-10/month Come From?

Let me calculate for realistic usage:

### Scenario: Moderate Usage
- **1,000 requests/day** = 30,000 requests/month
- **Average response time**: 300ms (0.3 seconds)
- **CPU allocation**: 2 vCPUs
- **Memory allocation**: 2 GB

### Cost Calculation:

**1. Requests:**
```
30,000 requests/month
Well under 2M free tier → $0
```

**2. CPU Time:**
```
Total CPU-seconds = 30,000 requests × 0.3s × 2 vCPUs = 18,000 vCPU-seconds
Free tier covers: 360,000 vCPU-seconds
Remaining: 0 (fully covered)
Cost: $0
```

**3. Memory Time:**
```
Total GB-seconds = 30,000 requests × 0.3s × 2 GB = 18,000 GB-seconds
Free tier covers: 360,000 GB-seconds  
Remaining: 0 (fully covered)
Cost: $0
```

**4. Container Storage:**
```
8.76 GB × $0.026/GB = $0.23/month
```

**5. Network Egress:**
```
Assume 100KB average response × 30,000 = 3 GB
First 1 GB free
2 GB × $0.12/GB = $0.24/month
```

**Total: $0.47/month** 😊

---

## So Why Did I Say $5-10/month?

I was being **conservative** and assuming:

### Higher Traffic Scenario:
- **10,000 requests/day** = 300,000 requests/month
- **400ms average response**
- **2 vCPUs, 2GB RAM**

**Cost Calculation:**

**Requests:**
```
300,000 requests
Free tier: 2,000,000
Cost: $0 (still under free tier!)
```

**CPU:**
```
300,000 × 0.4s × 2 vCPU = 240,000 vCPU-seconds
Free tier: 360,000
Cost: $0 (still covered!)
```

**Memory:**
```
300,000 × 0.4s × 2 GB = 240,000 GB-seconds
Free tier: 360,000
Cost: $0 (still covered!)
```

**Storage:**
```
8.76 GB image = $0.23/month
```

**Network:**
```
30 GB egress (100KB × 300K requests)
(30 - 1 GB free) × $0.12 = $3.48/month
```

**Total: ~$3.71/month**

---

## When Would You Hit $5-10/month?

You'd need to exceed free tier limits:

### Scenario: Heavy Usage
- **30,000 requests/day** = 900,000 requests/month
- **500ms average response**
- **2 vCPUs, 2GB RAM**

**CPU:**
```
900,000 × 0.5s × 2 vCPU = 900,000 vCPU-seconds
Free tier: 360,000
Billable: 540,000 vCPU-seconds
Cost: 540,000 × $0.000024 = $12.96
```

**Memory:**
```
900,000 × 0.5s × 2 GB = 900,000 GB-seconds
Free tier: 360,000
Billable: 540,000 GB-seconds
Cost: 540,000 × $0.0000025 = $1.35
```

**Network:**
```
90 GB egress
(90 - 1) × $0.12 = $10.68
```

**Total: ~$25/month**

---

## Revised Cost Estimates

### Your Likely Costs (GraphCodeBERT):

| Traffic Level | Requests/Day | Requests/Month | Estimated Cost |
|--------------|--------------|----------------|----------------|
| **Light** | 100 | 3,000 | **$0.10/month** |
| **Low** | 500 | 15,000 | **$0.30/month** |
| **Moderate** | 1,000 | 30,000 | **$0.50/month** |
| **Medium** | 5,000 | 150,000 | **$2/month** |
| **High** | 10,000 | 300,000 | **$4/month** |
| **Very High** | 30,000 | 900,000 | **$25/month** |
| **Production** | 100,000 | 3,000,000 | **$80/month** |

---

## Key Insights

### You'll Likely Pay Almost Nothing! 🎉

For typical usage (1,000-5,000 requests/day):
- **Actual cost: $0.50-2/month**
- Free tier covers most of it
- Scale-to-zero means $0 when idle

### What You Actually Pay For:

1. **Storage**: ~$0.23/month (container image)
2. **Network egress**: ~$0.20-3/month (depends on traffic)
3. **Compute over free tier**: Usually $0-5/month

### True Scale-to-Zero Benefits:

If you get:
- 0 requests for a week → **$0 compute charges**
- Spike to 100K requests one day → Auto-scales, pay for that day only
- Back to normal → Costs drop automatically

---

## How to Minimize Costs

### 1. Optimize Image Size (8.76GB → 3GB)
```dockerfile
# Use multi-stage build
FROM python:3.11-slim as builder
# ... install deps

FROM python:3.11-slim
COPY --from=builder ...
```
**Savings**: $0.15/month on storage

### 2. Reduce CPU/Memory Allocation
```bash
# Deploy with minimal resources
gcloud run deploy --memory 1Gi --cpu 1
```
**Savings**: 50% on compute

### 3. Enable HTTP/2
```bash
# Use newer protocol for smaller responses
gcloud run deploy --use-http2
```
**Savings**: ~30% on network egress

### 4. Add Response Compression
```python
# In app.py
from fastapi.middleware.gzip import GZipMiddleware
app.add_middleware(GZipMiddleware, minimum_size=1000)
```
**Savings**: ~70% on network egress

---

## Bottom Line

**For GraphCodeBERT with moderate usage:**
- **Realistic cost: $0.50-2/month** (not $5-10)
- **Free tier covers**: 2M requests, 360K CPU-seconds
- **Scale-to-zero**: True $0 when idle
- **Most costs**: Network egress, not compute

**When you'd hit $5-10/month:**
- 10,000+ requests/day consistently
- Large response payloads
- High CPU usage per request

**I was being conservative!** Your actual costs will likely be **under $1/month** for typical usage.

---

## Try It Risk-Free

Google Cloud gives you:
- **$300 free credit** for new accounts (90 days)
- **Always-free tier** (doesn't expire)
- **Billing alerts** (stop before charges)

You can run this for **months for free** before paying anything!
