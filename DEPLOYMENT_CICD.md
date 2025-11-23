**Development (CI/CD)**

- **Ringkasan singkat:** CI/CD memastikan perubahan kode melalui pemeriksaan otomatis, build artefak, dan deployment ke environment `staging` dan `production`. Version control (Git) menyimpan kode; Jenkins menjalankan pipeline; JIRA mengelola tiket dan workflow — semuanya terintegrasi tetapi memiliki peran yang berbeda.

**Implementation tools & environments**
- **Version control:** `Git` (hosted di GitHub/GitLab/Bitbucket).
- **Issue tracking:** `JIRA` (link branch/commit ke tiket, mis. `PROJ-123`).
- **CI server:** `Jenkins` (declarative pipelines) atau alternatif seperti GitHub Actions/GitLab CI.
- **Containerization:** `Docker` + `docker-compose` untuk environment lokal dan staging.
- **Registry:** Docker Hub / private registry untuk menyimpan image.
- **Monitoring:** Grafana / Prometheus (dengan cAdvisor / Node Exporter).

**Frontend (environment & checks)**
- Env files: `frontend/.env` (API URL, feature flags).
- Build: `npm ci` lalu `npm run build`.
- Checks in CI: `npm run lint`, `npm test`, `npm run security:audit`.
- Artefak: folder `build/` diupload ke static host/CDN atau dimasukkan ke dalam Docker image.

**Backend (environment & checks)**
- Env files: `backend/.env` (DB path, JWT secret, PORT, NODE_ENV).
- Build/run: `npm ci` lalu `npm start` atau `docker build` untuk container.
- Checks in CI: `npm run lint`, `npm test`, `npm run security:audit`.
- DB: gunakan SQLite untuk dev; pada staging/production gunakan volume atau managed DB.

**Tahapan pipeline (direkomendasikan)**
- Checkout — ambil kode dari Git.
- Install — `npm ci` untuk reproducible installs.
- Lint — gagal jika ada error (archive report `eslint-report.html`).
- Unit Tests — jalankan `npm test`.
- Security Audit — jalankan `npm audit --json` / Snyk, hasil disimpan sebagai artefak `security-audit-report.html`.
- Build — bundle frontend dan/atau package backend.
- Docker Build & Push — tag image dengan commit short SHA lalu push ke registry.
- Deploy ke Staging — otomatis setelah sukses.
- Integration / E2E Tests di Staging.
- Manual Approval — sebelum produksi.
- Deploy Production — setelah persetujuan.
- Post-deploy checks & notifikasi.

**Branching & release (recommended)**
- `main` untuk production-ready.
- `develop` (opsional) untuk integrasi fitur.
- `feature/<JIRA-KEY>-desc` untuk pekerjaan fitur.
- Gunakan PR/MR dengan setidaknya 1 reviewer; CI harus lulus sebelum merge.

**Contoh integrasi singkat:**
- Developer buat branch `feature/PROJ-123-login` dan commit `PROJ-123: add login`.
- Push ke remote → webhook memicu Jenkins → pipeline berjalan.
- Hasil lint/test/security diarsipkan ke PR dan dilampirkan di tiket JIRA bila perlu.

**Cara menangani vulnerabilities**
- Jangan otomatis memakai `npm audit fix --force` di CI.
- Klasifikasikan hasil: fixable, requires major upgrade, no-fix-available.
- Untuk paket tanpa patch (mis. `xlsx`), pertimbangkan penggantian library atau mitigasi (validasi input, batasi upload).

**Artefak & dokumentasi yang harus diarsipkan**
- `Jenkinsfile` di root repository.
- `security-audit-report.html` dan `eslint-report.html` sebagai artefak build.
- Deployment scripts di `deploy-scripts/`.
- README: bagian `CI/CD` tentang cara menjalankan pipeline lokal dan release.

**Referensi cepat perintah (PowerShell)**
````powershell
cd backend; npm ci
cd frontend; npm ci
cd backend; npm run lint
cd frontend; npm run lint
cd backend; npm run security:audit-report
cd frontend; npm run security:audit-report
docker-compose -f docker-compose.yml up --build
````

---
File ini dibuat untuk memudahkan integrasi CI/CD dan dokumentasi proses deployment.
