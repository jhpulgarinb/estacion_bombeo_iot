# ============================================================================
# SISTEMA DE MONITOREO DE ESTACIÓN DE BOMBEO - INICIO AUTOMÁTICO
# Script para inicializar y ejecutar todo el sistema con datos de prueba
# ============================================================================

param(
    [switch]$SkipDatabase,
    [switch]$SkipSensors,
    [switch]$SkipWeb,
    [switch]$ResetData,
    [int]$Port = 5000
)

# Configuración
$SCRIPT_DIR = Get-Location
$VENV_PATH = "$SCRIPT_DIR\venv"
$PYTHON_EXE = "$VENV_PATH\Scripts\python.exe"
$LOG_DIR = "$SCRIPT_DIR\logs"
$DATABASE_FILE = "$SCRIPT_DIR\monitoring.db"

# Colores para mensajes
$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$BLUE = "Cyan"

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

function Write-ColorMessage {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Banner {
    param([string]$Title)
    Write-Host ""
    Write-Host "=" * 70 -ForegroundColor $BLUE
    Write-Host " $Title" -ForegroundColor $BLUE
    Write-Host "=" * 70 -ForegroundColor $BLUE
    Write-Host ""
}

function Test-PythonEnvironment {
    Write-ColorMessage "🔍 Verificando entorno Python..." $YELLOW
    
    if (-not (Test-Path $VENV_PATH)) {
        Write-ColorMessage "❌ Entorno virtual no encontrado en: $VENV_PATH" $RED
        Write-ColorMessage "   Creando entorno virtual..." $YELLOW
        python -m venv $VENV_PATH
        if ($LASTEXITCODE -ne 0) {
            Write-ColorMessage "❌ Error al crear entorno virtual" $RED
            return $false
        }
    }
    
    if (-not (Test-Path $PYTHON_EXE)) {
        Write-ColorMessage "❌ Python no encontrado en entorno virtual" $RED
        return $false
    }
    
    Write-ColorMessage "✅ Entorno Python verificado" $GREEN
    return $true
}

function Install-Dependencies {
    Write-ColorMessage "📦 Instalando dependencias..." $YELLOW
    
    if (-not (Test-Path "requirements.txt")) {
        Write-ColorMessage "❌ Archivo requirements.txt no encontrado" $RED
        return $false
    }
    
    try {
        & $PYTHON_EXE -m pip install --upgrade pip | Out-Null
        & $PYTHON_EXE -m pip install -r requirements.txt | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorMessage "✅ Dependencias instaladas correctamente" $GREEN
            return $true
        } else {
            Write-ColorMessage "❌ Error al instalar dependencias" $RED
            return $false
        }
    } catch {
        Write-ColorMessage "❌ Error al ejecutar pip: $_" $RED
        return $false
    }
}

function Initialize-Database {
    Write-ColorMessage "🗄️  Inicializando base de datos..." $YELLOW
    
    if ($ResetData -and (Test-Path $DATABASE_FILE)) {
        Write-ColorMessage "🗑️  Eliminando base de datos existente..." $YELLOW
        Remove-Item $DATABASE_FILE -Force
    }
    
    if (-not (Test-Path $DATABASE_FILE) -or $ResetData) {
        Write-ColorMessage "📊 Creando base de datos con datos de prueba..." $YELLOW
        try {
            & $PYTHON_EXE initialize_test_data.py
            if ($LASTEXITCODE -eq 0) {
                Write-ColorMessage "✅ Base de datos inicializada con datos de prueba" $GREEN
                return $true
            } else {
                Write-ColorMessage "❌ Error al inicializar base de datos" $RED
                return $false
            }
        } catch {
            Write-ColorMessage "❌ Error al ejecutar inicialización: $_" $RED
            return $false
        }
    } else {
        Write-ColorMessage "✅ Base de datos ya existe" $GREEN
        return $true
    }
}

