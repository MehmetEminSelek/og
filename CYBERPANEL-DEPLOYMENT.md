# 🚀 OG Project - CyberPanel Deployment Rehberi
# Domain: ogsiparis.com

## 📋 Ön Hazırlık

### ✅ **Gereksinimler:**
- Hostinger VPS with CyberPanel
- Domain: **ogsiparis.com** (SSL ile)
- Node.js 18+
- PostgreSQL database

## 🔧 Adım Adım Deployment

### **1. CyberPanel'de Website Oluşturma**

```bash
# CyberPanel Admin Panel'e giriş yapın
# Websites > Create Website
# Domain: ogsiparis.com
# Email: admin@ogsiparis.com
# Package: Default
```

### **2. Database Oluşturma**

#### PostgreSQL (Önerilen):
```bash
# CyberPanel > Databases > Create Database
Database Name: ogformdb
Username: ogform
Password: secret
```

### **3. SSH Bağlantısı ve Hazırlık**

```bash
# SSH ile sunucuya bağlanın
ssh root@your-server-ip

# Node.js ve PM2 kurulumu
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs
npm install -g pm2

# Proje dizinine gidin
cd /home/ogsiparis.com/public_html
```

### **4. Dosya Upload ve Konfigürasyon**

```bash
# Local'den dosyaları upload edin (FTP/SFTP ile)
# Veya git clone kullanın:
git clone https://github.com/your-repo/og-project.git .

# Environment dosyasını oluşturun
cp backend/.env.production backend/.env
```

#### **Environment Variables (.env):**
```env
# Database Configuration
DATABASE_URL="postgresql://ogform:secret@localhost:5432/ogformdb?schema=public"

# JWT Secret
JWT_SECRET="og-siparis-super-secret-jwt-key-production-2024-very-long-and-secure"

# Domain Configuration
NEXT_PUBLIC_API_URL=https://ogsiparis.com/api
CORS_ORIGIN=https://ogsiparis.com

# Production
NODE_ENV=production
PORT=8080

# Email Configuration
SMTP_HOST=smtp.hostinger.com
SMTP_PORT=587
SMTP_USER=admin@ogsiparis.com
SMTP_PASS=your-email-password
```

### **5. Dependencies ve Build**

```bash
# Deployment script'i çalıştırın
chmod +x deploy-cyberpanel.sh
./deploy-cyberpanel.sh

# Veya manuel:
npm run install:all
npm run build
```

### **6. Database Migration**

```bash
cd backend
npx prisma generate
npx prisma db push

# Seed data (opsiyonel)
npx prisma db seed
cd ..
```

### **7. PM2 ile Uygulama Başlatma**

```bash
# PM2 ile başlat
pm2 start ecosystem.config.js

# Otomatik başlatma
pm2 save
pm2 startup

# Status kontrol
pm2 status
pm2 logs og-backend
```

### **8. Nginx/Apache Konfigürasyonu**

#### **Nginx (CyberPanel otomatik):**
```nginx
# Frontend static files
location / {
    root /home/ogsiparis.com/public_html/frontend/dist;
    try_files $uri $uri/ /index.html;
}

# API proxy
location /api {
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
```

### **9. SSL Sertifikası**

```bash
# CyberPanel > SSL > Issue SSL
# Domain: ogsiparis.com
# Let's Encrypt ile otomatik SSL
# Force HTTPS: Aktif
```

## 🔍 **Test ve Doğrulama**

### **Test URL'leri:**
```bash
# Frontend
curl https://ogsiparis.com

# API Health Check
curl https://ogsiparis.com/api/dropdown

# Recipe Cost Test (Peynirli Su Böreği)
curl "https://ogsiparis.com/api/receteler/maliyet?recipeId=1&miktar=1000"
# Beklenen sonuç: {"toplamMaliyet": 15.01, ...}
```

### **Beklenen Sonuçlar:**
- ✅ Frontend: https://ogsiparis.com yükleniyor
- ✅ API endpoints çalışıyor
- ✅ Recipe cost: 15.01₺ dönüyor
- ✅ Database bağlantısı aktif
- ✅ SSL sertifikası aktif

## 🚨 **Troubleshooting**

### **Database Bağlantı Kontrolü:**
```bash
# PostgreSQL service kontrol
systemctl status postgresql

# Database bağlantı test
psql -h localhost -U ogform -d ogformdb
```

### **PM2 Monitoring:**
```bash
# Logs kontrol
pm2 logs og-backend

# Memory ve CPU kullanımı
pm2 monit

# Restart
pm2 restart og-backend
```

## 📊 **Production Özellikleri**

### **Sistem Kapasitesi:**
- ✅ Recipe cost calculation: 15.01₺/KG
- ✅ 38 ürün fiyat yönetimi
- ✅ Sipariş yönetim sistemi
- ✅ Stok takip sistemi
- ✅ Kullanıcı yetkilendirme

### **Database Schema:**
- ✅ PostgreSQL: ogformdb
- ✅ User: ogform / secret
- ✅ Prisma ORM ile migration
- ✅ Recipe ingredients cost tracking

---

## 🎯 **Final Checklist**

- [ ] Domain: ogsiparis.com SSL aktif
- [ ] Database: ogformdb oluşturuldu
- [ ] Environment variables güncellendi
- [ ] Dependencies yüklendi
- [ ] Build tamamlandı
- [ ] PM2 ile uygulama başlatıldı
- [ ] API endpoints test edildi
- [ ] Recipe cost: 15.01₺ doğrulandı

**🚀 Deployment tamamlandığında sistem https://ogsiparis.com adresinde çalışır durumda olacak!** 