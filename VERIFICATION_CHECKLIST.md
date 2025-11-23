# ✅ Verification Checklist

Gunakan checklist ini untuk memastikan setup local dan deployment berjalan dengan baik.

## 📦 Local Development Verification

### Prerequisites
- [ ] Node.js terinstall (v16+)
  ```powershell
  node --version
  ```
- [ ] npm terinstall
  ```powershell
  npm --version
  ```

### Files Check
- [ ] File `backend/.env` exists
- [ ] File `frontend/.env` exists
- [ ] File `.gitignore` includes `.env`
- [ ] File `railway.json` exists

### Setup Verification

Run ini di root folder project:

```powershell
# Test setup script (dry run)
.\setup-local.ps1
```

Expected output:
- [ ] ✅ Node.js detected
- [ ] ✅ Backend dependencies installed
- [ ] ✅ Frontend dependencies installed
- [ ] ✅ Environment files OK
- [ ] ✅ Database initialized

### Backend Test

```powershell
cd backend
npm run dev
```

Expected:
- [ ] Server running on port 5000
- [ ] Database connected
- [ ] No errors in console
- [ ] Access http://localhost:5000 shows API info

### Frontend Test

```powershell
cd frontend
npm start
```

Expected:
- [ ] Compilation successful
- [ ] Browser opens to http://localhost:3000
- [ ] Login page displays
- [ ] No console errors (F12)

### Functionality Test

- [ ] Login sebagai Admin (`admin` / `admin123`)
- [ ] Dashboard loads
- [ ] Navigate ke Students menu
- [ ] Navigate ke Teachers menu
- [ ] Logout works

### API Test

```powershell
# Health check
curl http://localhost:5000/health
```

Expected response:
```json
{
  "status": "healthy",
  "database": "connected",
  "uptime": 123,
  "timestamp": "2025-11-18T..."
}
```

## 🚂 Railway Deployment Verification

### Pre-Deployment

- [ ] All code committed to Git
  ```powershell
  git status  # Should show "working tree clean"
  ```
- [ ] Code pushed to GitHub
  ```powershell
  git push origin main
  ```
- [ ] Railway account created
- [ ] Railway project linked to GitHub repo

### Environment Variables (Railway)

Verify di Railway Dashboard → Settings → Variables:

- [ ] `NODE_ENV` = `production`
- [ ] `PORT` = `5000` (or auto-set by Railway)
- [ ] `JWT_SECRET` = (random 32 chars, NOT default!)
- [ ] `FRONTEND_URL` = `https://your-app.railway.app`
- [ ] `RATE_LIMIT_WINDOW_MS` = `900000`
- [ ] `RATE_LIMIT_MAX_REQUESTS` = `500`

### Build Verification

Di Railway Dashboard → Deployments:

- [ ] Build status: Success
- [ ] Build logs tidak ada error
- [ ] Deploy status: Active
- [ ] Service URL accessible

### Database Initialization

```bash
railway run bash
cd backend
node src/init_db.js
exit
```

Expected:
- [ ] Database initialized successfully!
- [ ] Tables created
- [ ] Default admin created
- [ ] Sample data inserted

### Production Test

Access: `https://your-app.railway.app`

- [ ] App loads tanpa error
- [ ] Login page displays
- [ ] Login sebagai Admin works
- [ ] Dashboard displays data
- [ ] API responses working

### API Test (Production)

```powershell
curl https://your-app.railway.app/health
```

Expected:
```json
{
  "status": "healthy",
  "database": "connected",
  "uptime": 123,
  "timestamp": "..."
}
```

## 🔐 Security Verification

### Local Development

- [ ] `.env` files NOT committed to Git
  ```powershell
  git status  # Should not show .env files
  ```
- [ ] CORS allows only localhost
- [ ] Rate limiting configured (but relaxed)

### Production

- [ ] JWT_SECRET is random (NOT default)
  ```powershell
  # Check Railway env vars
  railway variables
  ```
