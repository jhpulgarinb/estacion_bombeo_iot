# iniciar_aplicacion.ps1
# Script para iniciar la aplicación web

Write-Host "Iniciando Sistema de Monitoreo de Estaciones de Bombeo..." -ForegroundColor Green

# Activar entorno virtual
$venvPath = Join-Path $PSScriptRoot "venv"
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"

if (Test-Path $activateScript) {
    & $activateScript
    Write-Host "Entorno virtual activado." -ForegroundColor Green
} else {
    Write-Host "Entorno virtual no encontrado. Ejecute primero instalar_sistema.ps1" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📊 SISTEMA DE MONITOREO DE ESTACIONES DE BOMBEO" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Servidor iniciando en: http://localhost:5000" -ForegroundColor Green
Write-Host "📊 Dashboard: http://localhost:5000/index.html" -ForegroundColor Green  
Write-Host "📚 Documentación: http://localhost:5000/docs/" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  Presione Ctrl+C para detener el servidor" -ForegroundColor Yellow
Write-Host ""

# Iniciar aplicación
python app.py
