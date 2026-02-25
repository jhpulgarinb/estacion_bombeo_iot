#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Inicia el sistema completo de monitoreo con simulador de datos
.DESCRIPTION
    Este script inicia tanto el simulador de datos virtuales como la aplicación principal
    del sistema de monitoreo de estaciones de bombeo
#>

param(
    [switch]$OnlySimulator,
    [switch]$OnlyApp,
    [string]$SimulatorPort = "5001",
    [string]$AppPort = "5000"
)

$ErrorActionPreference = "Stop"

Write-Host "🌊 SISTEMA DE MONITOREO DE ESTACIONES DE BOMBEO" -ForegroundColor Blue
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Blue
Write-Host "🔄 Iniciando sistema completo con simulador de datos" -ForegroundColor Green
Write-Host ""

function Start-SimulatorProcess {
    Write-Host "📊 Iniciando Simulador de Datos..." -ForegroundColor Yellow
    
    $simulatorScript = {
        param($Port)
        
        # Activar entorno virtual si existe
        if (Test-Path "venv\Scripts\Activate.ps1") {
            & "venv\Scripts\Activate.ps1"
        }
        
        # Cambiar al directorio del proyecto
        Set-Location $using:PWD
        
        # Iniciar el simulador
        python data_simulator.py
    }
    
    $simulatorJob = Start-Job -ScriptBlock $simulatorScript -ArgumentList $SimulatorPort
    Write-Host "   ✓ Simulador iniciado en proceso separado (Job ID: $($simulatorJob.Id))" -ForegroundColor Green
    
    # Esperar un poco para que el simulador se inicie
    Start-Sleep -Seconds 5
    
    # Verificar si el simulador está corriendo
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$SimulatorPort/api/simulator/status" -Method GET -TimeoutSec 5
        Write-Host "   ✓ Simulador respondiendo correctamente" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Simulador tardando en iniciar (normal)" -ForegroundColor Yellow
    }
    
    return $simulatorJob
}

function Start-ApplicationProcess {
    Write-Host "🏭 Iniciando Aplicación Principal..." -ForegroundColor Yellow
    
    $appScript = {
        param($Port)
        
        # Activar entorno virtual si existe
        if (Test-Path "venv\Scripts\Activate.ps1") {
            & "venv\Scripts\Activate.ps1"
        }
        
        # Cambiar al directorio del proyecto
        Set-Location $using:PWD
        
        # Configurar variables de entorno
        $env:FLASK_APP = "app.py"
        $env:FLASK_ENV = "development"
        
        # Iniciar la aplicación Flask
        python app.py
    }
    
    $appJob = Start-Job -ScriptBlock $appScript -ArgumentList $AppPort
    Write-Host "   ✓ Aplicación iniciada en proceso separado (Job ID: $($appJob.Id))" -ForegroundColor Green
    
    # Esperar un poco para que la aplicación se inicie
    Start-Sleep -Seconds 8
    
    # Verificar si la aplicación está corriendo
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$AppPort" -Method GET -TimeoutSec 10
        Write-Host "   ✓ Aplicación principal respondiendo correctamente" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Aplicación tardando en iniciar (normal)" -ForegroundColor Yellow
    }
    
    return $appJob
}

function Show-SystemInfo {
    Write-Host ""
    Write-Host "🌐 URLs del Sistema:" -ForegroundColor Cyan
    Write-Host "   📊 Dashboard Principal: http://localhost:$AppPort" -ForegroundColor White
    Write-Host "   📈 Simulador de Datos: http://localhost:$SimulatorPort/api/simulator/status" -ForegroundColor White
    Write-Host "   📚 Documentación: http://localhost:$AppPort/docs" -ForegroundColor White
    Write-Host ""
    Write-Host "🎛️  Funciones del Sistema:" -ForegroundColor Cyan
    Write-Host "   • Monitoreo en tiempo real de 4 estaciones" -ForegroundColor White
    Write-Host "   • 10 tipos de sensores virtuales simulados" -ForegroundColor White
    Write-Host "   • Gráficos interactivos y alertas automáticas" -ForegroundColor White
    Write-Host "   • Cálculos hidráulicos y reportes técnicos" -ForegroundColor White
    Write-Host "   • Patrones de datos realistas 24/7" -ForegroundColor White
    Write-Host ""
    Write-Host "⚡ Estado de los Servicios:" -ForegroundColor Cyan
}

