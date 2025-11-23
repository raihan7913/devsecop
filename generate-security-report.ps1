# Generate Custom Security Report
# Fix for empty npm-audit-html tables

param(
    [string]$ProjectPath = "."
)

Write-Host "Generating Custom Security Report..." -ForegroundColor Cyan
Write-Host ""

$auditJson = npm audit --json | ConvertFrom-Json
$vulnerabilities = $auditJson.vulnerabilities

# Count by severity
$critical = 0
$high = 0
$moderate = 0
$low = 0

$vulnList = @()

foreach ($key in $vulnerabilities.PSObject.Properties.Name) {
    $vuln = $vulnerabilities.$key
    
    switch ($vuln.severity) {
        "critical" { $critical++ }
        "high" { $high++ }
        "moderate" { $moderate++ }
        "low" { $low++ }
    }
    
    # Get CVE details
    $cves = @()
    $urls = @()
    
    if ($vuln.via -is [Array]) {
        foreach ($v in $vuln.via) {
            if ($v.source) {
                $cves += "CVE-$($v.source)"
                $urls += $v.url
            }
        }
    }
    
    $vulnList += [PSCustomObject]@{
        Package = $vuln.name
        Severity = $vuln.severity
        Title = if ($vuln.via[0].title) { $vuln.via[0].title } else { "Multiple vulnerabilities" }
        CVEs = ($cves -join ", ")
        URL = if ($urls.Count -gt 0) { $urls[0] } else { "" }
        FixAvailable = if ($vuln.fixAvailable) { "Yes" } else { "No" }
        Range = $vuln.range
    }
}

# Generate HTML
$html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Security Audit Report - $(Split-Path -Leaf $PWD)</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #007bff;
            padding-bottom: 10px;
        }
        .summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .summary-card {
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            color: white;
        }
        .critical { background: #dc3545; }
        .high { background: #fd7e14; }
        .moderate { background: #ffc107; color: #333; }
        .low { background: #6c757d; }
        .summary-card h2 {
            margin: 0;
            font-size: 3em;
        }
        .summary-card p {
            margin: 10px 0 0 0;
            font-size: 1.1em;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 30px;
        }
        th {
            background: #007bff;
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: 600;
        }
        td {
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover {
            background: #f8f9fa;
        }
        .severity-badge {
            padding: 4px 12px;
            border-radius: 12px;
            color: white;
            font-weight: bold;
            font-size: 0.85em;
            display: inline-block;
        }
        .badge-critical { background: #dc3545; }
        .badge-high { background: #fd7e14; }
        .badge-moderate { background: #ffc107; color: #333; }
        .badge-low { background: #6c757d; }
        .fix-yes { color: #28a745; font-weight: bold; }
        .fix-no { color: #dc3545; font-weight: bold; }
        a {
            color: #007bff;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .meta {
            color: #666;
            font-size: 0.9em;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔒 Security Audit Report</h1>
        <p><strong>Project:</strong> $(Split-Path -Leaf $PWD)</p>
        <p><strong>Generated:</strong> $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
        
        <div class="summary">
            <div class="summary-card critical">
                <h2>$critical</h2>
                <p>Critical</p>
            </div>
            <div class="summary-card high">
                <h2>$high</h2>
                <p>High</p>
            </div>
            <div class="summary-card moderate">
                <h2>$moderate</h2>
                <p>Moderate</p>
            </div>
            <div class="summary-card low">
                <h2>$low</h2>
                <p>Low</p>
            </div>
        </div>
        
        <h2>Vulnerability Details</h2>
        <table>
            <thead>
                <tr>
                    <th>Package</th>
                    <th>Severity</th>
                    <th>Title</th>
                    <th>Fix Available</th>
                    <th>Details</th>
                </tr>
            </thead>
            <tbody>
"@

foreach ($vuln in $vulnList) {
    $badgeClass = "badge-$($vuln.Severity)"
    $fixClass = if ($vuln.FixAvailable -eq "Yes") { "fix-yes" } else { "fix-no" }
    
    $html += @"
                <tr>
                    <td><strong>$($vuln.Package)</strong><br><small>$($vuln.Range)</small></td>
                    <td><span class="severity-badge $badgeClass">$($vuln.Severity.ToUpper())</span></td>
                    <td>$($vuln.Title)</td>
                    <td class="$fixClass">$($vuln.FixAvailable)</td>
                    <td><a href="$($vuln.URL)" target="_blank">View Advisory</a></td>
                </tr>
"@
}

$html += @"
            </tbody>
        </table>
        
        <div class="meta">
            <p><strong>Total Vulnerabilities:</strong> $($vulnList.Count)</p>
            <p><strong>Scan Tool:</strong> npm audit (Node.js built-in)</p>
            <p><strong>Report Generator:</strong> Custom PowerShell Script</p>
        </div>
    </div>
</body>
</html>
"@

# Save HTML
$outputFile = "security-audit-report.html"
$html | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "SUCCESS: Report generated at $outputFile" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Critical: $critical" -ForegroundColor $(if ($critical -gt 0) { "Red" } else { "Green" })
Write-Host "  High:     $high" -ForegroundColor $(if ($high -gt 0) { "Red" } else { "Green" })
Write-Host "  Moderate: $moderate" -ForegroundColor $(if ($moderate -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Low:      $low" -ForegroundColor Gray
Write-Host ""

# Open in browser
Start-Process $outputFile
