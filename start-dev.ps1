# ========================================
# Quick Start Script untuk Development
# ========================================
# Script ini akan menjalankan backend & frontend
# dalam 2 terminal terpisah
# ========================================

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "   STARTING SINFOMIK DEV MODE" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Get current directory
$rootDir = Get-Location

# Start Backend
Write-Host "Starting Backend Server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$rootDir\backend'; Write-Host 'BACKEND SERVER' -ForegroundColor Green; npm run dev"

# Wait a bit
Start-Sleep -Seconds 2

# Start Frontend
Write-Host "Starting Frontend Server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$rootDir\frontend'; Write-Host 'FRONTEND SERVER' -ForegroundColor Blue; npm start"

Write-Host ""
Write-Host "=================================" -ForegroundColor Green
Write-Host "  SERVERS STARTED!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""
Write-Host "Backend : http://localhost:5000" -ForegroundColor White
Write-Host "Frontend: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "Untuk stop server, tutup terminal yang muncul" -ForegroundColor Yellow
Write-Host ""