function Monitor-Jobs {
    param($Jobs)
    
    Write-Host "🔄 Monitoreando servicios... (Ctrl+C para detener todo)" -ForegroundColor Green
    Write-Host ""
    
    try {
        while ($true) {
            $runningJobs = $Jobs | Where-Object { $_.State -eq "Running" }
            
            if ($runningJobs.Count -eq 0) {
                Write-Host "❌ Todos los servicios se han detenido" -ForegroundColor Red
                break
            }
            
            # Mostrar estado cada 30 segundos
            Write-Host "$(Get-Date -Format 'HH:mm:ss') - $($runningJobs.Count) servicios activos" -ForegroundColor Green
            
            Start-Sleep -Seconds 30
        }
    } catch {
        Write-Host ""
        Write-Host "🛑 Deteniendo servicios..." -ForegroundColor Yellow
    }
    
    # Detener todos los jobs
    foreach ($job in $Jobs) {
        if ($job.State -eq "Running") {
            Stop-Job -Job $job
            Remove-Job -Job $job -Force
        }
    }
}

try {
    # Verificar entorno virtual
    if (Test-Path "venv\Scripts\Activate.ps1") {
        Write-Host "✓ Entorno virtual encontrado" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Entorno virtual no encontrado. Usando Python global." -ForegroundColor Yellow
    }
    
    # Verificar archivos necesarios
    $requiredFiles = @("data_simulator.py", "app.py", "database.py")
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-Host "✓ $file encontrado" -ForegroundColor Green
        } else {
            Write-Host "❌ $file no encontrado" -ForegroundColor Red
            throw "Archivo requerido $file no encontrado"
        }
    }
    
    Write-Host ""
    
    # Inicializar array de jobs
    $jobs = @()
    
    # Iniciar servicios según parámetros
    if (-not $OnlyApp) {
        $simulatorJob = Start-SimulatorProcess
        $jobs += $simulatorJob
    }
    
    if (-not $OnlySimulator) {
        $appJob = Start-ApplicationProcess  
        $jobs += $appJob
    }
    
    # Mostrar información del sistema
    Show-SystemInfo
    
    # Verificar estado de los servicios
    Start-Sleep -Seconds 2
    foreach ($job in $jobs) {
        $jobName = if ($job -eq $simulatorJob) { "Simulador" } else { "Aplicación" }
        if ($job.State -eq "Running") {
            Write-Host "   ✅ $jobName: EJECUTÁNDOSE" -ForegroundColor Green
        } else {
            Write-Host "   ❌ $jobName: ERROR" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "🚀 Sistema iniciado correctamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Abriendo navegador..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    
    # Abrir navegador
    if (-not $OnlySimulator) {
        Start-Process "http://localhost:$AppPort"
    }
    
    # Monitorear los servicios
    Monitor-Jobs -Jobs $jobs
    
} catch {
    Write-Host ""
    Write-Host "❌ Error durante la inicialización:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Posibles soluciones:" -ForegroundColor Yellow
    Write-Host "   1. Verificar que Python esté instalado" -ForegroundColor White
    Write-Host "   2. Instalar dependencias: pip install -r requirements.txt" -ForegroundColor White
    Write-Host "   3. Verificar puertos disponibles ($SimulatorPort, $AppPort)" -ForegroundColor White
    Write-Host "   4. Ejecutar desde el directorio del proyecto" -ForegroundColor White
}

Write-Host ""
Write-Host "✅ Sistema detenido" -ForegroundColor Green
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
