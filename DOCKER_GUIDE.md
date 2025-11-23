# 🐳 Docker Deployment Guide - Sinfomik

Panduan lengkap deploy aplikasi Sinfomik menggunakan Docker.

## 📋 Prerequisites

- Docker Desktop (Windows/Mac) atau Docker Engine (Linux)
- Docker Compose (biasanya sudah include di Docker Desktop)
- Git (optional)

**Install Docker:**
- Windows/Mac: https://www.docker.com/products/docker-desktop
- Linux: https://docs.docker.com/engine/install/

## 🚀 Quick Start

### 1. Generate JWT Secret

```powershell
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Copy hasilnya, nanti dipakai di step 2.

### 2. Setup Environment

```powershell
# Copy template environment
Copy-Item .env.docker .env

# Edit file .env, ganti JWT_SECRET dengan hasil dari step 1
notepad .env
```

### 3. Build & Run

```powershell
# Build image
docker-compose build

# Run container
docker-compose up -d

# Check status
docker-compose ps
```

### 4. Initialize Database

```powershell
# Access container
docker exec -it sinfomik-app sh

# Initialize database
cd backend
node src/init_db.js
exit
```

### 5. Access Application

Browser: **http://localhost:5000**

Login:
- Admin: `admin` / `admin123`
- Guru: `guru1` / `guru123`
- Siswa: `siswa1` / `siswa123`

## 📦 Docker Commands

### Build & Run

```powershell
# Build image
docker-compose build

# Run in background
docker-compose up -d

# Run in foreground (see logs)
docker-compose up

# Build & run (force rebuild)
docker-compose up --build -d
```

### Container Management

```powershell
# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop container
docker-compose stop

# Start container
docker-compose start

# Restart container
docker-compose restart

# Stop & remove container
docker-compose down

# Stop & remove container + volumes (⚠️ DELETES DATABASE!)
docker-compose down -v
```

### Database Management

```powershell
# Access container shell
docker exec -it sinfomik-app sh

# Initialize database
docker exec -it sinfomik-app node backend/src/init_db.js

# Backup database
docker cp sinfomik-app:/app/backend/data/academic_dashboard.db ./backup.db

# Restore database
docker cp ./backup.db sinfomik-app:/app/backend/data/academic_dashboard.db
docker-compose restart
```

### Logs & Debugging

```powershell
# View all logs
docker-compose logs

# View logs (follow)
docker-compose logs -f

# View last 100 lines
docker-compose logs --tail=100

# View specific service logs
docker-compose logs sinfomik
```

## 🔧 Configuration

### Environment Variables

Edit `docker-compose.yml` atau buat file `.env`:

```env
# Security
JWT_SECRET=your-secret-key-32-chars
JWT_EXPIRES_IN=24h

# Server
NODE_ENV=production
PORT=5000
FRONTEND_URL=http://localhost:5000

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=500

# Database
DB_PATH=/app/backend/data/academic_dashboard.db
```

### Custom Port

Edit `docker-compose.yml`:

```yaml
ports:
  - "8080:5000"  # Host:Container
```

Akses via: http://localhost:8080

### Volume Locations

Data disimpan di Docker volumes:

```powershell
# List volumes
docker volume ls

# Inspect volume
docker volume inspect sinfomik_sinfomik-data

# Backup volume
docker run --rm -v sinfomik_sinfomik-data:/data -v ${PWD}:/backup alpine tar czf /backup/sinfomik-backup.tar.gz -C /data .

