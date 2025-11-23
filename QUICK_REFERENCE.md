# 🚀 Quick Reference - Sinfomik

Panduan cepat untuk command yang sering digunakan.

## 📦 Setup Awal (Pertama Kali)

```powershell
# Run setup script (otomatis install semua)
.\setup-local.ps1
```

**Manual Steps:**
```powershell
# 1. Install dependencies
cd backend
npm install
cd ../frontend
npm install

# 2. Initialize database
cd backend
node src/init_db.js
```

## 🏃 Menjalankan Aplikasi

### Cara Cepat (Recommended)
```powershell
# Start backend & frontend sekaligus (2 terminal otomatis)
.\start-dev.ps1
```

### Manual (2 Terminal Terpisah)

**Terminal 1 - Backend:**
```powershell
cd backend
npm run dev
```

**Terminal 2 - Frontend:**
```powershell
cd frontend
npm start
```

## 🔄 Reset Database

```powershell
# Hapus database dan buat ulang dengan data fresh
.\reset-database.ps1
```

**Manual:**
```powershell
cd backend
Remove-Item academic_dashboard.db
node src/init_db.js
```

## 🌐 URLs

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | React App |
| Backend | http://localhost:5000 | Express API |
| Health Check | http://localhost:5000/health | API Status |

## 🔑 Default Login

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Guru | `guru1` | `guru123` |
| Siswa | `siswa1` | `siswa123` |

## 🛠️ Troubleshooting

### Port Sudah Digunakan

**Problem:** `Port 5000 already in use`

**Solution:**
```powershell
# Cari process yang pakai port
netstat -ano | findstr :5000

# Kill process (ganti <PID> dengan nomor yang muncul)
taskkill /PID <PID> /F
```

### Database Locked

**Problem:** `database is locked`

**Solution:**
```powershell
# Stop semua Node.js process
Get-Process node | Stop-Process -Force

# Reset database
.\reset-database.ps1
```

### Module Not Found

**Problem:** `Cannot find module 'xxx'`

**Solution:**
```powershell
# Reinstall dependencies
cd backend
Remove-Item -Recurse -Force node_modules
npm install

cd ../frontend
Remove-Item -Recurse -Force node_modules
npm install
```

### CORS Error

**Problem:** Browser console shows CORS error

**Solution:**
```powershell
# Cek backend/.env
# Pastikan FRONTEND_URL=http://localhost:3000

# Cek frontend/.env
# Pastikan REACT_APP_API_BASE_URL=http://localhost:5000

# Restart kedua server
```

## 📝 Environment Variables

### Backend (.env)
```env
NODE_ENV=development
PORT=5000
JWT_SECRET=your-secret-key
FRONTEND_URL=http://localhost:3000
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=500
DB_PATH=./academic_dashboard.db
```

### Frontend (.env)
```env
REACT_APP_API_BASE_URL=http://localhost:5000
GENERATE_SOURCEMAP=false
```

## 🔧 Utility Scripts

### Generate Sample Data
```powershell
cd backend
node src/seed_analytics_data.js
```

### Clean Old Classes
```powershell
cd backend
node src/clean_old_classes.js
```

### Debug Student Data
```powershell
cd backend
node debug_student_data.js
```

### Simulate Multi-Year Data
```powershell
cd backend
node src/scripts/simulate_6_years_data.js
```

## 📦 Build untuk Production

### Frontend Build
```powershell
cd frontend
npm run build
# Build output akan ada di frontend/build/
```

### Test Production Build Locally
```powershell
# Install serve
npm install -g serve

# Serve production build
cd frontend
serve -s build -l 3000
```

## 🚂 Deploy ke Railway

### Setup Railway
```powershell
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Link project
railway link

# Deploy
git push origin main
# Railway auto-deploy dari GitHub
```

### Set Environment Variables di Railway

```bash
NODE_ENV=production
PORT=5000
JWT_SECRET=<generate-random-32-chars>
FRONTEND_URL=https://your-app.railway.app
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=500
```

### Initialize Database di Railway
```bash
railway run bash
cd backend
node src/init_db.js
exit
```

## 🔍 Debugging

### Backend Logs
```powershell
# Development mode (auto-reload)
cd backend
npm run dev

# Production mode
cd backend
npm start
```

### Frontend Logs
```powershell
cd frontend
npm start
# Errors akan muncul di terminal dan browser console (F12)
```

### Database Inspection
```powershell
# Install SQLite viewer (VS Code Extension)
# Search: "SQLite" di VS Code Extensions

# Atau gunakan DB Browser for SQLite
# Download: https://sqlitebrowser.org/
```

## 📚 Dokumentasi Lainnya

- [README.md](README.md) - Overview & full documentation
- [LOCAL_SETUP_GUIDE.md](LOCAL_SETUP_GUIDE.md) - Detailed local setup
- [RAILWAY_DEPLOYMENT_GUIDE.md](RAILWAY_DEPLOYMENT_GUIDE.md) - Railway deployment
- [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Pre-deployment checklist

## 💡 Tips

1. **Always commit before deploy:**
   ```powershell
   git add .
   git commit -m "Your message"
   git push origin main
   ```

2. **Keep dependencies updated:**
   ```powershell
   npm outdated  # Check outdated packages
   npm update    # Update packages
   ```

3. **Database backup:**
   ```powershell
   # Backup database
   Copy-Item backend/academic_dashboard.db backend/academic_dashboard.db.backup
   
   # Restore backup
   Copy-Item backend/academic_dashboard.db.backup backend/academic_dashboard.db
   ```

4. **Clear browser cache** jika ada issue setelah update frontend

5. **Use Git branches** untuk feature development:
   ```powershell
   git checkout -b feature/new-feature
   # ... make changes ...
   git push origin feature/new-feature
   # Merge via GitHub PR
   ```

---

**Need more help?** Check [LOCAL_SETUP_GUIDE.md](LOCAL_SETUP_GUIDE.md)
