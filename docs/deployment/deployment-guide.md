# Hostinger VPS Deployment Rehberi

## 🚀 VPS Bilgileri
- **IP**: 147.93.123.161
- **OS**: AlmaLinux 9 + CyberPanel
- **SSH User**: root
- **RAM**: 32 GB
- **Disk**: 400 GB

## 📋 Deployment Adımları

### 1. SSH Bağlantısı
```bash
ssh root@147.93.123.161
```

### 2. Sistem Güncellemesi
```bash
dnf update -y
```

### 3. Node.js Kurulumu
```bash
# Node.js 20 kurulumu
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs
node --version
npm --version
```

### 4. PostgreSQL Kurulumu
```bash
# PostgreSQL 15 kurulumu
dnf install -y postgresql15-server postgresql15
postgresql-15-setup initdb
systemctl enable postgresql-15
systemctl start postgresql-15

# PostgreSQL kullanıcısı oluşturma
sudo -u postgres psql
CREATE USER ogform WITH PASSWORD 'your_secure_password';
CREATE DATABASE ogformdb OWNER ogform;
GRANT ALL PRIVILEGES ON DATABASE ogformdb TO ogform;
\q
```

### 5. PM2 Kurulumu
```bash
npm install -g pm2
```

### 6. Git Kurulumu
```bash
dnf install -y git
```

### 7. Proje Klonlama
```bash
cd /var/www
git clone https://github.com/yourusername/og.git
cd og
```

### 8. Backend Kurulumu
```bash
cd ogBackend
npm install
```

### 9. Environment Dosyası
```bash
cp .env.production .env
# .env dosyasını düzenle:
nano .env
```

### 10. Database Migration
```bash
npx prisma migrate deploy
npx prisma generate
```

### 11. Frontend Build
```bash
cd ../ogFrontend
npm install
npm run build
```

### 12. Nginx Konfigürasyonu
```bash
# Nginx config dosyası oluştur
nano /etc/nginx/conf.d/og.conf
```

### 13. SSL Sertifikası
```bash
# Let's Encrypt kurulumu
dnf install -y certbot python3-certbot-nginx
certbot --nginx -d yourdomain.com
```

### 14. PM2 ile Başlatma
```bash
cd /var/www/og/ogBackend
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## 🔧 Nginx Konfigürasyonu

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # Frontend (Vue.js)
    location / {
        root /var/www/og/ogFrontend/dist;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Socket.IO
    location /socket.io/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🔐 Güvenlik Ayarları

### Firewall Konfigürasyonu
```bash
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload
```

### PostgreSQL Güvenlik
```bash
# PostgreSQL config düzenle
nano /var/lib/pgsql/15/data/postgresql.conf
# listen_addresses = 'localhost'

nano /var/lib/pgsql/15/data/pg_hba.conf
# local   all             ogform                                  md5
```

## 📊 Monitoring

### PM2 Monitoring
```bash
pm2 monit
pm2 logs
pm2 status
```

### Sistem Monitoring
```bash
htop
df -h
free -h
```

## 🔄 Güncelleme Süreci

```bash
cd /var/www/og
git pull origin main

# Backend güncelleme
cd ogBackend
npm install
npx prisma migrate deploy
pm2 restart backend

# Frontend güncelleme
cd ../ogFrontend
npm install
npm run build
```

## 🆘 Sorun Giderme

### Log Kontrolleri
```bash
# PM2 logs
pm2 logs backend

# Nginx logs
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log

# PostgreSQL logs
tail -f /var/lib/pgsql/15/data/log/postgresql-*.log
```

### Servis Durumları
```bash
systemctl status nginx
systemctl status postgresql-15
pm2 status
``` 