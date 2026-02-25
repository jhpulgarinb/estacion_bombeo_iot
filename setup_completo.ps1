<#
.SYNOPSIS
    Script de Instalación y Configuración Completa
    Sistema IoT de Estación de Bombeo
    
.DESCRIPTION
    Este script realiza la instalación completa del sistema:
    1. Verifica/instala Python
    2. Crea entorno virtual
    3. Instala dependencias
    4. Inicializa base de datos SQLite
    5. Configura simulador Wokwi
    6. Lanza el sistema completo
    
.NOTES
    Promotora Palmera de Antioquia S.A.S.
    Fecha: 20 de febrero de 2026
#>

param(
    [switch]$SkipPythonInstall,
    [switch]$OnlyDatabase,
    [switch]$OnlySimulator,
    [switch]$FullSetup
)

$ErrorActionPreference = "Continue"
$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Colores
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Header {
    param([string]$Title)
    Write-Host "`n" -NoNewline
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error2 {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning2 {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

# ============================================================
# PASO 1: VERIFICAR/INSTALAR PYTHON
# ============================================================

function Test-PythonInstalled {
    Write-Header "Verificando Python"
    
    # Intentar encontrar Python en varias ubicaciones
    $pythonPaths = @(
        "python",
        "py",
        "C:\Python312\python.exe",
        "C:\Python311\python.exe",
        "C:\Python310\python.exe",
        "C:\Python39\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python310\python.exe"
    )
    
    foreach ($pythonPath in $pythonPaths) {
        try {
            $version = &amp; $pythonPath --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Python encontrado: $version"
                Write-Info "Ubicación: $pythonPath"
                return $pythonPath
            }
        } catch {
            continue
        }
    }
    
    Write-Warning2 "Python no encontrado en el sistema"
    return $null
}

function Install-Python {
    Write-Header "Instalación de Python"
    
    Write-Info "Descargando Python 3.11.8 (64-bit)..."
    $pythonInstaller = "$env:TEMP\python-3.11.8-amd64.exe"
    $pythonUrl = "https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe"
    
    try {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller -UseBasicParsing
        Write-Success "Descarga completada"
        
        Write-Info "Instalando Python (esto puede tomar varios minutos)..."
        Write-Warning2 "IMPORTANTE: Seleccionar 'Add Python to PATH' durante instalación"
        
        Start-Process -FilePath $pythonInstaller `
                      -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1", "Include_test=0" `
                      -Wait
        
        Write-Success "Python instalado correctamente"
        Write-Warning2 "Por favor, REINICIE PowerShell y ejecute este script nuevamente"
        
        Remove-Item $pythonInstaller -Force -ErrorAction SilentlyContinue
        
        Read-Host "Presione Enter para cerrar..."
        exit 0
        
    } catch {
        Write-Error2 "Error al descargar/instalar Python: $_"
        Write-Info "Por favor, descargue manualmente desde: https://www.python.org/downloads/"
        return $false
    }
}

# ============================================================
# PASO 2: CREAR ENTORNO VIRTUAL
# ============================================================

function Initialize-VirtualEnvironment {
    param([string]$PythonPath)
    
    Write-Header "Configurando Entorno Virtual"
    
    $venvPath = Join-Path $projectPath "venv"
    
    if (Test-Path $venvPath) {
        Write-Info "Entorno virtual ya existe"
    } else {
        Write-Info "Creando entorno virtual..."
        &amp; $PythonPath -m venv $venvPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Entorno virtual creado: $venvPath"
        } else {
            Write-Error2 "Error al crear entorno virtual"
            return $false
        }
    }
    
    # Activar entorno virtual
    $activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
    
    if (Test-Path $activateScript) {
        Write-Info "Activando entorno virtual..."
        &amp; $activateScript
        Write-Success "Entorno virtual activado"
        return $true
    } else {
        Write-Error2 "Script de activación no encontrado"
        return $false
    }
}

# ============================================================
# PASO 3: INSTALAR DEPENDENCIAS
# ============================================================

function Install-Dependencies {
    Write-Header "Instalando Dependencias Python"
    
    $requirementsFile = Join-Path $projectPath "requirements.txt"
    
    if (-not (Test-Path $requirementsFile)) {
        Write-Warning2 "requirements.txt no encontrado, creando..."
        
        $requirements = @"
flask==3.0.0
flask-cors==4.0.0
flask-sqlalchemy==3.1.1
requests==2.31.0
sqlalchemy==2.0.23
"@
        Set-Content -Path $requirementsFile -Value $requirements
        Write-Success "requirements.txt creado"
    }
    
    Write-Info "Instalando paquetes..."
    python -m pip install --upgrade pip --quiet
    python -m pip install -r $requirementsFile --quiet
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Dependencias instaladas correctamente"
        return $true
    } else {
        Write-Error2 "Error al instalar dependencias"
        return $false
    }
}

