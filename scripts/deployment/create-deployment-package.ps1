# Hostinger VPS Deployment Package Creator
# This script runs on Windows and prepares files for deployment

Write-Host "🚀 Creating Hostinger VPS Deployment Package..." -ForegroundColor Green

# Create deployment directory
$deploymentDir = ".\hostinger-deployment"
if (Test-Path $deploymentDir) {
    Remove-Item $deploymentDir -Recurse -Force
}
New-Item -ItemType Directory -Path $deploymentDir

Write-Host "📁 Deployment directory created: $deploymentDir" -ForegroundColor Yellow

# Copy backend files
Write-Host "📦 Copying backend files..." -ForegroundColor Cyan
$backendDest = "$deploymentDir\ogBackend"
New-Item -ItemType Directory -Path $backendDest

# Backend files/folders to copy
$backendItems = @(
    "pages",
    "src", 
    "prisma",
    "lib",
    "package.json",
    "package-lock.json",
    ".env.production",
    "ecosystem.config.js",
    "server.js",
    "middleware.js",
    "Dockerfile",
    ".dockerignore"
)

foreach ($item in $backendItems) {
    $sourcePath = ".\ogBackend\$item"
    if (Test-Path $sourcePath) {
        if (Test-Path $sourcePath -PathType Container) {
            Copy-Item $sourcePath -Destination $backendDest -Recurse
        } else {
            Copy-Item $sourcePath -Destination $backendDest
        }
        Write-Host "  ✅ $item copied" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $item not found" -ForegroundColor Yellow
    }
}

# Copy frontend files
Write-Host "📦 Copying frontend files..." -ForegroundColor Cyan
$frontendDest = "$deploymentDir\ogFrontend"
New-Item -ItemType Directory -Path $frontendDest

# Frontend files/folders to copy
$frontendItems = @(
    "src",
    "public",
    "package.json",
    "package-lock.json",
    ".env.production",
    "vite.config.js",
    "index.html",
    "tailwind.config.js",
    "postcss.config.js"
)

foreach ($item in $frontendItems) {
    $sourcePath = ".\ogFrontend\$item"
    if (Test-Path $sourcePath) {
        if (Test-Path $sourcePath -PathType Container) {
            Copy-Item $sourcePath -Destination $frontendDest -Recurse
        } else {
            Copy-Item $sourcePath -Destination $frontendDest
        }
        Write-Host "  ✅ $item copied" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $item not found" -ForegroundColor Yellow
    }
}

# Copy deployment files
Write-Host "📦 Copying deployment files..." -ForegroundColor Cyan
$deploymentFiles = @(
    "deploy.sh",
    "deployment-guide.md",
    "HOSTINGER_DEPLOYMENT.md",
    "docker-compose.yml"
)

foreach ($file in $deploymentFiles) {
    if (Test-Path $file) {
        Copy-Item $file -Destination $deploymentDir
        Write-Host "  ✅ $file copied" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $file not found" -ForegroundColor Yellow
    }
}

# Create README file
$currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$readmeContent = @"
# Hostinger VPS Deployment Package

This package contains all necessary files to deploy the OG project to Hostinger VPS.

## 📋 Contents
- ogBackend/ - Backend application (Next.js + Prisma)
- ogFrontend/ - Frontend application (Vue.js)
- deploy.sh - Automatic deployment script
- HOSTINGER_DEPLOYMENT.md - Detailed deployment guide

## 🚀 Quick Start

1. Upload these files to VPS (WinSCP, FileZilla, etc.)
2. SSH to VPS: ssh root@147.93.123.161
3. Run deployment script: ./deploy.sh

## 📖 Detailed Guide
Read HOSTINGER_DEPLOYMENT.md file.

## 🔧 Manual Installation
Follow deployment-guide.md file.

---
Created: $currentDate
"@

$readmeContent | Out-File -FilePath "$deploymentDir\README.md" -Encoding UTF8

# Create zip file
Write-Host "📦 Creating zip file..." -ForegroundColor Cyan
$zipPath = ".\hostinger-deployment.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath
}

# Use Compress-Archive for PowerShell 5.0+
try {
    Compress-Archive -Path "$deploymentDir\*" -DestinationPath $zipPath -CompressionLevel Optimal
    Write-Host "✅ Deployment package created: $zipPath" -ForegroundColor Green
} catch {
    Write-Host "❌ Zip creation error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please manually zip the $deploymentDir folder" -ForegroundColor Yellow
}

# Summary information
Write-Host ""
Write-Host "📊 Deployment Package Summary:" -ForegroundColor Magenta
Write-Host "📁 Folder: $deploymentDir" -ForegroundColor White
Write-Host "📦 Zip: $zipPath" -ForegroundColor White

if (Test-Path $deploymentDir) {
    $size = (Get-ChildItem $deploymentDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "📏 Size: $([math]::Round($size, 2)) MB" -ForegroundColor White
}

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Upload $zipPath to your VPS" -ForegroundColor White
Write-Host "2. Extract on VPS: unzip hostinger-deployment.zip" -ForegroundColor White
Write-Host "3. Run deployment on VPS:" -ForegroundColor White
Write-Host "   cd hostinger-deployment" -ForegroundColor Gray
Write-Host "   chmod +x deploy.sh" -ForegroundColor Gray
Write-Host "   ./deploy.sh" -ForegroundColor Gray

Write-Host ""
Write-Host "🚀 Deployment ready!" -ForegroundColor Green 