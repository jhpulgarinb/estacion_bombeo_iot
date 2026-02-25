# setup_database.ps1
# Script para configurar PostgreSQL y crear la base de datos del sistema

Write-Host "=== Configuración de Base de Datos - Sistema de Monitoreo de Estaciones de Bombeo ===" -ForegroundColor Green

# Verificar si PostgreSQL está instalado
$pgPath = Get-Command psql -ErrorAction SilentlyContinue
if (-not $pgPath) {
    Write-Host "PostgreSQL no está instalado o no está en el PATH del sistema." -ForegroundColor Red
    Write-Host "Por favor instale PostgreSQL desde https://www.postgresql.org/download/windows/" -ForegroundColor Yellow
    Write-Host "Presione cualquier tecla para continuar..."
    Read-Host
    exit 1
}

Write-Host "PostgreSQL detectado en: $($pgPath.Source)" -ForegroundColor Green

# Configuración de la base de datos
$DB_HOST = "localhost"
$DB_PORT = "5432"
$DB_NAME = "monitoring_db"
$DB_USER = "usuario"
$DB_PASSWORD = "password"

# Solicitar credenciales de administrador de PostgreSQL
Write-Host "`nIngrese las credenciales del administrador de PostgreSQL:" -ForegroundColor Yellow
$adminUser = Read-Host "Usuario administrador (por defecto: postgres)"
if ([string]::IsNullOrEmpty($adminUser)) {
    $adminUser = "postgres"
}

$adminPassword = Read-Host "Contraseña del administrador" -AsSecureString
$adminPasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($adminPassword))

# Crear usuario y base de datos
Write-Host "`nCreando usuario y base de datos..." -ForegroundColor Yellow

$env:PGPASSWORD = $adminPasswordText

try {
    # Crear usuario
    $createUserQuery = "CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASSWORD';"
    Write-Host "Creando usuario: $DB_USER"
    psql -h $DB_HOST -p $DB_PORT -U $adminUser -d postgres -c $createUserQuery 2>$null
    
    # Crear base de datos
    $createDbQuery = "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
    Write-Host "Creando base de datos: $DB_NAME"
    psql -h $DB_HOST -p $DB_PORT -U $adminUser -d postgres -c $createDbQuery 2>$null
    
    # Otorgar permisos
    $grantQuery = "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    Write-Host "Otorgando permisos al usuario"
    psql -h $DB_HOST -p $DB_PORT -U $adminUser -d postgres -c $grantQuery 2>$null
    
    Write-Host "Base de datos creada exitosamente!" -ForegroundColor Green
    
} catch {
    Write-Host "Error al crear la base de datos: $($_.Exception.Message)" -ForegroundColor Red
}

# Ejecutar esquema SQL
Write-Host "`nEjecutando esquema de base de datos..." -ForegroundColor Yellow
$env:PGPASSWORD = $DB_PASSWORD

try {
    $sqlFile = Join-Path $PSScriptRoot "bd-estacion-bombeo.sql"
    if (Test-Path $sqlFile) {
        psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $sqlFile
        Write-Host "Esquema ejecutado exitosamente!" -ForegroundColor Green
    } else {
        Write-Host "Archivo bd-estacion-bombeo.sql no encontrado!" -ForegroundColor Red
    }
} catch {
    Write-Host "Error al ejecutar el esquema: $($_.Exception.Message)" -ForegroundColor Red
}

# Actualizar config.py
Write-Host "`nActualizando archivo de configuración..." -ForegroundColor Yellow
$configFile = Join-Path $PSScriptRoot "config.py"
$newConfig = @"
import os

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
SQLALCHEMY_DATABASE_URI = 'postgresql://$DB_USER`:$DB_PASSWORD@$DB_HOST`:$DB_PORT/$DB_NAME'
SQLALCHEMY_TRACK_MODIFICATIONS = False
SECRET_KEY = 'clave-secreta-para-aplicacion-$(Get-Random)'
"@

$newConfig | Out-File -FilePath $configFile -Encoding utf8
Write-Host "Archivo config.py actualizado!" -ForegroundColor Green

Write-Host "`n=== Configuración completada ===" -ForegroundColor Green
Write-Host "Base de datos: $DB_NAME" -ForegroundColor Cyan
Write-Host "Usuario: $DB_USER" -ForegroundColor Cyan
Write-Host "Host: $DB_HOST" -ForegroundColor Cyan
Write-Host "Puerto: $DB_PORT" -ForegroundColor Cyan

Write-Host "`nPresione cualquier tecla para continuar..." -ForegroundColor Yellow
Read-Host

# Limpiar variable de entorno
Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
