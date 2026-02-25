# Script Rápido de Inicialización de Base de Datos
# Sistema IoT - Estación de Bombeo
# Promotora Palmera de Antioquia S.A.S.

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Inicialización de Base de Datos SQLite" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan

$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$dbFile = Join-Path $projectPath "monitoring.db"
$sqlFile = Join-Path $projectPath "init_database.sql"

Write-Host "`nℹ️  Directorio: $projectPath" -ForegroundColor Cyan

# Verificar si existe base de datos
if (Test-Path $dbFile) {
    Write-Host "⚠️  Base de datos ya existe: $dbFile" -ForegroundColor Yellow
    
    $fileSize = (Get-Item $dbFile).Length / 1KB
    Write-Host "   Tamaño actual: $([Math]::Round($fileSize, 2)) KB" -ForegroundColor Gray
    
    $recreate = Read-Host "`n¿Recrear base de datos? (S/N)"
    
    if ($recreate -ne "S" -and $recreate -ne "s") {
        Write-Host "`n✅ Manteniendo base de datos existente" -ForegroundColor Green
        Read-Host "`nPresione Enter para salir"
        exit 0
    }
    
    # Crear backup
    $backupFile = $dbFile + ".backup_" + (Get-Date -Format "yyyyMMdd_HHmmss")
    Copy-Item $dbFile $backupFile -Force
    Write-Host "`n✅ Backup creado: $backupFile" -ForegroundColor Green
    
    # Eliminar DB actual
    Remove-Item $dbFile -Force
    Write-Host "🗑️  Base de datos anterior eliminada" -ForegroundColor Gray
}

Write-Host "`n📊 Creando base de datos SQLite..." -ForegroundColor Cyan

# Crear script Python inline para inicializar DB
$pythonScript = @"
import sqlite3
import os
from datetime import datetime

db_path = r'$dbFile'

print('📂 Creando base de datos:', db_path)

# Conectar a base de datos (se crea automáticamente)
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

print("📋 Creando tablas...")

# Tabla: Estaciones de Monitoreo
cursor.execute('''
CREATE TABLE IF NOT EXISTS monitoring_station (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200),
    latitude REAL,
    longitude REAL,
    station_type VARCHAR(50),
    auto_control_enabled BOOLEAN DEFAULT 1,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
''')

# Tabla: Estaciones de Bombeo
cursor.execute('''
CREATE TABLE IF NOT EXISTS pumping_station (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    max_capacity_m3h REAL,
    rated_power_kw REAL,
    min_water_level_m REAL DEFAULT 0.5,
    max_water_level_m REAL DEFAULT 3.0,
    is_active BOOLEAN DEFAULT 1,
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id)
)
''')

# Tabla: Datos Meteorológicos
cursor.execute('''
CREATE TABLE IF NOT EXISTS meteorological_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id INTEGER NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    temperature_c REAL,
    humidity_percent REAL,
    precipitation_mm REAL,
    wind_speed_kmh REAL,
    wind_direction_deg INTEGER,
    atmospheric_pressure_hpa REAL,
    solar_radiation_wm2 REAL,
    uv_index REAL,
    evapotranspiration_mm REAL,
    soil_moisture_percent REAL,
    soil_temperature_c REAL,
    leaf_wetness_percent REAL,
    source_device VARCHAR(50),
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id)
)
''')

# Tabla: Telemetría de Bomba
cursor.execute('''
CREATE TABLE IF NOT EXISTS pump_telemetry (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pump_id INTEGER NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'OFF',
    flow_rate_m3h REAL DEFAULT 0.0,
    inlet_pressure_bar REAL,
    outlet_pressure_bar REAL,
    power_consumption_kw REAL DEFAULT 0.0,
    motor_temperature_c REAL,
    vibration_level INTEGER DEFAULT 0,
    running_hours REAL,
    operational_mode VARCHAR(20) DEFAULT 'AUTO',
    source_device VARCHAR(50),
    FOREIGN KEY (pump_id) REFERENCES pumping_station (id)
)
''')

