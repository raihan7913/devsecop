# 🎯 Deployment Configuration

Dokumentasi konfigurasi untuk deployment Sinfomik ke berbagai platform.

## 📋 Overview

Aplikasi ini menggunakan arsitektur **Monolithic** dimana:
- Backend (Express.js) serve API di `/api/*`
- Backend juga serve static files React (Production build)
- Database: SQLite (file-based)

## 🚂 Railway Deployment

### Konfigurasi

File `railway.json` mengatur build & deploy process:

```json
{
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "cd backend && npm install && cd ../frontend && npm install && npm run build"
  },
  "deploy": {
    "startCommand": "cd backend && node src/server.js",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### Environment Variables (Railway)

Set di Railway Dashboard → Settings → Variables:

```env
NODE_ENV=production
PORT=5000
JWT_SECRET=<generate-random-32-chars>
FRONTEND_URL=https://your-app-name.up.railway.app
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=500
DB_PATH=./academic_dashboard.db
JWT_EXPIRES_IN=24h
```

**Generate JWT_SECRET:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### Deployment Steps

1. **Push ke GitHub:**
   ```bash
   git add .
   git commit -m "Ready for deployment"
   git push origin main
   ```

2. **Deploy di Railway:**
   - Login ke [railway.app](https://railway.app)
   - New Project → Deploy from GitHub
   - Pilih repository `sinfomik`
   - Railway akan auto-deploy

3. **Set Environment Variables** (lihat di atas)

4. **Initialize Database:**
   ```bash
   # Via Railway CLI
   railway run bash
   cd backend
   node src/init_db.js
   exit
   ```

5. **Access App:**
   ```
   https://your-app-name.up.railway.app
   ```

### ⚠️ Important Notes

**SQLite di Railway:**
- Railway menggunakan ephemeral storage
- Database akan reset setiap kali redeploy
- **Solusi:** 
  - Gunakan Railway PostgreSQL plugin
  - Atau external database (MongoDB Atlas, Supabase)
  - Implementasi backup scheduler

**Logs:**
```bash
railway logs
```

## 🐳 Docker Deployment (Optional)

Untuk deploy dengan Docker:

### Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY backend/package*.json ./backend/
COPY frontend/package*.json ./frontend/

# Install dependencies
RUN cd backend && npm ci --only=production
RUN cd frontend && npm ci --only=production && npm run build

# Copy application code
COPY backend/ ./backend/
COPY frontend/build/ ./frontend/build/

# Expose port
EXPOSE 5000

# Start command
CMD ["node", "backend/src/server.js"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - PORT=5000
      - JWT_SECRET=${JWT_SECRET}
      - FRONTEND_URL=http://localhost:5000
    volumes:
      - ./data:/app/backend/data
    restart: unless-stopped
```

### Run Docker

```bash
# Build image
docker build -t sinfomik .

# Run container
docker run -p 5000:5000 \
  -e JWT_SECRET=your-secret \
  -v $(pwd)/data:/app/backend/data \
  sinfomik
```

## ☁️ Vercel Deployment (Alternative)

**Note:** Vercel bagus untuk frontend, tapi ada limitasi untuk backend Express.js

### Setup

1. **Install Vercel CLI:**
   ```bash
   npm install -g vercel
   ```

2. **Create vercel.json:**
   ```json
   {
     "version": 2,
     "builds": [
       {
         "src": "backend/src/server.js",
         "use": "@vercel/node"
       },
       {
         "src": "frontend/package.json",
         "use": "@vercel/static-build",
         "config": {
           "distDir": "build"
         }
       }
     ],
     "routes": [
       {
         "src": "/api/(.*)",
         "dest": "backend/src/server.js"
       },
       {
         "src": "/(.*)",
         "dest": "frontend/build/$1"
       }
     ]
   }
   ```

3. **Deploy:**
   ```bash
   vercel --prod
   ```

## 🌍 Render Deployment (Alternative)

### Setup

1. Create `render.yaml`:
   ```yaml
   services:
     - type: web
       name: sinfomik
       env: node
       buildCommand: |
         cd backend && npm install
         cd ../frontend && npm install && npm run build
       startCommand: cd backend && node src/server.js
       envVars:
         - key: NODE_ENV
           value: production
         - key: JWT_SECRET
           generateValue: true
         - key: PORT
           value: 5000
   ```

2. Connect to GitHub dan deploy

## 🔐 Security Checklist

### Before Deploy:

- [ ] JWT_SECRET menggunakan random 32+ characters
- [ ] `.env` files tidak di-commit ke Git (sudah di .gitignore)
- [ ] CORS configured dengan domain yang benar
- [ ] Rate limiting enabled
- [ ] Helmet middleware enabled
- [ ] Database backup strategy (jika production)

### After Deploy:

- [ ] Test semua endpoint
- [ ] Verifikasi authentication works
- [ ] Check logs untuk errors
- [ ] Test file upload functionality
- [ ] Verify CORS tidak block requests
- [ ] Monitor resource usage

## 📊 Monitoring

### Health Check

Endpoint untuk monitoring:
```
GET /health
```

Response:
```json
{
  "status": "healthy",
  "database": "connected",
  "uptime": 3600,
  "timestamp": "2025-11-18T10:00:00.000Z"
}
```

### Railway Monitoring

```bash
# View logs
railway logs

# Check service status
railway status

# Open dashboard
railway open
```

## 🔄 Update/Redeploy

### Railway Auto-Deploy

Railway akan otomatis redeploy saat ada push ke GitHub:

```bash
git add .
git commit -m "Update feature"
git push origin main
# Railway auto-deploy
```

### Manual Deploy

```bash
railway up
```

### Rollback

Via Railway Dashboard:
- Deployments → Select previous deployment → Rollback

## 💾 Database Migration

Jika menggunakan database baru atau perlu migrasi:

```bash
# Backup database lama
railway run bash
cd backend
cp academic_dashboard.db academic_dashboard.db.backup
exit

# Run migration script
railway run node backend/src/migrate.js
```

## 📈 Scaling

### Railway

Railway auto-scale berdasarkan traffic. Untuk custom scaling:
- Dashboard → Settings → Resources
- Adjust CPU/Memory

### Load Balancing

Untuk high traffic, consider:
- Multiple Railway services
- External load balancer (Cloudflare)
- CDN untuk static assets

## 🆘 Troubleshooting

### Build Failed

```bash
# Check Railway logs
railway logs --build

# Common issues:
# 1. Missing dependencies → check package.json
# 2. Build command error → check railway.json
# 3. Out of memory → increase Railway resources
```

### Runtime Errors

```bash
# Check runtime logs
railway logs

# Common issues:
# 1. Database connection → check DB_PATH
# 2. Port binding → Railway auto-sets PORT
# 3. CORS errors → check FRONTEND_URL
```

### Database Issues

```bash
# Reset database
railway run bash
cd backend
rm academic_dashboard.db
node src/init_db.js
exit
```

## 📚 Resources

- [Railway Documentation](https://docs.railway.app)
- [Railway CLI Reference](https://docs.railway.app/develop/cli)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Express.js Production Best Practices](https://expressjs.com/en/advanced/best-practice-performance.html)

---

**Deployment Support:** Check [RAILWAY_DEPLOYMENT_GUIDE.md](RAILWAY_DEPLOYMENT_GUIDE.md) for step-by-step guide.
