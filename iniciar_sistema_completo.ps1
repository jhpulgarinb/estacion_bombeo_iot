# iniciar_sistema_completo.ps1
# Script maestro para iniciar todo el Sistema de Monitoreo de Estaciones de Bombeo

param(
    [switch]$SkipDB = $false,
    [switch]$Development = $false,
    [int]$Port = 5000
)

Write-Host @"
╔══════════════════════════════════════════════════════════════════════════════════════╗
║                    SISTEMA DE MONITOREO DE ESTACIONES DE BOMBEO                     ║
║                            Iniciador del Sistema Completo                           ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

# Variables globales
$ScriptPath = $PSScriptRoot
$LogFile = Join-Path $ScriptPath "logs\system_startup.log"
$VenvPath = Join-Path $ScriptPath "venv"
$ActivateScript = Join-Path $VenvPath "Scripts\Activate.ps1"

# Crear directorio de logs si no existe
$LogsDir = Join-Path $ScriptPath "logs"
if (-not (Test-Path $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
}

# Función para logging
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    $LogMessage | Add-Content -Path $LogFile
    
    switch ($Level) {
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "WARN" { Write-Host $Message -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        default { Write-Host $Message -ForegroundColor White }
    }
}

# Función para verificar prerrequisitos
function Test-Prerequisites {
    Write-Log "Verificando prerrequisitos del sistema..."
    
    # Verificar Python
    try {
        $pythonVersion = python --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Python detectado: $pythonVersion" "SUCCESS"
        } else {
            throw "Python no encontrado"
        }
    } catch {
        Write-Log "Python no está instalado o no está en PATH" "ERROR"
        Write-Host "Por favor instale Python desde https://www.python.org/downloads/" -ForegroundColor Yellow
        return $false
    }
    
    # Verificar PostgreSQL (solo si no se omite DB)
    if (-not $SkipDB) {
        try {
            $pgVersion = psql --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Log "PostgreSQL detectado: $pgVersion" "SUCCESS"
            } else {
                throw "PostgreSQL no encontrado"
            }
        } catch {
            Write-Log "PostgreSQL no está instalado o no está en PATH" "WARN"
            Write-Host "¿Desea continuar sin verificar la base de datos? (y/n): " -NoNewline -ForegroundColor Yellow
            $continue = Read-Host
            if ($continue -ne "y" -and $continue -ne "Y") {
                return $false
            }
        }
    }
    
    # Verificar entorno virtual
    if (-not (Test-Path $ActivateScript)) {
        Write-Log "Entorno virtual no encontrado. Ejecute primero instalar_sistema.ps1" "ERROR"
        return $false
    }
    
    Write-Log "Prerrequisitos verificados correctamente" "SUCCESS"
    return $true
}

# Función para activar entorno virtual
function Enable-VirtualEnvironment {
    Write-Log "Activando entorno virtual..."
    
    try {
        & $ActivateScript
        Write-Log "Entorno virtual activado correctamente" "SUCCESS"
        return $true
    } catch {
        Write-Log "Error activando entorno virtual: $_" "ERROR"
        return $false
    }
}

# Función para verificar servicios de base de datos
function Test-DatabaseConnection {
    if ($SkipDB) {
        Write-Log "Omitiendo verificación de base de datos por parámetro --SkipDB" "WARN"
        return $true
    }
    
    Write-Log "Verificando conexión a base de datos..."
    
    try {
        # Verificar si PostgreSQL está ejecutándose
        $pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue
        if ($pgService -and $pgService.Status -eq "Running") {
            Write-Log "Servicio PostgreSQL ejecutándose" "SUCCESS"
        } else {
            Write-Log "Servicio PostgreSQL no está ejecutándose" "WARN"
        }
        
        # Probar conexión usando Python
        $testConnection = @"
import psycopg2
try:
    conn = psycopg2.connect(
        host='localhost',
        database='monitoring_db',
        user='usuario',
        password='password'
    )
    conn.close()
    print('SUCCESS')
except Exception as e:
    print(f'ERROR: {e}')
"@
        
        $result = echo $testConnection | python 2>$null
        if ($result -eq "SUCCESS") {
            Write-Log "Conexión a base de datos exitosa" "SUCCESS"
            return $true
        } else {
            Write-Log "No se pudo conectar a la base de datos: $result" "WARN"
            Write-Host "¿Desea continuar sin base de datos? (y/n): " -NoNewline -ForegroundColor Yellow
            $continue = Read-Host
            return ($continue -eq "y" -or $continue -eq "Y")
        }
    } catch {
        Write-Log "Error verificando base de datos: $_" "WARN"
        return $true  # Continuar de todos modos
    }
}

# Función para inicializar datos de ejemplo
function Initialize-SampleData {
    Write-Log "Inicializando datos de ejemplo..."
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$Port/api/init-db" -Method Post -TimeoutSec 10
        Write-Log "Datos de ejemplo inicializados: $($response.message)" "SUCCESS"
        return $true
    } catch {
        Write-Log "No se pudieron inicializar datos de ejemplo: $_" "WARN"
        return $false
    }
}

