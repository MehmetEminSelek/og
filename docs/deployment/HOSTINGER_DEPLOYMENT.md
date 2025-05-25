# 🚀 Hostinger VPS Deployment - Hızlı Başlangıç

## 📋 Ön Hazırlık

### 1. SSH Şifresini Alma
1. Hostinger paneline giriş yap
2. **VPS** → **Yönetim** → **SSH Anahtarları** veya **Root Şifresi**
3. Şifreyi kopyala

### 2. Domain Ayarları (Opsiyonel)
- Domain'iniz varsa A kaydını VPS IP'sine yönlendirin: `147.93.123.161`
- Yoksa IP ile test edebilirsiniz

## 🔧 VPS'e Bağlanma

### Windows'tan SSH Bağlantısı:
```bash
ssh root@147.93.123.161
```

### Alternatif: PuTTY kullanabilirsiniz
- Host: `147.93.123.161`
- Port: `22`
- Username: `root`

## 🚀 Otomatik Kurulum

VPS'e bağlandıktan sonra:

```bash
# 1. Deployment script'ini indir
curl -O https://raw.githubusercontent.com/yourusername/og/main/deploy.sh

# 2. Script'i çalıştırılabilir yap
chmod +x deploy.sh

# 3. Script'i çalıştır
./deploy.sh
```

## 📝 Manuel Kurulum (Adım Adım)

### 1. Sistem Güncellemesi
```bash
dnf update -y
```

### 2. Node.js Kurulumu
```bash
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs
node --version
npm --version
```

### 3. PostgreSQL Kurulumu
```bash
dnf install -y postgresql15-server postgresql15
postgresql-15-setup initdb
systemctl enable postgresql-15
systemctl start postgresql-15
```

### 4. PostgreSQL Kullanıcısı Oluşturma
```bash
sudo -u postgres psql
```
PostgreSQL'de:
```sql
CREATE USER ogform WITH PASSWORD 'güçlü_şifre_buraya';
CREATE DATABASE ogformdb OWNER ogform;
GRANT ALL PRIVILEGES ON DATABASE ogformdb TO ogform;
\q
```

### 5. PM2 ve Git Kurulumu
```bash
npm install -g pm2
dnf install -y git
```

### 6. Proje Dosyalarını Yükleme

#### Seçenek A: Git Repository (Önerilen)
```bash
cd /var/www
git clone https://github.com/yourusername/og.git
cd og
```

#### Seçenek B: Manuel Upload
- WinSCP veya FileZilla ile dosyaları `/var/www/og/` dizinine yükleyin

### 7. Backend Kurulumu
```bash
cd /var/www/og/ogBackend
npm install
```

### 8. Environment Dosyası Düzenleme
```bash
cp .env.production .env
nano .env
```

`.env` dosyasında güncellenecekler:
```env
DATABASE_URL="postgresql://ogform:güçlü_şifre_buraya@localhost:5432/ogformdb?schema=public"
NEXT_PUBLIC_API_URL=https://yourdomain.com/api
CORS_ORIGIN=https://yourdomain.com
JWT_SECRET=çok_güçlü_jwt_secret_key
```

### 9. Database Migration
```bash
npx prisma migrate deploy
npx prisma generate
```

### 10. Frontend Build
```bash
cd /var/www/og/ogFrontend
npm install
npm run build
```

### 11. Nginx Konfigürasyonu
```bash
nano /etc/nginx/conf.d/og.conf
```

Nginx config:
```nginx
server {
    listen 80;
    server_name yourdomain.com 147.93.123.161;
    
    # Frontend
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

### 12. Firewall ve Nginx
```bash
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload

systemctl restart nginx
nginx -t
```

### 13. Uygulamayı Başlatma
```bash
cd /var/www/og/ogBackend
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## 🔒 SSL Sertifikası (Domain varsa)

```bash
dnf install -y certbot python3-certbot-nginx
certbot --nginx -d yourdomain.com
```

## 📊 Kontrol ve Monitoring

### Servis Durumları
```bash
pm2 status
systemctl status nginx
systemctl status postgresql-15
```

### Log Kontrolleri
```bash
pm2 logs backend
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log
```

### Sistem Kaynakları
```bash
htop
df -h
free -h
```

## 🌐 Test Etme

1. **Frontend**: `http://147.93.123.161` veya `http://yourdomain.com`
2. **Backend API**: `http://147.93.123.161/api` veya `http://yourdomain.com/api`

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

### Yaygın Sorunlar

1. **Port 8080 kullanımda**
   ```bash
   lsof -i :8080
   kill -9 PID_NUMBER
   ```

2. **Database bağlantı hatası**
   - `.env` dosyasındaki DATABASE_URL'i kontrol edin
   - PostgreSQL servisinin çalıştığını kontrol edin

3. **Nginx 502 Bad Gateway**
   - Backend'in çalıştığını kontrol edin: `pm2 status`
   - Port 8080'in açık olduğunu kontrol edin

4. **Frontend yüklenmiyor**
   - Build dosyalarının doğru yerde olduğunu kontrol edin
   - Nginx konfigürasyonunu kontrol edin

### Yardım Komutları
```bash
# Tüm servisleri yeniden başlat
systemctl restart nginx
pm2 restart all

# Logları temizle
pm2 flush

# Disk alanını kontrol et
df -h
```

## 📞 Destek

Sorun yaşarsanız:
1. Log dosyalarını kontrol edin
2. Hata mesajlarını not alın
3. Sistem kaynaklarını kontrol edin

---

**Not**: Bu rehber AlmaLinux 9 + CyberPanel için hazırlanmıştır. Farklı sistemlerde komutlar değişebilir. 