#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Inicia el simulador de datos virtuales para el sistema de monitoreo
.DESCRIPTION
    Este script inicia el simulador de datos virtuales que genera datos realistas 
    para el sistema de monitoreo de estaciones de bombeo
#>

param(
    [switch]$NoAutoStart,
    [string]$Port = "5001"
)

$ErrorActionPreference = "Stop"

Write-Host "🔄 Iniciando Simulador de Datos Virtuales" -ForegroundColor Green
Write-Host "=" * 50

try {
    # Verificar si el entorno virtual existe
    if (Test-Path "venv\Scripts\Activate.ps1") {
        Write-Host "✓ Activando entorno virtual..." -ForegroundColor Yellow
        & "venv\Scripts\Activate.ps1"
    } else {
        Write-Host "⚠️  Entorno virtual no encontrado. Usando Python global." -ForegroundColor Yellow
    }
    
    # Verificar que el archivo del simulador existe
    if (-not (Test-Path "data_simulator.py")) {
        Write-Error "❌ Archivo data_simulator.py no encontrado"
        exit 1
    }
    
    # Verificar dependencias necesarias
    Write-Host "📦 Verificando dependencias..." -ForegroundColor Blue
    
    $requiredPackages = @("flask", "requests")
    foreach ($package in $requiredPackages) {
        try {
            python -c "import $package" 2>$null
            Write-Host "  ✓ $package instalado" -ForegroundColor Green
        } catch {
            Write-Host "  ❌ $package no encontrado. Instalando..." -ForegroundColor Red
            pip install $package
        }
    }
    
    # Verificar si el puerto está disponible
    Write-Host "🔍 Verificando disponibilidad del puerto $Port..." -ForegroundColor Blue
    $portInUse = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($portInUse) {
        Write-Host "⚠️  Puerto $Port en uso. El simulador podría fallar al iniciar." -ForegroundColor Yellow
        Write-Host "   Proceso usando el puerto:" -ForegroundColor Yellow
        $portInUse | ForEach-Object { 
            $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
            if ($proc) {
                Write-Host "   - $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host ""
    Write-Host "🚀 Iniciando simulador en puerto $Port..." -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Funciones del simulador:" -ForegroundColor Cyan
    Write-Host "   • Genera datos realistas para 4 estaciones" -ForegroundColor White
    Write-Host "   • 10 tipos de sensores virtuales" -ForegroundColor White
    Write-Host "   • Patrones diarios y variaciones climáticas" -ForegroundColor White
    Write-Host "   • Cálculos hidráulicos precisos" -ForegroundColor White
    Write-Host "   • Actualización cada 5 segundos" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 Endpoints disponibles:" -ForegroundColor Cyan
    Write-Host "   • http://localhost:$Port/api/simulator/dashboard" -ForegroundColor White
    Write-Host "   • http://localhost:$Port/api/simulator/sensors" -ForegroundColor White
    Write-Host "   • http://localhost:$Port/api/simulator/status" -ForegroundColor White
    Write-Host ""
    Write-Host "🔄 El simulador se iniciará automáticamente al ejecutar el archivo Python" -ForegroundColor Yellow
    Write-Host "   Presiona Ctrl+C para detener el simulador" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "⏳ Iniciando en 3 segundos..." -ForegroundColor Green
    Start-Sleep -Seconds 3
    
    # Iniciar el simulador
    python data_simulator.py
    
} catch {
    Write-Host ""
    Write-Host "❌ Error al iniciar el simulador:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Posibles soluciones:" -ForegroundColor Yellow
    Write-Host "   1. Verificar que Python esté instalado correctamente" -ForegroundColor White
    Write-Host "   2. Instalar dependencias: pip install flask requests" -ForegroundColor White
    Write-Host "   3. Verificar que el puerto $Port esté disponible" -ForegroundColor White
    Write-Host "   4. Ejecutar como administrador si hay problemas de permisos" -ForegroundColor White
    
    Write-Host ""
    Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""
Write-Host "✅ Simulador detenido correctamente" -ForegroundColor Green
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
