# 🍰 OG Projesi - Sipariş Yönetim Sistemi

## 📋 Proje Hakkında

OG Projesi, gıda sektörü için geliştirilmiş kapsamlı bir sipariş yönetim sistemidir. **ogsiparis.com** domain'i ile CyberPanel üzerinde çalışacak şekilde optimize edilmiştir.

## 🚀 Hızlı Deployment (CyberPanel)

### Tek Komutla Deployment
```bash
# VPS'e bağlanın
ssh root@your-vps-ip

# Proje dosyalarını indirin
wget -O - https://github.com/your-repo/og/archive/main.tar.gz | tar -xz
cd og-main

# Otomatik deployment başlatın
./scripts/deployment/cyberpanel-deploy.sh
```

### Manuel Deployment
```bash
# 1. Dosyaları VPS'e yükleyin
./scripts/deployment/upload-to-vps.sh

# 2. VPS'e bağlanın
ssh root@your-vps-ip

# 3. Deployment çalıştırın
cd /root/og-project
./scripts/deployment/cyberpanel-deploy.sh
```

## 🌐 Canlı Erişim

- **Website**: https://ogsiparis.com
- **Admin Panel**: https://ogsiparis.com/login
- **API**: https://ogsiparis.com/api

### Admin Giriş Bilgileri
- **Email**: admin@example.com
- **Şifre**: admin123

## 🛠️ Teknoloji Stack

### Backend
- **Framework**: Next.js 13.4.12
- **Database**: PostgreSQL + Prisma ORM
- **Authentication**: JWT
- **File Upload**: Multer
- **Real-time**: Socket.IO

### Frontend
- **Framework**: Vue.js 3.3.4
- **UI Library**: Vuetify 3
- **State Management**: Pinia
- **Charts**: Chart.js + Vue-ChartJS
- **HTTP Client**: Axios

### Deployment
- **Panel**: CyberPanel
- **Web Server**: LiteSpeed
- **Process Manager**: PM2
- **SSL**: Let's Encrypt
- **Reverse Proxy**: LiteSpeed

## 📦 Özellikler

### 🛍️ Sipariş Yönetimi
- Sipariş oluşturma ve takip
- Onay bekleyen siparişler
- Hazırlanacak ürünler listesi
- Kargo operasyonları

### 📊 Ürün Yönetimi
- Ürün CRUD işlemleri
- Kategori yönetimi
- Fiyat yönetimi (kampanya, toptan, perakende)
- Stok takibi ve uyarıları

### 👥 Müşteri Yönetimi (CRM)
- Müşteri kayıtları
- Adres yönetimi
- Ödeme takibi
- Vade takibi ve SMS bildirimleri

### 📈 Raporlama
- Satış raporları
- Üretim planı
- Stok raporları
- Finansal analizler

### 🔧 Sistem Yönetimi
- Kullanıcı yönetimi
- Rol bazlı erişim
- Excel import/export
- Otomatik backup

## 🏗️ Proje Yapısı

```
og/
├── backend/                 # Next.js Backend
│   ├── pages/api/          # API Routes
│   ├── prisma/             # Database Schema
│   ├── lib/                # Utilities
│   └── scripts/            # Helper Scripts
├── frontend/               # Vue.js Frontend
│   ├── src/
│   │   ├── components/     # Vue Components
│   │   ├── pages/          # Page Components
│   │   ├── stores/         # Pinia Stores
│   │   └── utils/          # Utilities
│   └── public/             # Static Assets
├── scripts/
│   ├── deployment/         # Deployment Scripts
│   ├── cleanup/           # Cleanup Scripts
│   └── testing/           # Test Scripts
└── docs/                  # Documentation
```

## 🔧 Development

### Gereksinimler
- Node.js 18+
- PostgreSQL 15+
- npm veya yarn

### Kurulum
```bash
# Tüm bağımlılıkları yükle
npm run install:all

# Development sunucularını başlat
npm run dev

# Alternatif: Ayrı ayrı başlat
npm run dev:backend  # http://localhost:3000
npm run dev:frontend # http://localhost:5173
```

### Environment Ayarları

