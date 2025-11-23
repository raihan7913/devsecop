# 🔍 OWASP ZAP Security Testing Guide - Sinfomik

Panduan lengkap **OWASP ZAP** untuk **Test Phase** security testing.

---

## 📋 Apa itu OWASP ZAP?

**OWASP Zed Attack Proxy (ZAP)** adalah security tool untuk:
- ✅ **Automated Security Testing** - Spider & scan aplikasi web
- ✅ **Vulnerability Detection** - Find XSS, SQL Injection, CSRF, dll
- ✅ **Penetration Testing** - Active & passive scanning
- ✅ **Security Reports** - Generate HTML/XML/JSON reports

**Tahap SDLC:** **TEST** (Pengujian keamanan otomatis dan manual)

---

## 🚀 Quick Start

### 1️⃣ Prerequisites

**Docker harus running:**
```powershell
docker --version
# Docker version 28.x.x
```

**Application harus jalan:**
- Backend: http://localhost:5000
- Frontend: http://localhost:3000

### 2️⃣ Run Security Scan

**Quick Scan (Baseline - 2-3 minutes):**
```powershell
.\zap-quick-scan.ps1
```

**Full Scan (Comprehensive - 5-10 minutes):**
```powershell
.\run-zap-scan.ps1
```

### 3️⃣ View Reports

Reports auto-open di browser, atau buka manual:
- `security-test-reports/zap-report-[timestamp].html`

---

## 📊 Types of Scans

### 1. Baseline Scan (Passive)

**What it does:**
- 🔍 Spider the application (crawl all pages)
- 🔍 Passive scanning only (no attacks)
- 🔍 Check for common issues
- ⚡ Fast (~2-3 minutes)

**Use case:**
- Quick security check
- CI/CD integration
- Regular monitoring
- Non-intrusive testing

**Command:**
```powershell
.\zap-quick-scan.ps1
```

### 2. Full Scan (Active)

**What it does:**
- 🔍 Spider + Passive scan
- ⚠️ Active attack simulations
- ⚠️ Inject payloads to find vulnerabilities
- 🐌 Slower (~5-10 minutes)

**Use case:**
- Comprehensive testing
- Before major releases
- Penetration testing
- Security audits

**Command:**
```powershell
.\run-zap-scan.ps1
```

---

## 🎯 What ZAP Tests For

### Common Web Vulnerabilities:

| Vulnerability | Severity | Description |
|---------------|----------|-------------|
| **XSS** | High | Cross-Site Scripting attacks |
| **SQL Injection** | Critical | Database injection attacks |
| **CSRF** | Medium | Cross-Site Request Forgery |
| **Broken Auth** | High | Authentication vulnerabilities |
| **Security Misconfiguration** | Medium | Missing security headers, etc. |
| **Sensitive Data Exposure** | High | Data leakage issues |
| **Broken Access Control** | High | Authorization bypasses |
| **Using Components with Known Vulnerabilities** | Varies | Outdated libraries |
| **Insufficient Logging** | Low | Missing audit logs |
| **Server Side Request Forgery** | High | SSRF attacks |

---

## 📄 Understanding Reports

### Report Structure:

**1. Summary Section:**
- Total alerts found
- Risk breakdown (High/Medium/Low/Informational)
- Confidence levels

**2. Alert Details:**
Each vulnerability shows:
- **Name** - Type of vulnerability
- **Risk** - Severity level
- **Confidence** - How sure ZAP is
- **URL** - Where it was found
- **Description** - What the issue is
- **Solution** - How to fix it
- **Reference** - Links to OWASP/CWE docs

**3. Risk Levels:**
- 🔴 **High** - Critical issues, fix immediately
- 🟠 **Medium** - Important issues, fix soon
- 🟡 **Low** - Minor issues, review and fix
- ℹ️ **Informational** - FYI, may not be issues

---

## 🛠️ Common Findings & Fixes

### 1. Missing Security Headers

