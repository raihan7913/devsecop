# 📊 Grafana Monitoring Setup - Sinfomik

Panduan setup monitoring Sinfomik dengan **Grafana + Prometheus + cAdvisor**.

## 🚀 Quick Start

### 1️⃣ Stop Container Lama (jika running)

```powershell
docker-compose down
```

### 2️⃣ Start dengan Monitoring

```powershell
docker-compose -f docker-compose.monitoring.yml up -d
```

### 3️⃣ Initialize Database

```powershell
docker exec -it sinfomik-app node src/init_db.js
```

### 4️⃣ Access Services

| Service | URL | Credentials |
|---------|-----|-------------|
| **Sinfomik App** | http://localhost:5000 | admin / admin123 |
| **Grafana** | http://localhost:3001 | admin / admin123 |
| **Prometheus** | http://localhost:9090 | - |
| **cAdvisor** | http://localhost:8080 | - |

## 📊 Grafana Dashboard

### First Login

1. Open **http://localhost:3001**
2. Login:
   - Username: `admin`
   - Password: `admin123`
3. Dashboard sudah auto-configured! ✅

### View Metrics

1. Go to **Dashboards** → **Browse**
2. Select **"Sinfomik - Docker Monitoring"**
3. Lihat real-time metrics:
   - 📈 CPU Usage
   - 💾 Memory Usage
   - 🌐 Network Traffic
   - 💽 Disk I/O
   - ✅ Container Status

### Create Custom Dashboard

1. Click **+ Create** → **Dashboard**
2. Add Panel → Select metric
3. Query examples:

```promql
# CPU Usage (%)
rate(container_cpu_usage_seconds_total{name="sinfomik-app"}[5m]) * 100

# Memory Usage (MB)
container_memory_usage_bytes{name="sinfomik-app"} / 1024 / 1024

# Memory Usage (%)
(container_memory_usage_bytes{name="sinfomik-app"} / container_spec_memory_limit_bytes{name="sinfomik-app"}) * 100

# Network RX (bytes/sec)
rate(container_network_receive_bytes_total{name="sinfomik-app"}[5m])

# Network TX (bytes/sec)
rate(container_network_transmit_bytes_total{name="sinfomik-app"}[5m])

# Disk Read (bytes/sec)
rate(container_fs_reads_bytes_total{name="sinfomik-app"}[5m])

# Disk Write (bytes/sec)
rate(container_fs_writes_bytes_total{name="sinfomik-app"}[5m])

# Container Up/Down
container_last_seen{name="sinfomik-app"}
```

## 🔔 Setup Alerts

### 1. Create Alert in Grafana

1. Edit Panel → Alert tab
2. Create Alert Rule
3. Example: CPU > 80%

```promql
rate(container_cpu_usage_seconds_total{name="sinfomik-app"}[5m]) * 100 > 80
```

### 2. Configure Notification Channel

1. **Alerting** → **Notification channels**
2. **Add channel**
3. Choose type:
   - Email
   - Slack
   - Discord
   - Webhook
   - etc.

### 3. Example Alert Rules

**High CPU Usage:**
```yaml
alert: HighCPUUsage
expr: rate(container_cpu_usage_seconds_total{name="sinfomik-app"}[5m]) * 100 > 80
for: 5m
annotations:
  summary: "High CPU usage on Sinfomik"
  description: "CPU usage is above 80% for 5 minutes"
```

**High Memory Usage:**
```yaml
alert: HighMemoryUsage
expr: (container_memory_usage_bytes{name="sinfomik-app"} / container_spec_memory_limit_bytes{name="sinfomik-app"}) * 100 > 80
for: 5m
annotations:
  summary: "High memory usage on Sinfomik"
  description: "Memory usage is above 80%"
```

**Container Down:**
```yaml
alert: ContainerDown
expr: up{job="sinfomik-app"} == 0
for: 1m
annotations:
  summary: "Sinfomik container is down"
  description: "Container has been down for 1 minute"
```

## 📈 Monitoring Best Practices

### 1. Key Metrics to Monitor

