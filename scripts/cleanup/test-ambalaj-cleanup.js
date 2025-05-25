// test-ambalaj-cleanup.js
// Ambalaj temizleme API'sini test etmek için script

const axios = require('axios');

// Environment'a göre base URL belirle
const getBaseUrl = () => {
    if (process.env.NODE_ENV === 'production') {
        return process.env.API_BASE_URL || 'https://yourdomain.com/api';
    }
    return process.env.API_BASE_URL || 'http://localhost:3000/api';
};

const API_BASE = getBaseUrl();

async function testAmbalajCleanup() {
    console.log('🧪 Ambalaj Temizleme API Testi Başlıyor...\n');
    console.log(`🌐 API Base: ${API_BASE}\n`);

    try {
        // 1. Mevcut durumu analiz et
        console.log('📊 1. Mevcut ambalaj durumunu analiz ediliyor...');
        const analiz = await axios.get(`${API_BASE}/cleanup-ambalaj`);

        console.log('📈 Analiz Sonuçları:');
        console.log(`   Toplam Ambalaj: ${analiz.data.ozet.toplam}`);
        console.log(`   İzinli Ambalaj: ${analiz.data.ozet.izinli}`);
        console.log(`   Silinecek Ambalaj: ${analiz.data.ozet.silinecek}`);
        console.log(`   Kullanımda Olan (Silinecek): ${analiz.data.ozet.silinecekAmaKullanimda}`);
        console.log(`   Güvenli Silinebilir: ${analiz.data.ozet.guvenliSilinebilir}\n`);

        if (analiz.data.kategoriler.silinecekAmbalajlar.length > 0) {
            console.log('🗑️ Silinecek Ambalajlar:');
            analiz.data.kategoriler.silinecekAmbalajlar.forEach(ambalaj => {
                console.log(`   - ${ambalaj.ad} (ID: ${ambalaj.id}, Kullanım: ${ambalaj.kullanımSayisi})`);
            });
            console.log('');
        }

        // 2. Gerekli ambalajları kontrol et ve eksikleri ekle
        console.log('✅ 2. Gerekli ambalajları kontrol ediliyor...');
        const gerekliAmbalaj = await axios.post(`${API_BASE}/cleanup-ambalaj`, {
            action: 'ENSURE_REQUIRED_AMBALAJ'
        });
        console.log(`   ${gerekliAmbalaj.data.message}`);
        if (gerekliAmbalaj.data.eklenenAmbalajlar) {
            console.log(`   Eklenen: ${gerekliAmbalaj.data.eklenenAmbalajlar.join(', ')}`);
        }
        console.log('');

        // 3. Kullanıcıya seçenek sun
        console.log('🤔 3. Temizleme seçenekleri:');
        console.log('   A) Sadece kullanılmayan izinsiz ambalajları sil (GÜVENLİ)');
        console.log('   B) TÜM izinsiz ambalajları ve ilgili siparişleri sil (RİSKLİ)');
        console.log('');

        // Güvenli temizleme yap
        console.log('🛡️ 4. Güvenli temizleme yapılıyor...');
        const guvenliSilme = await axios.delete(`${API_BASE}/cleanup-ambalaj`, {
            data: {
                action: 'DELETE_SAFE_UNAUTHORIZED'
            }
        });

        console.log(`   ${guvenliSilme.data.message}`);
        console.log(`   Silinen Ambalaj Sayısı: ${guvenliSilme.data.silinenAmbalaj}`);
        if (guvenliSilme.data.silinenler && guvenliSilme.data.silinenler.length > 0) {
            console.log(`   Silinenler: ${guvenliSilme.data.silinenler.join(', ')}`);
        }
        console.log('');

        // 5. Son durumu kontrol et
        console.log('📊 5. Temizleme sonrası durum:');
        const sonAnaliz = await axios.get(`${API_BASE}/cleanup-ambalaj`);

        console.log(`   Toplam Ambalaj: ${sonAnaliz.data.ozet.toplam}`);
        console.log(`   İzinli Ambalaj: ${sonAnaliz.data.ozet.izinli}`);
        console.log(`   Hala Silinecek: ${sonAnaliz.data.ozet.silinecek}`);

        if (sonAnaliz.data.ozet.silinecekAmaKullanimda > 0) {
            console.log('\n⚠️ DİKKAT: Hala kullanımda olan izinsiz ambalajlar var!');
            console.log('   Bu ambalajları silmek için önce ilgili siparişleri silmeniz gerekir.');
            console.log('   Riskli temizleme için şu komutu kullanabilirsiniz:');
            console.log('   action: "CLEANUP_UNAUTHORIZED_AMBALAJ"');
        }

        console.log('\n✅ Test tamamlandı!');

    } catch (error) {
        console.error('❌ Test sırasında hata:', error.response?.data || error.message);
    }
}

// Riskli temizleme fonksiyonu (ayrı çalıştırılmalı)
async function riskliTemizleme() {
    console.log('⚠️ RİSKLİ TEMİZLEME BAŞLIYOR...');
    console.log('Bu işlem TÜM izinsiz ambalajları ve ilgili siparişleri silecek!\n');

    try {
        const sonuc = await axios.delete(`${API_BASE}/cleanup-ambalaj`, {
            data: {
                action: 'CLEANUP_UNAUTHORIZED_AMBALAJ'
            }
        });

        console.log(`✅ ${sonuc.data.message}`);
        console.log(`   Silinen Sipariş: ${sonuc.data.silinenSiparis}`);
        console.log(`   Silinen Ambalaj: ${sonuc.data.silinenAmbalaj}`);
        console.log(`   Silinen Ambalajlar: ${sonuc.data.silinenAmbalajlar?.join(', ')}`);
        console.log(`   Korunan Ambalajlar: ${sonuc.data.korunanAmbalajlar.join(', ')}`);

    } catch (error) {
        console.error('❌ Riskli temizleme hatası:', error.response?.data || error.message);
    }
}

// Script'i çalıştır
if (require.main === module) {
    const args = process.argv.slice(2);

    if (args.includes('--riskli')) {
        riskliTemizleme();
    } else {
        testAmbalajCleanup()
            .then(() => {
                console.log('\n✅ Test tamamlandı!');
                process.exit(0);
            })
            .catch((error) => {
                console.error('\n❌ Test başarısız:', error);
                process.exit(1);
            });
    }
}

module.exports = { testAmbalajCleanup, riskliTemizleme }; 