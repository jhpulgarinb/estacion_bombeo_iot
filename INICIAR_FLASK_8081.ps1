Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIANDO ESTACION DE BOMBEO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "c:\inetpub\promotorapalmera\project_estacion_bombeo"

Write-Host "[1/2] Verificando directorio..." -ForegroundColor Yellow
if (Test-Path $projectPath) {
    Write-Host "OK: Directorio encontrado" -ForegroundColor Green
} else {
    Write-Host "ERROR: No se encuentra el directorio" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/2] Iniciando Flask en puerto 8081..." -ForegroundColor Yellow
Write-Host ""

Set-Location $projectPath
python app.py

