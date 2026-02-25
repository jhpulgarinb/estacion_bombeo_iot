# instalar_sistema.ps1
# Script principal de instalación del Sistema de Monitoreo de Estaciones de Bombeo

Write-Host @"
╔══════════════════════════════════════════════════════════════════════════════════════╗
║                    SISTEMA DE MONITOREO DE ESTACIONES DE BOMBEO                     ║
║                                Instalador para Windows                              ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "`nIniciando proceso de instalación..." -ForegroundColor Green

# Verificar si Python está instalado
Write-Host "`n[1/6] Verificando Python..." -ForegroundColor Yellow
$pythonPath = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonPath) {
    Write-Host "Python no está instalado o no está en el PATH." -ForegroundColor Red
    Write-Host "Por favor instale Python desde https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host "Asegúrese de marcar 'Add Python to PATH' durante la instalación." -ForegroundColor Yellow
    exit 1
}

$pythonVersion = python --version
Write-Host "Python detectado: $pythonVersion" -ForegroundColor Green

# Verificar si pip está disponible
$pipPath = Get-Command pip -ErrorAction SilentlyContinue
if (-not $pipPath) {
    Write-Host "pip no está disponible." -ForegroundColor Red
    exit 1
}

# Crear entorno virtual
Write-Host "`n[2/6] Creando entorno virtual..." -ForegroundColor Yellow
$venvPath = Join-Path $PSScriptRoot "venv"

if (Test-Path $venvPath) {
    Write-Host "Entorno virtual ya existe. Eliminando..." -ForegroundColor Yellow
    Remove-Item $venvPath -Recurse -Force
}

python -m venv $venvPath
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al crear el entorno virtual." -ForegroundColor Red
    exit 1
}

Write-Host "Entorno virtual creado exitosamente." -ForegroundColor Green

# Activar entorno virtual
Write-Host "`n[3/6] Activando entorno virtual..." -ForegroundColor Yellow
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"

if (-not (Test-Path $activateScript)) {
    Write-Host "Script de activación no encontrado." -ForegroundColor Red
    exit 1
}

& $activateScript
Write-Host "Entorno virtual activado." -ForegroundColor Green

# Actualizar pip
Write-Host "`n[4/6] Actualizando pip..." -ForegroundColor Yellow
python -m pip install --upgrade pip

# Instalar dependencias
Write-Host "`n[5/6] Instalando dependencias Python..." -ForegroundColor Yellow
$requirementsFile = Join-Path $PSScriptRoot "requirements.txt"

if (Test-Path $requirementsFile) {
    pip install -r $requirementsFile
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Dependencias instaladas exitosamente." -ForegroundColor Green
    } else {
        Write-Host "Error al instalar dependencias." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Archivo requirements.txt no encontrado." -ForegroundColor Red
    exit 1
}

# Configurar base de datos
Write-Host "`n[6/6] ¿Desea configurar la base de datos PostgreSQL ahora? (y/n)" -ForegroundColor Yellow
$configDb = Read-Host
if ($configDb -eq "y" -or $configDb -eq "Y" -or $configDb -eq "yes" -or $configDb -eq "Yes") {
    Write-Host "Ejecutando configuración de base de datos..." -ForegroundColor Yellow
    $dbScript = Join-Path $PSScriptRoot "setup_database.ps1"
    if (Test-Path $dbScript) {
        & $dbScript
    } else {
        Write-Host "Script de configuración de base de datos no encontrado." -ForegroundColor Red
    }
} else {
    Write-Host "Configuración de base de datos omitida." -ForegroundColor Yellow
    Write-Host "Puede ejecutar './setup_database.ps1' más tarde para configurar la base de datos." -ForegroundColor Cyan
}

# Crear scripts de ejecución
Write-Host "`nCreando scripts de ejecución..." -ForegroundColor Yellow

# Script para iniciar la aplicación
$startScript = @"
# iniciar_aplicacion.ps1
# Script para iniciar la aplicación web

Write-Host "Iniciando Sistema de Monitoreo de Estaciones de Bombeo..." -ForegroundColor Green

# Activar entorno virtual
`$venvPath = Join-Path `$PSScriptRoot "venv"
`$activateScript = Join-Path `$venvPath "Scripts\Activate.ps1"

if (Test-Path `$activateScript) {
    & `$activateScript
    Write-Host "Entorno virtual activado." -ForegroundColor Green
} else {
    Write-Host "Entorno virtual no encontrado. Ejecute primero instalar_sistema.ps1" -ForegroundColor Red
    exit 1
}

# Iniciar aplicación
Write-Host "Iniciando servidor web en http://localhost:5000..." -ForegroundColor Cyan
Write-Host "Presione Ctrl+C para detener el servidor." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

python app.py
"@

$startScript | Out-File -FilePath (Join-Path $PSScriptRoot "iniciar_aplicacion.ps1") -Encoding utf8

Write-Host @"

╔══════════════════════════════════════════════════════════════════════════════════════╗
║                                INSTALACIÓN COMPLETADA                               ║
╚══════════════════════════════════════════════════════════════════════════════════════╝

Para usar el sistema:

1. Ejecute: .\iniciar_aplicacion.ps1
2. Abra su navegador en: http://localhost:5000
3. Para abrir el dashboard directamente: http://localhost:5000/index.html

Archivos importantes:
- config.py: Configuración de la aplicación
- app.py: Servidor web principal
- index.html: Dashboard web
- bd-estacion-bombeo.sql: Esquema de base de datos

Para ayuda adicional, consulte la documentación en el directorio 'docs'.

¡El sistema está listo para usar!

"@ -ForegroundColor Green

Write-Host "Presione cualquier tecla para continuar..." -ForegroundColor Yellow
Read-Host
