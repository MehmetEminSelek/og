# 🚀 OG Sipariş Yönetim Sistemi - Production Deployment Rehberi

## 📋 Genel Bakış

Bu rehber, OG Sipariş Yönetim Sistemi'nin production ortamına nasıl deploy edileceğini adım adım açıklar.

### Sistem Mimarisi
- **Frontend:** Vue.js 3 + Vuetify (Static Files) - `ogsiparis.com`
- **Backend:** Next.js API + Socket.IO - `ogsiparis.com:3000`
- **Database:** PostgreSQL
- **Process Manager:** PM2
- **Web Server:** LiteSpeed/OpenLiteSpeed (CyberPanel)

---

## 🔧 1. Sunucu Hazırlığı

### Gereksinimler
- CyberPanel/LiteSpeed kurulu sunucu
- Node.js 18+
- PostgreSQL 13+
- PM2
- Git

### Sunucu Kurulumu
```bash
# Node.js kurulumu (eğer yoksa)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# PM2 kurulumu
npm install -g pm2

# PostgreSQL kurulumu (eğer yoksa)
sudo apt-get install postgresql postgresql-contrib
```

---

## 🗄️ 2. Database Kurulumu

### PostgreSQL Database Oluşturma

```bash
# PostgreSQL'e bağlan
sudo -u postgres psql

# Database ve user oluştur
CREATE DATABASE ogformdb;
CREATE USER ogform WITH PASSWORD 'secret';
GRANT ALL PRIVILEGES ON DATABASE ogformdb TO ogform;
ALTER USER ogform CREATEDB;

# Schema yetkilerini ver
\c ogformdb
GRANT ALL ON SCHEMA public TO ogform;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ogform;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ogform;

# Çık
\q
```

---

## 🔧 3. Backend Deployment

### Backend Repository Clone ve Kurulum

```bash
# Backend dizinine git
cd /home/ogsiparis.com

# Backend'i clone et
git clone https://github.com/MehmetEminSelek/ogBackend.git
cd ogBackend

# Environment dosyasını oluştur
cat > .env << 'EOF'
# Database
DATABASE_URL="postgresql://ogform:secret@localhost:5432/ogformdb?schema=public"

# JWT
JWT_SECRET="og-siparis-super-secret-jwt-key-production-2024-very-long-and-secure"

# Environment
NODE_ENV=production
PORT=3000

# API URLs
NEXT_PUBLIC_API_URL=https://ogsiparis.com:3000/api
CORS_ORIGIN=https://ogsiparis.com
EOF

# Dependencies yükle
npm install --production

# Prisma setup
npx prisma generate
npx prisma db push

# Seed data yükle (ilk kurulumda)
npx prisma db seed
```

### Backend Başlatma Script'i

```bash
# deploy-backend.sh oluştur
cat > deploy-backend.sh << 'EOF'
#!/bin/bash
echo "🚀 Backend deployment başlıyor..."

# Git pull
git pull origin main

# Dependencies güncelle
npm install --production

# Prisma güncelle
npx prisma generate
npx prisma db push

# PM2 restart
pm2 restart og-backend || pm2 start server.js --name og-backend

echo "✅ Backend deployment tamamlandı!"
EOF

chmod +x deploy-backend.sh
```

### PM2 ile Backend'i Başlat

```bash
# ecosystem.config.js oluştur
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'og-backend',
    script: './server.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: 'logs/err.log',
    out_file: 'logs/out.log',
    log_file: 'logs/combined.log',
    time: true
  }]
}
EOF

# PM2 ile başlat
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

---

## 🎨 4. Frontend Deployment

### Frontend Build ve Deploy

```bash
# Frontend dizinine git
cd /home/ogsiparis.com/public_html

# Frontend'i clone et
git clone https://github.com/MehmetEminSelek/ogFrontend.git .

# Environment dosyasını oluştur
cat > .env.production << 'EOF'
VITE_API_BASE_URL=https://ogsiparis.com:3000/api
EOF

# Vite config'i kontrol et (base: '/' olmalı)
cat vite.config.js

