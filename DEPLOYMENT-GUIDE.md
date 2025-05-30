# 🚀 OG Sipariş Yönetim Sistemi - İki Repository Deployment Rehberi

## 📋 Genel Bakış

Proje iki ayrı repository olarak deploy edilir:
- **Backend API:** `api.ogsiparis.com` (Node.js + PM2)
- **Frontend:** `ogsiparis.com` (Static files)

## 🏗 Mimari

```
┌─────────────────────┐    ┌─────────────────────┐
│   Frontend (Vue.js) │    │  Backend (Next.js)  │
│   ogsiparis.com     │───▶│  api.ogsiparis.com  │
│   Static Hosting    │    │  PM2 + PostgreSQL   │
└─────────────────────┘    └─────────────────────┘
```

## 🔧 1. Backend Deployment (api.ogsiparis.com)

### CyberPanel'de Subdomain Oluşturma
```bash
# CyberPanel Admin Panel
# Subdomains > Create Subdomain
# Subdomain: api
# Domain: ogsiparis.com
# Path: /home/api.ogsiparis.com/public_html
```

### Backend Repository Clone
```bash
# SSH ile sunucuya bağlan
ssh root@your-server-ip

# Backend dizinine git
cd /home/api.ogsiparis.com/public_html

# Backend repository'yi clone et
git clone https://github.com/your-username/og-backend.git .

# Deploy script'i çalıştır
chmod +x deploy.sh
./deploy.sh
```

### Database Oluşturma
```bash
# CyberPanel > Databases > Create Database
Database Name: ogformdb
Username: ogform
Password: secret
Host: localhost
```

### PM2 ile Başlatma
```bash
# PM2 ile backend'i başlat
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# Status kontrol
pm2 status
pm2 logs og-backend
```

### Environment Variables (Backend)
```env
DATABASE_URL="postgresql://ogform:secret@localhost:5432/ogformdb?schema=public"
JWT_SECRET="og-siparis-super-secret-jwt-key-production-2024"
NODE_ENV=production
NEXT_PUBLIC_API_URL=https://api.ogsiparis.com/api
CORS_ORIGIN=https://ogsiparis.com
PORT=8080
```

## 🎨 2. Frontend Deployment (ogsiparis.com)

### Option A: CyberPanel/Hostinger (Static)
```bash
# Method 1: Local build + Upload
# Local'de frontend repository'yi clone et
git clone https://github.com/your-username/og-frontend.git
cd og-frontend

# Deploy script'i çalıştır
chmod +x deploy.sh
./deploy.sh

# dist/ klasörünün İÇERİĞİNİ sunucuya upload et
# FTP/SFTP ile /home/ogsiparis.com/public_html/ klasörüne
# Önemli: dist/ klasörünü değil, içindeki dosyaları kopyalayın!

# Method 2: Doğrudan sunucuda build (Önerilen)
# SSH ile sunucuya bağlan
ssh root@your-server-ip

# Domain klasörüne git
cd /home/ogsiparis.com/public_html

# Mevcut dosyaları temizle
rm -rf *

# Frontend repository'yi clone et
git clone https://github.com/your-username/og-frontend.git temp-frontend
cd temp-frontend

# Build yap
npm install
npm run build

# Build dosyalarını public_html'e taşı
mv dist/* /home/ogsiparis.com/public_html/

# Temp klasörü sil
cd /home/ogsiparis.com/public_html
rm -rf temp-frontend
```

### Option B: Netlify (Önerilen)
```bash
# Netlify'a giriş yap
# New site from Git > GitHub repository seçin

# Build settings:
Build command: npm run build
Publish directory: dist

# Environment variables:
VITE_API_BASE_URL=https://api.ogsiparis.com/api
NODE_ENV=production
```

### Option C: Vercel
```bash
# Vercel'e giriş yap
# Import repository

# Framework: Vue.js
# Build command: npm run build
# Output directory: dist

# Environment variables:
VITE_API_BASE_URL=https://api.ogsiparis.com/api
NODE_ENV=production
```

## 🔗 3. Domain Konfigürasyonu

