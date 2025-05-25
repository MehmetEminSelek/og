# 🛍️ Ürün Yönetimi Sistemi Kullanım Rehberi

## 📋 İçindekiler
1. [Genel Bakış](#genel-bakış)
2. [Özellikler](#özellikler)
3. [Kullanım Kılavuzu](#kullanım-kılavuzu)
4. [API Dokümantasyonu](#api-dokümantasyonu)
5. [Teknik Detaylar](#teknik-detaylar)

---

## 🎯 Genel Bakış

Ürün Yönetimi sistemi, OG (Ömer Güllü) ERP sisteminin kapsamlı bir modülüdür. Bu sistem ile:

- ✅ Ürünleri kategorilere ayırarak organize edebilirsiniz
- ✅ Detaylı ürün bilgileri ve özellikler tanımlayabilirsiniz
- ✅ Gelişmiş fiyatlandırma stratejileri uygulayabilirsiniz
- ✅ Stok takibi ve kritik seviye uyarıları alabilirsiniz
- ✅ Üretim planlaması yapabilirsiniz

---

## 🚀 Özellikler

### 📂 Kategori Yönetimi
- **Renkli Kategoriler**: Her kategori için özel renk seçimi
- **İkon Desteği**: 16+ farklı ikon seçeneği
- **Sıralama**: Kategorileri istediğiniz sırada düzenleyin
- **Aktif/Pasif Durumu**: Kategorileri geçici olarak devre dışı bırakın

### 🛍️ Ürün Yönetimi
- **Kapsamlı Ürün Bilgileri**: 30+ farklı ürün özelliği
- **Görsel Yönetimi**: Ana görsel ve galeri desteği
- **Durum Etiketleri**: Yeni, Özel, İndirimli ürün etiketleri
- **SEO Optimizasyonu**: Arama motoru dostu ürün sayfaları

### 💰 Gelişmiş Fiyatlandırma
- **Çoklu Fiyat Tipleri**: Normal, Kampanya, Toptan, Perakende
- **Tarih Aralığı**: Başlangıç ve bitiş tarihleri
- **İskonto Sistemi**: Otomatik iskonto hesaplamaları
- **KDV Yönetimi**: Esnek vergi oranları

### 📊 Stok Takibi
- **Minimum/Maksimum Stok**: Otomatik stok uyarıları
- **Kritik Seviye**: Acil stok ihtiyacı bildirimleri
- **Satış Limitleri**: Minimum/maksimum satış miktarları

---

## 📖 Kullanım Kılavuzu

### 1. Kategori Oluşturma

1. **Ürün Yönetimi** sayfasına gidin
2. **"Kategori Yönet"** butonuna tıklayın
3. **Yeni Kategori Ekle** bölümünde:
   - Kategori adını girin
   - Açıklama ekleyin (opsiyonel)
   - Renk seçin
   - İkon seçin
   - Sıra numarası belirleyin
4. **"Kategori Ekle"** butonuna tıklayın

### 2. Ürün Ekleme

1. **"Yeni Ürün"** butonuna tıklayın
2. **Temel Bilgiler** sekmesinde:
   - Ürün adı (zorunlu)
   - Ürün kodu
   - Kategori seçimi
   - Kısa ve detaylı açıklama

3. **Ürün Özellikleri** sekmesinde:
   - Ağırlık (gram)
   - Barkod
   - Satış birimi
   - Ana malzeme
   - Menşei

4. **Stok Bilgileri** sekmesinde:
   - Min/Max stok miktarları
   - Kritik stok seviyesi
   - Min/Max satış miktarları

5. **Üretim Bilgileri** sekmesinde:
   - Üretim süresi
   - Raf ömrü
   - Saklama koşulları
   - Maliyet fiyatı
   - Kar marjı

6. **Durum ve Etiketler** sekmesinde:
   - Aktif/Pasif durumu
   - Satışa uygunluk
   - Özel ürün etiketleri

7. **"Kaydet"** butonuna tıklayın

### 3. Fiyat Belirleme

1. Ürün listesinden bir ürün seçin
2. **"Düzenle"** butonuna tıklayın
3. Fiyat bilgilerini girin veya
4. Ayrı bir fiyat yönetimi sayfasından toplu fiyat güncellemesi yapın

### 4. Arama ve Filtreleme

- **Metin Arama**: Ürün adı, kodu, açıklama, stok kodu veya barkod ile arama
- **Kategori Filtresi**: Belirli kategorideki ürünleri görüntüleme
- **Durum Filtresi**: Aktif/Pasif ürünleri filtreleme
- **Sıralama**: Ad, kod veya tarihe göre sıralama

### 5. Görünüm Modları

- **Liste Görünümü**: Detaylı tablo formatında görüntüleme
- **Kart Görünümü**: Görsel odaklı kart formatında görüntüleme

---

## 🔧 API Dokümantasyonu

### Ürün API Endpoint'leri

#### Ürünleri Listele
```http
GET /api/urunler
```

**Query Parametreleri:**
- `page`: Sayfa numarası (varsayılan: 1)
- `limit`: Sayfa başına kayıt (varsayılan: 20)
- `search`: Arama terimi
- `kategori`: Kategori ID
- `aktif`: true/false
- `sortBy`: Sıralama alanı
- `sortOrder`: asc/desc

#### Yeni Ürün Oluştur
```http
POST /api/urunler
Content-Type: application/json

{
  "ad": "Ürün Adı",
  "kodu": "URN001",
  "kategoriId": 1,
  "aciklama": "Ürün açıklaması",
  "agirlik": 100,
  "satisaBirimi": "Adet",
  "aktif": true
}
```

#### Ürün Güncelle
```http
PUT /api/urunler?id=1
Content-Type: application/json

{
  "ad": "Güncellenmiş Ürün Adı",
  "aciklama": "Yeni açıklama"
}
```

#### Ürün Sil
```http
DELETE /api/urunler?id=1
```

### Kategori API Endpoint'leri

#### Kategorileri Listele
```http
GET /api/kategoriler
```

#### Yeni Kategori Oluştur
```http
POST /api/kategoriler
Content-Type: application/json

{
  "ad": "Kategori Adı",
  "aciklama": "Kategori açıklaması",
  "renk": "#2196F3",
  "ikon": "mdi-package-variant",
  "aktif": true
}
```

### Fiyat API Endpoint'leri

#### Fiyatları Listele
```http
GET /api/fiyatlar
```

#### Yeni Fiyat Oluştur
```http
POST /api/fiyatlar
Content-Type: application/json

{
  "urunId": 1,
  "fiyat": 25.50,
  "birim": "KG",
  "fiyatTipi": "normal",
  "gecerliTarih": "2024-01-01",
  "vergiOrani": 18
}
```

---

## ⚙️ Teknik Detaylar

### Database Schema

#### UrunKategori Tablosu
```sql
- id: Primary Key
- ad: Kategori adı (unique)
- aciklama: Açıklama
- renk: Hex renk kodu
- ikon: Material Design ikon
- aktif: Boolean
- siraNo: Sıralama numarası
- createdAt/updatedAt: Zaman damgaları
```

#### Urun Tablosu
```sql
- id: Primary Key
- ad: Ürün adı (unique)
- kodu: Ürün kodu (unique)
- kategoriId: Foreign Key
- aciklama: Detaylı açıklama
- kisaAciklama: Kısa açıklama
- anaGorsel: Ana görsel URL
- galeriGorseller: JSON array
- agirlik: Float (gram)
- barkod: Unique barkod
- satisaBirimi: Satış birimi
- aktif: Boolean
- satisaUygun: Boolean
- ozelUrun: Boolean
- yeniUrun: Boolean
- indirimliUrun: Boolean
- maliyetFiyati: Float
- karMarji: Float
- createdAt/updatedAt: Zaman damgaları
```

#### Fiyat Tablosu
```sql
- id: Primary Key
- urunId: Foreign Key
- fiyat: Float
- birim: String
- fiyatTipi: Enum (normal, kampanya, toptan, perakende)
- iskonto: Float (%)
- vergiOrani: Float (%)
- gecerliTarih: Date
- bitisTarihi: Date (nullable)
- aktif: Boolean
- createdAt: Timestamp
```

### Frontend Teknolojileri

- **Vue.js 3**: Composition API
- **Vuetify 3**: Material Design UI
- **Vue Router**: Sayfa yönlendirme
- **Pinia**: State management

### Backend Teknolojileri

- **Next.js**: API Routes
- **Prisma ORM**: Database yönetimi
- **PostgreSQL**: Veritabanı
- **bcryptjs**: Şifreleme

---

## 📊 Test Verileri

Sistem şu test verileri ile gelir:

### Kategoriler (5 adet)
1. **Kurabiyeler** - Turuncu renk, kurabiye ikonu
2. **Kekler** - Pembe renk, kek ikonu
3. **Börekler** - Yeşil renk, börek ikonu
4. **Tatlılar** - Mor renk, tatlı ikonu
5. **Ekmekler** - Kahverengi renk, ekmek ikonu

### Ürünler (7 adet)
1. **Fıstıklı Kurabiye** - 3.50 TL/Adet
2. **Çikolatalı Kurabiye** - 4.00 TL/Adet
3. **Vanilyalı Kek** - 25.00 TL/Dilim
4. **Çikolatalı Kek** - 28.00 TL/Dilim (İndirimli)
5. **Su Böreği** - 15.00 TL/Porsiyon
6. **Baklava** - 20.00 TL/Adet (Özel)
7. **Tam Buğday Ekmeği** - 7.50 TL/Adet (Yeni)

---

## 🎯 Gelecek Özellikler

- [ ] **QR Kod Sistemi**: Ürünler için QR kod oluşturma
- [ ] **Toplu İşlemler**: Çoklu ürün seçimi ve toplu güncelleme
- [ ] **İstatistikler**: Satış analizi ve raporlama
- [ ] **Görsel Yönetimi**: Drag & drop görsel yükleme
- [ ] **Varyant Sistemi**: Farklı boyut/renk seçenekleri
- [ ] **İthalat/İhracat**: Uluslararası ticaret desteği

---

## 📞 Destek

Herhangi bir sorun yaşadığınızda:

1. **Dokümantasyonu** kontrol edin
2. **Test scriptlerini** çalıştırın
3. **Log dosyalarını** inceleyin
4. **Geliştirici ekibi** ile iletişime geçin

---

**Son Güncelleme**: 25 Aralık 2024  
**Versiyon**: 1.0.0  
**Geliştirici**: OG ERP Ekibi 