- [ ] CORS configured untuk Railway domain only
- [ ] Rate limiting strict (500 req/15min)
- [ ] HTTPS enabled (Railway auto)

## 🧪 Feature Testing

### Admin Features

- [ ] View students list
- [ ] Add new student
- [ ] Edit student
- [ ] Delete student
- [ ] View teachers list
- [ ] Manage classes
- [ ] Manage subjects
- [ ] View analytics

### Guru Features

- [ ] View assigned classes
- [ ] Input grades
- [ ] View grade summary
- [ ] Export to Excel
- [ ] Dashboard analytics

### Siswa Features

- [ ] View grades
- [ ] View subjects
- [ ] Dashboard raport

## 📊 Performance Check

### Local

- [ ] Backend starts < 5 seconds
- [ ] Frontend builds < 30 seconds
- [ ] Page loads < 2 seconds
- [ ] API responses < 500ms

### Production

- [ ] Railway build < 5 minutes
- [ ] Deploy time < 2 minutes
- [ ] First page load < 3 seconds
- [ ] API responses < 1 second

## 🐛 Common Issues Checklist

### Issue: Port already in use

- [ ] Check port usage:
  ```powershell
  netstat -ano | findstr :5000
  ```
- [ ] Kill process:
  ```powershell
  taskkill /PID <PID> /F
  ```

### Issue: Database locked

- [ ] Stop all Node processes
  ```powershell
  Get-Process node | Stop-Process -Force
  ```
- [ ] Reset database:
  ```powershell
  .\reset-database.ps1
  ```

### Issue: Module not found

- [ ] Reinstall dependencies:
  ```powershell
  cd backend
  Remove-Item -Recurse node_modules
  npm install
  ```

### Issue: CORS error

- [ ] Check `backend/.env`: `FRONTEND_URL=http://localhost:3000`
- [ ] Check `frontend/.env`: `REACT_APP_API_BASE_URL=http://localhost:5000`
- [ ] Restart both servers

### Issue: Railway build failed

- [ ] Check Railway logs
- [ ] Verify `railway.json` exists
- [ ] Check `package.json` scripts
- [ ] Ensure all dependencies in package.json

### Issue: Railway runtime error

- [ ] Check environment variables
- [ ] Verify database initialized
- [ ] Check Railway logs
- [ ] Verify FRONTEND_URL correct

## 📝 Final Verification

### Local Development ✅

- [ ] Backend running on port 5000
- [ ] Frontend running on port 3000
- [ ] Login works
- [ ] All features accessible
- [ ] No console errors
- [ ] Database persists data

### Production Deployment ✅

- [ ] App accessible via Railway URL
- [ ] Login works
- [ ] All features working
- [ ] Data persists
- [ ] No critical errors in logs
- [ ] Performance acceptable

## 🎉 Success Criteria

**Local Development Ready:**
- ✅ Both servers start without errors
- ✅ Can login and navigate all pages
- ✅ Database operations working
- ✅ No console errors

**Production Deployment Ready:**
- ✅ Railway build & deploy successful
- ✅ App accessible via public URL
- ✅ All features working
- ✅ Security configured properly
- ✅ Performance acceptable

---

## 🆘 If Issues Persist

1. **Check Documentation:**
   - [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
   - [LOCAL_SETUP_GUIDE.md](LOCAL_SETUP_GUIDE.md)
   - [DEPLOYMENT_CONFIG.md](DEPLOYMENT_CONFIG.md)

2. **Check Logs:**
   - Local: Terminal output
   - Railway: `railway logs`

3. **Reset Everything:**
   ```powershell
   # Local
   .\reset-database.ps1
   
   # Railway
   railway run bash
   cd backend
   rm academic_dashboard.db
   node src/init_db.js
   ```

4. **Fresh Setup:**
   ```powershell
   # Reinstall dependencies
   cd backend && Remove-Item -Recurse node_modules && npm install
   cd ../frontend && Remove-Item -Recurse node_modules && npm install
   
   # Rerun setup
   .\setup-local.ps1
   ```

---

**Last Updated:** November 18, 2025
