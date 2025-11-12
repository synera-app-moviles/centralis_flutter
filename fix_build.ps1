# Script para solucionar el problema de compilación bloqueado por OneDrive
# Ejecutar este script con: .\fix_build.ps1

Write-Host "🔧 Iniciando limpieza de archivos bloqueados..." -ForegroundColor Cyan

# 1. Detener todos los procesos Java/Gradle
Write-Host "`n📌 Paso 1: Deteniendo procesos Java..." -ForegroundColor Yellow
Get-Process -Name java -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 2. Detener Gradle Daemon
Write-Host "`n📌 Paso 2: Deteniendo Gradle Daemon..." -ForegroundColor Yellow
Set-Location android
if (Test-Path ".\gradlew.bat") {
    .\gradlew.bat --stop
} else {
    Write-Host "   ⚠️  gradlew.bat no encontrado" -ForegroundColor DarkYellow
}
Set-Location ..
Start-Sleep -Seconds 2

# 3. Eliminar carpetas problemáticas
Write-Host "`n📌 Paso 3: Eliminando carpetas bloqueadas..." -ForegroundColor Yellow

$foldersToDelete = @("build", ".dart_tool", "android\.gradle", "android\build")

foreach ($folder in $foldersToDelete) {
    if (Test-Path $folder) {
        Write-Host "   🗑️  Eliminando: $folder" -ForegroundColor Gray
        Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 500
    }
}

# 4. Limpiar con Flutter
Write-Host "`n📌 Paso 4: Ejecutando flutter clean..." -ForegroundColor Yellow
flutter clean

# 5. Obtener dependencias
Write-Host "`n📌 Paso 5: Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get

# 6. Mensaje final
Write-Host "`n✅ Limpieza completada!" -ForegroundColor Green
Write-Host "`n📱 Ahora puedes ejecutar: flutter run" -ForegroundColor Cyan
Write-Host "`n⚠️  IMPORTANTE: Si el problema persiste, considera:" -ForegroundColor Yellow
Write-Host "   1. Pausar OneDrive temporalmente" -ForegroundColor White
Write-Host "   2. Mover el proyecto fuera de OneDrive a C:\Dev\" -ForegroundColor White
Write-Host "   3. Excluir la carpeta del proyecto de la sincronización de OneDrive" -ForegroundColor White