# Tabla: Alertas del Sistema
cursor.execute('''
CREATE TABLE IF NOT EXISTS system_alert (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id INTEGER,
    pump_id INTEGER,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    alert_type VARCHAR(50) NOT NULL,
    severity VARCHAR(20) DEFAULT 'MEDIUM',
    title VARCHAR(200) NOT NULL,
    description TEXT,
    parameter_name VARCHAR(50),
    parameter_value REAL,
    threshold_value REAL,
    is_resolved BOOLEAN DEFAULT 0,
    resolved_at TIMESTAMP,
    notification_sent BOOLEAN DEFAULT 0,
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id),
    FOREIGN KEY (pump_id) REFERENCES pumping_station (id)
)
''')

# Tabla: Umbrales de Alerta
cursor.execute('''
CREATE TABLE IF NOT EXISTS alert_threshold (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parameter_name VARCHAR(50) NOT NULL UNIQUE,
    min_value REAL,
    max_value REAL,
    alert_level VARCHAR(20) DEFAULT 'MEDIUM',
    description TEXT,
    is_active BOOLEAN DEFAULT 1
)
''')

# Tabla: Log de Control Automático
cursor.execute('''
CREATE TABLE IF NOT EXISTS automatic_control_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id INTEGER NOT NULL,
    pump_id INTEGER,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(20) NOT NULL,
    reason TEXT,
    water_level_m REAL,
    precipitation_mm REAL,
    motor_temperature_c REAL,
    execution_status VARCHAR(20) DEFAULT 'SUCCESS',
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id),
    FOREIGN KEY (pump_id) REFERENCES pumping_station (id)
)
''')

# Tabla: Contactos para Notificaciones
cursor.execute('''
CREATE TABLE IF NOT EXISTS notification_contact (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    whatsapp_number VARCHAR(20),
    receive_critical BOOLEAN DEFAULT 1,
    receive_high BOOLEAN DEFAULT 1,
    receive_medium BOOLEAN DEFAULT 0,
    is_active BOOLEAN DEFAULT 1
)
''')

# Otras tablas auxiliares
cursor.execute('''CREATE TABLE IF NOT EXISTS water_level (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id INTEGER NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    level_m REAL NOT NULL,
    volume_m3 REAL,
    source_device VARCHAR(50),
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id)
)''')

cursor.execute('''CREATE TABLE IF NOT EXISTS gate_status (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id INTEGER NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    gate_number INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'CLOSED',
    opening_percent REAL DEFAULT 0.0,
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id)
)''')

cursor.execute('''CREATE TABLE IF NOT EXISTS flow_summary (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id INTEGER NOT NULL,
    date DATE NOT NULL,
    total_inflow_m3 REAL DEFAULT 0.0,
    total_outflow_m3 REAL DEFAULT 0.0,
    pump_running_hours REAL DEFAULT 0.0,
    energy_consumption_kwh REAL DEFAULT 0.0,
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id),
    UNIQUE (station_id, date)
)''')

print("✅ Tablas creadas")

# Verificar si ya hay datos
cursor.execute("SELECT COUNT(*) FROM monitoring_station")
count = cursor.fetchone()[0]

