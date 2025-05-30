#!/bin/bash

# OG Frontend - Production Deployment Script
echo "🚀 OG Frontend deployment başlıyor..."

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Frontend dizinine git
cd /home/ogsiparis.com/public_html || exit 1

echo -e "${YELLOW}1. Backup alınıyor...${NC}"
rm -rf backup_old
mkdir backup_old
mv * backup_old/ 2>/dev/null
mv .* backup_old/ 2>/dev/null

echo -e "${YELLOW}2. Frontend repository clone ediliyor...${NC}"
git clone https://github.com/MehmetEminSelek/ogFrontend.git temp
cd temp

echo -e "${YELLOW}3. Environment dosyası oluşturuluyor...${NC}"
echo "VITE_API_BASE_URL=https://ogsiparis.com:3000/api" > .env

echo -e "${YELLOW}4. Dependencies yükleniyor...${NC}"
npm install

echo -e "${YELLOW}5. Production build yapılıyor...${NC}"
npm run build

echo -e "${YELLOW}6. Build dosyaları taşınıyor...${NC}"
cp -r dist/* /home/ogsiparis.com/public_html/
cd /home/ogsiparis.com/public_html
rm -rf temp

echo -e "${YELLOW}7. Index.html güncelleniyor...${NC}"
JS_FILE=$(ls assets/ | grep -E "index-.*\.js$" | head -1)
CSS_FILE=$(ls assets/ | grep -E "index-.*\.css$" | head -1)

cat > index.html << EOF
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ömer Güllü Sistemi - Baklavacı Yönetim Paneli</title>
    <meta name="description" content="Ömer Güllü Baklavacı İşletmesi - Modern Sipariş ve Stok Yönetim Sistemi">
    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    <script type="module" crossorigin src="/assets/$JS_FILE"></script>
    <link rel="stylesheet" crossorigin href="/assets/$CSS_FILE">
</head>
<body>
    <div id="app"></div>
</body>
</html>
EOF

echo -e "${YELLOW}8. Cache temizleniyor...${NC}"
# LiteSpeed cache clear (opsiyonel)

echo -e "${GREEN}✅ Frontend deployment tamamlandı!${NC}"
echo ""
echo -e "${BLUE}Site:${NC} https://ogsiparis.com"
echo -e "${BLUE}API:${NC} https://ogsiparis.com:3000/api" 