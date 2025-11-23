# OWASP ZAP Security Testing Script
# Test Phase - Automated Security Scanning

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "OWASP ZAP Security Testing" -ForegroundColor Cyan
Write-Host "Test Phase - Security Scanning" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Configuration
$TARGET_URL = "http://host.docker.internal:3000"
$REPORT_DIR = "security-test-reports"

# Create reports directory
if (-not (Test-Path $REPORT_DIR)) {
    New-Item -ItemType Directory -Path $REPORT_DIR | Out-Null
    Write-Host "Created reports directory: $REPORT_DIR" -ForegroundColor Green
}

Write-Host "Step 1: Checking if application is running..." -ForegroundColor Yellow
Write-Host ""

# Check if backend is running
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/api/health" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "SUCCESS: Backend is running on port 5000" -ForegroundColor Green
} catch {
    Write-Host "WARNING: Backend not responding on port 5000" -ForegroundColor Red
    Write-Host "Please start backend first: cd backend; npm start" -ForegroundColor Yellow
    Write-Host ""
}

# Check if frontend is running
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "SUCCESS: Frontend is running on port 3000" -ForegroundColor Green
} catch {
    Write-Host "WARNING: Frontend not responding on port 3000" -ForegroundColor Red
    Write-Host "Please start frontend first: cd frontend; npm start" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 2: Pulling OWASP ZAP Docker image..." -ForegroundColor Yellow
Write-Host ""

docker pull ghcr.io/zaproxy/zaproxy:stable

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 3: Running ZAP Baseline Scan..." -ForegroundColor Yellow
Write-Host "Target: $TARGET_URL" -ForegroundColor Gray
Write-Host "This will take 2-5 minutes..." -ForegroundColor Gray
Write-Host ""

# Run ZAP baseline scan
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = "$REPORT_DIR/zap-baseline-report-$timestamp.html"

docker run --rm `
    -v "${PWD}/${REPORT_DIR}:/zap/wrk:rw" `
    -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py `
    -t $TARGET_URL `
    -r "zap-baseline-report-$timestamp.html" `
    -I

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 4: Running ZAP Full Scan..." -ForegroundColor Yellow
Write-Host "Target: $TARGET_URL" -ForegroundColor Gray
Write-Host "This will take 5-10 minutes..." -ForegroundColor Gray
Write-Host ""

$fullReportFile = "$REPORT_DIR/zap-full-report-$timestamp.html"

docker run --rm `
    -v "${PWD}/${REPORT_DIR}:/zap/wrk:rw" `
    -t ghcr.io/zaproxy/zaproxy:stable zap-full-scan.py `
    -t $TARGET_URL `
    -r "zap-full-report-$timestamp.html" `
    -I

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Summary
Write-Host "Security Testing Complete!" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Reports Generated:" -ForegroundColor Yellow
Write-Host ""

if (Test-Path $reportFile) {
    Write-Host "SUCCESS: Baseline Scan Report" -ForegroundColor Green
    Write-Host "  Location: $reportFile" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "WARNING: Baseline report not found" -ForegroundColor Red
}

if (Test-Path $fullReportFile) {
    Write-Host "SUCCESS: Full Scan Report" -ForegroundColor Green
    Write-Host "  Location: $fullReportFile" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "WARNING: Full scan report not found" -ForegroundColor Red
}

Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Test Coverage:" -ForegroundColor Cyan
Write-Host "  - Cross-Site Scripting (XSS)" -ForegroundColor Gray
Write-Host "  - SQL Injection" -ForegroundColor Gray
Write-Host "  - CSRF (Cross-Site Request Forgery)" -ForegroundColor Gray
Write-Host "  - Security Headers" -ForegroundColor Gray
Write-Host "  - Cookie Security" -ForegroundColor Gray
Write-Host "  - SSL/TLS Configuration" -ForegroundColor Gray
Write-Host "  - Authentication/Authorization" -ForegroundColor Gray
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Open reports in browser to review findings" -ForegroundColor Gray
Write-Host "2. Prioritize and fix high/medium severity issues" -ForegroundColor Gray
Write-Host "3. Re-run scan to verify fixes" -ForegroundColor Gray
Write-Host "4. Include reports in project documentation" -ForegroundColor Gray
Write-Host ""

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "OWASP ZAP Security Testing Completed!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Open reports
if (Test-Path $reportFile) {
    Write-Host "Opening baseline report..." -ForegroundColor Gray
    Start-Process $reportFile
}
