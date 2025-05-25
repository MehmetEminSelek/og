# 🧹 Ambalaj Temizleme Rehberi

## 📋 Durum
Veritabanınızda sadece **3 ambalaj türü** kalması gerekiyor:
- ✅ **Kutu**
- ✅ **Tepsi/Tava** 
- ✅ **Özel**

Diğer tüm ambalajlar silinecek.

## 🚨 Önemli Uyarı
Ambalajları silmek için önce o ambalajları kullanan **sipariş kalemlerini** silmek gerekir. Bu işlem **geri alınamaz**!

## 🛠️ Kullanım Adımları

### 1. Backend'i Başlatın
```bash
cd ogBackend
npm run dev
```

### 2. Mevcut Durumu Analiz Edin
```bash
node test-ambalaj-cleanup.js
```

Bu komut size şunları gösterecek:
- Toplam ambalaj sayısı
- İzinli ambalajlar (Kutu, Tepsi/Tava, Özel)
- Silinecek ambalajlar
- Hangi ambalajların kullanımda olduğu

### 3. Güvenli Temizleme (Önerilen)
```bash
# Sadece kullanılmayan ambalajları siler
node test-ambalaj-cleanup.js
```

### 4. Riskli Temizleme (Dikkatli Olun!)
```bash
# TÜM izinsiz ambalajları ve ilgili siparişleri siler
node test-ambalaj-cleanup.js --riskli
```

## 🔧 API Endpoint'leri

### GET `/api/cleanup-ambalaj`
Mevcut ambalaj durumunu analiz eder.

**Yanıt:**
```json
{
  "ambalajlar": [...],
  "ozet": {
    "toplam": 10,
    "izinli": 3,
    "silinecek": 7,
    "silinecekAmaKullanimda": 5,
    "guvenliSilinebilir": 2
  },
  "kategoriler": {
    "izinliAmbalajlar": [...],
    "silinecekAmbalajlar": [...],
    "silinecekAmaKullanimda": [...]
  }
}
```

### POST `/api/cleanup-ambalaj`
Gerekli ambalajları kontrol eder ve eksikleri ekler.

**İstek:**
```json
{
  "action": "ENSURE_REQUIRED_AMBALAJ"
}
```

### DELETE `/api/cleanup-ambalaj`

#### Güvenli Silme
```json
{
  "action": "DELETE_SAFE_UNAUTHORIZED"
}
```
Sadece kullanılmayan izinsiz ambalajları siler.

#### Riskli Silme
```json
{
  "action": "CLEANUP_UNAUTHORIZED_AMBALAJ"
}
```
TÜM izinsiz ambalajları ve ilgili siparişleri siler.

## 📊 Örnek Kullanım

### Postman/Insomnia ile Test

1. **Analiz:**
   ```
   GET http://localhost:3000/api/cleanup-ambalaj
   ```

2. **Güvenli Silme:**
   ```
   DELETE http://localhost:3000/api/cleanup-ambalaj
   Content-Type: application/json
   
   {
     "action": "DELETE_SAFE_UNAUTHORIZED"
   }
   ```

3. **Riskli Silme:**
   ```
   DELETE http://localhost:3000/api/cleanup-ambalaj
   Content-Type: application/json
   
   {
     "action": "CLEANUP_UNAUTHORIZED_AMBALAJ"
   }
   ```

## ⚠️ Dikkat Edilmesi Gerekenler

1. **Yedek Alın**: İşlem öncesi veritabanı yedeği alın
2. **Test Ortamında Deneyin**: Önce test veritabanında deneyin
3. **Adım Adım İlerleyin**: Önce güvenli silme, sonra riskli silme
4. **Logları Takip Edin**: Console çıktılarını kontrol edin

## 🔄 İşlem Sonrası

Temizleme sonrası sadece şu ambalajlar kalacak:
- Kutu (ID: ?, Kod: AMB01)
- Tepsi/Tava (ID: ?, Kod: AMB02)  
- Özel (ID: ?, Kod: AMB03)

## 🆘 Sorun Giderme

### "Foreign key constraint" Hatası
Bu hata, ambalajı kullanan sipariş kalemleri olduğu anlamına gelir. Önce siparişleri silmeniz gerekir.

### "Ambalaj bulunamadı" Hatası
Gerekli ambalajlar eksik. Şu komutu çalıştırın:
```bash
curl -X POST http://localhost:3000/api/cleanup-ambalaj \
  -H "Content-Type: application/json" \
  -d '{"action": "ENSURE_REQUIRED_AMBALAJ"}'
```

### Veritabanı Bağlantı Hatası
- Backend'in çalıştığından emin olun
- `.env` dosyasındaki `DATABASE_URL`'i kontrol edin
- PostgreSQL servisinin aktif olduğunu kontrol edin

## 📝 Log Örnekleri

### Başarılı Güvenli Silme
```
✅ Kullanılmayan izinsiz ambalajlar silindi
   Silinen Ambalaj Sayısı: 3
   Silinenler: Plastik Torba, Karton Kutu, Metal Kap
```

### Başarılı Riskli Silme
```
✅ İzinsiz ambalajlar ve ilgili siparişler başarıyla silindi
   Silinen Sipariş: 15
   Silinen Ambalaj: 7
   Korunan Ambalajlar: Kutu, Tepsi/Tava, Özel
```

---

**🎯 Hedef:** Sadece Kutu, Tepsi/Tava ve Özel ambalajları koruyarak veritabanını temizlemek. 