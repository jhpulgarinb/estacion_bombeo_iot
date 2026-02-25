
<!-- SCRIPT PARA CONFIGURAR AUTOARRANQUE EN WINDOWS -->
<!-- Ejecutar como ADMINISTRADOR -->

$TaskName = "PromotoraPalmera_Servidor_HTTPS"
$TaskPath = "\PromotoraPalmera\"
$ScriptPath = "c:\inetpub\promotorapalmera\project_estacion_bombeo\servidor_dual_http_https.py"
$PythonExe = "python"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CONFIGURANDO AUTOARRANQUE WINDOWS"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si se ejecuta como administrador
$isAdmin = [bool]([System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
if (-not $isAdmin) {
    Write-Host "❌ ERROR: Este script debe ejecutarse como ADMINISTRADOR" -ForegroundColor Red
    Write-Host ""
    Write-Host "Pasos:" -ForegroundColor Yellow
    Write-Host "  1. Haz clic derecho en PowerShell"
    Write-Host "  2. Selecciona 'Ejecutar como administrador'"
    Write-Host "  3. Ejecuta este comando:" -ForegroundColor Yellow
    Write-Host "    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force"
    Write-Host "    . '$ScriptPath'"
    exit 1
}

Write-Host "✓ Ejecutándose como administrador" -ForegroundColor Green
Write-Host ""

# Verificar si Python está disponible
try {
    $pythonCheck = & $PythonExe --version 2>&1
    Write-Host "✓ Python instalado: $pythonCheck" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Python no encontrado en PATH" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Eliminar tarea existente si la hay
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "🔄 Eliminando tarea anterior..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

# Crear acción
$action = New-ScheduledTaskAction `
    -Execute $PythonExe `
    -Argument $ScriptPath `
    -WorkingDirectory "c:\inetpub\promotorapalmera\project_estacion_bombeo"

# Crear trigger para al iniciar Windows
$trigger = New-ScheduledTaskTrigger -AtStartup

# Crear settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -MultipleInstances IgnoreNew

# Crear descripción
$description = "Iniciador automático del servidor HTTPS/HTTP para Promotora Palmera"

# Crear y registrar la tarea
try {
    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Description $description `
        -RunLevel Highest `
        -Force | Out-Null
    
    Write-Host "✓ Tarea creada: $TaskName" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR al crear tarea: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✓ AUTOARRANQUE CONFIGURADO"
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "El servidor se iniciará automáticamente cuando reinicies Windows."
Write-Host ""
Write-Host "CONFIGURACIÓN ACTUAL:" -ForegroundColor Cyan
Write-Host "  📍 Tarea: $TaskName"
Write-Host "  🐍 Python Script: $ScriptPath"
Write-Host "  🔒 HTTPS: puerto 8082"
Write-Host "  🔓 HTTP:  puerto 8081"
Write-Host ""
Write-Host "PARA INICIAR AHORA:" -ForegroundColor Yellow
Write-Host "  Start-ScheduledTask -TaskName '$TaskName'"
Write-Host ""
Write-Host "PARA VER LOGS:" -ForegroundColor Yellow
Write-Host "  Get-ScheduledTaskInfo -TaskName '$TaskName'"
Write-Host ""
