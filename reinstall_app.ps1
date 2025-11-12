# Script para desinstalar y reinstalar la app de Flutter
Write-Host "Desinstalando la aplicación..." -ForegroundColor Yellow
flutter clean
adb uninstall com.example.centralis_flutter.centralis_flutter

Write-Host "Reconstruyendo la aplicación..." -ForegroundColor Yellow
flutter pub get

Write-Host "Instalando la aplicación..." -ForegroundColor Yellow
flutter run

Write-Host "¡Listo!" -ForegroundColor Green

