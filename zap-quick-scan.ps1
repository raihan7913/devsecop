# Quick OWASP ZAP Baseline Scan
# Fast security testing (2-3 minutes)

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "OWASP ZAP Quick Scan" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

$TARGET_URL = "http://192.168.25.1:3000"
$REPORT_DIR = "security-test-reports"

# Create reports directory
if (-not (Test-Path $REPORT_DIR)) {
    New-Item -ItemType Directory -Path $REPORT_DIR | Out-Null
}

Write-Host "Target: $TARGET_URL" -ForegroundColor Yellow
Write-Host "Duration: ~2-3 minutes" -ForegroundColor Gray
Write-Host ""

Write-Host "Pulling OWASP ZAP Docker image..." -ForegroundColor Yellow
docker pull ghcr.io/zaproxy/zaproxy:stable

Write-Host ""
Write-Host "Running security scan..." -ForegroundColor Yellow
Write-Host ""

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportName = "zap-report-$timestamp.html"

# Run ZAP baseline scan
docker run --rm `
    -v "${PWD}/${REPORT_DIR}:/zap/wrk:rw" `
    -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py `
    -t $TARGET_URL `
    -r $reportName `
    -I

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Scan Complete!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

$reportPath = "$REPORT_DIR\$reportName"
if (Test-Path $reportPath) {
    Write-Host "Report: $reportPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "Opening report..." -ForegroundColor Gray
    Start-Process $reportPath
} else {
    Write-Host "Report not found at: $reportPath" -ForegroundColor Red
}
