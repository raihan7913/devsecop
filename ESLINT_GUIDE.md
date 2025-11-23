# 🔍 ESLint Setup Guide - Sinfomik

Panduan lengkap setup ESLint untuk development code quality.

## 📋 Apa itu ESLint?

**ESLint** adalah tool untuk:
- ✅ **Code Quality** - Deteksi bugs & bad practices
- ✅ **Code Style** - Konsistensi formatting
- ✅ **Best Practices** - Follow coding standards
- ✅ **Auto-Fix** - Automatic code correction

## 🚀 Setup (Quick Start)

### 1️⃣ Install Dependencies

**Backend:**
```powershell
cd backend
npm install --save-dev eslint
```

**Frontend:**
```powershell
cd frontend
npm install --save-dev eslint eslint-plugin-react eslint-plugin-react-hooks
```

### 2️⃣ Config Files Sudah Dibuat

✅ `backend/.eslintrc.json` - Backend config
✅ `frontend/.eslintrc.json` - Frontend config
✅ `backend/.eslintignore` - Files to ignore
✅ `frontend/.eslintignore` - Files to ignore

### 3️⃣ Run ESLint

**Backend:**
```powershell
cd backend
npm run lint          # Check for errors
npm run lint:fix      # Auto-fix errors
npm run lint:report   # Generate HTML report
```

**Frontend:**
```powershell
cd frontend
npm run lint          # Check for errors
npm run lint:fix      # Auto-fix errors
npm run lint:report   # Generate HTML report
```

## 📊 ESLint Rules yang Dipakai

### Backend Rules:

```json
{
  "indent": ["error", 2],              // 2 spaces indentation
  "quotes": ["error", "single"],       // Single quotes
  "semi": ["error", "always"],         // Always use semicolons
  "no-unused-vars": "warn",            // Warn on unused variables
  "no-console": "off",                 // Allow console.log
  "comma-dangle": ["error", "never"],  // No trailing commas
  "no-trailing-spaces": "error"        // No trailing whitespace
}
```

### Frontend Rules (React):

```json
{
  "react/react-in-jsx-scope": "off",      // Not needed in React 17+
  "react/prop-types": "off",              // PropTypes optional
  "react-hooks/rules-of-hooks": "error",  // Hooks rules
  "react-hooks/exhaustive-deps": "warn"   // Dependency array warnings
}
```

## 🎯 Common ESLint Commands

### Check Code Quality

```powershell
# Backend
cd backend
npm run lint

# Frontend
cd frontend
npm run lint
```

**Output Example:**
```
/src/server.js
  5:1   error    Unexpected console statement    no-console
  12:7  warning  'userId' is assigned but never used  no-unused-vars

✖ 2 problems (1 error, 1 warning)
```

### Auto-Fix Issues

```powershell
# Backend
cd backend
npm run lint:fix

# Frontend
cd frontend
npm run lint:fix
```

Auto-fix akan memperbaiki:
- ✅ Indentation
- ✅ Spacing
- ✅ Quotes
- ✅ Semicolons
- ✅ Trailing commas
- ✅ Line endings

### Generate HTML Report

```powershell
cd backend
npm run lint:report
# Opens eslint-report.html in browser
```

Report berisi:
- 📊 Error summary
- 📝 File-by-file breakdown
- 🔍 Line-by-line issues
- 💡 Suggested fixes

## 🔧 VS Code Integration

### Install Extension

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search "ESLint"
4. Install by Microsoft

### Auto-fix on Save

Add to `.vscode/settings.json`:

```json
{
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ]
}
```

Sekarang code auto-fix setiap kali save! 🎉

## 📝 Common Errors & Fixes

### 1. Unused Variables

**Error:**
```javascript
const userId = 123;  // ❌ 'userId' is assigned but never used
```

**Fix:**
```javascript
// Option 1: Use it
const userId = 123;
console.log(userId);

// Option 2: Remove it
// (delete the line)

// Option 3: Prefix with underscore
const _userId = 123;  // Indicates intentionally unused
```

### 2. Missing Semicolons

**Error:**
```javascript
const name = 'John'  // ❌ Missing semicolon
```

**Fix:**
```javascript
const name = 'John';  // ✅
```

### 3. Wrong Quotes

**Error:**
```javascript
const message = "Hello";  // ❌ Strings must use singlequote
```

