# Security Check Script for Sinfomik
# OWASP Dependency-Check (Build Phase)

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Sinfomik Security Audit" -ForegroundColor Cyan
Write-Host "OWASP Dependency-Check" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Backend Security Check
Write-Host "Checking Backend Dependencies..." -ForegroundColor Yellow
Write-Host "Location: backend/" -ForegroundColor Gray
Write-Host ""

Push-Location backend
npm audit
Write-Host ""
Write-Host "Generating HTML report..." -ForegroundColor Gray
& ..\generate-security-report.ps1

if (Test-Path "security-audit-report.html") {
    Write-Host "SUCCESS: Backend Report generated at backend/security-audit-report.html" -ForegroundColor Green
} else {
    Write-Host "WARNING: Failed to generate backend report" -ForegroundColor Red
}
Pop-Location

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Frontend Security Check
Write-Host "Checking Frontend Dependencies..." -ForegroundColor Yellow
Write-Host "Location: frontend/" -ForegroundColor Gray
Write-Host ""

Push-Location frontend
npm audit
Write-Host ""
Write-Host "Generating HTML report..." -ForegroundColor Gray
& ..\generate-security-report.ps1

if (Test-Path "security-audit-report.html") {
    Write-Host "SUCCESS: Frontend Report generated at frontend/security-audit-report.html" -ForegroundColor Green
} else {
    Write-Host "WARNING: Failed to generate frontend report" -ForegroundColor Red
}
Pop-Location

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Summary
Write-Host "Security Audit Summary" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Push-Location backend
$backendAudit = npm audit --json 2>&1 | ConvertFrom-Json
Pop-Location

Push-Location frontend
$frontendAudit = npm audit --json 2>&1 | ConvertFrom-Json
Pop-Location

$backendVulns = $backendAudit.metadata.vulnerabilities
$frontendVulns = $frontendAudit.metadata.vulnerabilities

Write-Host "Backend Vulnerabilities:" -ForegroundColor Yellow
Write-Host "  Critical: $($backendVulns.critical)" -ForegroundColor Red
Write-Host "  High:     $($backendVulns.high)" -ForegroundColor Red
Write-Host "  Moderate: $($backendVulns.moderate)" -ForegroundColor Yellow
Write-Host "  Low:      $($backendVulns.low)" -ForegroundColor Gray
Write-Host ""

Write-Host "Frontend Vulnerabilities:" -ForegroundColor Yellow
Write-Host "  Critical: $($frontendVulns.critical)" -ForegroundColor Red
Write-Host "  High:     $($frontendVulns.high)" -ForegroundColor Red
Write-Host "  Moderate: $($frontendVulns.moderate)" -ForegroundColor Yellow
Write-Host "  Low:      $($frontendVulns.low)" -ForegroundColor Gray
Write-Host ""

$totalCritical = $backendVulns.critical + $frontendVulns.critical
$totalHigh = $backendVulns.high + $frontendVulns.high
$totalModerate = $backendVulns.moderate + $frontendVulns.moderate
$totalLow = $backendVulns.low + $frontendVulns.low
$totalVulns = $totalCritical + $totalHigh + $totalModerate + $totalLow

Write-Host "Total Vulnerabilities: $totalVulns" -ForegroundColor Cyan
Write-Host ""

# Recommendations
Write-Host "Recommendations:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

if (($totalCritical -gt 0) -or ($totalHigh -gt 0)) {
    Write-Host "WARNING: CRITICAL/HIGH vulnerabilities found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Actions to take:" -ForegroundColor Yellow
    Write-Host "1. Review reports: backend/security-audit-report.html" -ForegroundColor Gray
    Write-Host "2. Try: cd backend; npm audit fix" -ForegroundColor Gray
    Write-Host "3. For breaking changes: npm audit fix --force" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "SUCCESS: No critical/high vulnerabilities!" -ForegroundColor Green
    Write-Host ""
}

# Reports Generated
Write-Host "Reports Generated:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "HTML Reports:" -ForegroundColor Yellow
Write-Host "  - backend/security-audit-report.html" -ForegroundColor Green
Write-Host "  - frontend/security-audit-report.html" -ForegroundColor Green
Write-Host ""
Write-Host "JSON Reports:" -ForegroundColor Yellow
Write-Host "  - backend/security-audit.json" -ForegroundColor Green
Write-Host "  - frontend/security-audit.json" -ForegroundColor Green
Write-Host ""

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Security audit completed!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