# ============================================================
# PASO 4: INICIALIZAR BASE DE DATOS
# ============================================================

function Initialize-DatabaseWithPython {
    Write-Header "Inicializando Base de Datos (Python)"
    
    $initScript = Join-Path $projectPath "init_database.py"
    
    if (Test-Path $initScript) {
        Write-Info "Ejecutando init_database.py..."
        python $initScript
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Base de datos inicializada con Python"
            return $true
        } else {
            Write-Warning2 "Error al inicializar con Python, intentando con SQLite3..."
            return $false
        }
    } else {
        Write-Warning2 "init_database.py no encontrado"
        return $false
    }
}

function Initialize-DatabaseWithSQLite {
    Write-Header "Inicializando Base de Datos (SQLite3)"
    
    $sqlFile = Join-Path $projectPath "init_database.sql"
    $dbFile = Join-Path $projectPath "monitoring.db"
    
    if (-not (Test-Path $sqlFile)) {
        Write-Error2 "init_database.sql no encontrado"
        return $false
    }
    
    # Verificar si sqlite3 está disponible
    try {
        $sqliteVersion = sqlite3 --version 2>&1
        Write-Info "SQLite3 encontrado: $sqliteVersion"
    } catch {
        Write-Warning2 "SQLite3 no encontrado en PATH"
        Write-Info "Intentando con Python SQLite..."
        
        # Usar Python para ejecutar el SQL
        $pythonSqlScript = @"
import sqlite3
import os

db_path = r'$dbFile'
sql_file = r'$sqlFile'

# Eliminar DB existente si hay problemas
if os.path.exists(db_path):
    print(f'⚠️  Base de datos existente encontrada: {db_path}')
    backup = db_path + '.backup'
    os.rename(db_path, backup)
    print(f'✅ Backup creado: {backup}')

# Crear base de datos
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Leer y ejecutar SQL
with open(sql_file, 'r', encoding='utf-8') as f:
    sql_script = f.read()
    cursor.executescript(sql_script)

conn.commit()
conn.close()

print('✅ Base de datos creada correctamente')
"@
        
        $tempPyScript = Join-Path $env:TEMP "create_db.py"
        Set-Content -Path $tempPyScript -Value $pythonSqlScript
        
        python $tempPyScript
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Base de datos inicializada con Python SQLite"
            Remove-Item $tempPyScript -Force -ErrorAction SilentlyContinue
            return $true
        } else {
            Write-Error2 "Error al inicializar base de datos"
            return $false
        }
    }
    
    # Si SQLite3 está disponible, usarlo
    Write-Info "Creando base de datos con SQLite3..."
    
    if (Test-Path $dbFile) {
        $backupFile = $dbFile + ".backup"
        Copy-Item $dbFile $backupFile -Force
        Write-Info "Backup creado: $backupFile"
        Remove-Item $dbFile -Force
    }
    
    Get-Content $sqlFile | sqlite3 $dbFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Base de datos creada: $dbFile"
        return $true
    } else {
        Write-Error2 "Error al ejecutar SQL"
        return $false
    }
}

