# Monitor avanzado del servidor puerto 8082
# Verifica que el puerto esté activo y responda a peticiones

$Port = 8082
$CheckInterval = 30  # segundos
$LogFile = "c:\inetpub\promotorapalmera\project_estacion_bombeo\monitor_8082.log"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MONITOR SERVIDOR PUERTO 8082" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Función para escribir en log
function Log-Info {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogFile -Value $logEntry
}

Log-Info "Monitor iniciado"

# Loop de monitoreo
$consecutiveFailures = 0
$maxRetries = 3

while ($true) {
    try {
        # Verificar si el puerto está escuchando
        $portActive = $false
        try {
            $connection = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
            if ($connection) {
                $portActive = $true
            }
        } catch {
            $portActive = $false
        }
        
        if ($portActive) {
            # Intentar conectar al servidor HTTPS
            try {
                $result = $null
                $result = Invoke-WebRequest -Uri "https://127.0.0.1:$Port/" `
                    -UseBasicParsing `
                    -TimeoutSec 5 `
                    -SkipCertificateCheck `
                    -ErrorAction SilentlyContinue
                
                if ($result.StatusCode -eq 200 -or $result.StatusCode -eq 302) {
                    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✓ Servidor respondiendo (Status: $($result.StatusCode))" -ForegroundColor Green
                    $consecutiveFailures = 0
                } else {
                    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ⚠ Status inesperado: $($result.StatusCode)" -ForegroundColor Yellow
                    $consecutiveFailures++
                }
            } catch {
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ⚠ Error conectando: $($_.Exception.Message.Substring(0,50))..." -ForegroundColor Yellow
                $consecutiveFailures++
            }
        } else {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✗ Puerto $Port NO está escuchando" -ForegroundColor Red
            $consecutiveFailures++
            Log-Info "Puerto no activo - Fallos consecutivos: $consecutiveFailures"
        }
        
        # Si hay demasiadas fallas, alertar
        if ($consecutiveFailures -ge $maxRetries) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ⚠ ALERTA: $consecutiveFailures fallos consecutivos" -ForegroundColor Red
            Log-Info "ALERTA: $consecutiveFailures fallos consecutivos"
        }
        
    } catch {
        Write-Host "[ERROR] $_" -ForegroundColor Red
        Log-Info "Error en monitor: $_"
    }
    
    # Esperar antes de la próxima verificación
    Start-Sleep -Seconds $CheckInterval
}
