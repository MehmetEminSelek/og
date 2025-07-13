# 🔄 GitHub Webhook Kurulum Rehberi

## 🎯 Amaç
GitHub'dan yapılan her push'ta otomatik olarak hostingde projeyi güncellemek.

## 📋 Gereksinimler
- ✅ GitHub Personal Access Token (PAT) - **HAZIR**
- ✅ Git authentication - **HAZIR**
- ✅ Webhook receiver script - **HAZIR**
- ✅ PM2 ecosystem config - **HAZIR**

## 🚀 Kurulum Adımları

### **1. Hostingde Webhook Receiver Çalıştırma**

```bash
# Projeyi hostingde klonla
cd /home/ogsiparis.com/public_html
git clone https://github.com/MehmetEminSelek/og.git .

# Dependencies yükle
npm install
cd backend && npm install
cd ../frontend && npm install

# PM2 ile çalıştır
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup
```

### **2. Environment Variables Ayarlama**

```bash
# .env dosyasına ekle
export WEBHOOK_SECRET="your-super-secret-webhook-key"
export PROJECT_PATH="/home/ogsiparis.com/public_html"
export DATABASE_URL="your-database-url"
export JWT_SECRET="your-jwt-secret"
```

### **3. GitHub Repository Ayarları**

1. **GitHub'da Repository'ye git:**
   - https://github.com/MehmetEminSelek/og

2. **Settings → Webhooks → Add webhook**
   - **Payload URL**: `https://ogsiparis.com/webhook`
   - **Content type**: `application/json`
   - **Secret**: `your-super-secret-webhook-key` (yukarıdaki ile aynı)
   - **Events**: `Just the push event`
   - **Active**: ✅ Checked

3. **SSL verification**: Enable

### **4. Nginx Configuration**

```nginx
# /etc/nginx/sites-available/ogsiparis.com
server {
    listen 80;
    listen [::]:80;
    server_name ogsiparis.com www.ogsiparis.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ogsiparis.com www.ogsiparis.com;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/ogsiparis.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ogsiparis.com/privkey.pem;
    
    # Root directory
    root /home/ogsiparis.com/public_html/frontend/dist;
    index index.html;
    
    # Frontend (Vue.js)
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Backend API
    location /api {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
    
    # Webhook endpoint
    location /webhook {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 30;
        proxy_connect_timeout 30;
        proxy_send_timeout 30;
    }
    
    # Static files
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### **5. Test Etme**

```bash
# Health check
curl https://ogsiparis.com/webhook/health

# Manuel deployment test
curl -X POST https://ogsiparis.com/webhook \
  -H "Content-Type: application/json" \
  -H "X-Hub-Signature-256: sha256=..." \
  -d '{"ref":"refs/heads/master","head_commit":{"message":"test"}}'
```

## 🔐 Güvenlik Notları

1. **Webhook Secret**: Güçlü bir secret kullanın
2. **SSL**: HTTPS zorunlu
3. **Firewall**: Sadece GitHub IP'lerinden webhook kabul edin
4. **Logs**: Webhook loglarını düzenli kontrol edin

## 📊 Monitoring

```bash
# PM2 status
pm2 status

# Logs
pm2 logs og-webhook --lines 50

# Webhook log dosyası
tail -f /home/ogsiparis.com/public_html/webhook.log
```

## 🔄 Workflow

1. **Developer push yapar** → GitHub repository
2. **GitHub webhook gönderir** → `https://ogsiparis.com/webhook`
3. **Webhook receiver çalışır** → Otomatik deployment
4. **Süreç tamamlanır** → Site güncel!

## 🎯 Test Senaryosu

```bash
# Local'de değişiklik yap
git add .
git commit -m "🔄 Webhook test"
git push origin master

# Webhook log'u kontrol et
tail -f webhook.log

# Site güncellendiğini kontrol et
curl https://ogsiparis.com/api/health
```

---

## 🎉 Başarı!

Artık her GitHub push'ta otomatik deployment yapılacak! 🚀 