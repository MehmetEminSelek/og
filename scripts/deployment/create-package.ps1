# OG Projesi Deployment Package Oluşturma Script'i
Write-Host "🚀 OG Projesi Deployment Package Oluşturuluyor..." -ForegroundColor Green

# Geçici dizin oluştur
$tempDir = "temp-deployment"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir

Write-Host "📁 Dosyalar kopyalanıyor..." -ForegroundColor Yellow

# Backend dosyalarını kopyala
Write-Host "   Backend dosyaları..." -ForegroundColor Cyan
Copy-Item "ogBackend" -Destination "$tempDir/ogBackend" -Recurse -Force

# Frontend'i production modunda build et
Write-Host "   Frontend build ediliyor (Production Mode)..." -ForegroundColor Cyan
Set-Location "ogFrontend"
npm run build
Set-Location ".."

# Build edilmiş frontend'i kopyala
Copy-Item "ogFrontend/dist" -Destination "$tempDir/ogFrontend" -Recurse -Force
Copy-Item "ogFrontend/package.json" -Destination "$tempDir/ogFrontend/" -Force
Copy-Item "ogFrontend/.env.production" -Destination "$tempDir/ogFrontend/" -Force

# Deployment dosyalarını kopyala
Write-Host "   Deployment dosyaları..." -ForegroundColor Cyan
Copy-Item "deploy.sh" -Destination "$tempDir/" -Force
Copy-Item "docker-compose.yml" -Destination "$tempDir/" -Force

# Package oluştur
Write-Host "📦 Package oluşturuluyor..." -ForegroundColor Yellow
$packageName = "og-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').zip"

# PowerShell 5.0+ için Compress-Archive kullan
Compress-Archive -Path "$tempDir/*" -DestinationPath $packageName -Force

# Geçici dizini temizle
Remove-Item $tempDir -Recurse -Force

Write-Host "✅ Deployment package hazır: $packageName" -ForegroundColor Green
Write-Host "📊 Package boyutu: $((Get-Item $packageName).Length / 1MB) MB" -ForegroundColor Cyan

# Environment bilgilerini göster
Write-Host "`n🔧 Environment Konfigürasyonu:" -ForegroundColor Magenta
Write-Host "   Frontend: Production mode (.env.production)" -ForegroundColor White
Write-Host "   Backend: Production environment (.env.production)" -ForegroundColor White
Write-Host "   API URL: http://ogsiparis.com:3001/api" -ForegroundColor White
Write-Host "   Frontend URL: http://ogsiparis.com" -ForegroundColor White

Write-Host "`n🚀 Deployment için hazır!" -ForegroundColor Green 