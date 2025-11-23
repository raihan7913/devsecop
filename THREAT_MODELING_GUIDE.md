# 🛡️ Threat Modeling Guide - Sinfomik
## Using OWASP Threat Dragon

Panduan lengkap untuk membuat threat model menggunakan OWASP Threat Dragon.

---

## 📋 Apa itu Threat Modeling?

**Threat Modeling** adalah proses untuk:
- 🔍 Identify potential security threats
- 🎯 Analyze attack vectors
- 🛡️ Design security controls
- 📊 Document security risks

**STRIDE Methodology:**
- **S**poofing - Identity impersonation
- **T**ampering - Data modification
- **R**epudiation - Denying actions
- **I**nformation Disclosure - Data leaks
- **D**enial of Service - System unavailability
- **E**levation of Privilege - Unauthorized access

---

## 🚀 Quick Start - OWASP Threat Dragon

### 1️⃣ Launch Application

```powershell
# Threat Dragon sudah installed, buka dari Start Menu atau:
Start-Process "Threat Dragon"
```

### 2️⃣ Create New Threat Model

1. Click **"Create New"**
2. Title: `Sinfomik - Academic Management System`
3. Owner: `[Your Name]`
4. Description: `Web-based academic management system for managing students, teachers, grades, and analytics`

---

## 🏗️ Sinfomik System Architecture

### Components to Add:

#### **External Entities:**
1. **Admin User** (Browser)
2. **Teacher User** (Browser)
3. **Student User** (Browser)

#### **Processes:**
1. **Frontend (React App)**
   - Port: 3000
   - Technology: React 18, PWA
   
2. **Backend API Server**
   - Port: 5000
   - Technology: Node.js + Express
   
3. **Authentication Service**
   - JWT-based auth
   
4. **Analytics Engine**
   - Grade processing

#### **Data Stores:**
1. **SQLite Database**
   - File: academic_dashboard.db
   - Tables: Users, Students, Teachers, Grades, etc.

#### **Data Flows:**
1. User → Frontend (HTTPS)
2. Frontend → Backend API (HTTP REST)
3. Backend → Database (SQL)
4. Backend → Frontend (JSON Response)

---

## 🎨 How to Draw Diagram

### Step 1: Add External Entities

1. Drag **"Actor"** from left panel
2. Name it: `Admin User`
3. Repeat for `Teacher User` and `Student User`

### Step 2: Add Processes

1. Drag **"Process"** 
2. Name: `React Frontend`
3. Add another: `Express Backend API`
4. Add: `Authentication Service`

### Step 3: Add Data Stores

1. Drag **"Store"**
2. Name: `SQLite Database`
3. Add: `Session Storage` (browser)

### Step 4: Connect with Data Flows

1. Click **"Flow"** button
2. Connect: `Admin User` → `React Frontend`
   - Label: `Login Request`
   - Protocol: `HTTPS`

3. Connect: `React Frontend` → `Express Backend`
   - Label: `API Request`
   - Protocol: `HTTP`

4. Connect: `Express Backend` → `SQLite Database`
   - Label: `SQL Query`

---

## ⚠️ Threats to Document (STRIDE)

### 1. **Spoofing Threats**

**Frontend Login:**
- ❌ **Threat:** Attacker impersonates admin user
- ✅ **Mitigation:** 
  - JWT authentication
  - bcrypt password hashing
  - Session timeout

**API Endpoints:**
- ❌ **Threat:** Fake API requests without valid token
- ✅ **Mitigation:**
  - JWT verification middleware
  - Token expiration

### 2. **Tampering Threats**

**Data Modification:**
- ❌ **Threat:** Attacker modifies student grades in transit
- ✅ **Mitigation:**
  - HTTPS for data transmission
  - Input validation (express-validator)
  - Role-based access control

**SQL Injection:**
- ❌ **Threat:** SQL injection via input fields
- ✅ **Mitigation:**
  - Parameterized queries
  - Input sanitization
  - SQLite prepared statements

### 3. **Repudiation Threats**

**Action Logging:**
- ❌ **Threat:** User denies making grade changes
- ✅ **Mitigation:**
  - Audit logs (to be implemented)
  - Timestamp tracking
  - User action history

### 4. **Information Disclosure**

**Password Exposure:**
- ❌ **Threat:** Passwords stored in plaintext
- ✅ **Mitigation:**
  - bcrypt hashing
  - No password in logs
  - Secure .env configuration

**JWT Token Theft:**
- ❌ **Threat:** Token stolen from localStorage
- ✅ **Mitigation:**
  - HTTPOnly cookies (recommended)
  - Token expiration
  - Secure token storage

**Database Exposure:**
- ❌ **Threat:** SQLite database file accessible
- ✅ **Mitigation:**
  - File permissions
  - Not in public directory
  - .gitignore database file

### 5. **Denial of Service**

**API Rate Limiting:**
- ❌ **Threat:** Excessive API requests crash server
- ✅ **Mitigation:**
  - express-rate-limit (implemented)
  - Rate: 100 requests/15 min

**Database Overload:**
- ❌ **Threat:** Too many concurrent queries
- ✅ **Mitigation:**
  - Connection pooling
  - Query optimization
  - Pagination

### 6. **Elevation of Privilege**

**Role Bypass:**
- ❌ **Threat:** Teacher accesses admin functions
- ✅ **Mitigation:**
  - Role-based middleware
  - Permission checks per route
  - JWT role claims

**Direct Object Reference:**
- ❌ **Threat:** Access other students' data via ID manipulation
- ✅ **Mitigation:**
  - Authorization checks
  - User context validation
  - Resource ownership verification

---

## 📊 Threat Priority Matrix

