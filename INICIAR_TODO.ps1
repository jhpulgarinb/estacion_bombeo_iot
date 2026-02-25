Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  INICIAR SISTEMA COMPLETO" -ForegroundColor Cyan
Write-Host "  Bombeo + Meteorología + Simulador" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "[1/3] Deteniendo procesos Python anteriores..." -ForegroundColor Yellow
taskkill /F /IM python.exe 2>$null | Out-Null
Start-Sleep -Seconds 2
Write-Host "  [OK]" -ForegroundColor Green

Write-Host "[2/3] Iniciando Flask (API + Dashboards en puerto 9000)..." -ForegroundColor Yellow
Push-Location $scriptDir

# Iniciar Flask en background
$job1 = Start-Job -ScriptBlock {
    Set-Location "$using:scriptDir"
    python app.py
}
Write-Host "  [OK] Flask iniciado" -ForegroundColor Green

Start-Sleep -Seconds 3

Write-Host "[3/3] Iniciando Simulador ESP32..." -ForegroundColor Yellow

# Iniciar Simulador
$job2 = Start-Job -ScriptBlock {
    Set-Location "$using:scriptDir"
    python simulador_esp32.py
}
Write-Host "  [OK] Simulador iniciado" -ForegroundColor Green

Pop-Location

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  SISTEMA INICIADO EXITOSAMENTE" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "DASHBOARDS DISPONIBLES:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Página Principal:" -ForegroundColor White
Write-Host "    http://localhost:9000" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Dashboard de Bombeo:" -ForegroundColor White
Write-Host "    http://localhost:9000/index.html" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Dashboard Meteorológico:" -ForegroundColor White
Write-Host "    http://localhost:9000/meteorologia.html" -ForegroundColor Cyan
Write-Host ""
Write-Host "ACCESO PUBLICO:" -ForegroundColor Yellow
Write-Host "  Base: http://<IP_O_DOMINIO>:9000" -ForegroundColor Cyan
Write-Host ""
Write-Host "PROCESOS EN EJECUCION:" -ForegroundColor Yellow
Write-Host "  - Flask:     $($job1.Id)" -ForegroundColor White
Write-Host "  - Simulador: $($job2.Id)" -ForegroundColor White
Write-Host ""
Write-Host "El simulador envía datos meteorológicos y de bombeo cada 10 segundos." -ForegroundColor Green
Write-Host ""
Write-Host "Presione Ctrl+C para detener el sistema..." -ForegroundColor Yellow
Write-Host ""

# Esperar a que se presione Ctrl+C
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
}
catch {
    Write-Host ""
}

Write-Host ""
Write-Host "Deteniendo sistema..." -ForegroundColor Yellow
Stop-Job -Job $job1, $job2 -ErrorAction SilentlyContinue
Remove-Job -Job $job1, $job2 -ErrorAction SilentlyContinue
taskkill /F /IM python.exe 2>$null | Out-Null
Write-Host "Sistema detenido." -ForegroundColor Green