if count == 0:
    print("\n📥 Insertando datos iniciales...")
    
    # Insertar estaciones
    cursor.execute('''
    INSERT INTO monitoring_station (name, location, latitude, longitude, station_type, auto_control_enabled)
    VALUES 
    ('Estación Administración', 'Entrada principal - Chigorodó', 6.2442, -75.5812, 'COMBINED', 1),
    ('Estación Playa', 'Zona de trabajo Playa', 6.2455, -75.5825, 'METEOROLOGICAL', 1),
    ('Estación Bendición', 'Zona de trabajo Bendición', 6.2438, -75.5798, 'METEOROLOGICAL', 1),
    ('Estación Plana', 'Zona de trabajo Plana', 6.2429, -75.5834, 'METEOROLOGICAL', 1)
    ''')
    
    # Insertar bombas
    cursor.execute('''
    INSERT INTO pumping_station (station_id, name, max_capacity_m3h, rated_power_kw, min_water_level_m, max_water_level_m)
    VALUES 
    (1, 'Bomba Principal Norte', 120.0, 15.0, 0.5, 3.0),
    (1, 'Bomba Auxiliar Sur', 80.0, 9.5, 0.6, 2.8),
    (1, 'Bomba Respaldo Este', 100.0, 11.0, 0.5, 3.0)
    ''')
    
    # Insertar umbrales
    cursor.execute('''
    INSERT INTO alert_threshold (parameter_name, min_value, max_value, alert_level, description)
    VALUES 
    ('water_level', 0.5, 3.0, 'HIGH', 'Nivel de agua crítico'),
    ('precipitation', 0.0, 50.0, 'MEDIUM', 'Precipitación acumulada'),
    ('motor_temperature_c', 0.0, 85.0, 'CRITICAL', 'Temperatura del motor'),
    ('inlet_pressure_bar', 2.0, 5.0, 'HIGH', 'Presión de entrada'),
    ('wind_speed_kmh', 0.0, 60.0, 'MEDIUM', 'Velocidad del viento')
    ''')
    
    # Insertar contactos
    cursor.execute('''
    INSERT INTO notification_contact (name, role, email, phone, whatsapp_number)
    VALUES 
    ('Supervisor Operaciones', 'Supervisor', 'supervisor@promotorapalmera.com', '+573001234567', '+573001234567'),
    ('Técnico de Campo', 'Técnico', 'tecnico@promotorapalmera.com', '+573007654321', '+573007654321')
    ''')
    
    print("✅ Datos iniciales insertados")
else:
    print(f"\nℹ️  Base de datos ya contiene {count} estaciones, omitiendo inserción de datos")

conn.commit()

# Mostrar resumen
print("\n" + "="*60)
print("📊 RESUMEN DE BASE DE DATOS")
print("="*60)

tables = [
    'monitoring_station',
    'pumping_station',
    'meteorological_data',
    'pump_telemetry',
    'system_alert',
    'alert_threshold',
    'automatic_control_log',
    'notification_contact',
    'water_level',
    'gate_status',
    'flow_summary'
]

for table in tables:
    cursor.execute(f"SELECT COUNT(*) FROM {table}")
    count = cursor.fetchone()[0]
    print(f"  • {table:30s}: {count:5d} registros")

print("="*60)

conn.close()

print("\n✅ Base de datos inicializada correctamente")
print(f"📁 Ubicación: {db_path}")

file_size = os.path.getsize(db_path) / 1024
print(f"💾 Tamaño: {file_size:.2f} KB")
'@ -f $dbFile

# Guardar script temporal
$tempPyScript = Join-Path $env:TEMP "init_db_temp.py"
Set-Content -Path $tempPyScript -Value $pythonScript -Encoding UTF8

# Buscar Python
$pythonExe = $null
$pythonPaths = @(
    "C:\Python312\python.exe",
    "C:\Python311\python.exe",
    "C:\Python310\python.exe",
    "C:\Python39\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe"
)

foreach ($path in $pythonPaths) {
    if (Test-Path $path) {
        $pythonExe = $path
        break
    }
}

if ($pythonExe) {
    Write-Host "✅ Python encontrado: $pythonExe" -ForegroundColor Green
    Write-Host ""
    
    # Ejecutar script
    & $pythonExe $tempPyScript
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ ¡Inicialización completada exitosamente!" -ForegroundColor Green
    } else {
        Write-Host "`n❌ Error durante la inicialización" -ForegroundColor Red
    }
    
    # Eliminar script temporal
    Remove-Item $tempPyScript -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "❌ Python no encontrado en el sistema" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor instale Python desde:" -ForegroundColor Yellow
    Write-Host "https://www.python.org/downloads/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "O use el script completo:" -ForegroundColor Yellow
    Write-Host ".\setup_completo.ps1" -ForegroundColor Cyan
}

Write-Host ""
Read-Host "Presione Enter para salir"
