#!/bin/bash

# OG Backend - Production Deployment Script
echo "🚀 OG Backend deployment başlıyor..."

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Backend dizinine git
cd /home/ogsiparis.com/ogBackend || exit 1

echo -e "${YELLOW}1. Git pull yapılıyor...${NC}"
git pull origin main

echo -e "${YELLOW}2. Dependencies yükleniyor...${NC}"
npm install --production

echo -e "${YELLOW}3. Environment dosyası kontrol ediliyor...${NC}"
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ .env dosyası bulunamadı!${NC}"
    echo -e "${YELLOW}💡 .env.production dosyasını kopyalıyorum...${NC}"
    cp .env.production .env
    echo -e "${GREEN}✅ .env dosyası oluşturuldu${NC}"
    echo -e "${YELLOW}⚠️  Database ve JWT credentials kontrol edin!${NC}"
fi

echo -e "${YELLOW}4. Prisma setup yapılıyor...${NC}"
npx prisma generate
npx prisma db push

echo -e "${YELLOW}5. PM2 ile restart yapılıyor...${NC}"
pm2 restart og-backend || pm2 start ecosystem.config.js

echo -e "${YELLOW}6. PM2 durumu kontrol ediliyor...${NC}"
pm2 status og-backend

echo -e "${GREEN}✅ Backend deployment tamamlandı!${NC}"
echo ""
echo -e "${BLUE}API Test:${NC} curl http://localhost:3000/api/dropdown" 