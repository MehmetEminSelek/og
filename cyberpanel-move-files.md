# 🔄 CyberPanel Dosya Taşıma Rehberi

## 📁 **Sorun:** Dosyalar `public_html/og/` altında, `public_html/` altında olması gerekiyor

### **🔍 Mevcut Durum Kontrolü:**
```bash
# SSH ile sunucuya bağlanın
ssh root@your-server-ip

# Mevcut dizin yapısını kontrol edin
ls -la /home/ogsiparis.com/public_html/
ls -la /home/ogsiparis.com/public_html/og/
```

### **📋 Dosya Taşıma Adımları:**

#### **1. Backup Oluştur (Güvenlik için)**
```bash
# Mevcut dosyaları yedekle
cd /home/ogsiparis.com/
tar -czf backup_$(date +%Y%m%d_%H%M%S).tar.gz public_html/
```

#### **2. og/ Klasöründeki Dosyaları Taşı**
```bash
# public_html dizinine git
cd /home/ogsiparis.com/public_html/

# og/ klasöründeki tüm dosyaları üst dizine taşı
mv og/* ./
mv og/.* ./ 2>/dev/null || true

# og/ klasörünü sil
rmdir og/
```

#### **3. Alternatif Yöntem (Daha Güvenli)**
```bash
# public_html dizinine git
cd /home/ogsiparis.com/public_html/

# Dosyaları kopyala (önce test için)
cp -r og/* ./
cp -r og/.* ./ 2>/dev/null || true

# Kopyalama başarılıysa og/ klasörünü sil
rm -rf og/
```

#### **4. İzinleri Düzelt**
```bash
# Dosya sahipliğini düzelt
chown -R cyberpanel:cyberpanel /home/ogsiparis.com/public_html/

# İzinleri düzelt
chmod -R 755 /home/ogsiparis.com/public_html/
```

### **✅ Doğrulama:**
```bash
# Dosya yapısını kontrol et
ls -la /home/ogsiparis.com/public_html/

# Şunları görmelisiniz:
# - backend/
# - frontend/
# - package.json
# - README.md
# - vb.
```

### **🚀 Kurulum Devam:**
```bash
# public_html dizininde olduğunuzdan emin olun
cd /home/ogsiparis.com/public_html/

# Dependencies yükle
npm run install:all

# Environment setup
cp backend/.env.production backend/.env

# Build
npm run build

# PM2 ile başlat
pm2 start ecosystem.config.js
```

### **⚠️ Dikkat Edilecekler:**
- Dosya taşıma işleminden önce mutlaka backup alın
- Hidden dosyalar (`.env`, `.gitignore` vb.) da taşınmalı
- İzinleri mutlaka düzeltin
- Taşıma sonrası dosya yapısını kontrol edin

### **🔧 Sorun Giderme:**
```bash
# Eğer "Permission denied" hatası alırsanız:
sudo chown -R $USER:$USER /home/ogsiparis.com/public_html/

# Eğer dosyalar eksikse:
ls -la /home/ogsiparis.com/public_html/og/
# Eksik dosyaları manuel taşıyın
``` 