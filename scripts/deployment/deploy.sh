#!/bin/bash

# Hostinger VPS Deployment Script
# Bu script'i VPS'te çalıştırın

echo "🚀 Hostinger VPS Deployment Başlıyor..."

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Hata durumunda script'i durdur
set -e

# Fonksiyonlar
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Sistem güncellemesi
print_status "Sistem güncelleniyor..."
dnf update -y

# 2. Node.js kurulumu kontrolü
if ! command -v node &> /dev/null; then
    print_status "Node.js kuruluyor..."
    curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
    dnf install -y nodejs
else
    print_status "Node.js zaten kurulu: $(node --version)"
fi

# 3. PM2 kurulumu kontrolü
if ! command -v pm2 &> /dev/null; then
    print_status "PM2 kuruluyor..."
    npm install -g pm2
else
    print_status "PM2 zaten kurulu: $(pm2 --version)"
fi

# 4. PostgreSQL kurulumu kontrolü
if ! systemctl is-active --quiet postgresql-15; then
    print_status "PostgreSQL kuruluyor..."
    dnf install -y postgresql15-server postgresql15
    postgresql-15-setup initdb
    systemctl enable postgresql-15
    systemctl start postgresql-15
    
    print_warning "PostgreSQL kuruldu. Veritabanı kullanıcısını manuel olarak oluşturmanız gerekiyor:"
    echo "sudo -u postgres psql"
    echo "CREATE USER ogform WITH PASSWORD 'your_secure_password';"
    echo "CREATE DATABASE ogformdb OWNER ogform;"
    echo "GRANT ALL PRIVILEGES ON DATABASE ogformdb TO ogform;"
    echo "\\q"
else
    print_status "PostgreSQL zaten çalışıyor"
fi

# 5. Git kurulumu kontrolü
if ! command -v git &> /dev/null; then
    print_status "Git kuruluyor..."
    dnf install -y git
else
    print_status "Git zaten kurulu: $(git --version)"
fi

# 6. Proje dizini oluşturma
PROJECT_DIR="/var/www/og"
if [ ! -d "$PROJECT_DIR" ]; then
    print_status "Proje dizini oluşturuluyor..."
    mkdir -p /var/www
    cd /var/www
    
    print_warning "Git repository URL'ini girin (örn: https://github.com/username/og.git):"
    read -p "Repository URL: " REPO_URL
    
    if [ ! -z "$REPO_URL" ]; then
        git clone "$REPO_URL" og
    else
        print_error "Repository URL girilmedi. Manuel olarak proje dosyalarını yükleyin."
        exit 1
    fi
else
    print_status "Proje dizini zaten mevcut"
fi

cd "$PROJECT_DIR"

# 7. Backend kurulumu
print_status "Backend bağımlılıkları kuruluyor..."
cd ogBackend
npm install

# 8. Environment dosyası kontrolü
if [ ! -f ".env" ]; then
    print_status "Environment dosyası oluşturuluyor..."
    cp .env.production .env
    print_warning ".env dosyasını düzenlemeniz gerekiyor:"
    echo "nano .env"
    echo "DATABASE_URL, domain adları ve API anahtarlarını güncelleyin"
fi

# 9. Frontend build
print_status "Frontend build ediliyor..."
cd ../ogFrontend
npm install
npm run build

# 10. Nginx konfigürasyonu
print_status "Nginx konfigürasyonu kontrol ediliyor..."
NGINX_CONFIG="/etc/nginx/conf.d/og.conf"
if [ ! -f "$NGINX_CONFIG" ]; then
    print_warning "Nginx konfigürasyon dosyası oluşturulacak"
    print_warning "Domain adınızı girin:"
    read -p "Domain (örn: example.com): " DOMAIN
    
    if [ ! -z "$DOMAIN" ]; then
        cat > "$NGINX_CONFIG" << EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    # SSL sertifikaları (Let's Encrypt ile oluşturulacak)
    # ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    # Frontend (Vue.js)
    location / {
        root /var/www/og/ogFrontend/dist;
        try_files \$uri \$uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Socket.IO
    location /socket.io/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
        print_status "Nginx konfigürasyonu oluşturuldu: $NGINX_CONFIG"
    fi
fi

# 11. Firewall ayarları
print_status "Firewall ayarları yapılıyor..."
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload

# 12. Nginx'i yeniden başlat
print_status "Nginx yeniden başlatılıyor..."
systemctl restart nginx

# 13. Database migration (eğer .env doğru ayarlanmışsa)
print_status "Database migration kontrol ediliyor..."
cd "$PROJECT_DIR/ogBackend"
if npx prisma db pull 2>/dev/null; then
    print_status "Database bağlantısı başarılı, migration çalıştırılıyor..."
    npx prisma migrate deploy
    npx prisma generate
else
    print_warning "Database bağlantısı başarısız. .env dosyasını kontrol edin."
fi

# 14. PM2 ile uygulamayı başlat
print_status "Uygulama PM2 ile başlatılıyor..."
pm2 delete backend 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save
pm2 startup

print_status "🎉 Deployment tamamlandı!"
echo ""
print_warning "Sonraki adımlar:"
echo "1. .env dosyasını düzenleyin: nano $PROJECT_DIR/ogBackend/.env"
echo "2. PostgreSQL kullanıcısını oluşturun (yukarıdaki komutları kullanın)"
echo "3. SSL sertifikası oluşturun: certbot --nginx -d yourdomain.com"
echo "4. PM2 durumunu kontrol edin: pm2 status"
echo "5. Nginx konfigürasyonunu test edin: nginx -t"
echo ""
print_status "Logları kontrol etmek için:"
echo "pm2 logs backend"
echo "tail -f /var/log/nginx/error.log" 