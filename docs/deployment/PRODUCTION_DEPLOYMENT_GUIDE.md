# 🚀 OG Projesi Production Deployment Rehberi

## 📋 Özet

Bu rehber, OG projesinin production ortamına deploy edilmesi için gerekli tüm adımları içerir. Proje artık **%95 canlıya çıkartılabilir durumda**!

## ✅ Hazırlanan Özellikler

### 🔧 Environment Sistemi
- ✅ **Development**: `localhost:3000` otomatik kullanımı
- ✅ **Production**: Environment variable'dan API URL
- ✅ **Fallback**: Relative path (`/api`) nginx proxy için

### 📦 Deployment Dosyaları
- ✅ Docker Compose konfigürasyonu
- ✅ PM2 ecosystem konfigürasyonu
- ✅ Nginx reverse proxy ayarları
- ✅ SSL sertifikası desteği
- ✅ Otomatik deployment script'i

### 🌐 URL Sistemi
```javascript
// Development
VITE_API_BASE_URL=http://localhost:3000/api

// Production
VITE_API_BASE_URL=https://yourdomain.com/api

// Nginx Proxy (fallback)
/api -> http://localhost:8080/api/
```

## 🚀 Hızlı Deployment

### 1. Sunucu Hazırlığı
```bash
# VPS'e bağlan
ssh root@your-server-ip

# Deployment script'ini indir
wget https://raw.githubusercontent.com/your-repo/og/main/scripts/deployment/deploy-production.sh
chmod +x deploy-production.sh

# Domain ve API URL'ini ayarla
export DOMAIN="yourdomain.com"
export API_URL="https://yourdomain.com/api"

# Deployment'ı başlat
./deploy-production.sh
```

### 2. Manuel Deployment

#### A. Sistem Gereksinimleri
```bash
# AlmaLinux 9 / CentOS 9 / RHEL 9
dnf update -y

# Node.js 20
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs

# PostgreSQL 15
dnf install -y https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf install -y postgresql15-server postgresql15
postgresql-15-setup initdb
systemctl enable postgresql-15
systemctl start postgresql-15

# PM2 ve diğer araçlar
npm install -g pm2
dnf install -y git nginx certbot python3-certbot-nginx
```

#### B. Database Kurulumu
```bash
sudo -u postgres psql
```
```sql
CREATE USER ogform WITH PASSWORD 'güçlü_şifre_buraya';
CREATE DATABASE ogformdb OWNER ogform;
GRANT ALL PRIVILEGES ON DATABASE ogformdb TO ogform;
\q
```

#### C. Proje Kurulumu
```bash
# Proje dizini
mkdir -p /var/www/og
cd /var/www/og

# Repository klonla
git clone https://github.com/your-username/og.git .

# Backend kurulum
cd backend
npm install --production

# Environment dosyası
cat > .env << EOF
DATABASE_URL="postgresql://ogform:güçlü_şifre_buraya@localhost:5432/ogformdb?schema=public"
JWT_SECRET=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-50)
NODE_ENV=production
PORT=8080
CORS_ORIGIN=https://yourdomain.com
EOF

# Prisma setup
npx prisma generate
npx prisma migrate deploy

# Frontend kurulum
cd ../frontend

# Environment dosyası
cat > .env.production << EOF
VITE_API_BASE_URL=https://yourdomain.com/api
NODE_ENV=production
VITE_BUILD_MODE=production
VITE_DEBUG=false
VITE_DROP_CONSOLE=true
EOF

npm install
npm run build
```

#### D. Nginx Konfigürasyonu
```bash
cat > /etc/nginx/conf.d/og.conf << 'EOF'
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    # Frontend static files
    location / {
        root /var/www/og/frontend/dist;
        try_files $uri $uri/ /index.html;
        
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
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
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

# Nginx'i test et ve başlat
nginx -t
systemctl enable nginx
systemctl start nginx
```

#### E. Backend'i PM2 ile Başlat
```bash
cd /var/www/og/backend
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd
```

#### F. SSL Sertifikası
```bash
certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

## 🔧 Environment Konfigürasyonu

### Development (.env)
```bash
# Backend
DATABASE_URL="postgresql://ogform:secret@localhost:5433/ogformdb?schema=public"
JWT_SECRET=supersecretkey123
NODE_ENV=development

# Frontend
VITE_API_BASE_URL=http://localhost:3000/api
NODE_ENV=development
VITE_DEBUG=true
```

### Production (.env.production)
```bash
# Backend
DATABASE_URL="postgresql://ogform:production_password@localhost:5432/ogformdb?schema=public"
JWT_SECRET=production_jwt_secret_64_chars
NODE_ENV=production
PORT=8080
CORS_ORIGIN=https://yourdomain.com