✅ **CPU Usage** - Should be < 70% average
✅ **Memory Usage** - Should be < 80% of limit
✅ **Response Time** - Should be < 500ms
✅ **Error Rate** - Should be < 1%
✅ **Disk Space** - Should have > 20% free

### 2. Set Retention Policies

Edit `prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

storage:
  tsdb:
    retention.time: 30d  # Keep data for 30 days
    retention.size: 10GB  # Max 10GB storage
```

### 3. Performance Tuning

**Reduce scrape interval for high-traffic:**

```yaml
scrape_configs:
  - job_name: 'sinfomik-app'
    scrape_interval: 10s  # More frequent
```

**Optimize Grafana queries:**
- Use appropriate time ranges
- Limit data points
- Use downsampling for long periods

## 🔧 Advanced Configuration

### Custom Metrics Export

Add to `backend/src/server.js`:

```javascript
const promClient = require('prom-client');

// Create metrics
const register = new promClient.Registry();
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

register.registerMetric(httpRequestDuration);

// Expose metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

Then add to `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'sinfomik-metrics'
    static_configs:
      - targets: ['sinfomik:5000']
    metrics_path: '/metrics'
```

### Loki for Log Aggregation (Optional)

Add to `docker-compose.monitoring.yml`:

```yaml
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - loki-data:/loki
    networks:
      - sinfomik-network

  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    networks:
      - sinfomik-network
```

## 🎯 Common Monitoring Tasks

### View Container Logs in Grafana

1. Add Loki data source
2. Use LogQL queries:

```logql
{container_name="sinfomik-app"} |= "error"
{container_name="sinfomik-app"} |= "warning"
```

### Export Dashboard

1. Dashboard Settings → JSON Model
2. Copy JSON
3. Save to file
4. Share or backup

### Import Dashboard

1. **+ Create** → **Import**
2. Paste JSON or upload file
3. Select Prometheus data source
4. Click **Import**

### Popular Pre-built Dashboards

Import from Grafana.com:

- **Docker Container & Host Metrics**: ID `10619`
- **Node Exporter Full**: ID `1860`
- **cAdvisor**: ID `14282`

**Import steps:**
1. **+ Create** → **Import**
2. Enter Dashboard ID
3. Click **Load**
4. Select data source
5. Import

## 📱 Mobile Access

**Grafana Mobile App:**
1. Download dari App Store/Play Store
2. Add server: `http://your-ip:3001`
3. Login dengan credentials
4. View dashboards on mobile

## 🛠️ Troubleshooting

### Grafana Can't Connect to Prometheus

```powershell
# Check network
docker network inspect sinfomik_sinfomik-network

# Check Prometheus
curl http://localhost:9090/-/healthy

# Restart services
docker-compose -f docker-compose.monitoring.yml restart
```

### No Data in Grafana

1. Check Prometheus targets: http://localhost:9090/targets
2. All should be **UP** (green)
3. If DOWN, check container connectivity

### High Resource Usage

```powershell
# Check stats
docker stats

# Reduce scrape interval in prometheus.yml
# Reduce retention period
```

## 📊 Monitoring Commands

```powershell
# View all services
docker-compose -f docker-compose.monitoring.yml ps

# View logs
docker-compose -f docker-compose.monitoring.yml logs -f grafana
docker-compose -f docker-compose.monitoring.yml logs -f prometheus

# Restart monitoring stack
docker-compose -f docker-compose.monitoring.yml restart

# Stop monitoring
docker-compose -f docker-compose.monitoring.yml down

# Stop & remove data
docker-compose -f docker-compose.monitoring.yml down -v
```

## 🎨 Dashboard Screenshots & Templates

Check folder: `monitoring/grafana/dashboards/` for templates

---

## 🚀 Quick Access URLs

After running `docker-compose -f docker-compose.monitoring.yml up -d`:

| Service | URL |
|---------|-----|
| 📊 Grafana Dashboard | http://localhost:3001 |
| 🔍 Prometheus | http://localhost:9090 |
| 📈 cAdvisor | http://localhost:8080 |
| 🖥️ Node Exporter | http://localhost:9100 |
| 🎓 Sinfomik App | http://localhost:5000 |

**Default Grafana Login:** admin / admin123

Happy Monitoring! 📊✨
