# 🚀 OG Siparis Sistemi - Deployment Guide

## 📁 Proje Yapısı

```
og/
├── backend/                    # 🎯 Node.js Backend
│   ├── ecosystem.config.js    # PM2 konfigürasyonu
│   ├── webhook-receiver.js    # GitHub webhook listener
│   ├── server.js             # Ana backend server
│   ├── package.json          # Backend dependencies
│   └── ...
├── frontend/                   # 🎨 Vue.js Frontend
│   ├── package.json          # Frontend dependencies
│   ├── vite.config.js        # Vite konfigürasyonu
│   └── ...
├── veriler/                   # 📊 CSV verileri
└── README.md                  # Dokümantasyon
```

## 🎯 İki Ana Servis

1. **Backend**: `backend/` - Node.js API server (Port 3000)
2. **Frontend**: `frontend/` - Vue.js SPA (Build → Static files)

---

## 🔧 Development Setup

### **Backend Development**

```bash
cd backend
npm install
npm run dev          # Development server (Port 3000)
```

### **Frontend Development**

```bash
cd frontend
npm install
npm run dev          # Development server (Port 5173)
```

### **Database Setup**

```bash
cd backend
npx prisma generate
npx prisma db push
npm run seed         # CSV verilerini yükle
```

---

## 🚀 Production Deployment

### **1. Server Kurulum (Ubuntu/Debian)**

```bash
# Node.js 18+ yükle
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# PM2 yükle
sudo npm install -g pm2

# Nginx yükle
sudo apt update
sudo apt install nginx

# PostgreSQL yükle
sudo apt install postgresql postgresql-contrib
```

### **2. Proje Klonlama**

```bash
# Proje dizinini oluştur
sudo mkdir -p /home/ogsiparis.com/public_html
cd /home/ogsiparis.com/public_html

# GitHub'dan klonla (token ile)
git clone https://github.com/MehmetEminSelek/og.git .

# Yetkileri ayarla
sudo chown -R $USER:$USER /home/ogsiparis.com/public_html
```

### **3. Backend Setup**

```bash
cd backend

# Dependencies yükle
npm install --production

# Environment variables
cp .env.production .env
nano .env  # Database URL ve diğer ayarları düzenle

# Database setup
npx prisma generate
npx prisma db push
npm run seed

# PM2 ile başlat
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup
```

### **4. Frontend Build**

```bash
cd ../frontend

# Dependencies yükle
npm install

# Production build
npm run build

# Build dosyalarını kontrol et
ls -la dist/
```

### **5. Nginx Konfigürasyonu**

```nginx
# /etc/nginx/sites-available/ogsiparis.com
server {
    listen 80;
    listen [::]:80;
    server_name ogsiparis.com www.ogsiparis.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ogsiparis.com www.ogsiparis.com;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/ogsiparis.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ogsiparis.com/privkey.pem;
    
    # Frontend Static Files
    root /home/ogsiparis.com/public_html/frontend/dist;
    index index.html;
    
    # Vue.js SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Backend API
    location /api {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
    
    # Webhook Endpoint
    location /webhook {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 30;
        proxy_connect_timeout 30;
        proxy_send_timeout 30;
    }
    
    # Static file caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
}
```

```bash
# Nginx'i aktifleştir
sudo ln -s /etc/nginx/sites-available/ogsiparis.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 🔄 GitHub Webhook Setup

### **1. Environment Variables**

```bash
# Backend/.env dosyasına ekle
WEBHOOK_SECRET="your-super-secret-webhook-key-here"
PROJECT_PATH="/home/ogsiparis.com/public_html"
DATABASE_URL="postgresql://user:pass@localhost:5432/ogdb"
JWT_SECRET="your-jwt-secret-here"
```

### **2. GitHub Repository Ayarları**

1. **GitHub'da Repository → Settings → Webhooks → Add webhook**
   - **Payload URL**: `https://ogsiparis.com/webhook`
   - **Content type**: `application/json`  
   - **Secret**: `your-super-secret-webhook-key-here`
   - **Events**: `Just the push event`
   - **Active**: ✅ Checked

### **3. PM2 Restart (Webhook dahil)**

```bash
cd /home/ogsiparis.com/public_html/backend
pm2 restart ecosystem.config.js --env production
```

---

## 🔄 Otomatik Deployment Workflow

1. **Developer push yapar** → GitHub repository
2. **GitHub webhook gönderir** → `https://ogsiparis.com/webhook`
3. **Webhook receiver otomatik çalışır**:
   - `git pull origin master`
   - `cd backend && npm install --production`
   - `cd frontend && npm install && npm run build`
   - `cd backend && npx prisma generate && npx prisma db push`
   - `pm2 reload ecosystem.config.js --env production`

4. **Site güncellenir** → Canlı!

---

## 📊 Monitoring & Maintenance

### **PM2 Commands**

```bash
# Status kontrol
pm2 status

# Logs
pm2 logs og-backend --lines 50
pm2 logs og-webhook --lines 50

# Restart
pm2 restart og-backend
pm2 restart og-webhook

# Memory kullanımı
pm2 monit
```

### **Webhook Logs**

```bash
# Webhook logları
tail -f /home/ogsiparis.com/public_html/webhook.log

# Health check
curl https://ogsiparis.com/webhook/health

# Debug info
curl https://ogsiparis.com/webhook/debug
```

### **Database Backup**

```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump ogformdb > /backups/og_backup_$DATE.sql
find /backups -name "og_backup_*.sql" -mtime +7 -delete
```

---

## 🎯 Quick Commands

### **Full Deployment**

```bash
# Manuel deployment
cd /home/ogsiparis.com/public_html
git pull origin master
cd backend && npm install --production
cd ../frontend && npm install && npm run build
cd ../backend && npx prisma generate && npx prisma db push
pm2 reload ecosystem.config.js --env production
```

### **Frontend Only Update**

```bash
cd /home/ogsiparis.com/public_html/frontend
npm run build
```

### **Backend Only Update**

```bash
cd /home/ogsiparis.com/public_html/backend
npm install --production
pm2 restart og-backend
```

---

## 🔧 Troubleshooting

### **Common Issues**

1. **PM2 processes not running**:
   ```bash
   cd backend
   pm2 start ecosystem.config.js --env production
   ```

2. **Frontend not updating**:
   ```bash
   cd frontend
   rm -rf dist/
   npm run build
   ```

3. **Database connection issues**:
   ```bash
   cd backend
   npx prisma db push
   npx prisma generate
   ```

4. **Webhook not receiving**:
   - Check GitHub webhook delivery
   - Verify webhook secret
   - Check PM2 logs: `pm2 logs og-webhook`

---

## 🎉 Success!

Artık projeniz tamamen otomatik deployment ile çalışıyor! 🚀

**Frontend**: Vue.js SPA → Nginx static files  
**Backend**: Node.js API → PM2 cluster mode  
**Webhook**: GitHub → Otomatik deployment 