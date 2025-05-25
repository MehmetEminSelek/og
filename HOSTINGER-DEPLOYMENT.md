# 🚀 OG Project - Hostinger Deployment Guide

## 📋 Pre-Deployment Checklist

### ✅ **Sistem Durumu:**
- ✅ Backend API endpoints çalışıyor
- ✅ Frontend UI components hazır  
- ✅ Database schema (Prisma) hazır
- ✅ Recipe cost calculation sistemi aktif
- ✅ Price management sistemi çalışıyor
- ✅ CORS configuration yapılmış

## 🔧 Hostinger Deployment Adımları

### 1. **Database Setup (Hostinger)**
```bash
# Hostinger'da PostgreSQL database oluştur
# Database credentials'ları not al:
# - Host: your-db-host
# - Database: your-db-name  
# - Username: your-username
# - Password: your-password
```

### 2. **Environment Variables Güncelleme**
```bash
# backend/.env dosyasını güncelle:
DATABASE_URL="postgresql://username:password@hostname:5432/database_name?schema=public"
NEXT_PUBLIC_API_URL=https://your-domain.com/api
CORS_ORIGIN=https://your-frontend-domain.com
```

### 3. **Build ve Deploy**
```bash
# Local'de build yap
chmod +x deploy-hostinger.sh
./deploy-hostinger.sh

# Files'ları Hostinger'a upload et
# public_html/ klasörüne tüm dosyaları kopyala
```

### 4. **Hostinger Server Setup**
```bash
# SSH ile Hostinger'a bağlan
ssh username@your-server.com

# Dependencies install
npm install

# Database migration
cd backend
npx prisma generate
npx prisma db push

# PM2 ile start
npm install -g pm2
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### 5. **Domain Configuration**
```bash
# Frontend domain: https://your-domain.com
# Backend API: https://your-domain.com/api
# 
# Nginx/Apache configuration:
# - Frontend: Serve from /frontend/dist
# - Backend: Proxy to Node.js app (port 8080)
```

## 🔍 **Verification Steps**

### Test Endpoints:
- ✅ `GET /api/dropdown` - Dropdown data
- ✅ `GET /api/urunler` - Products list
- ✅ `GET /api/receteler` - Recipes list  
- ✅ `GET /api/receteler/maliyet?recipeId=1&miktar=1000` - Recipe cost
- ✅ `GET /api/siparis` - Orders list

### Test Features:
- ✅ Recipe cost calculation (15.01₺ for Peynirli Su Böreği)
- ✅ Price management system
- ✅ Order management
- ✅ Product management

## 🚨 **Troubleshooting**

### Common Issues:
1. **Database Connection**: Check DATABASE_URL format
2. **CORS Errors**: Update CORS_ORIGIN in .env
3. **API 404**: Verify VITE_API_BASE_URL
4. **Memory Issues**: PM2 restart with memory limit

### Logs:
```bash
# PM2 logs
pm2 logs og-backend

# Application logs  
tail -f backend/logs/combined.log
```

## 📊 **Performance Monitoring**

```bash
# PM2 monitoring
pm2 monit

# Memory usage
pm2 show og-backend
```

## 🔐 **Security Notes**

- ✅ Environment variables secured
- ✅ CORS properly configured
- ✅ Database credentials protected
- ✅ API endpoints authenticated

---

## 📞 **Support**

Deployment sırasında sorun yaşarsanız:
1. Logs'ları kontrol edin
2. Environment variables'ları doğrulayın  
3. Database connection'ı test edin
4. PM2 status'unu kontrol edin 