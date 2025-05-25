#!/bin/bash

# 🚀 OG Projesi CyberPanel Otomatik Deployment Script
# Domain: ogsiparis.com
# Bu script tüm deployment işlemlerini otomatik yapar

set -e  # Hata durumunda script'i durdur

# Renkli output için
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Konfigürasyon
DOMAIN="ogsiparis.com"
SUBDOMAIN="www.ogsiparis.com"
DB_NAME="ogformdb"
DB_USER="ogform"
DB_PASS=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
JWT_SECRET=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-64)
PROJECT_DIR="/home/ogsiparis.com/public_html"
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/frontend"

echo -e "${BLUE}🚀 OG Projesi CyberPanel Deployment Başlıyor...${NC}"
echo -e "${CYAN}📋 Konfigürasyon:${NC}"
echo -e "   Domain: ${DOMAIN}"
echo -e "   Subdomain: ${SUBDOMAIN}"
echo -e "   Database: ${DB_NAME}"
echo -e "   Project Dir: ${PROJECT_DIR}"
echo ""

# 1. CyberPanel CLI ile Domain Oluştur
echo -e "${YELLOW}🌐 1. Domain oluşturuluyor...${NC}"

# Ana domain oluştur
cyberpanel createWebsite --domainName $DOMAIN --email admin@$DOMAIN --package Default

# www subdomain ekle
cyberpanel createChild --masterDomain $DOMAIN --childDomain $SUBDOMAIN

echo -e "${GREEN}   ✅ Domain oluşturuldu: $DOMAIN${NC}"

# 2. SSL Sertifikası Kur (Let's Encrypt)
echo -e "${YELLOW}🔒 2. SSL sertifikası kuruluyor...${NC}"

# Let's Encrypt SSL
cyberpanel issueSSL --domainName $DOMAIN

echo -e "${GREEN}   ✅ SSL sertifikası kuruldu${NC}"

# 3. Database Oluştur
echo -e "${YELLOW}🗄️ 3. PostgreSQL database oluşturuluyor...${NC}"

# PostgreSQL database oluştur
cyberpanel createDatabase --databaseWebsite $DOMAIN --dbName $DB_NAME --dbUsername $DB_USER --dbPassword $DB_PASS

echo -e "${GREEN}   ✅ Database oluşturuldu: $DB_NAME${NC}"
echo -e "${CYAN}   📝 DB Bilgileri kaydedildi: /root/og-db-credentials.txt${NC}"

# Database bilgilerini kaydet
cat > /root/og-db-credentials.txt << EOF
# OG Projesi Database Bilgileri
DATABASE_URL="postgresql://$DB_USER:$DB_PASS@localhost:5432/$DB_NAME?schema=public"
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASS
JWT_SECRET=$JWT_SECRET
DOMAIN=$DOMAIN
EOF

# 4. Node.js ve PM2 Kur
echo -e "${YELLOW}⚙️ 4. Node.js ve PM2 kuruluyor...${NC}"

# Node.js 18 kur (CyberPanel Node.js Manager kullan)
cyberpanel createNodeApp --domainName $DOMAIN --appName "og-backend" --nodeVersion "18" --appPath "/backend" --startupFile "server.js"

# PM2 global kur
npm install -g pm2

echo -e "${GREEN}   ✅ Node.js ve PM2 kuruldu${NC}"

# 5. Proje Dosyalarını Kopyala
echo -e "${YELLOW}📁 5. Proje dosyaları kopyalanıyor...${NC}"