**Finding:**
```
X-Content-Type-Options header missing
X-Frame-Options header missing
Content-Security-Policy header missing
```

**Fix (Backend - src/server.js):**
```javascript
const helmet = require('helmet');

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"]
    }
  },
  xFrameOptions: { action: 'deny' }
}));
```

### 2. Cookie Without Secure Flag

**Finding:**
```
Cookies sent without Secure and HttpOnly flags
```

**Fix (Backend - authController.js):**
```javascript
res.cookie('token', jwt, {
  httpOnly: true,  // Prevent XSS
  secure: true,    // HTTPS only
  sameSite: 'strict', // CSRF protection
  maxAge: 3600000
});
```

### 3. Cross-Site Scripting (XSS)

**Finding:**
```
Reflected XSS vulnerability detected
```

**Fix (Frontend):**
```javascript
// BAD
<div dangerouslySetInnerHTML={{__html: userInput}} />

// GOOD
import DOMPurify from 'dompurify';
<div>{DOMPurify.sanitize(userInput)}</div>
```

### 4. SQL Injection

**Finding:**
```
SQL Injection possible via query parameter
```

**Fix (Backend):**
```javascript
// BAD
db.query(`SELECT * FROM users WHERE id = ${userId}`);

// GOOD - Use parameterized queries
db.query('SELECT * FROM users WHERE id = ?', [userId]);
```

### 5. CSRF Token Missing

**Finding:**
```
Cross-Site Request Forgery protection not implemented
```

**Fix (Backend):**
```javascript
const csrf = require('csurf');
const csrfProtection = csrf({ cookie: true });

app.use(csrfProtection);

app.post('/api/important-action', (req, res) => {
  // CSRF token auto-validated
});
```

---

## 🔄 CI/CD Integration

### Add to Build Pipeline

**Example: GitLab CI**

```yaml
security-test:
  stage: test
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker pull ghcr.io/zaproxy/zaproxy:stable
    - docker run --rm -v $(pwd):/zap/wrk:rw 
        ghcr.io/zaproxy/zaproxy:stable zap-baseline.py 
        -t http://localhost:3000 
        -r zap-report.html
  artifacts:
    paths:
      - zap-report.html
    reports:
      junit: zap-report.xml
  only:
    - main
    - develop
```

**Example: GitHub Actions**

```yaml
- name: OWASP ZAP Scan
  uses: zaproxy/action-baseline@v0.10.0
  with:
    target: 'http://localhost:3000'
    rules_file_name: '.zap/rules.tsv'
    cmd_options: '-a'
```

---

## 📊 Interpreting Results

### Severity Guidelines:

**High Risk:**
- ❌ **Block deployment** until fixed
- 🔴 Critical security flaws
- 🎯 Examples: SQL Injection, XSS, Broken Auth

**Medium Risk:**
- ⚠️ **Review before deployment**
- 🟠 Important but not critical
- 🎯 Examples: Missing headers, CSRF, weak crypto

**Low Risk:**
- ℹ️ **Plan to fix**
- 🟡 Minor issues
- 🎯 Examples: Info disclosure, version exposure

**Informational:**
- ✅ **No action required**
- ℹ️ Just FYI
- 🎯 Examples: Comments in code, directory listings

---

## 🎓 For Tugas Dosen (Academic Report)

### Checklist untuk Laporan:

- [ ] ✅ Setup OWASP ZAP (Docker-based)
- [ ] ✅ Run baseline scan
- [ ] ✅ Run full scan (optional)
- [ ] ✅ Generate HTML reports
- [ ] ✅ Document findings (screenshot)
- [ ] ✅ Show vulnerability details
- [ ] ✅ List mitigation actions taken
- [ ] ✅ Show before/after comparison

### Template Dokumentasi:

