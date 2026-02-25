# Monitor persistente del servidor HTTPS puerto 8082
# Mantiene el servidor corriendo indefinidamente

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ServerScript = Join-Path $ScriptDir "servidor_dual_http_https.py"
$LogFile = Join-Path $ScriptDir "servidor_8082.log"
$Port = 8082

Write-Host ""
Write-Host "========================================" 
Write-Host "  MONITOR SERVIDOR PUERTO $Port"
Write-Host "========================================" 
Write-Host ""

# Iniciar log
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $LogFile -Value "$timestamp - Iniciando monitor de puerto $Port"

# Loop infinito
while ($true) {
    try {
        # Verificar si el puerto está activo
        $portActive = $false
        $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        if ($connection) {
            $portActive = $true
        }
        
        if (-not $portActive) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Puerto $Port NO está activo. Iniciando servidor..." -ForegroundColor Yellow
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $LogFile -Value "$timestamp - Puerto no activo, iniciando servidor"
            
            # Iniciar servidor en background
            $process = Start-Process -FilePath "python" `
                -ArgumentList $ServerScript `
                -WorkingDirectory $ScriptDir `
                -NoNewWindow `
                -PassThru
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Servidor iniciado (PID: $($process.Id))" -ForegroundColor Green
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $LogFile -Value "$timestamp - Servidor iniciado (PID: $($process.Id))"
            
            # Esperar a que el servidor se estabilice
            Start-Sleep -Seconds 3
        } else {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Puerto $Port activo ✓" -ForegroundColor Green
        }
        
        # Verificar cada 10 segundos
        Start-Sleep -Seconds 10
        
    } catch {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $LogFile -Value "$timestamp - ERROR: $_"
        Write-Host "[ERROR] $_" -ForegroundColor Red
        Start-Sleep -Seconds 5
    }
}
