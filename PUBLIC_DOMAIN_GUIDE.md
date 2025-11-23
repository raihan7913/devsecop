# 🌐 Public Domain Deployment Guide

Panduan lengkap untuk expose aplikasi Sinfomik ke public dengan domain.

## 📋 Prerequisites

1. **Domain Name** - Beli di:
   - Namecheap, GoDaddy, Cloudflare, dll
   - Atau domain gratis: Freenom, Afraid.org

2. **Server dengan IP Public:**
   - VPS (DigitalOcean, Linode, Vultr, AWS EC2)
   - Atau expose local dengan Ngrok/Cloudflare Tunnel

3. **Docker & Docker Compose** installed di server

## 🚀 Method 1: VPS + Domain (Production Ready)

### Step 1: Setup DNS

Di DNS provider (Namecheap, Cloudflare, etc):

```
Type    Name                Value               TTL
A       @                   YOUR_SERVER_IP      Auto
A       www                 YOUR_SERVER_IP      Auto
CNAME   monitoring          yourdomain.com      Auto
```

### Step 2: Edit Config Files

**1. Edit `nginx/nginx.conf`:**
```bash
# Ganti 'yourdomain.com' dengan domain kamu
server_name sinfomik.example.com www.sinfomik.example.com;
server_name monitoring.sinfomik.example.com;  # untuk Grafana
```

**2. Edit `docker-compose.production.yml`:**
```yaml
environment:
  - FRONTEND_URL=https://sinfomik.example.com
  - GF_SERVER_ROOT_URL=https://monitoring.sinfomik.example.com
```

### Step 3: Deploy to VPS

**Upload files ke server:**
```bash
# Via Git
git clone https://github.com/yourrepo/sinfomik.git
cd sinfomik

# Atau via SCP
scp -r . user@your-server-ip:/home/user/sinfomik
```

**Run on server:**
```bash
cd /home/user/sinfomik

# Generate JWT secret
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Create .env
nano .env
# Paste JWT_SECRET

# Start services
docker-compose -f docker-compose.production.yml up -d

# Initialize database
docker exec -it sinfomik-app node src/init_db.js
```

### Step 4: Setup SSL (HTTPS)

**Option A: Let's Encrypt (Free & Auto):**

```bash
# Install Certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d sinfomik.example.com -d www.sinfomik.example.com

# Get certificate for monitoring subdomain
sudo certbot --nginx -d monitoring.sinfomik.example.com

# Auto-renewal (already setup by certbot)
sudo certbot renew --dry-run
```

**Option B: Cloudflare SSL (Easier):**

1. Point domain to Cloudflare
2. Enable "Full (strict)" SSL
3. Nginx will use Cloudflare's certificate

### Step 5: Test

```
http://sinfomik.example.com  → Main App
https://sinfomik.example.com → Secure version
http://monitoring.sinfomik.example.com → Grafana
```

## 🔥 Method 2: Cloudflare Tunnel (Zero Config, No Port Forward!)

**Kelebihan:**
- ✅ Tidak perlu IP public
- ✅ Tidak perlu port forwarding
- ✅ Auto SSL/HTTPS
- ✅ DDoS protection
- ✅ Bisa dari komputer rumah!

### Setup:

**1. Install Cloudflare Tunnel:**
```powershell
# Windows
winget install --id Cloudflare.cloudflared

# Atau download dari: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/
```

**2. Login:**
```powershell
cloudflared tunnel login
```

**3. Create Tunnel:**
```powershell
cloudflared tunnel create sinfomik
```

**4. Configure Tunnel:**

Create `cloudflare-tunnel.yml`:
```yaml
tunnel: YOUR-TUNNEL-ID
credentials-file: C:\Users\YOUR_USER\.cloudflared\YOUR-TUNNEL-ID.json

ingress:
  # Main App
  - hostname: sinfomik.example.com
    service: http://localhost:80
  
  # Grafana Monitoring
  - hostname: monitoring.sinfomik.example.com
    service: http://localhost:3001
  
  # Catch-all
  - service: http_status:404
```

