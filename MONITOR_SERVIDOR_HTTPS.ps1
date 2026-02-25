Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  SERVIDOR HTTPS - INICIO AUTOMATICO" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Configuración
$projectPath = "c:\inetpub\promotorapalmera\project_estacion_bombeo"
$pythonScript = "servidor_dual_http_https.py"
$logFile = "$projectPath\servidor_https.log"
$checkInterval = 10 # Segundos entre verificaciones

Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "  Ruta: $projectPath" -ForegroundColor Gray
Write-Host "  Script: $pythonScript" -ForegroundColor Gray
Write-Host "  Log: $logFile" -ForegroundColor Gray
Write-Host "  Intervalo: $checkInterval segundos" -ForegroundColor Gray
Write-Host ""

# Función para verificar si el servidor está corriendo
function Test-ServidorActivo {
    $puertos = netstat -ano | findstr ":8082"
    return ($null -ne $puertos)
}

# Función para iniciar servidor
function Start-Servidor {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Iniciando servidor HTTPS..." -ForegroundColor Yellow
    
    Set-Location $projectPath
    
    # Iniciar proceso en segundo plano
    $proceso = Start-Process -FilePath "python" `
                            -ArgumentList $pythonScript `
                            -WorkingDirectory $projectPath `
                            -WindowStyle Hidden `
                            -PassThru `
                            -RedirectStandardOutput "$projectPath\stdout.log" `
                            -RedirectStandardError "$projectPath\stderr.log"
    
    Start-Sleep -Seconds 3
    
    if (Test-ServidorActivo) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✓ Servidor iniciado correctamente (PID: $($proceso.Id))" -ForegroundColor Green
        "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Servidor iniciado (PID: $($proceso.Id))" | Out-File -Append -FilePath $logFile
        return $true
    } else {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✗ Error al iniciar servidor" -ForegroundColor Red
        "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error al iniciar servidor" | Out-File -Append -FilePath $logFile
        return $false
    }
}

# Banner informativo
Write-Host "=======================================" -ForegroundColor Green
Write-Host "  MONITOR INICIADO" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""
Write-Host "El script mantendrá el servidor HTTPS activo." -ForegroundColor White
Write-Host "Si el servidor se detiene, se reiniciará automáticamente." -ForegroundColor White
Write-Host ""
Write-Host "URLs del servidor:" -ForegroundColor Cyan
Write-Host "  HTTPS: https://www.ppasas.com:8082/uploads/nomina/" -ForegroundColor White
Write-Host "  HTTP:  http://www.ppasas.com:8080/uploads/nomina/" -ForegroundColor White
Write-Host ""
Write-Host "Para detener este monitor, presione Ctrl+C" -ForegroundColor Yellow
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

# Verificación inicial
if (-not (Test-ServidorActivo)) {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Servidor no detectado, iniciando..." -ForegroundColor Yellow
    Start-Servidor
} else {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✓ Servidor ya está corriendo" -ForegroundColor Green
}

# Loop de monitoreo
$contador = 0
try {
    while ($true) {
        Start-Sleep -Seconds $checkInterval
        $contador++
        
        if (-not (Test-ServidorActivo)) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ⚠ Servidor caído - reiniciando..." -ForegroundColor Red
            "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Servidor caído detectado (check #$contador)" | Out-File -Append -FilePath $logFile
            Start-Servidor
        } else {
            # Mostrar mensaje cada 60 verificaciones (10 minutos si checkInterval=10)
            if ($contador % 60 -eq 0) {
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✓ Servidor activo (check #$contador)" -ForegroundColor Gray
            }
        }
    }
} catch {
    Write-Host "" 
    Write-Host "Monitor detenido" -ForegroundColor Yellow
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Monitor detenido manualmente" | Out-File -Append -FilePath $logFile
}
