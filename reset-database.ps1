# ========================================
# Reset Database Script
# ========================================
# Script ini akan menghapus dan membuat ulang
# database dengan data fresh
# ========================================

Write-Host "=================================" -ForegroundColor Red
Write-Host "   RESET DATABASE" -ForegroundColor Red
Write-Host "=================================" -ForegroundColor Red
Write-Host ""
Write-Host "WARNING: Ini akan menghapus SEMUA data!" -ForegroundColor Red
Write-Host ""

$confirmation = Read-Host "Ketik 'YES' untuk melanjutkan"

if ($confirmation -ne "YES") {
    Write-Host "Reset dibatalkan." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Resetting database..." -ForegroundColor Yellow

# Hapus database file
$dbPath = "backend\academic_dashboard.db"
if (Test-Path $dbPath) {
    Remove-Item $dbPath -Force
    Write-Host "  ✓ Old database deleted" -ForegroundColor Green
} else {
    Write-Host "  ! No existing database found" -ForegroundColor Yellow
}

# Hapus file-file terkait SQLite
$dbJournal = "backend\academic_dashboard.db-journal"
$dbWal = "backend\academic_dashboard.db-wal"
$dbShm = "backend\academic_dashboard.db-shm"

if (Test-Path $dbJournal) { Remove-Item $dbJournal -Force }
if (Test-Path $dbWal) { Remove-Item $dbWal -Force }
if (Test-Path $dbShm) { Remove-Item $dbShm -Force }

# Initialize database baru
Write-Host ""
Write-Host "Creating new database..." -ForegroundColor Yellow
Set-Location backend
node src/init_db.js
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Gagal create database" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Set-Location ..

Write-Host ""
Write-Host "=================================" -ForegroundColor Green
Write-Host "  DATABASE RESET COMPLETE!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""
Write-Host "Default credentials:" -ForegroundColor Cyan
Write-Host "  Admin: admin / admin123" -ForegroundColor White
Write-Host "  Guru : guru1 / guru123" -ForegroundColor White
Write-Host "  Siswa: siswa1 / siswa123" -ForegroundColor White
Write-Host ""
