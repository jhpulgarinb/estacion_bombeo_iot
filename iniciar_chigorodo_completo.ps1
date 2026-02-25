# ============================================================================
# SISTEMA DE MONITOREO RÍO LEÓN - CHIGORODÓ, ANTIOQUIA
# Script de inicio automático específico para Finca La Plana
# Simulación avanzada de niveles freáticos y patrones tropicales
# ============================================================================

param(
    [switch]$SkipDatabase,
    [switch]$SkipSensors,
    [switch]$SkipWeb,
    [switch]$ResetData,
    [switch]$UseTestData,  # Usar datos de prueba generales en lugar de Chigorodó
    [int]$Port = 5000
)

# Configuración específica
$SCRIPT_DIR = Get-Location
$VENV_PATH = "$SCRIPT_DIR\venv"
$PYTHON_EXE = "$VENV_PATH\Scripts\python.exe"
$LOG_DIR = "$SCRIPT_DIR\logs"
$DATABASE_FILE = "$SCRIPT_DIR\monitoring.db"

# Colores para mensajes
$BLUE = "Cyan"
$GREEN = "Green" 
$YELLOW = "Yellow"
$RED = "Red"
$MAGENTA = "Magenta"

# ============================================================================
# FUNCIONES ESPECÍFICAS PARA CHIGORODÓ
# ============================================================================

function Write-ChigorodoBanner {
    Write-Host ""
    Write-Host "=" * 80 -ForegroundColor $BLUE
    Write-Host "🌊 SISTEMA DE MONITOREO RÍO LEÓN - CHIGORODÓ 🌊" -ForegroundColor $BLUE
    Write-Host "   📍 Finca La Plana - Antioquia, Colombia" -ForegroundColor $BLUE
    Write-Host "   🏞️  Simulación Avanzada de Niveles Freáticos" -ForegroundColor $BLUE
    Write-Host "   ⛈️  Patrones Climáticos de Urabá Específicos" -ForegroundColor $BLUE
    Write-Host "=" * 80 -ForegroundColor $BLUE
    Write-Host ""
}

