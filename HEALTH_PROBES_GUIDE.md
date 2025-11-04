# Health Probes & Cold Starts - Quick Reference

## ⏱️ Idle Timeouts & Cold Starts

| Provider | Idle Before Cold | Cold Start Time | Keep-Warm Cost |
|----------|------------------|-----------------|----------------|
| **Google Cloud Run** | 15 min (configurable) | ~2-3 seconds | $3-5/month (min-instances=1) |
| **Azure Container Apps** | 2-5 min (not configurable) | ~2-4 seconds | $3-5/month (min-replicas=1) |

### Key Differences:

**Google Cloud Run:**
- More forgiving: 15 min idle timeout
- Can configure up to 60 min with min-instances=0
- Longer grace period before cold start

**Azure Container Apps:**
- More aggressive: 2-5 min idle timeout
- Cannot configure on free tier
- Faster scale-down (saves costs but more cold starts)

---

## 🏥 Health Probes & Free Tier

### Free Tier Limits (Monthly):

| Provider | Free Requests | Free CPU-Seconds | Free Memory-Seconds |
|----------|--------------|------------------|---------------------|
| **Google Cloud Run** | 2,000,000 | 360,000 | 360,000 GiB-sec |
| **Azure Container Apps** | 2,000,000 | 180,000 | 360,000 GiB-sec |

### Health Probe Behavior:

**Google Cloud Run:**
- ✅ Built-in health checks: FREE (don't count)
- ⚠️ Custom `/health` endpoint calls: **DO COUNT** as requests
- ✅ External probes (UptimeRobot, etc.): Count toward 2M free tier

**Azure Container Apps:**
- ✅ Built-in liveness/readiness probes: FREE (don't count)
- ⚠️ Custom `/health` endpoint calls: **DO COUNT** as requests
- ✅ External probes: Count toward 2M free tier

---

## 🔢 Math: Can You Probe for Free?

### Scenario: Probe every 5 minutes

**Monthly requests:**
```
60 min/hour ÷ 5 min/probe = 12 probes/hour
12 probes/hour × 24 hours = 288 probes/day
288 probes/day × 30 days = 8,640 probes/month
```

**Free tier usage:**
```
8,640 probes / 2,000,000 free requests = 0.4%
```

**Verdict: ✅ YES! Plenty of room**

You can probe every 5 minutes and still have **1,991,360 requests left** for actual traffic!

---

## 📊 Probe Frequency Options

| Probe Interval | Monthly Probes | % of Free Tier | Requests Left |
|----------------|----------------|----------------|---------------|
| **1 minute** | 43,200 | 2.2% | 1,956,800 |
| **5 minutes** | 8,640 | 0.4% | 1,991,360 |
| **10 minutes** | 4,320 | 0.2% | 1,995,680 |
| **15 minutes** | 2,880 | 0.1% | 1,997,120 |

**Recommendation: 5-10 minutes** balances warm containers with free tier usage.

---

## 🎯 Keep-Warm Strategies

### Strategy 1: Accept Cold Starts (Free)
```
Cost: $0/month
Cold start: 2-4 seconds (occasionally)
Best for: Experimentation, low-traffic
```

### Strategy 2: External Probes (Free)
```
Cost: $0/month
Probe every 5 min: Uses 0.4% of free tier
Cold start: Rare (only if probe fails)
Best for: Regular use, acceptable 5min gaps
```

### Strategy 3: Minimum Instances ($)
```
Cost: $3-5/month
Cold start: Never
Best for: Production, must be fast
```

**Google Cloud Run:**
```bash
gcloud run deploy --min-instances 1
```

**Azure Container Apps:**
```bash
az containerapp update --min-replicas 1
```

---

## 🆓 Free Probe Solutions

### Option A: UptimeRobot (Recommended)
- **Free tier:** 50 monitors, 5-min interval
- **Setup:** 2 minutes
- **URL:** https://uptimerobot.com/
- **Steps:**
  1. Sign up (free)
  2. Add monitor: HTTP(s)
  3. Set URL: `https://your-service/health`
  4. Set interval: 5 minutes
  5. Done!

### Option B: Google Cloud Scheduler
```bash
# Free tier: 3 jobs/month
gcloud scheduler jobs create http keep-warm \
  --schedule="*/5 * * * *" \
  --uri="https://your-service/health" \
  --http-method=GET
```

### Option C: Cron Job (Linux/Mac/WSL)
```bash
# Add to crontab: crontab -e
*/5 * * * * curl -s https://your-service/health > /dev/null 2>&1
```

### Option D: GitHub Actions (Free)
```yaml
# .github/workflows/keep-warm.yml
name: Keep Warm
on:
  schedule:
    - cron: '*/5 * * * *'  # Every 5 minutes
jobs:
  ping:
    runs-on: ubuntu-latest
    steps:
      - name: Ping health endpoint
        run: curl -s https://your-service/health
```

---

## 💡 Smart Probe Strategy

### Business Hours Only (Save Even More)

**UptimeRobot Advanced:**
```
Monitor: Active 6AM-10PM (16 hours)
Interval: 5 minutes
Monthly probes: 5,760 (0.29% of free tier)
```

**Google Cloud Scheduler:**
```bash
# Only run 6AM-10PM Mon-Fri
gcloud scheduler jobs create http keep-warm-business \
  --schedule="*/5 6-22 * * 1-5" \
  --uri="https://your-service/health"
```

**Benefit:**
- Warm during work hours
- Accept cold starts at night/weekends
- Uses even less of free tier

---

## 📈 Real Cost Examples

### Example 1: Experimentation (No Probes)
```
Traffic: 100 requests/day
Probes: None
Cold starts: Most requests
Cost: $0/month
```

### Example 2: Development (5-min Probes)
```
Traffic: 500 requests/day = 15K/month
Probes: 8,640/month
Total: 23,640 requests/month
Cost: $0/month (well under 2M free tier)
Cold starts: Rare
```

### Example 3: Production (1-min Probes + Traffic)
```
Traffic: 10,000 requests/day = 300K/month
Probes: 43,200/month (1-min interval)
Total: 343,200 requests/month
Cost: $0/month (still under 2M free tier!)
Cold starts: Never
```

### Example 4: Heavy Production (Min Instances)
```
Traffic: 50,000 requests/day = 1.5M/month
Min instances: 1 (always on)
Probes: Not needed (always warm)
Cost: $3-5/month (min instance) + compute over free tier
Cold starts: Never
```

---

## 🔍 Monitoring Cold Starts

### Google Cloud Run:
```bash
# View logs for cold starts
gcloud run services logs read graphcodebert --limit 100 | grep "cold start"
```

### Azure Container Apps:
```bash
# View replica scale events
az containerapp logs show \
  --name graphcodebert \
  --resource-group graphcodebert-rg \
  | grep -i "scale"
```

---

## ✅ Recommendations

### For Experimentation:
- ✅ **No probes** - accept occasional cold starts
- ✅ **Cost:** $0/month
- ✅ **Cold starts:** 2-4 seconds occasionally

### For Development:
- ✅ **5-minute probes** (UptimeRobot free)
- ✅ **Cost:** $0/month
- ✅ **Cold starts:** Rare (only if probe misses)

### For Production (Low Traffic):
- ✅ **5-minute probes** during business hours
- ✅ **Cost:** $0-2/month
- ✅ **Cold starts:** Rare during work hours

### For Production (High Traffic):
- ✅ **Min instances = 1**
- ✅ **Cost:** $3-10/month
- ✅ **Cold starts:** Never

---

## 🎯 Your Specific Questions Answered

**Q: How long idle before cold start?**
- Google: 15 minutes
- Azure: 2-5 minutes

**Q: Do health probes count toward free tier?**
- ✅ Yes, but **only 0.4%** of 2M free tier for 5-min probes
- ✅ Plenty of room for both probes + real traffic

**Q: Can I probe for free?**
- ✅ **Absolutely!** 8,640 probes/month uses <1% of free tier
- ✅ Leave 1,991,360 requests for actual traffic

**Q: Best strategy?**
- Experimentation: No probes ($0, occasional cold starts)
- Development: 5-min probes ($0, rare cold starts)
- Production: Min instances ($3-5/month, zero cold starts)