function Initialize-Database {
    $dbFile = Join-Path $projectPath "monitoring.db"
    
    if (Test-Path $dbFile) {
        Write-Info "Base de datos ya existe: $dbFile"
        
        $response = Read-Host "¿Recrear base de datos? (S/N)"
        if ($response -ne "S" -and $response -ne "s") {
            Write-Info "Manteniendo base de datos existente"
            return $true
        }
    }
    
    # Intentar primero con Python
    $success = Initialize-DatabaseWithPython
    
    if (-not $success) {
        # Si falla, intentar con SQLite3
        $success = Initialize-DatabaseWithSQLite
    }
    
    if ($success -and (Test-Path $dbFile)) {
        $fileSize = (Get-Item $dbFile).Length / 1KB
        Write-Success "Base de datos verificada (tamaño: $([Math]::Round($fileSize, 2)) KB)"
        return $true
    } else {
        Write-Error2 "No se pudo inicializar la base de datos"
        return $false
    }
}

# ============================================================
# PASO 5: CONFIGURAR SIMULADOR WOKWI
# ============================================================

function Show-WokwiInstructions {
    Write-Header "Configuración del Simulador Wokwi"
    
    $wokwiPath = Join-Path $projectPath "wokwi_esp32_simulator"
    
    if (Test-Path $wokwiPath) {
        Write-Success "Archivos de Wokwi encontrados: $wokwiPath"
        
        Write-Info "Para usar el simulador Wokwi:"
        Write-Host "  1. Visitar: " -NoNewline -ForegroundColor White
        Write-Host "https://wokwi.com/" -ForegroundColor Cyan
        
        Write-Host "  2. Crear nuevo proyecto ESP32" -ForegroundColor White
        
        Write-Host "  3. Copiar contenido de:" -ForegroundColor White
        Write-Host "     • $wokwiPath\diagram.json → Editor de diagrama" -ForegroundColor Gray
        Write-Host "     • $wokwiPath\sketch.ino → Editor de código" -ForegroundColor Gray
        
        Write-Host "  4. IMPORTANTE: Editar línea 17 de sketch.ino" -ForegroundColor Yellow
        
        # Obtener IP local
        $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like "*Ethernet*" -or $_.InterfaceAlias -like "*Wi-Fi*"} | Select-Object -First 1).IPAddress
        
        if ($localIP) {
            Write-Host "     Cambiar: " -NoNewline -ForegroundColor White
            Write-Host 'const char* serverURL = "http://192.168.1.100:5000/api";' -ForegroundColor Red
            Write-Host "     Por:     " -NoNewline -ForegroundColor White
            Write-Host "const char* serverURL = `"http://${localIP}:5000/api`";" -ForegroundColor Green
        }
        
        Write-Host "`n  5. Clic en 'Start Simulation' en Wokwi" -ForegroundColor White
        
        Write-Host "`n  6. Leer documentación completa: " -NoNewline -ForegroundColor White
        Write-Host "$wokwiPath\README_WOKWI.md" -ForegroundColor Cyan
        
    } else {
        Write-Warning2 "Directorio de Wokwi no encontrado: $wokwiPath"
    }
}

# ============================================================
# PASO 6: EJECUTAR SISTEMA
# ============================================================

function Start-FlaskServer {
    Write-Header "Iniciando Servidor Flask"
    
    $appFile = Join-Path $projectPath "app.py"
    
    if (-not (Test-Path $appFile)) {
        Write-Error2 "app.py no encontrado"
        return $false
    }
    
    Write-Info "Iniciando Flask en http://localhost:5000"
    Write-Warning2 "Presione Ctrl+C para detener el servidor"
    Write-Host ""
    
    Start-Process -FilePath "python" -ArgumentList $appFile -NoNewWindow
    
    Start-Sleep -Seconds 3
    
    # Verificar si el servidor inició
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Success "Servidor Flask iniciado correctamente"
            Write-Info "Dashboard: http://localhost:5000"
            return $true
        }
    } catch {
        Write-Warning2 "No se pudo verificar el servidor (puede estar iniciando...)"
        return $true
    }
}

