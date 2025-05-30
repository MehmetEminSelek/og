#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting deployment process...${NC}"

# Frontend Deployment
echo -e "${GREEN}Deploying Frontend...${NC}"
cd /home/ogsiparis.com/public_html

# Backup old files
rm -rf backup_old
mkdir backup_old
mv * backup_old/ 2>/dev/null

# Clone frontend
git clone https://github.com/MehmetEminSelek/ogFrontend.git temp
cd temp

# Create environment file with HTTPS
echo "VITE_API_BASE_URL=https://ogsiparis.com:3000/api" > .env
echo "VITE_SOCKET_URL=https://ogsiparis.com:3000" >> .env

# Install dependencies and build
npm install
npm run build

# Move build files to main directory
cp -r dist/* /home/ogsiparis.com/public_html/
cd /home/ogsiparis.com/public_html

# Clean up temp directory
rm -rf temp

# Clean unnecessary files
rm -rf node_modules src package* *.md .git* vite* postcss* tailwind* docker* deploy* dist .env*

# Update index.html for hashed file names
JS_FILE=$(ls assets/ | grep -E "index-.*\.js$" | head -1)
CSS_FILE=$(ls assets/ | grep -E "index-.*\.css$" | head -1)

# Create new index.html
cat > index.html << HTML
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ömer Güllü Sistemi - Baklavacı Yönetim Paneli</title>
    <meta name="description" content="Ömer Güllü Baklavacı İşletmesi - Modern Sipariş ve Stok Yönetim Sistemi">
    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    <script type="module" crossorigin src="/assets/$JS_FILE"></script>
    <link rel="stylesheet" crossorigin href="/assets/$CSS_FILE">
</head>
<body>
    <div id="app"></div>
</body>
</html>
HTML

# Set permissions
chmod -R 755 .

echo -e "${GREEN}Frontend deployment completed!${NC}"

# Backend Deployment
echo -e "${GREEN}Deploying Backend...${NC}"
cd /home/ogsiparis.com/backend

# Backup old backend
rm -rf backup_old
mkdir backup_old
mv * backup_old/ 2>/dev/null

# Clone backend
git clone https://github.com/MehmetEminSelek/ogBackend.git temp
cd temp

# Create .env file
cat > .env << EOL
PORT=3000
MONGODB_URI=your_mongodb_uri
JWT_SECRET=your_jwt_secret
NODE_ENV=production
EOL

# Install dependencies
npm install

# Move files to main directory
cp -r * /home/ogsiparis.com/backend/
cd /home/ogsiparis.com/backend

# Clean up temp directory
rm -rf temp

# Restart backend service
echo -e "${GREEN}Restarting Backend Service...${NC}"
pm2 restart og-siparis || pm2 start npm --name "og-siparis" -- start

echo -e "${BLUE}Deployment completed successfully!${NC}" 