function Start-WebApplication {
    Write-ColorMessage "🌐 Iniciando aplicación web..." $YELLOW
    
    try {
        $env:FLASK_APP = "app.py"
        $env:FLASK_ENV = "development"
        
        # Iniciar aplicación Flask en segundo plano
        $webJob = Start-Job -ScriptBlock {
            param($PythonPath, $Port)
            Set-Location $using:SCRIPT_DIR
            & $PythonPath -c "
import os
os.environ['FLASK_APP'] = 'app.py'
os.environ['FLASK_ENV'] = 'development'
from app import app
app.run(host='0.0.0.0', port=$Port, debug=False, use_reloader=False)
" 2>&1
        } -ArgumentList $PYTHON_EXE, $Port
        
        # Esperar un momento para que inicie
        Start-Sleep -Seconds 3
        
        # Verificar que la aplicación esté corriendo
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$Port" -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-ColorMessage "✅ Aplicación web iniciada en http://localhost:$Port" $GREEN
                return $webJob
            }
        } catch {
            Write-ColorMessage "⚠️  Aplicación web iniciándose..." $YELLOW
            return $webJob
        }
        
        return $webJob
        
    } catch {
        Write-ColorMessage "❌ Error al iniciar aplicación web: $_" $RED
        return $null
    }
}

function Start-VirtualSensors {
    Write-ColorMessage "🔧 Iniciando sensores virtuales..." $YELLOW
    
    try {
        # Esperar que la aplicación web esté lista
        $maxRetries = 10
        $retries = 0
        $webReady = $false
        
        while (-not $webReady -and $retries -lt $maxRetries) {
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:$Port" -TimeoutSec 2 -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
                    $webReady = $true
                }
            } catch {
                $retries++
                Start-Sleep -Seconds 2
            }
        }
        
        if (-not $webReady) {
            Write-ColorMessage "⚠️  Aplicación web no responde, iniciando sensores de todos modos..." $YELLOW
        }
        
        # Iniciar sensores virtuales
        $sensorsJob = Start-Job -ScriptBlock {
            param($PythonPath, $ApiUrl)
            Set-Location $using:SCRIPT_DIR
            & $PythonPath virtual_sensors.py 2>&1
        } -ArgumentList $PYTHON_EXE, "http://localhost:$Port"
        
        Start-Sleep -Seconds 2
        
        if ($sensorsJob.State -eq "Running") {
            Write-ColorMessage "✅ Sensores virtuales iniciados" $GREEN
            return $sensorsJob
        } else {
            Write-ColorMessage "❌ Error al iniciar sensores virtuales" $RED
            return $null
        }
        
    } catch {
        Write-ColorMessage "❌ Error al iniciar sensores virtuales: $_" $RED
        return $null
    }
}

function Show-SystemStatus {
    param($WebJob, $SensorsJob)
    
    Write-Banner "ESTADO DEL SISTEMA"
    
    Write-ColorMessage "📊 Base de datos: " -NoNewline
    if (Test-Path $DATABASE_FILE) {
        Write-ColorMessage "✅ Activa" $GREEN
        $dbSize = (Get-Item $DATABASE_FILE).Length / 1KB
        Write-ColorMessage "   Tamaño: $([math]::Round($dbSize, 2)) KB"
    } else {
        Write-ColorMessage "❌ No encontrada" $RED
    }
    
    Write-ColorMessage "🌐 Aplicación web: " -NoNewline
    if ($WebJob -and $WebJob.State -eq "Running") {
        Write-ColorMessage "✅ Corriendo en http://localhost:$Port" $GREEN
    } else {
        Write-ColorMessage "❌ No está corriendo" $RED
    }
    
    Write-ColorMessage "🔧 Sensores virtuales: " -NoNewline
    if ($SensorsJob -and $SensorsJob.State -eq "Running") {
        Write-ColorMessage "✅ Activos y enviando datos" $GREEN
    } else {
        Write-ColorMessage "❌ No están activos" $RED
    }
    
    Write-Host ""
    Write-ColorMessage "🎯 URLs importantes:" $BLUE
    Write-ColorMessage "   • Dashboard: http://localhost:$Port" 
    Write-ColorMessage "   • API datos: http://localhost:$Port/api/data"
    Write-ColorMessage "   • API dashboard: http://localhost:$Port/api/dashboard"
    
    Write-Host ""
    Write-ColorMessage "📝 Archivos de configuración:" $BLUE
    Write-ColorMessage "   • Base de datos: $DATABASE_FILE"
    Write-ColorMessage "   • Sensores: virtual_sensors.py"
    Write-ColorMessage "   • Aplicación: app.py"
    
    Write-Host ""
}

