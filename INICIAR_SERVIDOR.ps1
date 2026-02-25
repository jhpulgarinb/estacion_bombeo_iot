# Script para iniciar servidor HTTPS/HTTP

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ServerScript = Join-Path $ScriptDir "servidor_dual_http_https.py"

Write-Host ""
Write-Host "SERVIDOR HTTPS/HTTP"
Write-Host ""
Write-Host "Configuracion:"
Write-Host "  HTTPS: puerto 8082 (moviles)"
Write-Host "  HTTP:  puerto 8081 (IIS)"
Write-Host ""

# Detener procesos anteriores
Write-Host "Deteniendo procesos anteriores..."
taskkill /F /IM python.exe 2>$null | Out-Null
Start-Sleep -Seconds 2

# Iniciar servidor
Write-Host "Iniciando servidor..." 
Write-Host ""

cd $ScriptDir
python -u $ServerScript

Write-Host ""
Write-Host "Servidor detenido"

