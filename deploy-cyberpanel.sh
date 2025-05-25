#!/bin/bash

# OG Project - CyberPanel Deployment Script
# Domain: ogsiparis.com
echo "🚀 OG Sipariş Yönetim Sistemi - CyberPanel Deployment Başlıyor..."

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 ogsiparis.com CyberPanel Deployment Checklist${NC}"
echo "=================================================="

# 1. Environment kontrolü
echo -e "${YELLOW}1. Environment dosyası kontrol ediliyor...${NC}"
if [ ! -f "backend/.env" ]; then
    echo -e "${RED}❌ backend/.env dosyası bulunamadı!${NC}"
    echo -e "${YELLOW}💡 Production environment dosyasını kopyalıyorum...${NC}"
    cp backend/.env.production backend/.env
    echo -e "${GREEN}✅ .env dosyası oluşturuldu${NC}"
    echo -e "${YELLOW}⚠️  Database credentials kontrol edin:${NC}"
    echo "   DATABASE_URL=postgresql://ogform:secret@localhost:5432/ogformdb"
else
    echo -e "${GREEN}✅ Environment dosyası mevcut${NC}"
fi

# 2. Database credentials kontrolü
echo -e "${YELLOW}2. Database credentials kontrol ediliyor...${NC}"
if grep -q "ogformdb" backend/.env && grep -q "ogform" backend/.env; then
    echo -e "${GREEN}✅ Database credentials doğru${NC}"
else
    echo -e "${YELLOW}⚠️  Database credentials güncelleniyor...${NC}"
    sed -i 's|DATABASE_URL=.*|DATABASE_URL="postgresql://ogform:secret@localhost:5432/ogformdb?schema=public"|' backend/.env
fi

# 3. Domain configuration kontrolü
echo -e "${YELLOW}3. Domain configuration kontrol ediliyor...${NC}"
if grep -q "ogsiparis.com" backend/.env; then
    echo -e "${GREEN}✅ Domain configuration doğru${NC}"
else
    echo -e "${YELLOW}⚠️  Domain configuration güncelleniyor...${NC}"
    sed -i 's|NEXT_PUBLIC_API_URL=.*|NEXT_PUBLIC_API_URL=https://ogsiparis.com/api|' backend/.env
    sed -i 's|CORS_ORIGIN=.*|CORS_ORIGIN=https://ogsiparis.com|' backend/.env
fi

# 4. Dependencies install
echo -e "${YELLOW}4. Dependencies yükleniyor...${NC}"
npm run install:all

# 5. Build işlemi
echo -e "${YELLOW}5. Production build yapılıyor...${NC}"
npm run build

# 6. Database migration
echo -e "${YELLOW}6. Database migration çalıştırılıyor...${NC}"
cd backend
npx prisma generate
echo -e "${YELLOW}   Prisma schema generate tamamlandı${NC}"
npx prisma db push
echo -e "${YELLOW}   Database migration tamamlandı${NC}"
cd ..

# 7. Logs klasörü oluştur
echo -e "${YELLOW}7. Logs klasörü oluşturuluyor...${NC}"
mkdir -p backend/logs

# 8. Upload klasörü oluştur
echo -e "${YELLOW}8. Upload klasörü oluşturuluyor...${NC}"
mkdir -p backend/uploads

# 9. Permissions ayarla
echo -e "${YELLOW}9. Dosya izinleri ayarlanıyor...${NC}"
chmod -R 755 backend/uploads
chmod -R 755 backend/logs
chmod +x backend/ecosystem.config.js

echo -e "${GREEN}✅ Build işlemi tamamlandı!${NC}"
echo ""
echo -e "${BLUE}📌 CyberPanel'e Upload Adımları:${NC}"
echo "=================================="
echo "1. 📁 Tüm dosyaları /home/ogsiparis.com/public_html/ klasörüne upload edin"
echo "2. 🗄️ CyberPanel'de PostgreSQL database oluşturun:"
echo "   - Database Name: ogformdb"
echo "   - Username: ogform"
echo "   - Password: secret"
echo "3. 🔧 Environment variables zaten hazır"
echo "4. 🚀 PM2 ile uygulamayı başlatın: pm2 start ecosystem.config.js"
echo "5. 🔒 SSL sertifikası aktifleştirin (Let's Encrypt)"
echo ""
echo -e "${BLUE}🧪 Test URL'leri:${NC}"
echo "=================================="
echo "Frontend: https://ogsiparis.com"
echo "API Health: https://ogsiparis.com/api/dropdown"
echo "Recipe Cost: https://ogsiparis.com/api/receteler/maliyet?recipeId=1&miktar=1000"
echo "Beklenen Recipe Cost: 15.01₺"
echo ""
echo -e "${YELLOW}⚠️  Önemli Notlar:${NC}"
echo "• Node.js version: 18+ gerekli"
echo "• PM2 kurulu olmalı: npm install -g pm2"
echo "• PostgreSQL service aktif olmalı"
echo "• Domain SSL sertifikası aktif olmalı"
echo "• Recipe cost calculation sistemi hazır: 15.01₺/KG" 