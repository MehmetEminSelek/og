# 🚀 OG Projesi CyberPanel Deployment Rehberi

## 📋 Genel Bakış

Bu rehber, OG projesinin **ogsiparis.com** domain'i ile CyberPanel üzerinde otomatik deployment sürecini açıklar.

## ✅ Ön Gereksinimler

### VPS Gereksinimleri
- **OS**: Ubuntu 20.04+ / CentOS 8+ / AlmaLinux 9
- **RAM**: Minimum 2GB (Önerilen: 4GB)
- **Disk**: Minimum 20GB SSD
- **CPU**: 2 vCPU
- **CyberPanel**: Kurulu ve çalışır durumda

### Domain Gereksinimleri
- **Domain**: ogsiparis.com
- **DNS**: VPS IP'sine yönlendirilmiş
- **Nameserver**: Cloudflare veya domain sağlayıcısı

## 🚀 Otomatik Deployment

### 1. VPS'e Bağlanın
```bash
ssh root@your-vps-ip
```

### 2. Proje Dosyalarını Yükleyin
```bash
# Git ile klonlayın (önerilen)
git clone https://github.com/your-username/og-project.git
cd og-project

# Veya ZIP dosyası yükleyin
wget https://github.com/your-username/og-project/archive/main.zip
unzip main.zip
cd og-project-main
```

### 3. Deployment Script'ini Çalıştırın
```bash
# Script'i çalıştırılabilir yapın
chmod +x scripts/deployment/cyberpanel-deploy.sh

# Deployment'ı başlatın
./scripts/deployment/cyberpanel-deploy.sh
```

### 4. İşlem Tamamlandı! 🎉
Script otomatik olarak şunları yapacak:
- ✅ Domain oluşturma (ogsiparis.com)
- ✅ SSL sertifikası kurma
- ✅ PostgreSQL database oluşturma
- ✅ Node.js ve PM2 kurulumu
- ✅ Proje dosyalarını kopyalama
- ✅ Environment ayarları
- ✅ Frontend build
- ✅ Backend PM2 konfigürasyonu
- ✅ Nginx reverse proxy
- ✅ Firewall ve security
- ✅ Monitoring ve backup

## 🔧 Manuel Adımlar (Gerekirse)

### CyberPanel CLI Komutları
```bash
# Domain oluştur
cyberpanel createWebsite --domainName ogsiparis.com --email admin@ogsiparis.com --package Default

# SSL kur
cyberpanel issueSSL --domainName ogsiparis.com

# Database oluştur
cyberpanel createDatabase --databaseWebsite ogsiparis.com --dbName ogformdb --dbUsername ogform --dbPassword your_password

# Node.js app oluştur
cyberpanel createNodeApp --domainName ogsiparis.com --appName "og-backend" --nodeVersion "18" --appPath "/backend" --startupFile "server.js"
```

### PM2 Yönetimi
```bash
# PM2 status
pm2 status

# Logları görüntüle
pm2 logs og-backend

# Restart
pm2 restart og-backend

# Stop
pm2 stop og-backend

# Delete
pm2 delete og-backend
```

## 📁 Dosya Yapısı

### Proje Dizini
```
/home/ogsiparis.com/
├── public_html/
│   ├── dist/              # Frontend build dosyaları
│   ├── backend/           # Backend kaynak kodları
│   ├── frontend/          # Frontend kaynak kodları
│   └── uploads/           # Yüklenen dosyalar
├── logs/
│   ├── access.log
│   └── error.log
└── ssl/
    ├── cert.pem
    └── private.key
```

### Konfigürasyon Dosyaları
```
/root/
├── og-db-credentials.txt  # Database bilgileri
├── og-backup.sh          # Backup script'i
└── og-health-check.sh    # Health check script'i
```

## 🌐 URL Yapısı

### Ana URL'ler
- **Website**: https://ogsiparis.com
- **Admin Panel**: https://ogsiparis.com/login
- **API**: https://ogsiparis.com/api
- **Socket.IO**: https://ogsiparis.com/socket.io

### API Endpoints
- **Health Check**: https://ogsiparis.com/api/health
- **Ürünler**: https://ogsiparis.com/api/urunler
- **Kategoriler**: https://ogsiparis.com/api/kategoriler
- **Siparişler**: https://ogsiparis.com/api/siparis

## 🔑 Giriş Bilgileri

