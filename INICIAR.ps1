#!/usr/bin/env pwsh
<#
.SYNOPSIS
    🌊 INICIO AUTOMÁTICO - Sistema de Monitoreo de Estaciones de Bombeo
.DESCRIPTION
    Script de inicio completamente automatizado que configura y ejecuta todo el sistema
    incluyendo simulador de datos y aplicación principal con un solo clic
#>

param(
    [switch]$SoloSimulador,
    [switch]$SoloApp,
    [switch]$NoAbrir,
    [int]$TimeoutInicio = 15
)

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "🌊 Sistema de Monitoreo - Estaciones de Bombeo"

# Colores y estilos
$ColorTitulo = "Blue"
$ColorExito = "Green" 
$ColorAdvertencia = "Yellow"
$ColorError = "Red"
$ColorInfo = "Cyan"
$ColorTexto = "White"

function Write-Banner {
    Clear-Host
    Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor $ColorTitulo
    Write-Host "║                                                                              ║" -ForegroundColor $ColorTitulo
    Write-Host "║           🌊 SISTEMA DE MONITOREO DE ESTACIONES DE BOMBEO 🌊                ║" -ForegroundColor $ColorTitulo
    Write-Host "║                                                                              ║" -ForegroundColor $ColorTitulo
    Write-Host "║                    ⚡ INICIO AUTOMÁTICO INTELIGENTE ⚡                      ║" -ForegroundColor $ColorTitulo
    Write-Host "║                                                                              ║" -ForegroundColor $ColorTitulo
    Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor $ColorTitulo
    Write-Host ""
}

function Write-Step {
    param($Message, $Status = "info")
    $Icon = switch($Status) {
        "success" { "✅" }
        "warning" { "⚠️ " }
        "error" { "❌" }
        "info" { "🔄" }
        "wait" { "⏳" }
        default { "📋" }
    }
    
    $Color = switch($Status) {
        "success" { $ColorExito }
        "warning" { $ColorAdvertencia }
        "error" { $ColorError }
        "wait" { $ColorAdvertencia }
        default { $ColorInfo }
    }
    
    Write-Host "$Icon $Message" -ForegroundColor $Color
}

function Test-Prerequisites {
    Write-Step "Verificando prerequisitos del sistema..." "info"
    
    # Verificar Python
    try {
        $pythonVersion = python --version 2>&1
        Write-Step "Python disponible: $pythonVersion" "success"
    } catch {
        Write-Step "❌ Python no encontrado o no funcional" "error"
        Write-Host ""
        Write-Host "🔧 SOLUCIÓN:" -ForegroundColor $ColorAdvertencia
        Write-Host "   1. Instala Python desde https://python.org" -ForegroundColor $ColorTexto
        Write-Host "   2. Asegúrate de agregar Python al PATH" -ForegroundColor $ColorTexto
        Write-Host "   3. Reinicia PowerShell" -ForegroundColor $ColorTexto
        Read-Host "Presiona Enter para salir"
        exit 1
    }
    
    # Verificar entorno virtual
    if (Test-Path "venv\Scripts\Activate.ps1") {
        Write-Step "Entorno virtual encontrado" "success"
        
        # Activar entorno virtual si no está activo
        if (-not $env:VIRTUAL_ENV) {
            Write-Step "Activando entorno virtual..." "info"
            & "venv\Scripts\Activate.ps1"
        }
    } else {
        Write-Step "Entorno virtual no encontrado - usando Python global" "warning"
    }
    
    # Verificar archivos del proyecto
    $archivosNecesarios = @(
        "app.py",
        "data_simulator.py", 
        "database.py",
        "index.html",
        "script.js",
        "styles.css"
    )
    
    $archivosFaltantes = @()
    foreach ($archivo in $archivosNecesarios) {
        if (Test-Path $archivo) {
            Write-Step "$archivo ✓" "success"
        } else {
            $archivosFaltantes += $archivo
            Write-Step "$archivo ❌" "error"
        }
    }
    
    if ($archivosFaltantes.Count -gt 0) {
        Write-Step "Archivos faltantes detectados" "error"
        Write-Host "Archivos faltantes:" -ForegroundColor $ColorError
        $archivosFaltantes | ForEach-Object { Write-Host "  - $_" -ForegroundColor $ColorError }
        Read-Host "Presiona Enter para salir"
        exit 1
    }
    
    return $true
}

