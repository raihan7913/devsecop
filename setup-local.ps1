# ========================================
# Setup Script untuk Sinfomik (Local Dev)
# ========================================
# Script ini akan:
# 1. Install dependencies backend & frontend
# 2. Initialize database
# 3. Menjalankan aplikasi
# ========================================

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "   SINFOMIK - LOCAL SETUP" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Cek apakah Node.js terinstall
Write-Host "[1/5] Checking Node.js..." -ForegroundColor Yellow
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js tidak ditemukan!" -ForegroundColor Red
    Write-Host "Silakan install Node.js dari https://nodejs.org/" -ForegroundColor Red
    exit 1
}

$nodeVersion = node --version
Write-Host "  ✓ Node.js $nodeVersion terdeteksi" -ForegroundColor Green
Write-Host ""

# Install Backend Dependencies
Write-Host "[2/5] Installing backend dependencies..." -ForegroundColor Yellow
Set-Location backend
if (Test-Path "package.json") {
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Gagal install backend dependencies" -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✓ Backend dependencies installed" -ForegroundColor Green
} else {
    Write-Host "ERROR: backend/package.json tidak ditemukan!" -ForegroundColor Red
    exit 1
}
Set-Location ..
Write-Host ""

# Install Frontend Dependencies
Write-Host "[3/5] Installing frontend dependencies..." -ForegroundColor Yellow
Set-Location frontend
if (Test-Path "package.json") {
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Gagal install frontend dependencies" -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✓ Frontend dependencies installed" -ForegroundColor Green
} else {
    Write-Host "ERROR: frontend/package.json tidak ditemukan!" -ForegroundColor Red
    exit 1
}
Set-Location ..
Write-Host ""

# Check .env files
Write-Host "[4/5] Checking environment files..." -ForegroundColor Yellow
$envOK = $true

if (!(Test-Path "backend/.env")) {
    Write-Host "  ! backend/.env tidak ditemukan, menggunakan default" -ForegroundColor Yellow
    Write-Host "    File sudah ada seharusnya, silakan cek manual" -ForegroundColor Yellow
    $envOK = $false
}

if (!(Test-Path "frontend/.env")) {
    Write-Host "  ! frontend/.env tidak ditemukan, menggunakan default" -ForegroundColor Yellow
    Write-Host "    File sudah ada seharusnya, silakan cek manual" -ForegroundColor Yellow
    $envOK = $false
}

if ($envOK) {
    Write-Host "  ✓ Environment files OK" -ForegroundColor Green
}
Write-Host ""

# Initialize Database
Write-Host "[5/5] Initializing database..." -ForegroundColor Yellow
Set-Location backend
node src/init_db.js
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Gagal initialize database" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "  ✓ Database initialized" -ForegroundColor Green
Set-Location ..
Write-Host ""

# Success
Write-Host "=================================" -ForegroundColor Green
Write-Host "   SETUP COMPLETED!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""
Write-Host "Untuk menjalankan aplikasi:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Backend (Terminal 1):" -ForegroundColor Yellow
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "2. Frontend (Terminal 2):" -ForegroundColor Yellow
Write-Host "   cd frontend" -ForegroundColor White
Write-Host "   npm start" -ForegroundColor White
Write-Host ""
Write-Host "Atau gunakan script quick-start:" -ForegroundColor Cyan
Write-Host "   .\start-dev.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Login Credentials:" -ForegroundColor Cyan
Write-Host "  Admin   : admin / admin123" -ForegroundColor White
Write-Host "  Guru    : guru1 / guru123" -ForegroundColor White
Write-Host "  Siswa   : siswa1 / siswa123" -ForegroundColor White
Write-Host ""
Write-Host "URLs:" -ForegroundColor Cyan
Write-Host "  Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "  Backend : http://localhost:5000" -ForegroundColor White
Write-Host ""