### Admin Hesabı
- **URL**: https://ogsiparis.com/login
- **Email**: admin@example.com
- **Şifre**: admin123

### Database
- **Host**: localhost
- **Port**: 5432
- **Database**: ogformdb
- **Username**: ogform
- **Password**: (Script tarafından oluşturulan)

## 📊 Monitoring ve Backup

### Otomatik Backup
```bash
# Manuel backup çalıştır
/root/og-backup.sh

# Backup dosyalarını listele
ls -la /root/backups/

# Backup restore (gerekirse)
pg_dump ogformdb < /root/backups/og-YYYYMMDD_HHMMSS/database.sql
```

### Health Check
```bash
# Manuel health check
/root/og-health-check.sh

# Crontab kontrol
crontab -l
```

### Log Dosyaları
```bash
# PM2 logları
pm2 logs og-backend

# Nginx logları
tail -f /home/ogsiparis.com/logs/access.log
tail -f /home/ogsiparis.com/logs/error.log

# System logları
journalctl -u lsws -f
```

## 🔧 Sorun Giderme

### Backend Çalışmıyor
```bash
# PM2 status kontrol
pm2 status

# PM2 restart
pm2 restart og-backend

# Logları kontrol
pm2 logs og-backend --lines 50
```

### Frontend Yüklenmiyor
```bash
# Build dosyalarını kontrol
ls -la /home/ogsiparis.com/public_html/dist/

# Nginx konfigürasyonu kontrol
cat /usr/local/lsws/conf/vhosts/ogsiparis.com/vhconf.conf

# LiteSpeed restart
systemctl restart lsws
```

### Database Bağlantı Sorunu
```bash
# PostgreSQL status
systemctl status postgresql

# Database bağlantı test
psql -h localhost -U ogform -d ogformdb

# Database bilgilerini kontrol
cat /root/og-db-credentials.txt
```

### SSL Sorunu
```bash
# SSL sertifikası kontrol
cyberpanel issueSSL --domainName ogsiparis.com

# SSL dosyalarını kontrol
ls -la /home/ogsiparis.com/ssl/
```

## 🔄 Güncelleme Süreci

### Kod Güncellemesi
```bash
# Git pull (eğer git kullanıyorsanız)
cd /path/to/project
git pull origin main

# Dosyaları kopyala
cp -r ./backend/* /home/ogsiparis.com/public_html/backend/
cp -r ./frontend/* /home/ogsiparis.com/public_html/frontend/

# Backend restart
cd /home/ogsiparis.com/public_html/backend
npm install --production
pm2 restart og-backend

# Frontend rebuild
cd /home/ogsiparis.com/public_html/frontend
npm install
npm run build
rm -rf /home/ogsiparis.com/public_html/dist
mv dist /home/ogsiparis.com/public_html/
```

### Database Migration
```bash
cd /home/ogsiparis.com/public_html/backend
npx prisma db push
npx prisma generate
```

## 📞 Destek Komutları

### Sistem Durumu
```bash
# Disk kullanımı
df -h

# Memory kullanımı
free -h

# CPU kullanımı
top

# Network bağlantıları
netstat -tulpn | grep :8080
```

### CyberPanel Komutları
```bash
# CyberPanel status
systemctl status lscpd

# CyberPanel restart
systemctl restart lscpd

# CyberPanel logs
journalctl -u lscpd -f
```

## 🎯 Performans Optimizasyonu

### PM2 Cluster Mode
```javascript
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'og-backend',
    script: 'server.js',
    instances: 'max', // CPU sayısı kadar instance
    exec_mode: 'cluster',
    max_memory_restart: '1G'
  }]
}
```

### Nginx Caching
```nginx
# Static dosyalar için cache
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

---

## 🎉 Sonuç

Bu rehberi takip ederek OG projenizi CyberPanel üzerinde başarıyla deploy edebilirsiniz. 

**Deployment sonrası kontrol listesi:**
- [ ] https://ogsiparis.com açılıyor
- [ ] Admin paneline giriş yapılabiliyor
- [ ] API endpoint'leri çalışıyor
- [ ] Database bağlantısı var
- [ ] SSL sertifikası aktif
- [ ] PM2 backend çalışıyor
- [ ] Backup script'i kurulu

**Herhangi bir sorun yaşarsanız:**
1. Log dosyalarını kontrol edin
2. Sorun giderme bölümünü inceleyin
3. Script'i tekrar çalıştırın

🚀 **Başarılı deployment'lar!** 