function Install-Dependencies {
    Write-Step "Verificando e instalando dependencias..." "info"
    
    $dependenciasBasicas = @("flask", "flask-cors", "flask-sqlalchemy", "requests")
    $dependenciasOpcionales = @("numpy", "scipy")
    
    foreach ($dep in $dependenciasBasicas) {
        Write-Step "Verificando $dep..." "info"
        try {
            python -c "import $dep" 2>$null
            Write-Step "$dep ya instalado ✓" "success"
        } catch {
            Write-Step "Instalando $dep..." "wait"
            pip install $dep --quiet
            Write-Step "$dep instalado ✓" "success"
        }
    }
    
    foreach ($dep in $dependenciasOpcionales) {
        try {
            python -c "import $dep" 2>$null
            Write-Step "$dep disponible ✓" "success"
        } catch {
            Write-Step "$dep no disponible - instalando..." "wait"
            try {
                pip install $dep --quiet
                Write-Step "$dep instalado ✓" "success"
            } catch {
                Write-Step "$dep no se pudo instalar (opcional)" "warning"
            }
        }
    }
}

function Test-Ports {
    param($Ports)
    
    Write-Step "Verificando disponibilidad de puertos..." "info"
    
    foreach ($port in $Ports) {
        $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($connection) {
            Write-Step "Puerto $port en uso" "warning"
            
            $processes = $connection | ForEach-Object {
                Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
            } | Select-Object -Unique ProcessName, Id
            
            if ($processes) {
                Write-Host "   Procesos usando el puerto:" -ForegroundColor $ColorAdvertencia
                $processes | ForEach-Object {
                    Write-Host "   - $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor $ColorTexto
                }
                
                $respuesta = Read-Host "¿Quieres intentar terminar estos procesos? (y/n)"
                if ($respuesta -eq "y" -or $respuesta -eq "Y") {
                    try {
                        $processes | Stop-Process -Force -ErrorAction SilentlyContinue
                        Write-Step "Procesos terminados" "success"
                        Start-Sleep -Seconds 2
                    } catch {
                        Write-Step "No se pudieron terminar algunos procesos" "warning"
                    }
                }
            }
        } else {
            Write-Step "Puerto $port disponible ✓" "success"
        }
    }
}

function Initialize-Database {
    Write-Step "Inicializando base de datos..." "info"
    
    try {
        if (Test-Path "monitoring.db") {
            Write-Step "Base de datos existente encontrada" "success"
        } else {
            Write-Step "Creando nueva base de datos..." "info"
            python -c "
from database import db, Station, Reading
from app import app
with app.app_context():
    db.create_all()
    print('Base de datos creada exitosamente')
"
            Write-Step "Base de datos inicializada ✓" "success"
        }
    } catch {
        Write-Step "Error inicializando base de datos - usando valores por defecto" "warning"
    }
}