# Dependencies yükle ve build yap
npm install
npm run build

# Build dosyalarını root'a taşı
cp -r dist/* .

# Gereksiz dosyaları temizle
rm -rf node_modules src package* *.md .git* vite* postcss* tailwind* docker* deploy* dist .env*

# Index.html'i güncelle (hash'li dosya isimleri için)
JS_FILE=$(ls assets/ | grep -E "index-.*\.js$" | head -1)
CSS_FILE=$(ls assets/ | grep -E "index-.*\.css$" | head -1)

cat > index.html << EOF
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ömer Güllü Sistemi - Baklavacı Yönetim Paneli</title>
    <meta name="description" content="Ömer Güllü Baklavacı İşletmesi - Modern Sipariş ve Stok Yönetim Sistemi">
    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    <script type="module" crossorigin src="/assets/$JS_FILE"></script>
    <link rel="stylesheet" crossorigin href="/assets/$CSS_FILE">
</head>
<body>
    <div id="app"></div>
</body>
</html>
EOF
```

### Frontend Deployment Script

```bash
# deploy-frontend.sh oluştur
cat > /home/ogsiparis.com/deploy-frontend.sh << 'EOF'
#!/bin/bash
echo "🚀 Frontend deployment başlıyor..."

cd /home/ogsiparis.com/public_html

# Backup al
rm -rf backup_old
mkdir backup_old
mv * backup_old/ 2>/dev/null

# Frontend'i clone et
git clone https://github.com/MehmetEminSelek/ogFrontend.git temp
cd temp

# Environment ayarla
echo "VITE_API_BASE_URL=https://ogsiparis.com:3000/api" > .env

# Build yap
npm install
npm run build

# Dosyaları taşı
cp -r dist/* /home/ogsiparis.com/public_html/
cd /home/ogsiparis.com/public_html
rm -rf temp

# Index.html'i güncelle
JS_FILE=$(ls assets/ | grep -E "index-.*\.js$" | head -1)
CSS_FILE=$(ls assets/ | grep -E "index-.*\.css$" | head -1)

cat > index.html << HTML
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ömer Güllü Sistemi - Baklavacı Yönetim Paneli</title>
    <meta name="description" content="Ömer Güllü Baklavacı İşletmesi - Modern Sipariş ve Stok Yönetim Sistemi">
    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    <script type="module" crossorigin src="/assets/$JS_FILE"></script>
    <link rel="stylesheet" crossorigin href="/assets/$CSS_FILE">
</head>
<body>
    <div id="app"></div>
</body>
</html>
HTML

echo "✅ Frontend deployment tamamlandı!"
EOF

chmod +x /home/ogsiparis.com/deploy-frontend.sh
```

---

## 🔧 5. Web Server Konfigürasyonu

### LiteSpeed/OpenLiteSpeed vHost Config

CyberPanel > Websites > ogsiparis.com > vHost Conf:

```apache
docRoot                   $VH_ROOT/public_html
vhDomain                  $VH_NAME
vhAliases                 www.$VH_NAME
enableGzip                1

index  {
  useServer               0
  indexFiles              index.html
}

# SPA Routing için Rewrite Rules
rewrite  {
  enable                  1
  autoLoadHtaccess        1
  rules                   <<<END_rules
  RewriteEngine On
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
  END_rules
}

# MIME Types
context ~ \.js$ {
  location                $VH_ROOT/public_html/$0
  allowBrowse             1
  extraHeaders            <<<END_extraHeaders
Content-Type application/javascript
X-Content-Type-Options nosniff
END_extraHeaders
}

context ~ \.css$ {
  location                $VH_ROOT/public_html/$0
  allowBrowse             1
  extraHeaders            <<<END_extraHeaders
Content-Type text/css
X-Content-Type-Options nosniff
END_extraHeaders
}
```

### Firewall Ayarları

```bash
# Port 3000'i aç
firewall-cmd --permanent --add-port=3000/tcp
firewall-cmd --reload
```

---

## 🔐 6. Güvenlik Ayarları

### SSL Sertifikası
CyberPanel'de Let's Encrypt SSL sertifikası aktifleştirin.

### Environment Güvenliği
```bash
# .env dosyalarını güvenli hale getir
chmod 600 /home/ogsiparis.com/ogBackend/.env
```

### Database Güvenliği
Production'da güçlü şifreler kullanın ve düzenli backup alın.

---

## 🧪 7. Test ve Doğrulama

### Backend Test
```bash
# API Health Check
curl http://localhost:3000/api/dropdown

# External Access Test
curl https://ogsiparis.com:3000/api/dropdown
```

### Frontend Test
```bash
# Ana sayfa
curl https://ogsiparis.com

# Browser'da test
# https://ogsiparis.com
```

### Admin User Oluşturma
```bash
# PostgreSQL'de admin user oluştur
sudo -u postgres psql -d ogformdb

INSERT INTO "User" (email, ad, "passwordHash", role, "createdAt")
VALUES ('admin@ogform.com', 'Admin User', '$2b$10$K7L1OJ45/4Y2nIvhRVpCe.FSmhDdWoXehVzJptJ/op0lSsvqNu/1u', 'ADMIN', NOW());

\q
```

**Giriş Bilgileri:**
- Email: admin@ogform.com
- Şifre: Admin123!

---

## 🔄 8. Güncelleme Prosedürü

### Backend Güncelleme
```bash
cd /home/ogsiparis.com/ogBackend
./deploy-backend.sh
```

### Frontend Güncelleme
```bash
/home/ogsiparis.com/deploy-frontend.sh
```

---

## 🚨 9. Troubleshooting

### Backend Sorunları
```bash
# PM2 logları
pm2 logs og-backend

# PM2 restart
pm2 restart og-backend

# Port kontrolü
netstat -tlnp | grep 3000
```

### Frontend Sorunları
```bash
# Cache temizleme
rm -rf /home/ogsiparis.com/public_html/*
# Frontend'i yeniden deploy et

# MIME type sorunları için vHost config kontrol
```

### Database Sorunları
```bash
# PostgreSQL status
sudo systemctl status postgresql

# Database bağlantı testi
psql -h localhost -U ogform -d ogformdb
```

---

## 📊 10. Monitoring ve Maintenance

### PM2 Monitoring
```bash
# PM2 durumu
pm2 status

# PM2 monitoring
pm2 monit
```

### Log Rotation
```bash
# PM2 log rotation
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

### Backup Script
```bash
# backup.sh oluştur
cat > /home/ogsiparis.com/backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/ogsiparis.com/backups"

mkdir -p $BACKUP_DIR

# Database backup
pg_dump -h localhost -U ogform ogformdb > $BACKUP_DIR/db_backup_$DATE.sql

# File backup
tar -czf $BACKUP_DIR/files_backup_$DATE.tar.gz /home/ogsiparis.com/ogBackend /home/ogsiparis.com/public_html

# Eski backupları sil (7 günden eski)
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup tamamlandı: $DATE"
EOF

chmod +x /home/ogsiparis.com/backup.sh

# Cron job ekle
crontab -e
# 0 3 * * * /home/ogsiparis.com/backup.sh
```

---

## ✅ Deployment Checklist

- [ ] PostgreSQL database oluşturuldu
- [ ] Database user ve yetkiler verildi
- [ ] Backend clone edildi
- [ ] Backend .env dosyası oluşturuldu
- [ ] Backend dependencies yüklendi
- [ ] Prisma migration çalıştırıldı
- [ ] PM2 ile backend başlatıldı
- [ ] Frontend clone edildi
- [ ] Frontend build alındı
- [ ] Frontend dosyaları public_html'e taşındı
- [ ] Firewall'da port 3000 açıldı
- [ ] SSL sertifikası aktif
- [ ] Admin user oluşturuldu
- [ ] Sistem test edildi

---

## 📞 Destek

Deployment sırasında sorun yaşarsanız:
1. PM2 loglarını kontrol edin
2. Browser console'u kontrol edin
3. Network sekmesinde API isteklerini kontrol edin
4. Database bağlantısını test edin

**Başarılar!** 🚀 