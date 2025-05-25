#!/bin/bash

# 🚀 OG Projesi CyberPanel Hızlı Kurulum
# Bu script'i VPS'te çalıştırın: wget -O - https://raw.githubusercontent.com/your-repo/og/main/scripts/deployment/cyberpanel-quick-setup.sh | bash

echo "🚀 OG Projesi CyberPanel Kurulumu Başlıyor..."

# Domain ve proje ayarları
DOMAIN="ogsiparis.com"
PROJECT_DIR="/home/ogsiparis.com/public_html"

# 1. Domain oluştur
echo "🌐 Domain oluşturuluyor..."
cyberpanel createWebsite --domainName $DOMAIN --email admin@$DOMAIN --package Default

# 2. SSL kur
echo "🔒 SSL kuruluyor..."
cyberpanel issueSSL --domainName $DOMAIN

# 3. Database oluştur
echo "🗄️ Database oluşturuluyor..."
DB_PASS=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
cyberpanel createDatabase --databaseWebsite $DOMAIN --dbName ogformdb --dbUsername ogform --dbPassword $DB_PASS

# 4. Node.js kur
echo "⚙️ Node.js kuruluyor..."
cyberpanel createNodeApp --domainName $DOMAIN --appName "og-backend" --nodeVersion "18" --appPath "/backend" --startupFile "server.js"

echo "✅ Temel kurulum tamamlandı!"
echo "📝 Database şifresi: $DB_PASS"
echo "🔗 Şimdi proje dosyalarını yükleyin ve tam deployment script'ini çalıştırın." 