function Start-Services {
    param($StartSimulator, $StartApp)
    
    $jobs = @()
    
    if ($StartSimulator) {
        Write-Step "Iniciando Simulador de Datos..." "info"
        
        $simulatorScript = {
            if (Test-Path "venv\Scripts\Activate.ps1") {
                & "venv\Scripts\Activate.ps1"
            }
            Set-Location $using:PWD
            python data_simulator.py
        }
        
        $simulatorJob = Start-Job -ScriptBlock $simulatorScript -Name "SimuladorDatos"
        $jobs += @{ Name = "Simulador"; Job = $simulatorJob; Port = 5001; Url = "http://localhost:5001/api/simulator/status" }
        Write-Step "Simulador iniciado (Job ID: $($simulatorJob.Id))" "success"
    }
    
    if ($StartApp) {
        Write-Step "Iniciando Aplicación Principal..." "info"
        
        $appScript = {
            if (Test-Path "venv\Scripts\Activate.ps1") {
                & "venv\Scripts\Activate.ps1"  
            }
            Set-Location $using:PWD
            $env:FLASK_APP = "app.py"
            $env:FLASK_ENV = "development"
            python app.py
        }
        
        $appJob = Start-Job -ScriptBlock $appScript -Name "AplicacionPrincipal"
        $jobs += @{ Name = "Aplicación"; Job = $appJob; Port = 5000; Url = "http://localhost:5000" }
        Write-Step "Aplicación iniciada (Job ID: $($appJob.Id))" "success"
    }
    
    return $jobs
}

function Wait-ForServices {
    param($Services, $TimeoutSeconds = 15)
    
    Write-Step "Esperando que los servicios estén listos..." "wait"
    
    $maxAttempts = $TimeoutSeconds
    $attempt = 0
    
    do {
        $attempt++
        $allReady = $true
        
        foreach ($service in $Services) {
            try {
                $response = Invoke-WebRequest -Uri $service.Url -Method GET -TimeoutSec 3 -UseBasicParsing
                Write-Step "$($service.Name) respondiendo ✓" "success"
            } catch {
                $allReady = $false
                Write-Step "$($service.Name) aún cargando..." "wait"
            }
        }
        
        if (-not $allReady -and $attempt -lt $maxAttempts) {
            Start-Sleep -Seconds 1
        }
        
    } while (-not $allReady -and $attempt -lt $maxAttempts)
    
    if ($allReady) {
        Write-Step "¡Todos los servicios están listos!" "success"
        return $true
    } else {
        Write-Step "Algunos servicios tardaron en iniciar (esto es normal)" "warning"
        return $false
    }
}

function Show-SystemInfo {
    param($Services)
    
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor $ColorInfo
    Write-Host "║                      🎯 SISTEMA INICIADO                      ║" -ForegroundColor $ColorInfo
    Write-Host "╠═══════════════════════════════════════════════════════════════╣" -ForegroundColor $ColorInfo
    
    foreach ($service in $Services) {
        $status = if ($service.Job.State -eq "Running") { "🟢 EJECUTÁNDOSE" } else { "🔴 ERROR" }
        $serviceLine = "║ 📊 $($service.Name): $status"
        $padding = 63 - $serviceLine.Length
        Write-Host "$serviceLine$(' ' * $padding)║" -ForegroundColor $ColorTexto
        
        $urlLine = "║    🌐 $($service.Url)"
        $urlPadding = 63 - $urlLine.Length  
        Write-Host "$urlLine$(' ' * $urlPadding)║" -ForegroundColor $ColorTexto
    }
    
    Write-Host "╠═══════════════════════════════════════════════════════════════╣" -ForegroundColor $ColorInfo
    Write-Host "║                     🎛️  CARACTERÍSTICAS                      ║" -ForegroundColor $ColorInfo
    Write-Host "║ • Monitoreo en tiempo real de 4 estaciones                   ║" -ForegroundColor $ColorTexto
    Write-Host "║ • 10 tipos de sensores virtuales simulados                   ║" -ForegroundColor $ColorTexto
    Write-Host "║ • Gráficos interactivos y alertas automáticas                ║" -ForegroundColor $ColorTexto
    Write-Host "║ • Cálculos hidráulicos y reportes técnicos                   ║" -ForegroundColor $ColorTexto
    Write-Host "║ • Patrones de datos realistas 24/7                           ║" -ForegroundColor $ColorTexto
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor $ColorInfo
    Write-Host ""
}