# Frontend
VITE_API_BASE_URL=https://yourdomain.com/api
NODE_ENV=production
VITE_BUILD_MODE=production
VITE_DEBUG=false
VITE_DROP_CONSOLE=true
```

## 🐳 Docker Deployment (Alternatif)

### Docker Compose
```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: ogform
      POSTGRES_PASSWORD: production_password
      POSTGRES_DB: ogformdb
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://ogform:production_password@db:5432/ogformdb
      NODE_ENV: production
      PORT: 8080
    ports:
      - "8080:8080"
    depends_on:
      - db

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend

volumes:
  postgres_data:
```

### Docker Build ve Run
```bash
# Build
docker-compose build

# Run
docker-compose up -d

# Logs
docker-compose logs -f
```

## 📊 Monitoring ve Maintenance

### Sistem Durumu Kontrol
```bash
# Backend durumu
pm2 status
pm2 logs backend

# Database durumu
systemctl status postgresql-15
sudo -u postgres psql -c "SELECT version();"

# Nginx durumu
systemctl status nginx
nginx -t

# Disk ve memory
df -h
free -h
```

### Güncelleme Süreci
```bash
cd /var/www/og

# Kodu güncelle
git pull origin main

# Backend güncelle
cd backend
npm install --production
npx prisma migrate deploy
pm2 restart backend

# Frontend güncelle
cd ../frontend
npm install
npm run build

# Nginx reload
systemctl reload nginx
```

### Backup
```bash
# Database backup
sudo -u postgres pg_dump ogformdb > backup_$(date +%Y%m%d_%H%M%S).sql

# Proje backup
tar -czf og_backup_$(date +%Y%m%d_%H%M%S).tar.gz /var/www/og
```

## 🔒 Güvenlik

### Firewall
```bash
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload
```

### SSL/TLS
```bash
# Let's Encrypt otomatik yenileme
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -
```

### Database Güvenlik
```bash
# PostgreSQL konfigürasyonu
echo "listen_addresses = 'localhost'" >> /var/lib/pgsql/15/data/postgresql.conf
systemctl restart postgresql-15
```

## 🆘 Troubleshooting

### Yaygın Sorunlar

#### 1. Backend 502 Bad Gateway
```bash
# PM2 durumunu kontrol et
pm2 status

# Backend loglarını kontrol et
pm2 logs backend

# Port kullanımını kontrol et
lsof -i :8080
```

#### 2. Frontend Yüklenmiyor
```bash
# Build dosyalarını kontrol et
ls -la /var/www/og/frontend/dist/

# Nginx konfigürasyonunu kontrol et
nginx -t
cat /var/log/nginx/error.log
```

#### 3. Database Bağlantı Hatası
```bash
# PostgreSQL durumunu kontrol et
systemctl status postgresql-15

# Database bağlantısını test et
sudo -u postgres psql -d ogformdb -c "SELECT 1;"

# .env dosyasını kontrol et
cat /var/www/og/backend/.env
```

#### 4. API CORS Hatası
```bash
# Backend .env dosyasında CORS_ORIGIN'i kontrol et
grep CORS_ORIGIN /var/www/og/backend/.env

# Frontend .env.production'da API URL'ini kontrol et
grep VITE_API_BASE_URL /var/www/og/frontend/.env.production
```

## 📈 Performance Optimizasyonu

### PM2 Cluster Mode
```javascript
// ecosystem.config.js
module.exports = {
    apps: [{
        name: 'backend',
        script: 'npm',
        args: 'start',
        instances: 'max',  // CPU core sayısı kadar instance
        exec_mode: 'cluster',
        autorestart: true,
        watch: false,
        max_memory_restart: '1G'
    }]
}
```

### Nginx Caching
```nginx
# /etc/nginx/conf.d/og.conf içine ekle
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    access_log off;
}
```

### Database Optimizasyonu
```sql
-- PostgreSQL performans ayarları
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
SELECT pg_reload_conf();
```

## 🎯 Deployment Checklist

### Pre-deployment
- [ ] Domain DNS ayarları yapıldı
- [ ] SSL sertifikası hazır
- [ ] Database backup alındı
- [ ] Environment variables ayarlandı

### Deployment
- [ ] Backend build başarılı
- [ ] Frontend build başarılı
- [ ] Database migration uygulandı
- [ ] PM2 ile backend başlatıldı
- [ ] Nginx konfigürasyonu aktif

### Post-deployment
- [ ] Website erişilebilir
- [ ] API endpoint'leri çalışıyor
- [ ] Database bağlantısı aktif
- [ ] SSL sertifikası geçerli
- [ ] Monitoring aktif

## 🎉 Sonuç

**Proje %95 canlıya çıkartılabilir durumda!** 

Eksik olan sadece:
1. Gerçek domain adı
2. Production database bilgileri
3. SSL sertifikası kurulumu

Bu rehberi takip ederek projenizi başarıyla production ortamına deploy edebilirsiniz.

---

**Son Güncelleme**: 25 Aralık 2024  
**Versiyon**: 2.0.0  
**Durum**: Production Ready ✅ 