function Wait-ForUserInput {
    param($WebJob, $SensorsJob)
    
    Write-ColorMessage "💡 El sistema está corriendo. Opciones disponibles:" $YELLOW
    Write-ColorMessage "   [S] - Mostrar estado del sistema"
    Write-ColorMessage "   [L] - Ver logs en tiempo real"
    Write-ColorMessage "   [R] - Reiniciar sensores"
    Write-ColorMessage "   [O] - Abrir dashboard en navegador"
    Write-ColorMessage "   [Q] - Detener y salir"
    Write-Host ""
    Write-ColorMessage "Presiona una tecla o Ctrl+C para salir..." $GREEN
    
    while ($true) {
        if ([System.Console]::KeyAvailable) {
            $key = [System.Console]::ReadKey($true)
            
            switch ($key.KeyChar.ToString().ToUpper()) {
                'S' { 
                    Show-SystemStatus $WebJob $SensorsJob
                    Write-ColorMessage "Presiona otra tecla para continuar..." $YELLOW
                }
                'L' { 
                    Write-ColorMessage "📝 Mostrando logs (Ctrl+C para parar)..." $YELLOW
                    try {
                        if ($SensorsJob) {
                            Receive-Job $SensorsJob -Keep | Select-Object -Last 20
                        }
                        if ($WebJob) {
                            Receive-Job $WebJob -Keep | Select-Object -Last 10
                        }
                    } catch {
                        Write-ColorMessage "No hay logs disponibles aún" $YELLOW
                    }
                }
                'R' { 
                    Write-ColorMessage "🔄 Reiniciando sensores..." $YELLOW
                    if ($SensorsJob) {
                        Stop-Job $SensorsJob -Force
                        Remove-Job $SensorsJob -Force
                    }
                    $SensorsJob = Start-VirtualSensors
                }
                'O' { 
                    Write-ColorMessage "🌐 Abriendo dashboard..." $YELLOW
                    Start-Process "http://localhost:$Port"
                }
                'Q' { 
                    Write-ColorMessage "🛑 Deteniendo sistema..." $YELLOW
                    return $false
                }
            }
        }
        
        Start-Sleep -Milliseconds 100
    }
}

function Cleanup-Jobs {
    param($WebJob, $SensorsJob)
    
    Write-ColorMessage "🧹 Limpiando procesos..." $YELLOW
    
    if ($SensorsJob) {
        Stop-Job $SensorsJob -Force -ErrorAction SilentlyContinue
        Remove-Job $SensorsJob -Force -ErrorAction SilentlyContinue
    }
    
    if ($WebJob) {
        Stop-Job $WebJob -Force -ErrorAction SilentlyContinue
        Remove-Job $WebJob -Force -ErrorAction SilentlyContinue
    }
    
    # Intentar cerrar procesos Python relacionados
    try {
        Get-Process -Name python -ErrorAction SilentlyContinue | Where-Object {
            $_.ProcessName -eq "python" -and $_.Path -like "*$SCRIPT_DIR*"
        } | Stop-Process -Force -ErrorAction SilentlyContinue
    } catch {
        # Ignorar errores
    }
}

# ============================================================================
# FUNCIÓN PRINCIPAL
# ============================================================================

