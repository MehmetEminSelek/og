#!/bin/bash

# 🔄 GitHub Webhook Setup for CyberPanel
# Bu script CyberPanel'de GitHub webhook'larını ayarlar

echo "🔄 GitHub Webhook Setup for CyberPanel"
echo "======================================"

# Konfigürasyon
DOMAIN="ogsiparis.com"
BACKEND_PATH="/home/$DOMAIN/public_html/backend"
FRONTEND_PATH="/home/$DOMAIN/public_html/frontend"
WEBHOOK_SECRET=$(openssl rand -hex 20)

# Webhook endpoint oluştur
echo "📝 Webhook endpoint oluşturuluyor..."

cat > /home/$DOMAIN/public_html/webhook.php << 'EOF'
<?php
// GitHub Webhook Handler for OG Project

$secret = getenv('WEBHOOK_SECRET');
$headers = getallheaders();
$payload = file_get_contents('php://input');

// Verify webhook signature
$signature = 'sha256=' . hash_hmac('sha256', $payload, $secret);
if (!hash_equals($signature, $headers['X-Hub-Signature-256'] ?? '')) {
    http_response_code(401);
    die('Unauthorized');
}

$data = json_decode($payload, true);

// Check if push to main branch
if ($data['ref'] === 'refs/heads/main') {
    $repo = $data['repository']['name'];
    
    if ($repo === 'ogFrontend') {
        // Frontend deployment
        exec('cd /home/ogsiparis.com/public_html/frontend && git pull && npm install && npm run build 2>&1', $output);
    } elseif ($repo === 'ogBackend') {
        // Backend deployment
        exec('cd /home/ogsiparis.com/public_html/backend && git pull && npm install && npm run build && pm2 restart og-backend 2>&1', $output);
    }
    
    // Log output
    file_put_contents('/tmp/webhook-' . $repo . '.log', implode("\n", $output), FILE_APPEND);
}

http_response_code(200);
echo "OK";
?>
EOF

# CyberPanel'de Git Manager kullanımı
echo ""
echo "📋 CyberPanel Git Manager Kurulumu:"
echo "1. CyberPanel → Git Manager"
echo "2. 'Deploy Key' oluşturun:"
echo ""

# SSH key oluştur
ssh-keygen -t rsa -b 4096 -f ~/.ssh/og_deploy_key -N ""

echo "3. Bu public key'i GitHub'a ekleyin:"
echo ""
cat ~/.ssh/og_deploy_key.pub
echo ""

# Webhook URL'leri
echo "4. GitHub Webhook URL'leri:"
echo "   Frontend: https://$DOMAIN/webhook.php"
echo "   Backend: https://$DOMAIN/webhook.php"
echo ""
echo "5. Webhook Secret: $WEBHOOK_SECRET"
echo ""

# Environment variable ekle
echo "WEBHOOK_SECRET=$WEBHOOK_SECRET" >> /home/$DOMAIN/.bashrc

# Git config
echo "📝 Git konfigürasyonu..."
cd $BACKEND_PATH
git config --global --add safe.directory $BACKEND_PATH
git config core.filemode false

cd $FRONTEND_PATH
git config --global --add safe.directory $FRONTEND_PATH
git config core.filemode false

echo ""
echo "✅ Webhook setup tamamlandı!"
echo ""
echo "🔧 GitHub'da Webhook Ekleme:"
echo "1. Repository → Settings → Webhooks → Add webhook"
echo "2. Payload URL: https://$DOMAIN/webhook.php"
echo "3. Content type: application/json"
echo "4. Secret: $WEBHOOK_SECRET"
echo "5. Events: Just the push event"
echo "" 