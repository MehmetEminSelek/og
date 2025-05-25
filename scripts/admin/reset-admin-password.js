// scripts/admin/reset-admin-password.js
// Admin şifre sıfırlama script'i

const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function resetAdminPassword() {
    try {
        console.log('🔐 Admin şifre sıfırlama işlemi başlıyor...\n');

        // Mevcut admin kullanıcıları listele
        const adminUsers = await prisma.user.findMany({
            where: {
                role: 'admin'
            },
            select: {
                id: true,
                ad: true,
                email: true,
                role: true,
                createdAt: true
            }
        });

        if (adminUsers.length === 0) {
            console.log('❌ Hiç admin kullanıcı bulunamadı!');
            console.log('📝 Yeni admin kullanıcı oluşturuluyor...\n');

            // Yeni admin kullanıcı oluştur
            const newPassword = 'admin123';
            const hashedPassword = await bcrypt.hash(newPassword, 10);

            const newAdmin = await prisma.user.create({
                data: {
                    ad: 'Admin',
                    email: 'admin@og.com',
                    passwordHash: hashedPassword,
                    role: 'admin',
                    erpPasifAktif: true
                }
            });

            console.log('✅ Yeni admin kullanıcı oluşturuldu:');
            console.log(`   ID: ${newAdmin.id}`);
            console.log(`   Ad: ${newAdmin.ad}`);
            console.log(`   Email: ${newAdmin.email}`);
            console.log(`   Şifre: ${newPassword}`);
            console.log(`   Role: ${newAdmin.role}\n`);

        } else {
            console.log('👥 Mevcut admin kullanıcıları:');
            adminUsers.forEach((user, index) => {
                console.log(`   ${index + 1}. ${user.ad} (${user.email}) - ID: ${user.id}`);
            });

            console.log('\n🔄 İlk admin kullanıcının şifresi sıfırlanıyor...');

            const targetUser = adminUsers[0];
            const newPassword = 'admin123';
            const hashedPassword = await bcrypt.hash(newPassword, 10);

            await prisma.user.update({
                where: { id: targetUser.id },
                data: { passwordHash: hashedPassword }
            });

            console.log('✅ Şifre başarıyla sıfırlandı:');
            console.log(`   Kullanıcı: ${targetUser.ad}`);
            console.log(`   Email: ${targetUser.email}`);
            console.log(`   Yeni Şifre: ${newPassword}\n`);
        }

        console.log('🎉 İşlem tamamlandı!');
        console.log('💡 Giriş yaptıktan sonra şifrenizi değiştirmeyi unutmayın.');

    } catch (error) {
        console.error('❌ Hata oluştu:', error.message);
    } finally {
        await prisma.$disconnect();
    }
}

// Alternatif: Özel şifre belirleme
async function setCustomPassword(userId, newPassword) {
    try {
        const hashedPassword = await bcrypt.hash(newPassword, 10);

        await prisma.user.update({
            where: { id: userId },
            data: { passwordHash: hashedPassword }
        });

        console.log(`✅ Kullanıcı ${userId} için şifre güncellendi: ${newPassword}`);
    } catch (error) {
        console.error('❌ Şifre güncellenirken hata:', error.message);
    }
}

// Script'i çalıştır
if (require.main === module) {
    const args = process.argv.slice(2);

    if (args.length === 2 && args[0] === '--custom') {
        const [, password] = args;
        console.log('🔐 Özel şifre belirleniyor...');
        // İlk admin kullanıcı için özel şifre
        prisma.user.findFirst({ where: { role: 'admin' } })
            .then(user => {
                if (user) {
                    return setCustomPassword(user.id, password);
                } else {
                    console.log('❌ Admin kullanıcı bulunamadı!');
                }
            })
            .finally(() => prisma.$disconnect());
    } else {
        resetAdminPassword();
    }
}

module.exports = { resetAdminPassword, setCustomPassword }; 