# Función para iniciar el servidor Flask
function Start-FlaskServer {
    Write-Log "Iniciando servidor Flask en puerto $Port..."
    
    try {
        # Cambiar variables de entorno si es desarrollo
        if ($Development) {
            $env:FLASK_ENV = "development"
            $env:FLASK_DEBUG = "1"
            Write-Log "Modo desarrollo activado" "INFO"
        } else {
            $env:FLASK_ENV = "production"
            $env:FLASK_DEBUG = "0"
        }
        
        Write-Log "Servidor iniciándose en http://localhost:$Port" "SUCCESS"
        Write-Log "Dashboard disponible en: http://localhost:$Port/index.html" "SUCCESS"
        Write-Log "Documentación disponible en: http://localhost:$Port/docs/" "SUCCESS"
        Write-Log "" "INFO"
        Write-Log "Presione Ctrl+C para detener el servidor" "WARN"
        Write-Log "═══════════════════════════════════════════════════════════════════" "INFO"
        
        # Iniciar servidor
        python app.py
        
    } catch {
        Write-Log "Error iniciando servidor Flask: $_" "ERROR"
        return $false
    }
}

# Función para abrir navegador automáticamente
function Open-Browser {
    $urls = @(
        "http://localhost:$Port/index.html",
        "http://localhost:$Port/docs/"
    )
    
    Write-Host "¿Desea abrir el navegador automáticamente? (y/n): " -NoNewline -ForegroundColor Cyan
    $openBrowser = Read-Host
    
    if ($openBrowser -eq "y" -or $openBrowser -eq "Y") {
        Start-Sleep -Seconds 3  # Esperar que el servidor se inicie
        
        try {
            Write-Log "Abriendo dashboard en el navegador..." "INFO"
            Start-Process $urls[0]
            
            Start-Sleep -Seconds 1
            Write-Log "Abriendo documentación en el navegador..." "INFO"  
            Start-Process $urls[1]
        } catch {
            Write-Log "Error abriendo navegador: $_" "WARN"
        }
    }
}

# Función principal
function Main {
    Write-Log "=== INICIANDO SISTEMA DE MONITOREO DE ESTACIONES DE BOMBEO ===" "INFO"
    Write-Log "Parámetros: SkipDB=$SkipDB, Development=$Development, Port=$Port" "INFO"
    
    # Verificar prerrequisitos
    if (-not (Test-Prerequisites)) {
        Write-Log "Falló verificación de prerrequisitos. Abortando." "ERROR"
        exit 1
    }
    
    # Activar entorno virtual
    if (-not (Enable-VirtualEnvironment)) {
        Write-Log "Falló activación de entorno virtual. Abortando." "ERROR"
        exit 1
    }
    
    # Verificar conexión a base de datos
    if (-not (Test-DatabaseConnection)) {
        Write-Log "Falló verificación de base de datos. Abortando." "ERROR"
        exit 1
    }
    
    Write-Log "═══════════════════════════════════════════════════════════════════" "INFO"
    Write-Log "Sistema listo. Iniciando servidor web..." "SUCCESS"
    Write-Log "═══════════════════════════════════════════════════════════════════" "INFO"
    
    # Programar apertura de navegador en background
    Start-Job -ScriptBlock {
        param($Port)
        Start-Sleep -Seconds 5
        
        # Verificar que el servidor esté respondiendo
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$Port" -TimeoutSec 10
            if ($response.StatusCode -eq 200) {
                # El servidor está listo, inicializar datos
                try {
                    Invoke-RestMethod -Uri "http://localhost:$Port/api/init-db" -Method Post -TimeoutSec 10
                } catch {
                    # Ignorar errores de inicialización
                }
            }
        } catch {
            # El servidor aún no está listo
        }
    } -ArgumentList $Port | Out-Null
    
    # Programar apertura del navegador
    if (-not $Development) {
        Open-Browser
    }
    
    # Iniciar servidor (esto bloquea hasta que se termine)
    Start-FlaskServer
}

# Manejo de errores globales
trap {
    Write-Log "Error crítico: $_" "ERROR"
    Write-Log "Verifique el log en: $LogFile" "INFO"
    
    Write-Host "`nPresione cualquier tecla para salir..." -ForegroundColor Yellow
    Read-Host
    exit 1
}

# Ejecutar función principal
try {
    Main
} finally {
    Write-Log "Sistema detenido" "INFO"
    
    # Limpiar variables de entorno
    Remove-Item Env:FLASK_ENV -ErrorAction SilentlyContinue
    Remove-Item Env:FLASK_DEBUG -ErrorAction SilentlyContinue
    
    Write-Host "`n¡Hasta luego!" -ForegroundColor Green
}
