// ===================================================================
// 🔄 GITHUB WEBHOOK RECEIVER - Otomatik Deployment Sistemi
// Hostingde çalışacak webhook listener
// ===================================================================

const express = require('express');
const { execSync } = require('child_process');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.WEBHOOK_PORT || 3001;
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET || 'your-webhook-secret';
const PROJECT_PATH = process.env.PROJECT_PATH || '/home/ogsiparis.com/public_html';

// Middleware
app.use(express.json());

// Webhook signature verification
function verifySignature(req, res, next) {
    const signature = req.headers['x-hub-signature-256'];
    if (!signature) {
        return res.status(401).json({ error: 'No signature provided' });
    }

    const body = JSON.stringify(req.body);
    const expectedSignature = `sha256=${crypto
        .createHmac('sha256', WEBHOOK_SECRET)
        .update(body)
        .digest('hex')}`;

    if (!crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expectedSignature))) {
        return res.status(401).json({ error: 'Invalid signature' });
    }

    next();
}

// Logging function
function log(message) {
    const timestamp = new Date().toISOString();
    const logMessage = `${timestamp} - ${message}\n`;

    console.log(logMessage);

    // Log to file
    const logFile = path.join(PROJECT_PATH, 'webhook.log');
    fs.appendFileSync(logFile, logMessage);
}

// Deployment function
async function deployProject() {
    log('🚀 Deployment başlıyor...');

    try {
        // 1. Git pull
        log('📥 Git pull yapılıyor...');
        execSync('git pull origin master', {
            cwd: PROJECT_PATH,
            stdio: 'inherit'
        });

        // 2. Backend dependencies
        log('📦 Backend dependencies güncelleniyor...');
        execSync('npm install --production', {
            cwd: path.join(PROJECT_PATH, 'backend'),
            stdio: 'inherit'
        });

        // 3. Frontend build
        log('🏗️ Frontend build yapılıyor...');
        execSync('npm install', {
            cwd: path.join(PROJECT_PATH, 'frontend'),
            stdio: 'inherit'
        });
        execSync('npm run build', {
            cwd: path.join(PROJECT_PATH, 'frontend'),
            stdio: 'inherit'
        });

        // 4. Prisma migrate
        log('🗄️ Database migration yapılıyor...');
        execSync('npx prisma generate', {
            cwd: path.join(PROJECT_PATH, 'backend'),
            stdio: 'inherit'
        });
        execSync('npx prisma db push', {
            cwd: path.join(PROJECT_PATH, 'backend'),
            stdio: 'inherit'
        });

        // 5. PM2 restart
        log('🔄 PM2 restart yapılıyor...');
        execSync('pm2 restart og-backend', { stdio: 'inherit' });

        // 6. Nginx reload (if needed)
        try {
            execSync('sudo nginx -t && sudo systemctl reload nginx', { stdio: 'inherit' });
        } catch (error) {
            log('⚠️ Nginx reload atlandı (yetki problemi olabilir)');
        }

        log('✅ Deployment başarıyla tamamlandı!');
        return { success: true, message: 'Deployment successful' };

    } catch (error) {
        log(`❌ Deployment hatası: ${error.message}`);
        return { success: false, message: error.message };
    }
}

// Webhook endpoint
app.post('/webhook', verifySignature, async (req, res) => {
    const { ref, head_commit, repository } = req.body;

    log(`📡 Webhook alındı: ${repository.name} - ${ref}`);

    // Only deploy on master branch
    if (ref !== 'refs/heads/master') {
        log('🚫 Master branch değil, deployment atlandı');
        return res.json({ message: 'Not master branch, deployment skipped' });
    }

    log(`📝 Commit: ${head_commit.message} by ${head_commit.author.name}`);

    // Run deployment
    const result = await deployProject();

    if (result.success) {
        res.json({ message: 'Deployment successful', commit: head_commit.id });
    } else {
        res.status(500).json({ message: 'Deployment failed', error: result.message });
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        project: 'OG Siparis Sistemi'
    });
});

// Start server
app.listen(PORT, () => {
    log(`🎯 Webhook receiver çalışıyor: Port ${PORT}`);
    log(`📁 Proje dizini: ${PROJECT_PATH}`);
});

// Graceful shutdown
process.on('SIGINT', () => {
    log('🛑 Webhook receiver kapatılıyor...');
    process.exit(0);
}); 