function Start-PythonSimulator {
    Write-Header "Iniciando Simulador Python"
    
    $simFile = Join-Path $projectPath "simulator_extended.py"
    
    if (-not (Test-Path $simFile)) {
        Write-Error2 "simulator_extended.py no encontrado"
        return $false
    }
    
    Write-Info "Iniciando simulador..."
    Write-Warning2 "El simulador enviará datos cada 10 segundos"
    Write-Warning2 "Presione Ctrl+C para detener"
    Write-Host ""
    
    python $simFile
}

function Show-StartupMenu {
    Write-Header "Opciones de Inicio"
    
    Write-Host "1. Iniciar SOLO el servidor Flask (API + Dashboard)" -ForegroundColor White
    Write-Host "2. Iniciar SOLO el simulador Python" -ForegroundColor White
    Write-Host "3. Iniciar AMBOS (Servidor + Simulador)" -ForegroundColor Green
    Write-Host "4. Ver instrucciones de Wokwi" -ForegroundColor Cyan
    Write-Host "5. Salir" -ForegroundColor Yellow
    Write-Host ""
    
    $option = Read-Host "Seleccione una opción (1-5)"
    
    switch ($option) {
        "1" {
            Start-FlaskServer
            Read-Host "`nPresione Enter para salir"
        }
        "2" {
            Start-PythonSimulator
        }
        "3" {
            Write-Info "Iniciando servidor Flask en segundo plano..."
            Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath'; python app.py"
            Start-Sleep -Seconds 5
            
            Write-Info "Iniciando simulador Python..."
            Start-PythonSimulator
        }
        "4" {
            Show-WokwiInstructions
            Read-Host "`nPresione Enter para continuar"
            Show-StartupMenu
        }
        "5" {
            Write-Info "Saliendo..."
            exit 0
        }
        default {
            Write-Warning2 "Opción inválida"
            Start-Sleep -Seconds 2
            Show-StartupMenu
        }
    }
}

# ============================================================
# FUNCIÓN PRINCIPAL
# ============================================================

function Main {
    Clear-Host
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  SISTEMA IoT - ESTACIÓN DE BOMBEO" -ForegroundColor Yellow
    Write-Host "  Instalación y Configuración Completa" -ForegroundColor Yellow
    Write-Host "  Promotora Palmera de Antioquia S.A.S." -ForegroundColor White
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Info "Directorio de trabajo: $projectPath"
    Write-Host ""
    
    # Si solo base de datos
    if ($OnlyDatabase) {
        Initialize-Database
        Read-Host "`nPresione Enter para salir"
        return
    }
    
    # Si solo simulador
    if ($OnlySimulator) {
        Show-WokwiInstructions
        Read-Host "`nPresione Enter para salir"
        return
    }
    
    # Setup completo
    $pythonPath = Test-PythonInstalled
    
    if (-not $pythonPath -and -not $SkipPythonInstall) {
        $installPython = Read-Host "¿Desea instalar Python automáticamente? (S/N)"
        if ($installPython -eq "S" -or $installPython -eq "s") {
            Install-Python
            return
        } else {
            Write-Warning2 "Python es necesario para ejecutar el sistema"
            Write-Info "Puede ejecutar solo la inicialización de base de datos con: .\setup_completo.ps1 -OnlyDatabase"
            Read-Host "`nPresione Enter para salir"
            return
        }
    }
    
    if ($pythonPath) {
        # Crear/activar entorno virtual
        $venvSuccess = Initialize-VirtualEnvironment -PythonPath $pythonPath
        
        if ($venvSuccess) {
            # Instalar dependencias
            $depsSuccess = Install-Dependencies
            
            if (-not $depsSuccess) {
                Write-Warning2 "Continuando sin instalar dependencias..."
            }
        }
        
        # Inicializar base de datos
        $dbSuccess = Initialize-Database
        
        if (-not $dbSuccess) {
            Write-Error2 "No se pudo inicializar la base de datos"
            Read-Host "`nPresione Enter para salir"
            return
        }
        
        # Mostrar instrucciones de Wokwi
        Show-WokwiInstructions
        
        Write-Host "`n"
        Read-Host "Presione Enter para continuar al menú de inicio"
        
        # Mostrar menú de inicio
        Show-StartupMenu
    }
}

# Ejecutar
Main