**Fix:**
```javascript
const message = 'Hello';  // ✅
```

### 4. Wrong Indentation

**Error:**
```javascript
function test() {
    return true;  // ❌ Expected indentation of 2 spaces but found 4
}
```

**Fix:**
```javascript
function test() {
  return true;  // ✅
}
```

### 5. Trailing Spaces

**Error:**
```javascript
const x = 1;   // ❌ Trailing spaces
```

**Fix:**
```javascript
const x = 1;  // ✅ No trailing spaces
```

## 🎨 Custom Rules (Optional)

Edit `.eslintrc.json` untuk customize:

```json
{
  "rules": {
    "no-console": "off",        // Allow console.log
    "no-unused-vars": "warn",   // Warning instead of error
    "quotes": ["error", "double"], // Use double quotes
    "indent": ["error", 4]      // 4 spaces instead of 2
  }
}
```

## 🚫 Disable ESLint for Specific Lines

```javascript
// Disable for next line
// eslint-disable-next-line no-console
console.log('Debug info');

// Disable for entire file
/* eslint-disable no-console */
console.log('Line 1');
console.log('Line 2');
/* eslint-enable no-console */

// Disable specific rule
// eslint-disable-next-line no-unused-vars
const unused = 'value';
```

## 📦 Pre-commit Hook (Optional)

Install Husky untuk auto-lint sebelum commit:

```powershell
# Install Husky
npm install --save-dev husky lint-staged

# Setup
npx husky install
npx husky add .husky/pre-commit "npm run lint-staged"
```

Add to `package.json`:
```json
{
  "lint-staged": {
    "*.js": [
      "eslint --fix",
      "git add"
    ]
  }
}
```

Sekarang code akan auto-lint setiap commit! 🎯

## 🎓 Untuk Tugas Dosen

### Checklist ESLint untuk Tugas:

- [ ] ✅ ESLint installed di backend & frontend
- [ ] ✅ Config files created (.eslintrc.json)
- [ ] ✅ Run `npm run lint` - no errors
- [ ] ✅ Generate HTML report (`npm run lint:report`)
- [ ] ✅ Include report di dokumentasi
- [ ] ✅ Show before/after code quality
- [ ] ✅ Explain rules yang dipakai

### Dokumentasi untuk Laporan:

```markdown
## Development Tools - ESLint

### Setup
- ESLint version: 8.57.0
- Configuration: `.eslintrc.json`
- Rules: ESLint recommended + Custom rules

### Code Quality Results

**Before ESLint:**
- 45 errors
- 23 warnings
- Inconsistent formatting

**After ESLint Fix:**
- 0 errors
- 0 warnings
- Consistent code style

**Report:** See `eslint-report.html`

### Rules Enforced:
1. 2-space indentation
2. Single quotes for strings
3. Always use semicolons
4. No trailing spaces
5. No unused variables
```

## 📊 Quality Metrics

Track code quality improvement:

```powershell
# Count errors before fix
npm run lint | findstr "error"

# Apply fixes
npm run lint:fix

# Count errors after fix
npm run lint | findstr "error"
```

## 🎯 Best Practices

1. **Run lint sebelum commit**
   ```powershell
   npm run lint
   ```

2. **Use auto-fix untuk formatting**
   ```powershell
   npm run lint:fix
   ```

3. **Review warnings** - jangan diabaikan

4. **Consistent rules** - pakai config yang sama untuk team

5. **CI/CD integration** - add to deployment pipeline

## 🔗 Resources

- **ESLint Docs:** https://eslint.org/docs/latest/
- **Rules List:** https://eslint.org/docs/latest/rules/
- **React ESLint Plugin:** https://github.com/jsx-eslint/eslint-plugin-react
- **Airbnb Style Guide:** https://github.com/airbnb/javascript

---

## 🚀 Quick Commands Reference

```powershell
# Backend
cd backend
npm install --save-dev eslint
npm run lint          # Check
npm run lint:fix      # Fix
npm run lint:report   # Report

# Frontend
cd frontend
npm install --save-dev eslint eslint-plugin-react eslint-plugin-react-hooks
npm run lint          # Check
npm run lint:fix      # Fix
npm run lint:report   # Report
```

**Happy Clean Coding! 🎉**