function Write-ColorMessage {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-PythonEnvironment {
    Write-ColorMessage "🔍 Verificando entorno Python para Chigorodó..." $YELLOW
    
    if (-not (Test-Path $VENV_PATH)) {
        Write-ColorMessage "❌ Entorno virtual no encontrado. Creando..." $RED
        Write-ColorMessage "   📁 Ubicación: $VENV_PATH" $YELLOW
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

function Install-ChigorodoDependencies {
    Write-ColorMessage "📦 Instalando dependencias específicas para Chigorodó..." $YELLOW
    
    if (-not (Test-Path "requirements.txt")) {
        Write-ColorMessage "❌ Archivo requirements.txt no encontrado" $RED
        return $false
    }
    
    try {
        Write-ColorMessage "   ⬆️  Actualizando pip..." $YELLOW
        & $PYTHON_EXE -m pip install --upgrade pip --quiet
        
        Write-ColorMessage "   📊 Instalando librerías para análisis hidrológico..." $YELLOW
        & $PYTHON_EXE -m pip install -r requirements.txt --quiet
        
        # Dependencias adicionales específicas para Chigorodó
        Write-ColorMessage "   🌡️  Instalando librerías climáticas adicionales..." $YELLOW
        & $PYTHON_EXE -m pip install numpy scipy --quiet
        
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

function Initialize-ChigorodoDatabase {
    Write-ColorMessage "🗄️  Inicializando base de datos específica para Chigorodó..." $YELLOW
    
    if ($ResetData -and (Test-Path $DATABASE_FILE)) {
        Write-ColorMessage "🗑️  Eliminando base de datos existente..." $YELLOW
        Remove-Item $DATABASE_FILE -Force
    }
    
    $needsInitialization = (-not (Test-Path $DATABASE_FILE)) -or $ResetData
    
    if ($needsInitialization) {
        if ($UseTestData) {
            Write-ColorMessage "📊 Inicializando con datos de prueba generales..." $YELLOW
            try {
                & $PYTHON_EXE initialize_test_data.py
            } catch {
                Write-ColorMessage "⚠️  Error con datos generales, usando datos de Chigorodó..." $YELLOW
                & $PYTHON_EXE initialize_chigorodo_data.py
            }
        } else {
            Write-ColorMessage "🏞️  Inicializando con datos específicos de Río León..." $YELLOW
            Write-ColorMessage "   📍 Ubicación: Chigorodó, Antioquia" $BLUE
            Write-ColorMessage "   🌊 Cuenca: Río León - Subcuenca del Atrato" $BLUE
            Write-ColorMessage "   🌧️  Patrones: Clima tropical de Urabá" $BLUE
            
            try {
                & $PYTHON_EXE initialize_chigorodo_data.py
                if ($LASTEXITCODE -ne 0) {
                    throw "Error en inicialización específica"
                }
            } catch {
                Write-ColorMessage "⚠️  Error con datos de Chigorodó, usando datos generales..." $YELLOW
                & $PYTHON_EXE initialize_test_data.py
            }
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorMessage "✅ Base de datos inicializada con datos de Río León" $GREEN
            return $true
        } else {
            Write-ColorMessage "❌ Error al inicializar base de datos" $RED
            return $false
        }
    } else {
        Write-ColorMessage "✅ Base de datos existente encontrada" $GREEN
        return $true
    }
}

function Start-ChigorodoWebApplication {
    Write-ColorMessage "🌐 Iniciando aplicación web para monitoreo de Río León..." $YELLOW
    
    try {
        $env:FLASK_APP = "app.py"
        $env:FLASK_ENV = "development"
        
        # Iniciar Flask con configuración específica para Chigorodó
        $webJob = Start-Job -ScriptBlock {
            param($PythonPath, $Port, $ScriptDir)
            Set-Location $ScriptDir
            $env:FLASK_APP = "app.py"
            $env:FLASK_ENV = "development"
            $env:CHIGORODO_MODE = "true"  # Variable específica
            
            & $PythonPath -c "
import os
import sys
sys.path.append('.')

# Configuración específica para Chigorodó
os.environ['FLASK_APP'] = 'app.py'
os.environ['FLASK_ENV'] = 'development'
os.environ['CHIGORODO_MODE'] = 'true'

print('🌊 Iniciando servidor web - Río León, Chigorodó')
print(f'📍 Puerto: $Port')
print(f'🏞️  Modo: Chigorodó Específico')

from app import app
app.run(host='0.0.0.0', port=$Port, debug=False, use_reloader=False)
" 2>&1
        } -ArgumentList $PYTHON_EXE, $Port, $SCRIPT_DIR
        
        # Esperar inicio
        Start-Sleep -Seconds 4
        
        # Verificar que esté corriendo
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$Port" -TimeoutSec 8 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-ColorMessage "✅ Aplicación web iniciada para Río León" $GREEN
                Write-ColorMessage "   🔗 URL: http://localhost:$Port" $BLUE
                return $webJob
            }
        } catch {
            Write-ColorMessage "⚠️  Aplicación web iniciándose (Río León)..." $YELLOW
            return $webJob
        }
        
        return $webJob
        
    } catch {
        Write-ColorMessage "❌ Error al iniciar aplicación web: $_" $RED
        return $null
    }
}

function Start-ChigorodoVirtualSensors {
    Write-ColorMessage "🔧 Iniciando sensores virtuales específicos de Río León..." $YELLOW
    Write-ColorMessage "   🌊 Sensores de nivel freático" $BLUE
    Write-ColorMessage "   🌧️  Patrones de precipitación de Urabá" $BLUE
    Write-ColorMessage "   🏞️  Simulación de caudales tropicales" $BLUE
    
    try {
        # Esperar que la aplicación web esté lista
        $maxRetries = 15
        $retries = 0
        $webReady = $false
        
        while (-not $webReady -and $retries -lt $maxRetries) {
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:$Port" -TimeoutSec 3 -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
                    $webReady = $true
                }
            } catch {
                $retries++
                Write-ColorMessage "   ⏳ Esperando aplicación web ($retries/$maxRetries)..." $YELLOW
                Start-Sleep -Seconds 2
            }
        }
        
        if (-not $webReady) {
            Write-ColorMessage "⚠️  Aplicación web no responde, iniciando sensores..." $YELLOW
        }
        
        # Verificar si existe el archivo de sensores específicos
        if (Test-Path "sensores_rio_leon.py") {
            Write-ColorMessage "   🎯 Usando sensores específicos de Río León..." $GREEN
            
            $sensorsJob = Start-Job -ScriptBlock {
                param($PythonPath, $ScriptDir)
                Set-Location $ScriptDir
                
                Write-Output "🌊 === SENSORES VIRTUALES RÍO LEÓN ==="
                Write-Output "📍 Ubicación: Chigorodó, Antioquia"
                Write-Output "🏞️  Finca La Plana - Estaciones Específicas"
                Write-Output "🔧 Iniciando simulación avanzada..."
                
                & $PythonPath sensores_rio_leon.py 2>&1
            } -ArgumentList $PYTHON_EXE, $SCRIPT_DIR
        } else {
            Write-ColorMessage "   ⚠️  Sensores de Río León no encontrados, usando generales..." $YELLOW
            
            $sensorsJob = Start-Job -ScriptBlock {
                param($PythonPath, $ScriptDir)
                Set-Location $ScriptDir
                & $PythonPath virtual_sensors.py 2>&1
            } -ArgumentList $PYTHON_EXE, $SCRIPT_DIR
        }
        
        Start-Sleep -Seconds 3
        
        if ($sensorsJob.State -eq "Running") {
            Write-ColorMessage "✅ Sensores virtuales de Río León activos" $GREEN
            return $sensorsJob
        } else {
            Write-ColorMessage "❌ Error al iniciar sensores virtuales" $RED
            return $null
        }
        
    } catch {
        Write-ColorMessage "❌ Error al iniciar sensores: $_" $RED
        return $null
    }
}

function Show-ChigorodoSystemStatus {
    param($WebJob, $SensorsJob)
    
    Write-Host ""
    Write-Host "=" * 70 -ForegroundColor $BLUE
    Write-Host "📊 ESTADO DEL SISTEMA - RÍO LEÓN" -ForegroundColor $BLUE
    Write-Host "=" * 70 -ForegroundColor $BLUE
    
    # Estado de base de datos
    Write-ColorMessage "🗄️  Base de datos: " -NoNewline
    if (Test-Path $DATABASE_FILE) {
        Write-ColorMessage "✅ Activa (Datos de Chigorodó)" $GREEN
        $dbSize = (Get-Item $DATABASE_FILE).Length / 1KB
        Write-ColorMessage "   📊 Tamaño: $([math]::Round($dbSize, 2)) KB"
        
        # Intentar obtener estadísticas básicas de la BD
        try {
            $stationCount = & $PYTHON_EXE -c "
from app import app
from database import PumpingStation
with app.app_context():
    count = PumpingStation.query.count()
    if count > 0:
        stations = PumpingStation.query.all()
        for station in stations:
            print(f'   🏭 {station.name}')
    else:
        print('   ⚠️  No hay estaciones configuradas')
" 2>$null
            if ($stationCount) {
                Write-Output $stationCount
            }
        } catch {
            Write-ColorMessage "   ⚠️  No se pueden leer estadísticas de BD" $YELLOW
        }
    } else {
        Write-ColorMessage "❌ No encontrada" $RED
    }
    
    # Estado de aplicación web
    Write-ColorMessage "🌐 Aplicación web: " -NoNewline
    if ($WebJob -and $WebJob.State -eq "Running") {
        Write-ColorMessage "✅ Activa en http://localhost:$Port" $GREEN
        Write-ColorMessage "   🎯 Modo: Chigorodó - Río León específico"
    } else {
        Write-ColorMessage "❌ No está corriendo" $RED
    }
    
    # Estado de sensores
    Write-ColorMessage "🔧 Sensores virtuales: " -NoNewline
    if ($SensorsJob -and $SensorsJob.State -eq "Running") {
        Write-ColorMessage "✅ Activos (Río León)" $GREEN
        Write-ColorMessage "   🌊 Simulando niveles freáticos"
        Write-ColorMessage "   🌧️  Patrones climáticos de Urabá"
        Write-ColorMessage "   🏞️  Caudales específicos del río"
    } else {
        Write-ColorMessage "❌ No están activos" $RED
    }
    
    Write-Host ""
    Write-ColorMessage "🎯 INFORMACIÓN ESPECÍFICA DE CHIGORODÓ:" $BLUE
    Write-ColorMessage "   📍 Municipio: Chigorodó, Antioquia"
    Write-ColorMessage "   🏞️  Cuenca: Río León - Subcuenca del Atrato"
    Write-ColorMessage "   🌡️  Clima: Tropical húmedo de bosque muy húmedo"
    Write-ColorMessage "   🌧️  Precipitación: ~2,800 mm/año"
    Write-ColorMessage "   📏 Coordenadas: 7.6667°N, 76.6833°W"
    
    Write-Host ""
    Write-ColorMessage "🔗 URLS IMPORTANTES:" $BLUE
    Write-ColorMessage "   • Dashboard Río León: http://localhost:$Port"
    Write-ColorMessage "   • API datos: http://localhost:$Port/api/data"
    Write-ColorMessage "   • API dashboard: http://localhost:$Port/api/dashboard"
    
    Write-Host ""
}

function Wait-ForChigorodoInput {
    param($WebJob, $SensorsJob)
    
    Write-ColorMessage "💡 Sistema Río León activo. Opciones:" $YELLOW
    Write-ColorMessage "   [S] - Estado del sistema Chigorodó"
    Write-ColorMessage "   [L] - Logs de sensores en tiempo real"
    Write-ColorMessage "   [R] - Reiniciar sensores de Río León"
    Write-ColorMessage "   [O] - Abrir dashboard en navegador"
    Write-ColorMessage "   [C] - Información climática actual"
    Write-ColorMessage "   [Q] - Detener sistema"
    Write-Host ""
    Write-ColorMessage "Presiona una tecla o Ctrl+C para salir..." $GREEN
    
    while ($true) {
        if ([System.Console]::KeyAvailable) {
            $key = [System.Console]::ReadKey($true)
            
            switch ($key.KeyChar.ToString().ToUpper()) {
                'S' { 
                    Show-ChigorodoSystemStatus $WebJob $SensorsJob
                    Write-ColorMessage "Presiona otra tecla para continuar..." $YELLOW
                }
                'L' { 
                    Write-ColorMessage "📝 Logs de sensores Río León (últimos)..." $YELLOW
                    try {
                        if ($SensorsJob) {
                            $logs = Receive-Job $SensorsJob -Keep | Select-Object -Last 25
                            if ($logs) {
                                $logs | ForEach-Object { 
                                    if ($_ -match "ERROR") {
                                        Write-Host $_ -ForegroundColor Red
                                    } elseif ($_ -match "Sensor.*León") {
                                        Write-Host $_ -ForegroundColor Green
                                    } else {
                                        Write-Host $_
                                    }
                                }
                            } else {
                                Write-ColorMessage "No hay logs disponibles aún" $YELLOW
                            }
                        }
                    } catch {
                        Write-ColorMessage "Error al obtener logs" $RED
                    }
                }
                'R' { 
                    Write-ColorMessage "🔄 Reiniciando sensores de Río León..." $YELLOW
                    if ($SensorsJob) {
                        Stop-Job $SensorsJob -Force -ErrorAction SilentlyContinue
                        Remove-Job $SensorsJob -Force -ErrorAction SilentlyContinue
                    }
                    $SensorsJob = Start-ChigorodoVirtualSensors
                    Write-ColorMessage "✅ Sensores reiniciados" $GREEN
                }
                'O' { 
                    Write-ColorMessage "🌐 Abriendo dashboard de Río León..." $YELLOW
                    Start-Process "http://localhost:$Port"
                }
                'C' {
                    Write-ColorMessage "🌡️  INFORMACIÓN CLIMÁTICA ACTUAL:" $BLUE
                    $month = (Get-Date).Month
                    $hour = (Get-Date).Hour
                    
                    # Determinar época del año
                    if ($month -in @(1,2,7,8)) {
                        $season = "Época seca (veranillo)"
                        $rainfall = "Baja precipitación"
                    } elseif ($month -in @(4,5,9,10,11)) {
                        $season = "Época lluviosa"
                        $rainfall = "Alta precipitación"
                    } else {
                        $season = "Época de transición"
                        $rainfall = "Precipitación moderada"
                    }
                    
                    Write-ColorMessage "   📅 Mes actual: $(Get-Date -Format 'MMMM')"
                    Write-ColorMessage "   🌦️  Época: $season"
                    Write-ColorMessage "   🌧️  Precipitación: $rainfall"
                    Write-ColorMessage "   🕒 Hora: $hour`:00 (Patrón tropical)"
                    
                    if ($hour -ge 14 -and $hour -le 18) {
                        Write-ColorMessage "   ⛈️  Probabilidad de lluvias: ALTA (tarde tropical)" $YELLOW
                    } elseif ($hour -ge 20 -or $hour -le 6) {
                        Write-ColorMessage "   🌙 Probabilidad de lluvias: Media (noche)" $BLUE
                    } else {
                        Write-ColorMessage "   ☀️  Probabilidad de lluvias: Baja (mañana)" $GREEN
                    }
                }
                'Q' { 
                    Write-ColorMessage "🛑 Deteniendo sistema Río León..." $YELLOW
                    return $false
                }
            }
        }
        
        Start-Sleep -Milliseconds 150
    }
}

function Cleanup-ChigorodoJobs {
    param($WebJob, $SensorsJob)
    
    Write-ColorMessage "🧹 Deteniendo componentes de Río León..." $YELLOW
    
    if ($SensorsJob) {
        Stop-Job $SensorsJob -Force -ErrorAction SilentlyContinue
        Remove-Job $SensorsJob -Force -ErrorAction SilentlyContinue
    }
    
    if ($WebJob) {
        Stop-Job $WebJob -Force -ErrorAction SilentlyContinue
        Remove-Job $WebJob -Force -ErrorAction SilentlyContinue
    }
    
    # Limpiar procesos específicos
    try {
        Get-Process -Name python -ErrorAction SilentlyContinue | Where-Object {
            $_.ProcessName -eq "python" -and $_.Path -like "*$SCRIPT_DIR*"
        } | Stop-Process -Force -ErrorAction SilentlyContinue
    } catch {
        # Ignorar errores de limpieza
    }
}

# ============================================================================
# FUNCIÓN PRINCIPAL PARA CHIGORODÓ
# ============================================================================

function Main-Chigorodo {
    Write-ChigorodoBanner
    Write-ColorMessage "🚀 Iniciando sistema completo de Río León..." $GREEN
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
        
        # 2. Instalar dependencias específicas
        if (-not (Install-ChigorodoDependencies)) {
            Write-ColorMessage "❌ Error al instalar dependencias" $RED
            exit 1
        }
        
        # 3. Inicializar base de datos específica (si no se omite)
        if (-not $SkipDatabase) {
            if (-not (Initialize-ChigorodoDatabase)) {
                Write-ColorMessage "❌ Error al inicializar base de datos de Chigorodó" $RED
                exit 1
            }
        }
        
        # 4. Iniciar aplicación web (si no se omite)
        if (-not $SkipWeb) {
            $webJob = Start-ChigorodoWebApplication
            if (-not $webJob) {
                Write-ColorMessage "❌ Error al iniciar aplicación web" $RED
                exit 1
            }
        }
        
        # 5. Iniciar sensores virtuales específicos (si no se omite)
        if (-not $SkipSensors) {
            $sensorsJob = Start-ChigorodoVirtualSensors
            if (-not $sensorsJob) {
                Write-ColorMessage "⚠️  Sensores virtuales no se iniciaron correctamente" $YELLOW
            }
        }
        
        # 6. Mostrar estado del sistema
        Show-ChigorodoSystemStatus $webJob $sensorsJob
        
        # 7. Esperar entrada del usuario
        $continue = Wait-ForChigorodoInput $webJob $sensorsJob
        
    } catch [System.Management.Automation.RuntimeException] {
        if ($_.Exception.Message -like "*canceled*") {
            Write-ColorMessage "`n🛑 Sistema Río León interrumpido por el usuario" $YELLOW
        } else {
            Write-ColorMessage "`n❌ Error inesperado en sistema Chigorodó: $($_.Exception.Message)" $RED
        }
    } finally {
        # Limpieza final
        Cleanup-ChigorodoJobs $webJob $sensorsJob
        Write-ColorMessage "✅ Sistema Río León detenido correctamente" $GREEN
    }
}