function Main {
    Write-Banner "SISTEMA DE MONITOREO DE ESTACIÓN DE BOMBEO"
    Write-ColorMessage "🚀 Iniciando sistema completo..." $GREEN
    Write-Host ""
    
    # Variables para trabajos en segundo plano
    $webJob = $null
    $sensorsJob = $null
    
    try {
        # 1. Verificar entorno Python
        if (-not (Test-PythonEnvironment)) {
            Write-ColorMessage "❌ Error en configuración de Python" $RED
            exit 1
        }
        
        # 2. Instalar dependencias
        if (-not (Install-Dependencies)) {
            Write-ColorMessage "❌ Error al instalar dependencias" $RED
            exit 1
        }
        
        # 3. Inicializar base de datos (si no se omite)
        if (-not $SkipDatabase) {
            if (-not (Initialize-Database)) {
                Write-ColorMessage "❌ Error al inicializar base de datos" $RED
                exit 1
            }
        }
        
        # 4. Iniciar aplicación web (si no se omite)
        if (-not $SkipWeb) {
            $webJob = Start-WebApplication
            if (-not $webJob) {
                Write-ColorMessage "❌ Error al iniciar aplicación web" $RED
                exit 1
            }
        }
        
        # 5. Iniciar sensores virtuales (si no se omite)
        if (-not $SkipSensors) {
            $sensorsJob = Start-VirtualSensors
            if (-not $sensorsJob) {
                Write-ColorMessage "⚠️  Sensores virtuales no se iniciaron correctamente" $YELLOW
            }
        }
        
        # 6. Mostrar estado del sistema
        Show-SystemStatus $webJob $sensorsJob
        
        # 7. Esperar entrada del usuario o señal de interrupción
        $continue = Wait-ForUserInput $webJob $sensorsJob
        
    } catch [System.Management.Automation.RuntimeException] {
        if ($_.Exception.Message -like "*canceled*") {
            Write-ColorMessage "`n🛑 Proceso interrumpido por el usuario" $YELLOW
        } else {
            Write-ColorMessage "`n❌ Error inesperado: $($_.Exception.Message)" $RED
        }
    } finally {
        # Limpieza final
        Cleanup-Jobs $webJob $sensorsJob
        Write-ColorMessage "✅ Sistema detenido correctamente" $GREEN
    }
}

# ============================================================================
# MANEJO DE SEÑALES E INICIO
# ============================================================================

# Manejar Ctrl+C
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Write-Host "`n🛑 Deteniendo sistema..." -ForegroundColor Yellow
}

# Mostrar ayuda si se solicita
if ($args -contains "-h" -or $args -contains "--help") {
    Write-Host "=== SISTEMA DE MONITOREO DE ESTACIÓN DE BOMBEO ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Uso: .\iniciar_sistema_completo_nuevo.ps1 [opciones]" -ForegroundColor Green
    Write-Host ""
    Write-Host "Opciones:" -ForegroundColor Yellow
    Write-Host "  -SkipDatabase      Omitir inicialización de base de datos"
    Write-Host "  -SkipSensors       Omitir inicio de sensores virtuales"
    Write-Host "  -SkipWeb           Omitir inicio de aplicación web"
    Write-Host "  -ResetData         Recrear base de datos desde cero"
    Write-Host "  -Port <numero>     Puerto para la aplicación web (default: 5000)"
    Write-Host ""
    Write-Host "Ejemplos:" -ForegroundColor Green
    Write-Host "  .\iniciar_sistema_completo_nuevo.ps1"
    Write-Host "  .\iniciar_sistema_completo_nuevo.ps1 -Port 8080"
    Write-Host "  .\iniciar_sistema_completo_nuevo.ps1 -ResetData"
    Write-Host "  .\iniciar_sistema_completo_nuevo.ps1 -SkipSensors"
    exit 0
}

# Iniciar sistema principal
Main
