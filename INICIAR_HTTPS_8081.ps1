Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SERVIDOR HTTP/HTTPS - PUERTO 8081" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "c:\inetpub\promotorapalmera\project_estacion_bombeo"

Write-Host "[1/3] Deteniendo servidores anteriores..." -ForegroundColor Yellow
taskkill /F /IM python.exe 2>$null
Start-Sleep -Seconds 2
Write-Host "OK: Procesos anteriores detenidos" -ForegroundColor Green

Write-Host ""
Write-Host "[2/3] Verificando directorio..." -ForegroundColor Yellow
if (Test-Path $projectPath) {
    Write-Host "OK: Directorio encontrado" -ForegroundColor Green
} else {
    Write-Host "ERROR: No se encuentra el directorio" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[3/3] Instalando dependencias SSL..." -ForegroundColor Yellow

Set-Location $projectPath

# Verificar si pyOpenSSL está instalado
$pyOpenSSL = python -c "import OpenSSL; print('OK')" 2>$null
if ($pyOpenSSL -ne "OK") {
    Write-Host "  Instalando pyOpenSSL..." -ForegroundColor Yellow
    pip install pyopenssl --quiet
    Write-Host "  OK: pyOpenSSL instalado" -ForegroundColor Green
} else {
    Write-Host "  OK: pyOpenSSL ya instalado" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  INICIANDO SERVIDORES" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Ejecutar servidor dual
python servidor_dual_http_https.py