#### Backend (.env)
```env
DATABASE_URL="postgresql://ogform:secret@localhost:5433/ogformdb?schema=public"
JWT_SECRET=supersecretkey123
NODE_ENV=development
```

#### Frontend (.env)
```env
VITE_API_BASE_URL=http://localhost:3000/api
NODE_ENV=development
VITE_DEBUG=true
```

## 📚 API Dokümantasyonu

### Ana Endpoint'ler
- `GET /api/health` - Health check
- `GET /api/urunler` - Ürün listesi
- `GET /api/kategoriler` - Kategori listesi
- `GET /api/siparis` - Sipariş listesi
- `GET /api/cari` - Müşteri listesi

### Authentication
```javascript
// Login
POST /api/auth/login
{
  "email": "admin@example.com",
  "password": "admin123"
}

// Response
{
  "token": "jwt_token_here",
  "user": { "id": 1, "email": "admin@example.com", "role": "admin" }
}
```

## 🔒 Güvenlik

### Authentication & Authorization
- JWT token tabanlı kimlik doğrulama
- Rol bazlı erişim kontrolü (admin, mudur, user)
- API endpoint'leri için middleware koruması

### Data Protection
- SQL injection koruması (Prisma ORM)
- XSS koruması
- CORS konfigürasyonu
- File upload güvenliği

## 📊 Monitoring & Backup

### Otomatik Backup
```bash
# Günlük backup (02:00)
0 2 * * * /root/og-backup.sh

# Manuel backup
/root/og-backup.sh
```

### Health Check
```bash
# 5 dakikada bir health check
*/5 * * * * /root/og-health-check.sh

# Manuel health check
/root/og-health-check.sh
```

### Log Monitoring
```bash
# PM2 logları
pm2 logs og-backend

# LiteSpeed logları
tail -f /home/ogsiparis.com/logs/access.log
tail -f /home/ogsiparis.com/logs/error.log
```

## 🔄 Güncelleme

### Kod Güncellemesi
```bash
# Git pull
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
npm install && npm run build
mv dist /home/ogsiparis.com/public_html/
```

### Database Migration
```bash
cd /home/ogsiparis.com/public_html/backend
npx prisma db push
npx prisma generate
```

## 🐛 Sorun Giderme

### Backend Sorunları
```bash
# PM2 status
pm2 status

# Logları kontrol
pm2 logs og-backend --lines 50

# Restart
pm2 restart og-backend
```

### Frontend Sorunları
```bash
# Build dosyalarını kontrol
ls -la /home/ogsiparis.com/public_html/dist/

# LiteSpeed restart
systemctl restart lsws
```

### Database Sorunları
```bash
# PostgreSQL status
systemctl status postgresql

# Database bağlantı test
psql -h localhost -U ogform -d ogformdb
```

## 📞 Destek

### Sistem Komutları
```bash
# Disk kullanımı
df -h

# Memory kullanımı
free -h

# Network bağlantıları
netstat -tulpn | grep :8080

# CyberPanel status
systemctl status lscpd
```

### Önemli Dosyalar
- `/root/og-db-credentials.txt` - Database bilgileri
- `/root/og-backup.sh` - Backup script'i
- `/root/og-health-check.sh` - Health check script'i

## 🎯 Performans

### PM2 Cluster Mode
```javascript
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'og-backend',
    script: 'server.js',
    instances: 'max',
    exec_mode: 'cluster',
    max_memory_restart: '1G'
  }]
}
```

### Caching
- Static dosyalar için 1 yıl cache
- API response'ları için Redis (opsiyonel)
- Database query optimization

## 📄 Lisans

Bu proje özel kullanım için geliştirilmiştir.

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit edin (`git commit -m 'Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

---

## 🎉 Deployment Özeti

**Proje %100 production-ready durumda!**

### Hızlı Başlangıç
1. VPS'e bağlanın
2. `./scripts/deployment/cyberpanel-deploy.sh` çalıştırın
3. https://ogsiparis.com adresinden erişin

### Özellikler
- ✅ Otomatik domain oluşturma
- ✅ SSL sertifikası
- ✅ Database kurulumu
- ✅ PM2 cluster mode
- ✅ Nginx reverse proxy
- ✅ Otomatik backup
- ✅ Health monitoring

🚀 **Başarılı deployment'lar!** 