function Monitor-System {
    param($Services)
    
    Write-Step "Sistema en ejecución - Ctrl+C para detener" "info"
    Write-Host ""
    
    $iteration = 0
    
    try {
        while ($true) {
            $iteration++
            $runningServices = $Services | Where-Object { $_.Job.State -eq "Running" }
            
            if ($runningServices.Count -eq 0) {
                Write-Step "❌ Todos los servicios se han detenido" "error"
                break
            }
            
            # Mostrar estado cada 30 segundos
            if ($iteration % 30 -eq 1) {
                $timestamp = Get-Date -Format "HH:mm:ss"
                Write-Step "$timestamp - $($runningServices.Count)/$($Services.Count) servicios activos" "success"
            }
            
            Start-Sleep -Seconds 1
        }
    } catch {
        Write-Host ""
        Write-Step "Deteniendo sistema..." "warning"
    }
    
    # Limpiar trabajos
    foreach ($service in $Services) {
        if ($service.Job.State -eq "Running") {
            Stop-Job -Job $service.Job -ErrorAction SilentlyContinue
            Remove-Job -Job $service.Job -Force -ErrorAction SilentlyContinue
        }
    }
}

# ========================= EJECUCIÓN PRINCIPAL =========================

try {
    Write-Banner
    
    Write-Step "🚀 Iniciando Sistema de Monitoreo de Estaciones de Bombeo..." "info"
    Write-Host ""
    
    # Verificar prerequisitos
    Test-Prerequisites | Out-Null
    Write-Host ""
    
    # Instalar dependencias
    Install-Dependencies
    Write-Host ""
    
    # Verificar puertos
    $ports = @()
    if (-not $SoloApp) { $ports += 5001 }
    if (-not $SoloSimulador) { $ports += 5000 }
    Test-Ports -Ports $ports
    Write-Host ""
    
    # Inicializar base de datos
    if (-not $SoloSimulador) {
        Initialize-Database
        Write-Host ""
    }
    
    # Iniciar servicios
    $services = Start-Services -StartSimulator (-not $SoloApp) -StartApp (-not $SoloSimulador)
    Write-Host ""
    
    # Esperar a que los servicios estén listos
    $servicesReady = Wait-ForServices -Services $services -TimeoutSeconds $TimeoutInicio
    Write-Host ""
    
    # Mostrar información del sistema
    Show-SystemInfo -Services $services
    
    # Abrir navegador automáticamente
    if (-not $NoAbrir -and (-not $SoloSimulador)) {
        Write-Step "🌐 Abriendo navegador..." "info"
        Start-Sleep -Seconds 2
        try {
            Start-Process "http://localhost:5000"
            Write-Step "Navegador abierto ✓" "success"
        } catch {
            Write-Step "No se pudo abrir el navegador automáticamente" "warning"
            Write-Step "Abre manualmente: http://localhost:5000" "info"
        }
    }
    
    Write-Host ""
    Write-Step "🎯 ¡Sistema completamente operativo!" "success"
    Write-Host ""
    
    # Monitorear el sistema
    Monitor-System -Services $services
    
} catch {
    Write-Host ""
    Write-Step "❌ Error crítico durante la inicialización:" "error"
    Write-Host $_.Exception.Message -ForegroundColor $ColorError
    Write-Host ""
    Write-Host "🔧 SOLUCIONES SUGERIDAS:" -ForegroundColor $ColorAdvertencia
    Write-Host "   1. Ejecuta como administrador" -ForegroundColor $ColorTexto
    Write-Host "   2. Verifica que Python esté instalado correctamente" -ForegroundColor $ColorTexto
    Write-Host "   3. Asegúrate de estar en el directorio correcto del proyecto" -ForegroundColor $ColorTexto
    Write-Host "   4. Cierra otras aplicaciones que puedan usar los puertos 5000/5001" -ForegroundColor $ColorTexto
    Write-Host ""
    Write-Step "Intenta ejecutar: .\INICIAR.ps1" "info"
}

Write-Host ""
Write-Step "✅ Proceso finalizado" "success"
Write-Host "Presiona cualquier tecla para cerrar..." -ForegroundColor $ColorAdvertencia
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