# ============================================================================
# MANEJO DE PARÁMETROS Y AYUDA
# ============================================================================

if ($args -contains "-h" -or $args -contains "--help") {
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host "🌊 SISTEMA DE MONITOREO RÍO LEÓN - CHIGORODÓ 🌊" -ForegroundColor Cyan
    Write-Host "   📍 Finca La Plana, Antioquia - Simulación Específica" -ForegroundColor Cyan
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Uso: .\iniciar_chigorodo_completo.ps1 [opciones]" -ForegroundColor Green
    Write-Host ""
    Write-Host "Opciones específicas:" -ForegroundColor Yellow
    Write-Host "  -SkipDatabase      Omitir inicialización de base de datos"
    Write-Host "  -SkipSensors       Omitir sensores virtuales de Río León"
    Write-Host "  -SkipWeb           Omitir aplicación web"
    Write-Host "  -ResetData         Recrear base de datos desde cero"
    Write-Host "  -UseTestData       Usar datos generales en lugar de Chigorodó"
    Write-Host "  -Port <numero>     Puerto para aplicación web (default: 5000)"
    Write-Host ""
    Write-Host "Características específicas de Chigorodó:" -ForegroundColor Blue
    Write-Host "  🌊 Sensores de nivel freático específicos"
    Write-Host "  🌧️  Patrones de precipitación de Urabá"
    Write-Host "  🏞️  Caudales del río León simulados"
    Write-Host "  📍 Coordenadas reales de Finca La Plana"
    Write-Host "  🌡️  Clima tropical húmedo específico"
    Write-Host ""
    Write-Host "Ejemplos:" -ForegroundColor Green
    Write-Host "  .\iniciar_chigorodo_completo.ps1"
    Write-Host "  .\iniciar_chigorodo_completo.ps1 -Port 8080"
    Write-Host "  .\iniciar_chigorodo_completo.ps1 -ResetData"
    Write-Host "  .\iniciar_chigorodo_completo.ps1 -UseTestData"
    Write-Host ""
    exit 0
}

# ============================================================================
# INICIAR SISTEMA PRINCIPAL
# ============================================================================

# Manejar Ctrl+C
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Write-Host "`n🛑 Deteniendo sistema Río León..." -ForegroundColor Yellow
}

# Iniciar sistema principal de Chigorodó
Main-Chigorodo
