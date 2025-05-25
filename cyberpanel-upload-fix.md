# 🔧 CyberPanel Dosya Yükleme Sorunu Çözümü

## ❌ **Sorun:** "You are not authorized to access this resource"

Bu hata CyberPanel'de dosya yüklerken çıkar ve genellikle şu nedenlerle olur:

### **1. Dosya Boyutu Sınırı**
```bash
# CyberPanel > Websites > ogsiparis.com > Configurations
# PHP Configuration > upload_max_filesize: 50M
# PHP Configuration > post_max_size: 50M
# PHP Configuration > max_execution_time: 300
```

### **2. Dizin İzinleri**
```bash
# SSH ile sunucuya bağlanın
ssh root@your-server-ip

# Dizin izinlerini düzeltin
chown -R cyberpanel:cyberpanel /home/ogsiparis.com/public_html/
chmod -R 755 /home/ogsiparis.com/public_html/
```

### **3. ModSecurity Kuralları**
```bash
# ModSecurity'yi geçici olarak devre dışı bırakın
# CyberPanel > Security > ModSecurity
# ogsiparis.com için ModSecurity: OFF
```

### **4. Firewall Kuralları**
```bash
# CyberPanel > Security > Firewall
# Port 80, 443, 22 açık olmalı
ufw allow 80
ufw allow 443
ufw allow 22
```

## ✅ **Çözüm Adımları:**

### **Yöntem 1: FTP/SFTP ile Upload**
```bash
# FileZilla veya WinSCP kullanın
Host: your-server-ip
Username: root (veya cyberpanel user)
Password: your-password
Port: 22 (SFTP)

# Dosyaları şuraya yükleyin:
/home/ogsiparis.com/public_html/
```

### **Yöntem 2: Git Clone (Önerilen)**
```bash
# SSH ile sunucuya bağlanın
ssh root@your-server-ip

# Proje dizinine gidin
cd /home/ogsiparis.com/public_html/

# Mevcut dosyaları temizleyin
rm -rf *

# Git repository'den clone yapın
git clone https://github.com/your-repo/og-project.git .

# Veya dosyaları manuel kopyalayın
```

### **Yöntem 3: Zip Upload**
```bash
# 1. Projeyi zip'leyin (local'de)
# 2. CyberPanel File Manager'da zip upload edin
# 3. Extract edin
```

## 🚀 **Upload Sonrası Kurulum:**

### **1. Dependencies Yükleme**
```bash
# SSH ile sunucuya bağlanın
cd /home/ogsiparis.com/public_html/

# Node.js kurulumu (eğer yoksa)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# PM2 kurulumu
npm install -g pm2

# Dependencies yükleme
npm run install:all
```

### **2. Environment Setup**
```bash
# Production environment dosyasını kopyala
cp backend/.env.production backend/.env

# Database credentials'ları kontrol et
nano backend/.env
```

### **3. Database Setup**
```bash
# CyberPanel > Databases > Create Database
# Database Name: ogformdb
# Username: ogform  
# Password: secret

# Migration çalıştır
cd backend
npx prisma generate
npx prisma db push
cd ..
```

### **4. Build ve Start**
```bash
# Production build
npm run build

# PM2 ile başlat
pm2 start ecosystem.config.js

# Otomatik başlatma
pm2 save
pm2 startup
```

### **5. SSL Sertifikası**
```bash
# CyberPanel > SSL > Issue SSL
# Domain: ogsiparis.com
# Let's Encrypt: Enable
# Force HTTPS: Enable
```

## 🧪 **Test**
```bash
# Frontend test
curl https://ogsiparis.com

# API test  
curl https://ogsiparis.com/api/dropdown

# Recipe cost test
curl "https://ogsiparis.com/api/receteler/maliyet?recipeId=1&miktar=1000"
```

## 📞 **Alternatif Çözümler:**

### **Manuel Upload (Eğer CyberPanel çalışmazsa):**
1. **WinSCP/FileZilla** ile SFTP bağlantısı
2. Dosyaları `/home/ogsiparis.com/public_html/` dizinine upload
3. SSH ile izinleri düzelt: `chmod -R 755 /home/ogsiparis.com/public_html/`
4. Kurulum adımlarını SSH'dan çalıştır

### **Git Repository (En Kolay):**
1. GitHub'a projeyi push edin
2. SSH ile sunucuya bağlanın  
3. `git clone` ile projeyi indirin
4. Kurulum adımlarını çalıştırın

**🎯 Bu yöntemlerden biri mutlaka çalışacak!** 