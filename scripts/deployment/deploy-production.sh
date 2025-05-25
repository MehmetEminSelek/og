#!/bin/bash

# 🚀 OG Projesi Production Deployment Script
# Bu script projeyi production ortamına deploy eder

set -e  # Hata durumunda script'i durdur

echo "🚀 OG Projesi Production Deployment Başlıyor..."

# Renkli output için
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Konfigürasyon
BACKEND_DIR="/var/www/og/backend"
FRONTEND_DIR="/var/www/og/frontend"
NGINX_CONFIG="/etc/nginx/conf.d/og.conf"
DOMAIN="${DOMAIN:-your-domain.com}"
API_URL="${API_URL:-https://$DOMAIN/api}"

echo -e "${BLUE}📋 Deployment Konfigürasyonu:${NC}"
echo -e "   Domain: ${DOMAIN}"
echo -e "   API URL: ${API_URL}"
echo -e "   Backend Dir: ${BACKEND_DIR}"
echo -e "   Frontend Dir: ${FRONTEND_DIR}"
echo ""

# 1. Sistem güncellemeleri
echo -e "${YELLOW}📦 Sistem güncellemeleri kontrol ediliyor...${NC}"
dnf update -y

# 2. Node.js ve PM2 kontrolü
echo -e "${YELLOW}🔧 Node.js ve PM2 kontrol ediliyor...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js bulunamadı. Yükleniyor...${NC}"
    curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
    dnf install -y nodejs
fi

if ! command -v pm2 &> /dev/null; then
    echo -e "${RED}❌ PM2 bulunamadı. Yükleniyor...${NC}"
    npm install -g pm2
fi

# 3. PostgreSQL kontrolü
echo -e "${YELLOW}🗄️ PostgreSQL kontrol ediliyor...${NC}"
if ! systemctl is-active --quiet postgresql-15; then
    echo -e "${RED}❌ PostgreSQL çalışmıyor. Başlatılıyor...${NC}"
    systemctl start postgresql-15
    systemctl enable postgresql-15
fi

# 4. Proje dizinlerini oluştur
echo -e "${YELLOW}📁 Proje dizinleri hazırlanıyor...${NC}"
mkdir -p /var/www/og
cd /var/www/og

# 5. Git repository'yi klonla veya güncelle
if [ -d ".git" ]; then
    echo -e "${YELLOW}🔄 Mevcut repository güncelleniyor...${NC}"
    git pull origin main
else
    echo -e "${YELLOW}📥 Repository klonlanıyor...${NC}"
    git clone https://github.com/your-username/og.git .
fi

# 6. Backend deployment
echo -e "${BLUE}🔧 Backend deployment başlıyor...${NC}"
cd $BACKEND_DIR

# Environment dosyasını oluştur
echo -e "${YELLOW}⚙️ Backend environment konfigürasyonu...${NC}"
cat > .env << EOF
DATABASE_URL="postgresql://ogform:$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)@localhost:5432/ogformdb?schema=public"
JWT_SECRET=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-50)
NODE_ENV=production
PORT=8080
CORS_ORIGIN=https://$DOMAIN
EOF

# Backend bağımlılıklarını yükle
echo -e "${YELLOW}📦 Backend bağımlılıkları yükleniyor...${NC}"
npm install --production

# Prisma setup
echo -e "${YELLOW}🗄️ Database migration ve Prisma setup...${NC}"
npx prisma generate
npx prisma migrate deploy

# PM2 ile backend'i başlat
echo -e "${YELLOW}🚀 Backend PM2 ile başlatılıyor...${NC}"
pm2 delete backend 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save

# 7. Frontend deployment
echo -e "${BLUE}🎨 Frontend deployment başlıyor...${NC}"
cd $FRONTEND_DIR

# Frontend environment dosyasını oluştur
echo -e "${YELLOW}⚙️ Frontend environment konfigürasyonu...${NC}"
cat > .env.production << EOF
VITE_API_BASE_URL=$API_URL
NODE_ENV=production
VITE_BUILD_MODE=production
VITE_DEBUG=false
VITE_DROP_CONSOLE=true
EOF

# Frontend bağımlılıklarını yükle
echo -e "${YELLOW}📦 Frontend bağımlılıkları yükleniyor...${NC}"
npm install

# Frontend build
echo -e "${YELLOW}🏗️ Frontend build ediliyor...${NC}"
npm run build

# 8. Nginx konfigürasyonu
echo -e "${BLUE}🌐 Nginx konfigürasyonu yapılıyor...${NC}"
cat > $NGINX_CONFIG << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Frontend static files
    location / {
        root $FRONTEND_DIR/dist;
        try_files \$uri \$uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Backend API proxy
    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
}
EOF

# Nginx'i test et ve yeniden başlat
echo -e "${YELLOW}🔄 Nginx konfigürasyonu test ediliyor...${NC}"
nginx -t
systemctl reload nginx

# 9. SSL sertifikası (Let's Encrypt)
if command -v certbot &> /dev/null && [ "$DOMAIN" != "your-domain.com" ]; then
    echo -e "${YELLOW}🔒 SSL sertifikası kuruluyor...${NC}"
    certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN
fi

# 10. Firewall ayarları
echo -e "${YELLOW}🔥 Firewall ayarları yapılıyor...${NC}"
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# 11. Sistem servislerini enable et
echo -e "${YELLOW}⚙️ Sistem servisleri enable ediliyor...${NC}"
systemctl enable nginx
systemctl enable postgresql-15

# 12. PM2 startup script
echo -e "${YELLOW}🚀 PM2 startup script ayarlanıyor...${NC}"
pm2 startup systemd -u root --hp /root
pm2 save

# 13. Deployment testi
echo -e "${BLUE}🧪 Deployment testi yapılıyor...${NC}"
sleep 5

# Backend health check
if curl -f http://localhost:8080/api/health &>/dev/null; then
    echo -e "${GREEN}✅ Backend health check başarılı${NC}"
else
    echo -e "${RED}❌ Backend health check başarısız${NC}"
fi

# Frontend check
if [ -f "$FRONTEND_DIR/dist/index.html" ]; then
    echo -e "${GREEN}✅ Frontend build başarılı${NC}"
else
    echo -e "${RED}❌ Frontend build başarısız${NC}"
fi

# Nginx check
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✅ Nginx çalışıyor${NC}"
else
    echo -e "${RED}❌ Nginx çalışmıyor${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Deployment tamamlandı!${NC}"
echo -e "${BLUE}📊 Deployment Özeti:${NC}"
echo -e "   🌐 Website: http://$DOMAIN"
echo -e "   🔧 API: http://$DOMAIN/api"
echo -e "   📁 Backend: $BACKEND_DIR"
echo -e "   🎨 Frontend: $FRONTEND_DIR"
echo ""
echo -e "${YELLOW}📋 Yararlı Komutlar:${NC}"
echo -e "   pm2 status          - Backend durumu"
echo -e "   pm2 logs backend    - Backend logları"
echo -e "   systemctl status nginx - Nginx durumu"
echo -e "   tail -f /var/log/nginx/error.log - Nginx logları"
echo ""
echo -e "${GREEN}✨ Deployment başarıyla tamamlandı! ✨${NC}" 