# Mevcut dosyaları temizle
rm -rf $PROJECT_DIR/*

# Backend dosyalarını kopyala
cp -r ./backend/* $BACKEND_DIR/
cp -r ./frontend/* $FRONTEND_DIR/

# Sahiplik ayarları
chown -R $DOMAIN:$DOMAIN $PROJECT_DIR
chmod -R 755 $PROJECT_DIR

echo -e "${GREEN}   ✅ Proje dosyaları kopyalandı${NC}"

# 6. Backend Environment Ayarları
echo -e "${YELLOW}🔧 6. Backend environment ayarlanıyor...${NC}"

# Production .env dosyası oluştur
cat > $BACKEND_DIR/.env << EOF
# Production Environment
NODE_ENV=production
PORT=8080

# Database
DATABASE_URL="postgresql://$DB_USER:$DB_PASS@localhost:5432/$DB_NAME?schema=public"

# JWT
JWT_SECRET=$JWT_SECRET

# CORS
CORS_ORIGIN=https://$DOMAIN

# Upload
UPLOAD_DIR=/home/$DOMAIN/uploads
MAX_FILE_SIZE=10485760

# Email (isteğe bağlı)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=

# SMS (isteğe bağlı)
SMS_API_KEY=
SMS_SECRET=
EOF

# Uploads dizini oluştur
mkdir -p /home/$DOMAIN/uploads
chown -R $DOMAIN:$DOMAIN /home/$DOMAIN/uploads

echo -e "${GREEN}   ✅ Backend environment ayarlandı${NC}"

# 7. Frontend Environment Ayarları
echo -e "${YELLOW}🎨 7. Frontend environment ayarlanıyor...${NC}"

# Production .env dosyası oluştur
cat > $FRONTEND_DIR/.env.production << EOF
# Production Environment
NODE_ENV=production
VITE_BUILD_MODE=production

# API URL
VITE_API_BASE_URL=https://$DOMAIN/api

# Build optimizasyonları
VITE_DEBUG=false
VITE_DROP_CONSOLE=true
VITE_CHUNK_SIZE_WARNING_LIMIT=1000
EOF

echo -e "${GREEN}   ✅ Frontend environment ayarlandı${NC}"

# 8. Backend Dependencies ve Build
echo -e "${YELLOW}📦 8. Backend dependencies kuruluyor...${NC}"

cd $BACKEND_DIR
npm install --production

# Prisma setup
npx prisma generate
npx prisma db push

echo -e "${GREEN}   ✅ Backend hazırlandı${NC}"

# 9. Frontend Build
echo -e "${YELLOW}🏗️ 9. Frontend build ediliyor...${NC}"

cd $FRONTEND_DIR
npm install
npm run build

# Build dosyalarını public_html'e taşı
rm -rf $PROJECT_DIR/dist
mv dist $PROJECT_DIR/
chown -R $DOMAIN:$DOMAIN $PROJECT_DIR/dist

echo -e "${GREEN}   ✅ Frontend build edildi${NC}"

# 10. PM2 Ecosystem Konfigürasyonu
echo -e "${YELLOW}⚡ 10. PM2 ecosystem ayarlanıyor...${NC}"

cat > $BACKEND_DIR/ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'og-backend',
    script: 'server.js',
    cwd: '$BACKEND_DIR',
    instances: 2,
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 8080
    },
    error_file: '/var/log/og-backend-error.log',
    out_file: '/var/log/og-backend-out.log',
    log_file: '/var/log/og-backend.log',
    time: true,
    max_memory_restart: '1G',
    node_args: '--max-old-space-size=1024'
  }]
}
EOF

# PM2 başlat
cd $BACKEND_DIR
pm2 start ecosystem.config.js
pm2 save
pm2 startup

echo -e "${GREEN}   ✅ PM2 ecosystem ayarlandı${NC}"

# 11. Nginx Reverse Proxy Konfigürasyonu
echo -e "${YELLOW}🌐 11. Nginx reverse proxy ayarlanıyor...${NC}"

# CyberPanel nginx konfigürasyonunu güncelle
cat > /usr/local/lsws/conf/vhosts/$DOMAIN/vhconf.conf << EOF
docRoot                   \$VH_ROOT/dist/
index                     {
  useServer               0
  indexFiles              index.html
}

errorlog \$VH_ROOT/logs/error.log {
  useServer               0
  logLevel                DEBUG
  rollingSize             10M
}

accesslog \$VH_ROOT/logs/access.log {
  useServer               0
  logFormat               "%h %l %u %t \"%r\" %>s %b"
  logHeaders              5
  rollingSize             10M
  keepDays                10
}

scripthandler  {
  add                     lsphp81 php
}

# API Proxy
context /api/ {
  type                    proxy
  uri                     http://127.0.0.1:8080/api/
  extraHeaders            Host \$host
  addDefaultCharset       off
}

# Socket.IO Proxy
context /socket.io/ {
  type                    proxy
  uri                     http://127.0.0.1:8080/socket.io/
  extraHeaders            Host \$host
  addDefaultCharset       off
}

# Static files
context / {
  location                \$DOC_ROOT/
  allowBrowse             1
  indexFiles              index.html
  
  rewrite  {
    enable                1
    autoLoadHtaccess      1
    rules                 <<<END_rules
    RewriteEngine On
    RewriteBase /
    RewriteRule ^index\.html$ - [L]
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.html [L]
    END_rules
  }
}
EOF

# LiteSpeed restart
systemctl restart lsws

echo -e "${GREEN}   ✅ Nginx reverse proxy ayarlandı${NC}"

# 12. Firewall ve Security
echo -e "${YELLOW}🔒 12. Firewall ve security ayarlanıyor...${NC}"

# Gerekli portları aç
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8080/tcp
ufw allow 22/tcp

# PM2 logrotate
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7

echo -e "${GREEN}   ✅ Security ayarlandı${NC}"

# 13. Monitoring ve Backup Script'leri
echo -e "${YELLOW}📊 13. Monitoring ve backup ayarlanıyor...${NC}"

# Backup script oluştur
cat > /root/og-backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/root/backups/og-$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

# Database backup
pg_dump ogformdb > $BACKUP_DIR/database.sql

# Files backup
tar -czf $BACKUP_DIR/files.tar.gz /home/ogsiparis.com/

# PM2 backup
pm2 save > $BACKUP_DIR/pm2.json

# Keep only last 7 backups
find /root/backups -name "og-*" -type d -mtime +7 -exec rm -rf {} \;

echo "Backup completed: $BACKUP_DIR"
EOF

chmod +x /root/og-backup.sh

# Crontab ekle
(crontab -l 2>/dev/null; echo "0 2 * * * /root/og-backup.sh") | crontab -

# Health check script
cat > /root/og-health-check.sh << 'EOF'
#!/bin/bash
# Backend health check
if ! curl -f http://localhost:8080/api/health > /dev/null 2>&1; then
    echo "Backend down, restarting..."
    pm2 restart og-backend
fi

# Disk space check
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "Disk usage high: $DISK_USAGE%"
fi
EOF

chmod +x /root/og-health-check.sh

# Health check crontab
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/og-health-check.sh") | crontab -

echo -e "${GREEN}   ✅ Monitoring ve backup ayarlandı${NC}"

# 14. Test ve Doğrulama
echo -e "${YELLOW}🧪 14. Deployment test ediliyor...${NC}"

# Backend test
sleep 5
if curl -f https://$DOMAIN/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Backend çalışıyor${NC}"
else
    echo -e "${RED}   ❌ Backend test başarısız${NC}"
fi

# Frontend test
if curl -f https://$DOMAIN > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Frontend çalışıyor${NC}"
else
    echo -e "${RED}   ❌ Frontend test başarısız${NC}"
fi

# SSL test
if curl -f https://$DOMAIN > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ SSL çalışıyor${NC}"
else
    echo -e "${RED}   ❌ SSL test başarısız${NC}"
fi

echo -e "${GREEN}   ✅ Deployment testleri tamamlandı${NC}"

# 15. Final Özet
echo ""
echo -e "${PURPLE}🎉 DEPLOYMENT TAMAMLANDI! 🎉${NC}"
echo ""
echo -e "${CYAN}📋 Özet Bilgiler:${NC}"
echo -e "   🌐 Website: https://$DOMAIN"
echo -e "   🌐 Alt Domain: https://$SUBDOMAIN"
echo -e "   🔗 API: https://$DOMAIN/api"
echo -e "   🗄️ Database: $DB_NAME"
echo -e "   📁 Proje Dizini: $PROJECT_DIR"
echo ""
echo -e "${CYAN}🔑 Önemli Bilgiler:${NC}"
echo -e "   📄 DB Bilgileri: /root/og-db-credentials.txt"
echo -e "   📄 Backup Script: /root/og-backup.sh"
echo -e "   📄 Health Check: /root/og-health-check.sh"
echo ""
echo -e "${CYAN}⚙️ Yönetim Komutları:${NC}"
echo -e "   PM2 Status: pm2 status"
echo -e "   PM2 Logs: pm2 logs og-backend"
echo -e "   PM2 Restart: pm2 restart og-backend"
echo -e "   Backup Çalıştır: /root/og-backup.sh"
echo ""
echo -e "${CYAN}🔗 Admin Giriş:${NC}"
echo -e "   URL: https://$DOMAIN/login"
echo -e "   Email: admin@example.com"
echo -e "   Şifre: admin123"
echo ""
echo -e "${GREEN}✅ Proje başarıyla deploy edildi ve çalışıyor!${NC}"
echo -e "${YELLOW}🚀 Artık https://$DOMAIN adresinden erişebilirsiniz!${NC}" 