# 🔄 GitHub Webhook ile Otomatik Deployment

## 📋 Genel Bakış

GitHub'a push yaptığınızda otomatik olarak Hostinger'daki siteniz güncellensin! İki yöntem mevcuttur:

1. **GitHub Actions** (Önerilen)
2. **GitHub Webhooks + CyberPanel**

## 🚀 Yöntem 1: GitHub Actions (Önerilen)

### Avantajları
- ✅ Build işlemi GitHub sunucularında yapılır (VPS'i yormaz)
- ✅ Test'ler otomatik çalışır
- ✅ Hata durumunda rollback kolay
- ✅ Deployment logları GitHub'da saklanır

### Kurulum Adımları

#### 1. GitHub Repository Secrets Ekleme
```
Repository → Settings → Secrets and variables → Actions
```

Eklenecek secret'lar:
```
HOSTINGER_HOST: 147.93.123.161
HOSTINGER_USERNAME: root
HOSTINGER_PASSWORD: [SSH şifreniz]
HOSTINGER_PORT: 22
HOSTINGER_PATH: /home/ogsiparis.com/public_html/backend
HOSTINGER_FRONTEND_PATH: /home/ogsiparis.com/public_html/frontend
VITE_API_BASE_URL: https://ogsiparis.com/api
```

#### 2. Workflow Dosyaları Zaten Hazır!
- Frontend: `frontend/.github/workflows/main.yml`
- Backend: `backend/.github/workflows/main.yml`

#### 3. İlk Deployment
```bash
# Frontend deployment
cd frontend
git add .
git commit -m "Enable auto deployment"
git push origin main

# Backend deployment
cd backend
git add .
git commit -m "Enable auto deployment"
git push origin main
```

## 🔗 Yöntem 2: GitHub Webhooks + CyberPanel

### Avantajları
- ✅ Gerçek zamanlı senkronizasyon
- ✅ CyberPanel entegrasyonu
- ✅ Daha basit konfigürasyon

### Kurulum

#### 1. VPS'de Webhook Handler Kurulumu
```bash
ssh root@147.93.123.161
cd /root/og-project
./scripts/deployment/setup-github-webhook.sh
```

#### 2. GitHub'da Webhook Ekleme

**Frontend Repository için:**
1. Repository → Settings → Webhooks → Add webhook
2. Payload URL: `https://ogsiparis.com/webhook.php`
3. Content type: `application/json`
4. Secret: [Script'in verdiği secret]
5. Events: Just the push event

**Backend Repository için:**
- Aynı adımları backend repository için tekrarlayın

## 🛠️ CyberPanel Git Manager (Alternatif)

CyberPanel'in kendi Git Manager'ını kullanmak için:

### 1. CyberPanel'de Git Kurulumu
```
CyberPanel → Git Manager → Setup Git
```

### 2. Deploy Key Oluşturma
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/og_deploy_key -N ""
cat ~/.ssh/og_deploy_key.pub
```

### 3. GitHub'a Deploy Key Ekleme
```
Repository → Settings → Deploy keys → Add deploy key
```

### 4. Auto Pull Ayarlama
```
CyberPanel → Git Manager → Auto Pull from Git
Repository URL: https://github.com/username/repo.git
Branch: main
```

## 📊 Karşılaştırma Tablosu

| Özellik | GitHub Actions | Webhooks | CyberPanel Git |
|---------|---------------|----------|----------------|
| Build Yeri | GitHub | VPS | VPS |
| Test Desteği | ✅ Var | ❌ Yok | ❌ Yok |
| Log Görüntüleme | GitHub UI | VPS logs | CyberPanel |
| Kurulum Kolaylığı | Orta | Kolay | Çok Kolay |
| Özelleştirme | Yüksek | Orta | Düşük |

## 🔍 Deployment Durumu Kontrolü

### GitHub Actions için:
```
Repository → Actions → Son workflow run'ı kontrol edin
```

### Webhook için:
```bash
# VPS'de log kontrolü
tail -f /tmp/webhook-ogFrontend.log
tail -f /tmp/webhook-ogBackend.log
```

### PM2 Status:
```bash
pm2 status
pm2 logs og-backend
```

## 🚨 Sorun Giderme

### SSH Bağlantı Hatası
```bash
# SSH key authentication kullanın
ssh-copy-id root@147.93.123.161
```

### Build Hataları
```bash
# Manuel build test
cd /home/ogsiparis.com/public_html/frontend
npm run build

cd /home/ogsiparis.com/public_html/backend
npm run build
```

### Webhook 401 Hatası
- GitHub webhook secret'ı kontrol edin
- VPS'deki WEBHOOK_SECRET environment variable'ı kontrol edin

## 📝 Best Practices

1. **Staging Branch Kullanın**
   - `main` → Production
   - `develop` → Staging

2. **Environment Variables**
   - Production secret'ları GitHub Secrets'da saklayın
   - `.env` dosyalarını commit etmeyin

3. **Database Migrations**
   - Migration'ları test edin
   - Backup alın

4. **Monitoring**
   - PM2 monitoring aktif tutun
   - Error loglarını düzenli kontrol edin

## 🎯 Sonuç

GitHub webhook sistemi ile:
- ✅ `git push` = Otomatik deployment
- ✅ Downtime yok
- ✅ Rollback kolay
- ✅ Test entegrasyonu

Artık kod yazmaya odaklanabilirsiniz! 🚀 