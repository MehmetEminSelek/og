# 🚀 Hostinger VPS Deployment - Özet Rehber

## ✅ Hazırlanan Dosyalar

### 📦 Deployment Package
- **Dosya**: `hostinger-deployment.zip` (296 KB)
- **İçerik**: Backend, Frontend ve deployment dosyaları

### 📋 Rehber Dosyaları
1. **HOSTINGER_DEPLOYMENT.md** - Detaylı adım adım rehber
2. **deployment-guide.md** - Teknik deployment rehberi  
3. **deploy.sh** - Otomatik kurulum script'i

## 🎯 VPS Bilgileri
- **IP**: 147.93.123.161
- **OS**: AlmaLinux 9 + CyberPanel
- **SSH**: root kullanıcısı
- **Kaynaklar**: 32GB RAM, 400GB Disk, 8 CPU

## 🚀 Hızlı Deployment Adımları

### 1. SSH Şifresini Al
- Hostinger paneli → VPS → SSH Anahtarları/Root Şifresi

### 2. Dosyaları VPS'e Yükle
```bash
# WinSCP, FileZilla veya scp ile
scp hostinger-deployment.zip root@147.93.123.161:/root/
```

### 3. VPS'e Bağlan ve Kur
```bash
# SSH bağlantısı
ssh root@147.93.123.161

# Zip'i aç
unzip hostinger-deployment.zip
cd hostinger-deployment

# Otomatik kurulum
chmod +x deploy.sh
./deploy.sh
```

## 🔧 Manuel Kurulum (Alternatif)

### Gerekli Yazılımlar
```bash
# Sistem güncelleme
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

# PM2 ve Git
npm install -g pm2
dnf install -y git
```

### Database Kurulumu
```bash
sudo -u postgres psql
```
```sql
CREATE USER ogform WITH PASSWORD 'güçlü_şifre';
CREATE DATABASE ogformdb OWNER ogform;
GRANT ALL PRIVILEGES ON DATABASE ogformdb TO ogform;
\q
```

### Proje Kurulumu
```bash
# Backend
cd /var/www/og/ogBackend
npm install
cp .env.production .env
# .env dosyasını düzenle (nano .env)
npx prisma migrate deploy
npx prisma generate

# Frontend
cd ../ogFrontend
npm install
npm run build
```

### Nginx Konfigürasyonu
```bash
nano /etc/nginx/conf.d/og.conf
```

### Uygulamayı Başlat
```bash
cd /var/www/og/ogBackend
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## 🌐 Test URL'leri
- **Frontend**: http://147.93.123.161
- **Backend API**: http://147.93.123.161/api
- **CyberPanel**: https://147.93.123.161:8090

## 🔒 SSL Sertifikası (Domain varsa)
```bash
dnf install -y certbot python3-certbot-nginx
certbot --nginx -d yourdomain.com
```

## 📊 Monitoring Komutları
```bash
# Servis durumları
pm2 status
systemctl status nginx
systemctl status postgresql-15

# Loglar
pm2 logs backend
tail -f /var/log/nginx/error.log

# Sistem kaynakları
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

## 🆘 Yaygın Sorunlar

### 1. SSH Bağlantı Sorunu
- Hostinger panelinden şifreyi kontrol edin
- VPS'in çalıştığından emin olun

### 2. Port 8080 Kullanımda
```bash
lsof -i :8080
kill -9 PID_NUMBER
```

### 3. Database Bağlantı Hatası
- `.env` dosyasındaki DATABASE_URL'i kontrol edin
- PostgreSQL servisinin çalıştığını kontrol edin

### 4. Nginx 502 Bad Gateway
- Backend'in çalıştığını kontrol edin: `pm2 status`
- Port 8080'in açık olduğunu kontrol edin

### 5. Frontend Yüklenmiyor
- Build dosyalarının `/var/www/og/ogFrontend/dist` dizininde olduğunu kontrol edin
- Nginx konfigürasyonunu kontrol edin

## 📞 Destek

### Log Dosyaları
- **PM2**: `pm2 logs backend`
- **Nginx**: `/var/log/nginx/error.log`
- **PostgreSQL**: `/var/lib/pgsql/15/data/log/`

### Yardımcı Komutlar
```bash
# Tüm servisleri yeniden başlat
systemctl restart nginx
pm2 restart all

# Disk alanını kontrol et
df -h

# Bellek kullanımını kontrol et
free -h
```

---

## 🎉 Başarılı Deployment Sonrası

1. ✅ Frontend erişilebilir: http://147.93.123.161
2. ✅ Backend API çalışıyor: http://147.93.123.161/api
3. ✅ Database bağlantısı aktif
4. ✅ PM2 ile backend çalışıyor
5. ✅ Nginx reverse proxy aktif

**Tebrikler! OG projesi Hostinger VPS'te başarıyla çalışıyor! 🚀** 