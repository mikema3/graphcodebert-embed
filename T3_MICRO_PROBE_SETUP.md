# Setup Health Probes from AWS t3.micro

## On Your t3.micro EC2 Instance

### Step 1: Upload the Script

```bash
# From your Windows machine (PowerShell)
# Replace YOUR_T3_IP with your EC2 instance IP
scp health-probe.sh ec2-user@YOUR_T3_IP:~/health-probe.sh

# Or copy-paste the content directly
ssh ec2-user@YOUR_T3_IP
nano ~/health-probe.sh
# Paste content, save (Ctrl+O, Ctrl+X)
```

### Step 2: Update URLs in Script

```bash
# Edit the script
nano ~/health-probe.sh

# Update these lines with your actual URLs:
GOOGLE_CLOUD_RUN_URL="https://your-actual-google-url"
AZURE_CONTAINER_APP_URL="https://your-actual-azure-url"
```

### Step 3: Make Executable

```bash
chmod +x ~/health-probe.sh
```

### Step 4: Test Manually

```bash
# Run once to test
~/health-probe.sh
```

Expected output:
```
[Mon Nov  4 10:00:00 UTC 2025] Probing Google Cloud Run...
[Mon Nov  4 10:00:00 UTC 2025] ✓ Google Cloud Run is healthy
[Mon Nov  4 10:00:00 UTC 2025] Probing Azure Container Apps...
[Mon Nov  4 10:00:00 UTC 2025] ✓ Azure Container Apps is healthy
```

### Step 5: Add to Crontab

```bash
# Edit crontab
crontab -e

# Add this line (probe every 5 minutes)
*/5 * * * * /home/ec2-user/health-probe.sh >> /home/ec2-user/probe.log 2>&1

# Save and exit (press ESC, then :wq in vim)
```

### Step 6: Verify Cron Job

```bash
# List cron jobs
crontab -l

# Wait 5 minutes, then check log
tail -f ~/probe.log
```

---

## Alternative Probe Frequencies

### Every 5 minutes (Recommended):
```bash
*/5 * * * * /home/ec2-user/health-probe.sh >> /home/ec2-user/probe.log 2>&1
```
- **Requests/month:** 8,640
- **% of free tier:** 0.4%

### Every 10 minutes (More conservative):
```bash
*/10 * * * * /home/ec2-user/health-probe.sh >> /home/ec2-user/probe.log 2>&1
```
- **Requests/month:** 4,320
- **% of free tier:** 0.2%

### Every 3 minutes (More aggressive):
```bash
*/3 * * * * /home/ec2-user/health-probe.sh >> /home/ec2-user/probe.log 2>&1
```
- **Requests/month:** 14,400
- **% of free tier:** 0.7%

### Business hours only (9AM-6PM, Mon-Fri):
```bash
*/5 9-18 * * 1-5 /home/ec2-user/health-probe.sh >> /home/ec2-user/probe.log 2>&1
```
- **Requests/month:** ~2,640
- **% of free tier:** 0.1%
- **Benefit:** Warm during work hours, save free tier for after hours

---

## Monitoring

### View real-time logs:
```bash
tail -f ~/probe.log
```

### View last 50 probes:
```bash
tail -50 ~/probe.log
```

### Check cron is running:
```bash
# View cron service status
sudo systemctl status crond

# View recent cron activity
grep CRON /var/log/syslog
```

### Clear old logs (optional):
```bash
# Keep only last 1000 lines
tail -1000 ~/probe.log > ~/probe.log.tmp
mv ~/probe.log.tmp ~/probe.log
```

---

## Advanced: Probe with Alerts

If you want to be notified when probes fail:

```bash
#!/bin/bash
# health-probe-with-alerts.sh

GOOGLE_URL="https://your-google-url"
AZURE_URL="https://your-azure-url"
ALERT_EMAIL="your-email@example.com"

check_service() {
    local name=$1
    local url=$2
    
    if ! curl -s -f "${url}/health" > /dev/null; then
        echo "[$(date)] ✗ ${name} is DOWN!" | mail -s "${name} Health Check Failed" $ALERT_EMAIL
    fi
}

check_service "Google Cloud Run" $GOOGLE_URL
check_service "Azure Container Apps" $AZURE_URL
```

---

## Cost Calculation

### Your Setup:
- **t3.micro:** Already paid (reserved instance)
- **Bandwidth:** Negligible (~1KB/probe × 8,640 = 8.6MB/month)
- **Cloud provider requests:** 8,640/month per service
- **Total cost:** **$0** (using existing infrastructure + free tier)

### Comparison vs Alternatives:

| Solution | Cost | Reliability | Control |
|----------|------|-------------|---------|
| **Your t3.micro** | $0 | ✅ High (AWS) | ✅ Full |
| UptimeRobot | $0 | ✅ High | ⚠️ Limited |
| Cloud Scheduler | $0 | ✅ High | ⚠️ Medium |
| Min instances | $3-5/month | ✅ Perfect | ✅ Full |

**Your t3.micro is the best option!** Free + reliable + full control.

---

## Summary

1. ✅ **Internal probes**: Won't keep warm (only health checks)
2. ✅ **External probes**: Will keep warm (counts as traffic)
3. ✅ **Your t3.micro**: Perfect for free external probes
4. ✅ **Cost**: $0 (using existing infrastructure)
5. ✅ **Setup time**: 5 minutes

Your reserved t3.micro instances are ideal for this!
