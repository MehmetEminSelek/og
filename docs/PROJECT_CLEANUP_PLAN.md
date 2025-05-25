# 🧹 Proje Temizleme ve Düzenleme Planı

## 📊 Mevcut Durum Analizi

### 🚨 Tespit Edilen Sorunlar:
1. **Duplikasyon**: `ogBackend/ogBackend/` iç içe klasör yapısı
2. **Dağınık dosyalar**: Ana dizinde test dosyaları ve script'ler
3. **Çoklu deployment**: Birden fazla deployment dosyası
4. **Gereksiz dosyalar**: Boş dosyalar ve eski test dosyaları
5. **Karışık isimlendirme**: og prefix'li klasörler

## 🎯 Hedef Yapı

```
og/
├── backend/                    # Ana backend uygulaması
│   ├── pages/api/             # API endpoint'leri
│   ├── prisma/                # Veritabanı şeması
│   ├── lib/                   # Utility fonksiyonlar
│   ├── src/                   # Kaynak kodlar
│   └── package.json
├── frontend/                   # Ana frontend uygulaması
│   ├── src/                   # Vue.js kaynak kodları
│   ├── public/                # Statik dosyalar
│   └── package.json
├── docs/                       # Tüm dokümantasyon
│   ├── deployment/            # Deployment rehberleri
│   ├── api/                   # API dokümantasyonu
│   └── user-guide/            # Kullanıcı rehberleri
├── scripts/                    # Utility script'ler
│   ├── cleanup/               # Temizleme script'leri
│   ├── deployment/            # Deployment script'leri
│   └── testing/               # Test script'leri
├── tests/                      # Test dosyaları
│   ├── api/                   # API testleri
│   ├── integration/           # Entegrasyon testleri
│   └── data/                  # Test verileri
├── deployment/                 # Deployment konfigürasyonları
│   ├── docker/                # Docker dosyaları
│   ├── nginx/                 # Nginx konfigürasyonları
│   └── scripts/               # Deployment script'leri
└── README.md                   # Ana proje dokümantasyonu
```

## 🔄 Düzenleme Adımları

### 1. Klasör Yeniden Adlandırma
- `ogBackend/` → `backend/`
- `ogFrontend/` → `frontend/`

### 2. Duplikasyon Temizleme
- `ogBackend/ogBackend/` içeriğini ana `backend/` ile birleştir
- `hostinger-deployment/` klasörünü temizle

### 3. Dosya Organizasyonu
- Test dosyalarını `tests/` klasörüne taşı
- Script'leri `scripts/` klasörüne taşı
- Dokümantasyonu `docs/` klasörüne taşı

### 4. Gereksiz Dosya Temizleme
- Boş dosyaları sil
- Duplike dosyaları sil
- Eski deployment dosyalarını temizle

### 5. Konfigürasyon Güncellemesi
- Package.json dosyalarını güncelle
- Import path'lerini düzelt
- Docker konfigürasyonlarını güncelle

## ⚠️ Dikkat Edilecekler

1. **Yedek Al**: İşlem öncesi tam yedek al
2. **Git Commit**: Her adımda commit yap
3. **Test Et**: Her değişiklik sonrası test et
4. **Path Güncellemeleri**: Import path'lerini kontrol et

## 🚀 Uygulama Sırası

1. ✅ Plan oluştur
2. 🔄 Yedek al
3. 🔄 Klasörleri yeniden adlandır
4. 🔄 Dosyaları organize et
5. 🔄 Konfigürasyonları güncelle
6. 🔄 Test et
7. ✅ Dokümante et 