### DNS Ayarları
```
# A Records
ogsiparis.com        → Frontend IP (Netlify/Hostinger)
api.ogsiparis.com    → Backend IP (Hostinger VPS)

# CNAME (Netlify kullanıyorsanız)
ogsiparis.com        → your-site.netlify.app
```

### SSL Sertifikaları
```bash
# Backend (CyberPanel)
# SSL > Issue SSL > api.ogsiparis.com
# Let's Encrypt otomatik

# Frontend (Netlify)
# Otomatik SSL aktif

# Frontend (Hostinger)
# SSL > Issue SSL > ogsiparis.com
```

## 🧪 4. Test ve Doğrulama

### Backend API Test
```bash
# Health check
curl https://api.ogsiparis.com/api/dropdown

# Recipe cost test
curl "https://api.ogsiparis.com/api/urunler/1/recete-maliyet?miktar=1000"
# Beklenen: {"toplamMaliyet": 15.01, ...}

# CORS test
curl -H "Origin: https://ogsiparis.com" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: X-Requested-With" \
     -X OPTIONS \
     https://api.ogsiparis.com/api/dropdown
```

### Frontend Test
```bash
# Frontend yükleme
curl https://ogsiparis.com

# API bağlantısı (browser console)
fetch('https://api.ogsiparis.com/api/dropdown')
  .then(r => r.json())
  .then(console.log)
```

## 📊 5. Production Features

### ✅ Çalışan Özellikler
- **Recipe Cost Calculation:** 15.01₺/KG (Peynirli Su Böreği)
- **Product Management:** CRUD operations
- **Order Management:** Full workflow
- **Customer Management:** Cari hesap sistemi
- **Stock Management:** Hammadde takibi
- **PDF Export:** Sipariş ve raporlar
- **Authentication:** JWT token sistemi

### 📈 Performance
- **Backend Response:** <100ms average
- **Frontend Load:** <3s first load
- **Database:** PostgreSQL optimized
- **Build Size:** ~2MB (gzipped)

## 🚨 6. Troubleshooting

### Backend Issues
```bash
# PM2 logs
pm2 logs og-backend

# Database connection
psql -h localhost -U ogform -d ogformdb

# Port check
netstat -tlnp | grep 8080

# Restart
pm2 restart og-backend
```

### Frontend Issues
```bash
# Build errors
npm run build

# API connection test
curl https://api.ogsiparis.com/api/dropdown

# CORS errors
# Backend CORS_ORIGIN kontrol edin
```

### Common CORS Issues
```javascript
// Backend .env kontrol
CORS_ORIGIN=https://ogsiparis.com

// Frontend API URL kontrol
VITE_API_BASE_URL=https://api.ogsiparis.com/api
```

## 📝 7. Maintenance

### Backend Updates
```bash
cd /home/api.ogsiparis.com/public_html
git pull origin main
npm install
npm run build
pm2 restart og-backend
```

### Frontend Updates
```bash
# Netlify: Otomatik deploy (git push)
# Hostinger: Manual upload
git pull origin main
npm run build
# Upload dist/ contents
```

### Database Backup
```bash
# PostgreSQL backup
pg_dump -h localhost -U ogform ogformdb > backup.sql

# Restore
psql -h localhost -U ogform ogformdb < backup.sql
```

## 📞 Support

### URLs
- **Frontend:** https://ogsiparis.com
- **Backend API:** https://api.ogsiparis.com/api
- **Admin Panel:** https://ogsiparis.com/admin

### Key Metrics
- **Recipe Cost:** 15.01₺/KG (Peynirli Su Böreği)
- **Database:** 13 reçete, 38 ürün
- **API Endpoints:** 15+ endpoints
- **Response Time:** <100ms average

### Repository Structure
```
og-backend/          # Backend API repository
├── pages/api/       # Next.js API routes
├── prisma/          # Database schema & seed
├── ecosystem.config.js
├── deploy.sh
└── README.md

og-frontend/         # Frontend repository  
├── src/             # Vue.js source
├── dist/            # Build output
├── deploy.sh
└── README.md
``` 