# Restore volume
docker run --rm -v sinfomik_sinfomik-data:/data -v ${PWD}:/backup alpine tar xzf /backup/sinfomik-backup.tar.gz -C /data
```

## 🌐 Production Deployment

### 1. Setup Reverse Proxy (Nginx)

**nginx.conf:**

```nginx
server {
    listen 80;
    server_name sinfomik.example.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 2. SSL Certificate (Let's Encrypt)

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d sinfomik.example.com
```

### 3. Docker Production Config

**docker-compose.prod.yml:**

```yaml
version: '3.8'

services:
  sinfomik:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: sinfomik-app
    restart: always
    ports:
      - "127.0.0.1:5000:5000"  # Bind to localhost only
    environment:
      - NODE_ENV=production
      - JWT_SECRET=${JWT_SECRET}
      - FRONTEND_URL=https://sinfomik.example.com
    volumes:
      - /var/lib/sinfomik/data:/app/backend/data
      - /var/lib/sinfomik/uploads:/app/backend/uploads
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

Run:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

## 📊 Monitoring

### Health Check

```powershell
# Via curl
curl http://localhost:5000/health

# Via PowerShell
Invoke-WebRequest http://localhost:5000/health

# Check container health
docker inspect sinfomik-app --format='{{.State.Health.Status}}'
```

### Resource Usage

```powershell
# Container stats
docker stats sinfomik-app

# Detailed info
docker inspect sinfomik-app
```

## 🔄 Update & Maintenance

### Update Application

```powershell
# Pull latest code
git pull origin main

# Rebuild & restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Database Migration

```powershell
# Backup current database
docker cp sinfomik-app:/app/backend/data/academic_dashboard.db ./backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').db

# Run migration
docker exec -it sinfomik-app node backend/src/migrate.js
```

### Clean Up

```powershell
# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Clean everything
docker system prune -a --volumes
```

## 🐛 Troubleshooting

### Container Won't Start

```powershell
# Check logs
docker-compose logs

# Check if port is in use
netstat -ano | findstr :5000

# Remove and recreate
docker-compose down
docker-compose up -d
```

### Database Issues

```powershell
# Reset database
docker exec -it sinfomik-app sh
cd backend
rm data/academic_dashboard.db
node src/init_db.js
exit
docker-compose restart
```

### Permission Issues (Linux)

```bash
# Fix volume permissions
sudo chown -R 1000:1000 /var/lib/sinfomik
```

### Out of Memory

Edit `docker-compose.yml`:

```yaml
services:
  sinfomik:
    deploy:
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
```

## 📚 Advanced

### Multi-Container Setup (with PostgreSQL)

**docker-compose.postgres.yml:**

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: sinfomik-db
    restart: always
    environment:
      POSTGRES_DB: sinfomik
      POSTGRES_USER: sinfomik
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - sinfomik-network

  sinfomik:
    build: .
    container_name: sinfomik-app
    restart: always
    depends_on:
      - postgres
    environment:
      - DATABASE_URL=postgresql://sinfomik:${DB_PASSWORD}@postgres:5432/sinfomik
    networks:
      - sinfomik-network

volumes:
  postgres-data:

networks:
  sinfomik-network:
```

### Docker Swarm (Clustering)

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml sinfomik

# Scale service
docker service scale sinfomik_sinfomik=3

# List services
docker stack services sinfomik
```

## 📝 Best Practices

1. **Security:**
   - ✅ Always use strong JWT_SECRET
   - ✅ Don't commit .env to Git
   - ✅ Use HTTPS in production
   - ✅ Limit container resources

2. **Backup:**
   - ✅ Regular database backups
   - ✅ Backup before updates
   - ✅ Test restore procedure

3. **Monitoring:**
   - ✅ Check logs regularly
   - ✅ Monitor resource usage
   - ✅ Setup health checks

4. **Updates:**
   - ✅ Test in staging first
   - ✅ Backup before update
   - ✅ Use semantic versioning

## 🆘 Support

- **Issues:** Check logs first (`docker-compose logs`)
- **Performance:** Monitor with `docker stats`
- **Database:** Backup regularly
- **Updates:** Follow changelog

---

**Quick Reference Card:**

```powershell
# Build & Run
docker-compose up -d

# Initialize DB
docker exec -it sinfomik-app node backend/src/init_db.js

# View Logs
docker-compose logs -f

# Stop
docker-compose down

# Backup DB
docker cp sinfomik-app:/app/backend/data/academic_dashboard.db ./backup.db

# Access: http://localhost:5000
```

**Created:** November 18, 2025