| Threat | Severity | Likelihood | Risk Level | Status |
|--------|----------|------------|------------|--------|
| SQL Injection | High | Medium | HIGH | ✅ Mitigated |
| Password Exposure | High | Low | MEDIUM | ✅ Mitigated |
| JWT Token Theft | Medium | Medium | MEDIUM | 🟡 Partial |
| Session Hijacking | Medium | Low | MEDIUM | 🟡 Partial |
| Role Bypass | High | Low | MEDIUM | ✅ Mitigated |
| DoS Attack | Medium | Medium | MEDIUM | ✅ Mitigated |
| XSS Attack | High | Low | MEDIUM | ✅ Mitigated (Helmet) |
| CSRF Attack | Medium | Low | LOW | ✅ Mitigated (CORS) |

---

## 🔧 Security Controls Implemented

### Application Layer:
- ✅ **Helmet.js** - Security headers
- ✅ **CORS** - Cross-origin protection
- ✅ **express-validator** - Input validation
- ✅ **bcryptjs** - Password hashing
- ✅ **jsonwebtoken** - Authentication
- ✅ **express-rate-limit** - DoS protection

### Code Quality:
- ✅ **ESLint** - Code linting
- ✅ **OWASP Dependency-Check** - Vulnerability scanning

### Infrastructure:
- ✅ **Docker** - Container isolation
- ✅ **Nginx** - Reverse proxy (production)
- ✅ **Grafana/Prometheus** - Monitoring

---

## 📝 How to Add Threats in Threat Dragon

### For Each Component:

1. **Right-click on component** (e.g., Backend API)
2. Click **"Add Threat"**
3. Fill in:
   - **Title:** e.g., "SQL Injection via Login Form"
   - **Status:** "Mitigated" / "Not Started" / "In Progress"
   - **Severity:** "High" / "Medium" / "Low"
   - **Description:** Detailed threat explanation
   - **Mitigation:** What you did to fix it
   - **Type:** Select STRIDE category

### Example Threat Entry:

```
Title: SQL Injection in Authentication
Type: Tampering
Status: Mitigated
Severity: High
Priority: High

Description:
Attacker could inject malicious SQL code through login form
to bypass authentication or access unauthorized data.

Threat Scenario:
Username: admin' OR '1'='1
Password: anything

Mitigation:
1. Using parameterized queries with sqlite3
2. Input validation with express-validator
3. Prepared statements for all database operations
4. No dynamic SQL concatenation

Code Example:
// Before (Vulnerable)
db.get(`SELECT * FROM users WHERE username='${username}'`)

// After (Secure)
db.get('SELECT * FROM users WHERE username=?', [username])
```

---

## 📄 Export Options

### 1. **JSON Export**
- File → Export → JSON
- Save as: `sinfomik-threat-model.json`

### 2. **PDF Report**
- File → Export → PDF
- Save as: `sinfomik-threat-model.pdf`

### 3. **Image Export**
- Right-click diagram → Export as Image
- Save as: `sinfomik-architecture-diagram.png`

---

## 🎓 For Tugas Dosen

### Deliverables:

1. **Threat Model Diagram** (PNG/PDF)
   - System architecture
   - Data flow arrows
   - Trust boundaries

2. **Threat Analysis Document** (PDF)
   - List of identified threats (STRIDE)
   - Risk assessment
   - Mitigation strategies

3. **Screenshots**
   - Threat Dragon interface
   - Individual threat details
   - Mitigation notes

### Documentation Template:

```markdown
## Plan Phase - Threat Modeling

### Tool Used
OWASP Threat Dragon v2.5.0 - Open source threat modeling tool

### Methodology
STRIDE threat classification:
- Spoofing, Tampering, Repudiation
- Information Disclosure, Denial of Service
- Elevation of Privilege

### System Architecture
[Include architecture diagram from Threat Dragon]

### Identified Threats
Total: 15 threats identified across 6 STRIDE categories

High Priority Threats:
1. SQL Injection - MITIGATED (parameterized queries)
2. Password Exposure - MITIGATED (bcrypt hashing)
3. Role Bypass - MITIGATED (RBAC middleware)

Medium Priority Threats:
1. JWT Token Theft - PARTIAL (implementing HTTPOnly cookies)
2. Session Hijacking - PARTIAL (session timeout implemented)
3. DoS Attacks - MITIGATED (rate limiting)

### Security Controls
[List all security measures from Security Controls section above]

### Risk Assessment
[Include Threat Priority Matrix]

### Conclusion
System has strong security posture with multiple layers of defense.
Key threats have been identified and mitigated through secure coding
practices and security frameworks.
```

---

## 🚀 Quick Commands

```powershell
# Launch Threat Dragon
Start-Process "Threat Dragon"

# Open project folder
explorer C:\Users\Han\Desktop\sinfomik\backup8\backup5

# Export location
# Save exports to: C:\Users\Han\Desktop\sinfomik\backup8\backup5\threat-modeling\
```

---

## 📚 Resources

- **OWASP Threat Dragon:** https://www.threatdragon.com/
- **STRIDE Guide:** https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats
- **Threat Modeling Process:** https://owasp.org/www-community/Threat_Modeling_Process

---

## ✅ Checklist

- [ ] Install OWASP Threat Dragon
- [ ] Create new threat model project
- [ ] Draw system architecture
- [ ] Add all components (users, processes, stores)
- [ ] Define data flows
- [ ] Add threats for each component (STRIDE)
- [ ] Document mitigations
- [ ] Export diagram as PNG
- [ ] Export report as PDF
- [ ] Include in tugas documentation

---

**Happy Threat Modeling! 🛡️**