**5. Setup DNS (Auto via Cloudflare):**
```powershell
cloudflared tunnel route dns sinfomik sinfomik.example.com
cloudflared tunnel route dns sinfomik monitoring.sinfomik.example.com
```

**6. Run Tunnel:**
```powershell
cloudflared tunnel run sinfomik
```

**7. Access:**
```
https://sinfomik.example.com → Main App (Auto HTTPS!)
https://monitoring.sinfomik.example.com → Grafana
```

## ⚡ Method 3: Ngrok (Quick Test)

**Untuk testing cepat:**

```powershell
# Install ngrok
choco install ngrok
# atau download: https://ngrok.com/download

# Login
ngrok config add-authtoken YOUR_TOKEN

# Expose port 80
ngrok http 80

# Akan dapat URL: https://random-id.ngrok.io
```

**Kelebihan:**
- ✅ Super cepat (1 command)
- ✅ Auto HTTPS
- ⚠️ Random URL (paid plan untuk custom domain)
- ⚠️ Hanya untuk testing

## 🔒 Security Checklist

**Before going public:**

- [ ] Change JWT_SECRET ke random strong key
- [ ] Enable HTTPS/SSL
- [ ] Setup firewall (UFW, iptables)
- [ ] Change Grafana default password
- [ ] Enable rate limiting (sudah ada di nginx.conf)
- [ ] Regular backups
- [ ] Monitor logs
- [ ] Update regularly

**Firewall Setup (VPS):**
```bash
# UFW
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable

# Atau via cloud provider (AWS Security Groups, DigitalOcean Firewall)
```

## 📊 Domain Examples

**Single Domain:**
```
https://sinfomik.example.com → Main App
https://sinfomik.example.com/monitoring → Grafana (via nginx proxy)
```

**Multi Subdomain:**
```
https://sinfomik.example.com → Main App
https://monitoring.sinfomik.example.com → Grafana
https://api.sinfomik.example.com → API only
```

## 🎯 Quick Commands Reference

```powershell
# Start production
docker-compose -f docker-compose.production.yml up -d

# View logs
docker-compose -f docker-compose.production.yml logs -f

# Restart nginx (after config change)
docker-compose -f docker-compose.production.yml restart nginx

# Check SSL expiry
echo | openssl s_client -connect sinfomik.example.com:443 2>/dev/null | openssl x509 -noout -dates

# Renew SSL (Certbot)
sudo certbot renew

# Backup database
docker cp sinfomik-app:/app/backend/data/academic_dashboard.db ./backup-$(date +%Y%m%d).db
```

## 💰 Cost Estimate

**Minimum Setup:**
- Domain: $10-15/year
- VPS: $5-10/month (DigitalOcean, Vultr)
- SSL: FREE (Let's Encrypt)
- **Total: ~$70-135/year**

**Free Alternative:**
- Free domain: Freenom, Afraid.org
- Cloudflare Tunnel: FREE
- Run from home PC
- **Total: $0/year**

## 🆘 Troubleshooting

**Domain tidak bisa diakses:**
```bash
# Check DNS propagation
nslookup sinfomik.example.com
dig sinfomik.example.com

# Check if nginx running
docker ps | grep nginx

# Check nginx logs
docker logs sinfomik-nginx
```

**SSL error:**
```bash
# Check certificate
sudo certbot certificates

# Force renewal
sudo certbot renew --force-renewal
```

**Port 80/443 already in use:**
```bash
# Check what's using it
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Stop conflicting service
sudo systemctl stop apache2  # or whatever service
```

---

## 🎉 Recommendation

**For Testing:** Ngrok (5 menit setup)
**For Home/Personal:** Cloudflare Tunnel (gratis, aman)
**For Production:** VPS + Let's Encrypt (professional, scalable)

Mau pakai yang mana? 😊
