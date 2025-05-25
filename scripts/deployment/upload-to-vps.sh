#!/bin/bash

# 🚀 OG Projesi VPS Upload Script
# Bu script proje dosyalarını VPS'e yükler

# Konfigürasyon
VPS_IP="YOUR_VPS_IP"
VPS_USER="root"
DOMAIN="ogsiparis.com"
PROJECT_DIR="/home/$DOMAIN/public_html"

echo "🚀 OG Projesi VPS'e yükleniyor..."
echo "📋 Hedef: $VPS_USER@$VPS_IP:$PROJECT_DIR"

# 1. VPS bağlantısını test et
echo "🔍 VPS bağlantısı test ediliyor..."
if ! ssh -o ConnectTimeout=10 $VPS_USER@$VPS_IP "echo 'Bağlantı başarılı'"; then
    echo "❌ VPS'e bağlanılamadı. IP adresini ve SSH anahtarlarını kontrol edin."
    exit 1
fi

# 2. Proje dosyalarını hazırla
echo "📦 Proje dosyaları hazırlanıyor..."

# Geçici dizin oluştur
TEMP_DIR="/tmp/og-project-$(date +%Y%m%d_%H%M%S)"
mkdir -p $TEMP_DIR

# Backend dosyalarını kopyala (node_modules hariç)
echo "   📁 Backend dosyaları kopyalanıyor..."
rsync -av --exclude='node_modules' --exclude='.next' --exclude='logs' ./backend/ $TEMP_DIR/backend/

# Frontend dosyalarını kopyala (node_modules ve dist hariç)
echo "   📁 Frontend dosyaları kopyalanıyor..."
rsync -av --exclude='node_modules' --exclude='dist' ./frontend/ $TEMP_DIR/frontend/

# Script dosyalarını kopyala
echo "   📁 Script dosyaları kopyalanıyor..."
cp -r ./scripts/ $TEMP_DIR/scripts/

# Docs dosyalarını kopyala
echo "   📁 Dokümantasyon kopyalanıyor..."
cp -r ./docs/ $TEMP_DIR/docs/

# Root dosyaları kopyala
echo "   📁 Root dosyaları kopyalanıyor..."
cp ./package.json $TEMP_DIR/
cp ./README.md $TEMP_DIR/

echo "✅ Dosyalar hazırlandı: $TEMP_DIR"

# 3. VPS'e yükle
echo "📤 VPS'e yükleniyor..."

# Hedef dizini oluştur
ssh $VPS_USER@$VPS_IP "mkdir -p /root/og-project"

# Dosyaları yükle
rsync -avz --progress $TEMP_DIR/ $VPS_USER@$VPS_IP:/root/og-project/

echo "✅ Dosyalar VPS'e yüklendi"

# 4. Deployment script'ini çalıştırılabilir yap
echo "🔧 Deployment script'i hazırlanıyor..."
ssh $VPS_USER@$VPS_IP "chmod +x /root/og-project/scripts/deployment/cyberpanel-deploy.sh"

# 5. Geçici dosyaları temizle
echo "🧹 Geçici dosyalar temizleniyor..."
rm -rf $TEMP_DIR

echo ""
echo "🎉 Upload tamamlandı!"
echo ""
echo "📋 Sonraki adımlar:"
echo "1. VPS'e bağlanın: ssh $VPS_USER@$VPS_IP"
echo "2. Proje dizinine gidin: cd /root/og-project"
echo "3. Deployment script'ini çalıştırın: ./scripts/deployment/cyberpanel-deploy.sh"
echo ""
echo "🔗 Deployment sonrası erişim:"
echo "   Website: https://$DOMAIN"
echo "   Admin: https://$DOMAIN/login"
echo "" 