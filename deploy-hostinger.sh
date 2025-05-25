#!/bin/bash

# OG Project - Hostinger Deployment Script
echo "🚀 Starting OG Project deployment to Hostinger..."

# 1. Install dependencies
echo "📦 Installing dependencies..."
npm run install:all

# 2. Build backend
echo "🔨 Building backend..."
cd backend
npm run build
cd ..

# 3. Build frontend
echo "🎨 Building frontend..."
cd frontend
npm run build
cd ..

# 4. Database migration
echo "🗄️ Running database migrations..."
cd backend
npx prisma generate
npx prisma db push
cd ..

# 5. Create logs directory
echo "📝 Creating logs directory..."
mkdir -p backend/logs

# 6. Copy production files
echo "📋 Copying production files..."
cp backend/.env.production backend/.env

echo "✅ Deployment preparation complete!"
echo ""
echo "📌 Next steps for Hostinger:"
echo "1. Upload files to public_html"
echo "2. Update .env with real database credentials"
echo "3. Run: npm start"
echo "4. Setup PM2: pm2 start ecosystem.config.js" 