```markdown
## Test Phase - OWASP ZAP Security Testing

### Tools Used
- OWASP ZAP 2.15.0 (via Docker)
- Baseline Scan (Passive)
- Full Scan (Active)

### Setup
1. Installed OWASP ZAP via Docker container
2. Started application (backend + frontend)
3. Configured ZAP to scan http://localhost:3000
4. Created automated scanning scripts

### Test Scope
- Target: Sinfomik Web Application
- URL: http://localhost:3000
- Pages Scanned: [X] pages
- Duration: [Y] minutes

### Scan Results

#### Baseline Scan Summary
- Total Alerts: [X]
- High Risk: [X]
- Medium Risk: [X]
- Low Risk: [X]
- Informational: [X]

#### Key Findings

1. **Missing Security Headers** (Medium)
   - Issue: X-Frame-Options, CSP headers not set
   - Impact: Clickjacking, XSS risks
   - Fix: Added helmet.js middleware

2. **Cookie Security** (Medium)
   - Issue: Cookies without HttpOnly, Secure flags
   - Impact: XSS, MITM attacks
   - Fix: Updated cookie configuration

3. **CSRF Protection** (Medium)
   - Issue: No CSRF tokens
   - Impact: Request forgery attacks
   - Fix: Implemented CSRF middleware

#### Mitigation Actions Taken
1. Added security headers via helmet.js
2. Secured cookies with HttpOnly/Secure flags
3. Implemented CSRF protection
4. Input validation & sanitization
5. Parameterized SQL queries

### Reports Generated
- baseline-scan-report.html
- full-scan-report.html
- XML reports for CI/CD integration

### Recommendations
1. Fix all High and Medium severity issues before deployment
2. Implement automated ZAP scanning in CI/CD pipeline
3. Regular security testing (monthly)
4. Security training for development team
5. Keep dependencies updated
```

---

## 🚀 Quick Commands Reference

```powershell
# Quick baseline scan (2-3 minutes)
.\zap-quick-scan.ps1

# Full comprehensive scan (5-10 minutes)
.\run-zap-scan.ps1

# Start application first
cd backend; npm start
cd frontend; npm start

# View reports
Start-Process security-test-reports\zap-report-[timestamp].html

# Manual ZAP scan
docker run --rm -v "${PWD}/reports:/zap/wrk:rw" `
  ghcr.io/zaproxy/zaproxy:stable zap-baseline.py `
  -t http://host.docker.internal:3000 `
  -r report.html -I
```

---

## 💡 Best Practices

1. ✅ **Run before every major release**
2. ✅ **Fix High/Medium issues immediately**
3. ✅ **Review Low issues regularly**
4. ✅ **Integrate into CI/CD pipeline**
5. ✅ **Test in staging environment**
6. ✅ **Keep ZAP updated**
7. ✅ **Combine with other security tools**
8. ✅ **Document all findings & fixes**

---

## 🔗 Resources

- **OWASP ZAP Docs:** https://www.zaproxy.org/docs/
- **Docker Hub:** https://hub.docker.com/r/zaproxy/zap-stable
- **GitHub:** https://github.com/zaproxy/zaproxy
- **OWASP Top 10:** https://owasp.org/www-project-top-ten/
- **ZAP API:** https://www.zaproxy.org/docs/api/

---

## 🎯 Troubleshooting

**Docker not running:**
```powershell
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
```

**Application not accessible:**
```powershell
# Check if servers running
Test-NetConnection -ComputerName localhost -Port 5000
Test-NetConnection -ComputerName localhost -Port 3000
```

**Report not generated:**
- Check Docker logs
- Ensure write permissions on reports folder
- Verify application is accessible from Docker

**Scan taking too long:**
- Use baseline scan instead of full scan
- Reduce scan scope
- Check application performance

---

**✅ Setup Complete!** 

OWASP ZAP ready untuk:
- ✅ Test phase security testing
- ✅ Automated vulnerability scanning
- ✅ HTML reports untuk tugas dosen
- ✅ CI/CD integration ready

**Happy Secure Testing! 🔍**
