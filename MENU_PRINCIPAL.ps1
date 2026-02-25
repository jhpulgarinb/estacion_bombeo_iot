# 🚀 GUÍA COMPLETA DE INICIO DEL SISTEMA
# Sistema IoT de Estación de Bombeo con Simulador Wokwi
# Promotora Palmera de Antioquia S.A.S.

Write-Host "`n" -NoNewline
Write-Host "████████████████████████████████████████████████████████████" -ForegroundColor Cyan
Write-Host "█                                                              █" -ForegroundColor Cyan
Write-Host "█  🚤 SISTEMA IoT - ESTACIÓN DE BOMBEO                       █" -ForegroundColor Yellow
Write-Host "█  📍 Promotora Palmera de Antioquia S.A.S.                  █" -ForegroundColor White
Write-Host "█  📆 Fecha: 20 de febrero de 2026                           █" -ForegroundColor White
Write-Host "█                                                              █" -ForegroundColor Cyan
Write-Host "████████████████████████████████████████████████████████████" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# MENÚ PRINCIPAL
# ============================================================

function Show-Menu {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  MENÚ PRINCIPAL                                            ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  [1] 🗄️  INICIALIZAR BASE DE DATOS" -ForegroundColor Cyan
    Write-Host "  [2] 🎮 SIMULADOR ESP32 CON WOKWI" -ForegroundColor Cyan
    Write-Host "  [3] 🌐 SERVIDOR FLASK" -ForegroundColor Cyan
    Write-Host "  [4] ▶️  EJECUTAR SISTEMA COMPLETO (Recomendado)" -ForegroundColor Green
    Write-Host "  [5] 📚 VER DOCUMENTACIÓN" -ForegroundColor Cyan
    Write-Host "  [6] ❌ SALIR" -ForegroundColor Red
    Write-Host ""
}

# ============================================================
# OPCIÓN 1: INICIALIZAR BASE DE DATOS
# ============================================================

function Initialize-DB {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║  INICIALIZACIÓN DE BASE DE DATOS                           ║" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""
    
    $dbFile = "monitoring.db"
    
    if (Test-Path $dbFile) {
        Write-Host "✅ Base de datos encontrada: $dbFile" -ForegroundColor Green
        $fileSize = (Get-Item $dbFile).Length / 1KB
        Write-Host "   Tamaño: $([Math]::Round($fileSize, 2)) KB" -ForegroundColor Gray
        Write-Host ""
        
        $recreate = Read-Host "¿Recrear base de datos? (S/N)"
        if ($recreate -ne "S" -and $recreate -ne "s") {
            Write-Host "✅ Base de datos conservada" -ForegroundColor Green
            return
        }
        
        # Backup
        $backup = "$dbFile.backup_$(Get-Date -Format yyyyMMdd_HHmmss)"
        Copy-Item $dbFile $backup
        Write-Host "💾 Backup realizado: $backup" -ForegroundColor Cyan
        Remove-Item $dbFile
    }
    
    # Ejecutar script de creación
    Write-Host "`n📊 Creando tablas y datos iniciales..." -ForegroundColor Cyan
    
    # Usar el archivo SQL
    $sqlFile = "init_database.sql"
    if (Test-Path $sqlFile) {
        # Intentar con sqlite3 si está disponible
        try {
            $sqliteCmd = Get-Command sqlite3 -ErrorAction Stop
            Write-Host "✅ SQLite3 encontrado" -ForegroundColor Green
            Get-Content $sqlFile | &amp; $sqliteCmd.Path $dbFile
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Base de datos creada exitosamente" -ForegroundColor Green
                return
            }
        } catch {
            Write-Host "ℹ️  SQLite3 no disponible, usando método alternativo..." -ForegroundColor Yellow
        }
    }
    
    # Crear script Python temporal
    $pythonScript = @'
import sqlite3

db = sqlite3.connect("monitoring.db")
c = db.cursor()

# Crear tablas
tables_sql = """
CREATE TABLE IF NOT EXISTS monitoring_station (id INTEGER PRIMARY KEY, name TEXT UNIQUE);
CREATE TABLE IF NOT EXISTS pumping_station (id INTEGER PRIMARY KEY, station_id INTEGER, name TEXT);
CREATE TABLE IF NOT EXISTS meteorological_data (id INTEGER PRIMARY KEY, station_id INTEGER, temperature_c REAL, humidity_percent REAL, precipitation_mm REAL, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS pump_telemetry (id INTEGER PRIMARY KEY, pump_id INTEGER, status TEXT, flow_rate_m3h REAL, power_consumption_kw REAL, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS system_alert (id INTEGER PRIMARY KEY, station_id INTEGER, severity TEXT, title TEXT, is_resolved BOOLEAN DEFAULT 0, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS alert_threshold (id INTEGER PRIMARY KEY, parameter_name TEXT UNIQUE, min_value REAL, max_value REAL, alert_level TEXT);
CREATE TABLE IF NOT EXISTS automatic_control_log (id INTEGER PRIMARY KEY, station_id INTEGER, action TEXT, reason TEXT, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS notification_contact (id INTEGER PRIMARY KEY, name TEXT, email TEXT, phone TEXT, whatsapp TEXT);
CREATE TABLE IF NOT EXISTS water_level (id INTEGER PRIMARY KEY, station_id INTEGER, level_m REAL, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS gate_status (id INTEGER PRIMARY KEY, station_id INTEGER, gate_number INTEGER, status TEXT);
CREATE TABLE IF NOT EXISTS flow_summary (id INTEGER PRIMARY KEY, station_id INTEGER, date DATE, total_inflow_m3 REAL, pump_running_hours REAL);
"""

for sql in tables_sql.split(";"):
    if sql.strip():
        c.execute(sql)

# Insertar datos iniciales
initial_data = """
INSERT OR IGNORE INTO monitoring_station VALUES (1, 'Estacion Administracion');
INSERT OR IGNORE INTO monitoring_station VALUES (2, 'Estacion Playa');
INSERT OR IGNORE INTO monitoring_station VALUES (3, 'Estacion Bendicion');
INSERT OR IGNORE INTO monitoring_station VALUES (4, 'Estacion Plana');

INSERT OR IGNORE INTO pumping_station VALUES (1, 1, 'Bomba Principal Norte');
INSERT OR IGNORE INTO pumping_station VALUES (2, 1, 'Bomba Auxiliar Sur');
INSERT OR IGNORE INTO pumping_station VALUES (3, 1, 'Bomba Respaldo Este');

INSERT OR IGNORE INTO alert_threshold VALUES (1, 'water_level', 0.5, 3.0, 'HIGH');
INSERT OR IGNORE INTO alert_threshold VALUES (2, 'precipitation', 0.0, 50.0, 'MEDIUM');
INSERT OR IGNORE INTO alert_threshold VALUES (3, 'motor_temperature_c', 0.0, 85.0, 'CRITICAL');
INSERT OR IGNORE INTO alert_threshold VALUES (4, 'inlet_pressure_bar', 2.0, 5.0, 'HIGH');
INSERT OR IGNORE INTO alert_threshold VALUES (5, 'wind_speed_kmh', 0.0, 60.0, 'MEDIUM');

INSERT OR IGNORE INTO notification_contact VALUES (1, 'Supervisor Operaciones', 'supervisor@promotorapalmera.com', '+573001234567', '+573001234567');
INSERT OR IGNORE INTO notification_contact VALUES (2, 'Tecnico de Campo', 'tecnico@promotorapalmera.com', '+573007654321', '+573007654321');
"""

for sql in initial_data.split(";"):
    if sql.strip():
        c.execute(sql)

db.commit()

# Mostrar resumen
print("\n" + "="*60)
print("RESUMEN DE BASE DE DATOS")
print("="*60)
print(f"✅ Estaciones: {c.execute('SELECT COUNT(*) FROM monitoring_station').fetchone()[0]}")
print(f"✅ Bombas: {c.execute('SELECT COUNT(*) FROM pumping_station').fetchone()[0]}")
print(f"✅ Umbrales: {c.execute('SELECT COUNT(*) FROM alert_threshold').fetchone()[0]}")
print(f"✅ Contactos: {c.execute('SELECT COUNT(*) FROM notification_contact').fetchone()[0]}")
print("="*60)

db.close()
print("\n✅ Base de datos lista: monitoring.db")
'@
    
    $tempFile = [System.IO.Path]::GetTempFileName() + ".py"
    Set-Content -Path $tempFile -Value $pythonScript -Encoding UTF8
    
    # Buscar Python
    $pythonExe = $null
    $pythonPaths = @(
        "C:\Python312\python.exe",
        "C:\Python311\python.exe",
        "C:\inetpub\promotorapalmera\project_estacion_bombeo\venv\Scripts\python.exe"
    )
    
    foreach ($path in $pythonPaths) {
        if (Test-Path $path) {
            $pythonExe = $path
            break
        }
    }
    
    if ($pythonExe) {
        &amp; $pythonExe $tempFile
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Base de datos creada correctamente" -ForegroundColor Green
        } else {
            Write-Host "❌ Error al crear base de datos" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ No se encontró Python" -ForegroundColor Red
        Write-Host "   Por favor instale Python desde: https://www.python.org/downloads/" -ForegroundColor Yellow
    }
    
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
}

# ============================================================
# OPCIÓN 2: SIMULADOR WOKWI
# ============================================================

function Show-Wokwi {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  SIMULADOR ESP32 CON WOKWI                                ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📌 OPCIÓN 1: Wokwi Online (Recomendado - Sin instalación)" -ForegroundColor Green
    Write-Host "   1. Visitar: https://wokwi.com/" -ForegroundColor White
    Write-Host "   2. Crear nuevo proyecto ESP32" -ForegroundColor White
    Write-Host "   3. Copiar archivos:" -ForegroundColor White
    Write-Host "      • wokwi_esp32_simulator/diagram.json → Diagrama" -ForegroundColor Gray
    Write-Host "      • wokwi_esp32_simulator/sketch.ino → Código" -ForegroundColor Gray
    Write-Host "   4. EDITAR línea 17 en sketch.ino:" -ForegroundColor Yellow
    Write-Host "      const char* serverURL = \"http://IP_LOCAL:5000/api\";" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📌 OPCIÓN 2: Wokwi CLI (Instalación requerida)" -ForegroundColor Green
    Write-Host "   npm install -g wokwi-cli" -ForegroundColor Cyan
    Write-Host "   cd wokwi_esp32_simulator" -ForegroundColor Cyan
    Write-Host "   wokwi-cli ." -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📌 FLUJO DEL SIMULADOR:" -ForegroundColor Green
    Write-Host "   [ESP32 Wokwi]" -ForegroundColor Cyan
    Write-Host "        ⬇️  (WiFi simulado)" -ForegroundColor Gray
    Write-Host "   [Flask API :5000]" -ForegroundColor Cyan
    Write-Host "        ⬇️  (Guarda datos)" -ForegroundColor Gray
    Write-Host "   [monitoring.db]" -ForegroundColor Cyan
    Write-Host "        ⬇️  (Lee datos)" -ForegroundColor Gray
    Write-Host "   [Dashboard Frontend]" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📂 Archivos Wokwi:" -ForegroundColor Cyan
    if (Test-Path "wokwi_esp32_simulator") {
        Write-Host "   ✅ wokwi_esp32_simulator/ encontrado" -ForegroundColor Green
        Get-ChildItem "wokwi_esp32_simulator" | ForEach-Object {
            Write-Host "      • $($_.Name)" -ForegroundColor Gray
        }
    }
    
    Read-Host "`nPresione Enter para volver al menú"
}

# ============================================================
# OPCIÓN 3: SERVIDOR FLASK
# ============================================================

function Start-Server {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  INICIANDO SERVIDOR FLASK                                  ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    $appFile = "app.py"
    if (-not (Test-Path $appFile)) {
        Write-Host "❌ app.py no encontrado" -ForegroundColor Red
        Read-Host "`nPresione Enter para volver"
        return
    }
    
    Write-Host "🌐 Iniciando Flask..." -ForegroundColor Cyan
    Write-Host "📍 Dashboard: http://localhost:5000" -ForegroundColor Green
    Write-Host "📍 API: http://localhost:5000/api" -ForegroundColor Green
    Write-Host ""
    Write-Host "⚠️  Presione Ctrl+C para detener el servidor" -ForegroundColor Yellow
    Write-Host ""
    
    python app.py
}

# ============================================================
# OPCIÓN 4: SISTEMA COMPLETO
# ============================================================

function Start-Complete {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║  INICIANDO SISTEMA COMPLETO                                ║" -ForegroundColor Magenta
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    
    # Verificar BD
    if (-not (Test-Path "monitoring.db")) {
        Write-Host "ℹ️  Base de datos no encontrada, creando..." -ForegroundColor Yellow
        Initialize-DB
    }
    
    Write-Host ""
    Write-Host "✅ Base de datos verificada" -ForegroundColor Green
    Write-Host "🚀 Iniciando Flask en segundo plano..." -ForegroundColor Cyan
    Write-Host ""
    
    # Iniciar Flask en background
    $flaskProcess = Start-Process python -ArgumentList "app.py" -PassThru -WindowStyle Hidden
    Start-Sleep -Seconds 3
    
    Write-Host "✅ Flask iniciado (PID: $($flaskProcess.Id))" -ForegroundColor Green
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "🎯 SIGUIENTES PASOS:" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "1️⃣  ABRIR DASHBOARD WEB" -ForegroundColor Green
    Write-Host "    http://localhost:5000" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2️⃣  INICIAR SIMULADOR WOKWI (en otra ventana)" -ForegroundColor Green
    Write-Host "    • Ir a: https://wokwi.com/" -ForegroundColor Cyan
    Write-Host "    • Crear proyecto ESP32" -ForegroundColor Cyan
    Write-Host "    • Copiar archivos de wokwi_esp32_simulator/" -ForegroundColor Cyan
    Write-Host "    • CAMBIAR IP en línea 17 de sketch.ino a tu IP local" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "3️⃣  INICIAR SIMULADOR PYTHON (opcional)" -ForegroundColor Green
    Write-Host "    python simulator_extended.py" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "📊 DATOS EN VIVO:" -ForegroundColor Cyan
    Write-Host "    • Meteorología: http://localhost:5000/api/meteorology" -ForegroundColor Gray
    Write-Host "    • Telemetría: http://localhost:5000/api/pump/telemetry" -ForegroundColor Gray
    Write-Host "    • Alertas: http://localhost:5000/api/alerts" -ForegroundColor Gray
    Write-Host ""
    Write-Host "⏹️  Para detener: Presione Ctrl+C aquí" -ForegroundColor Yellow
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    
    # Mantener el script corriendo
    while ($true) {
        Start-Sleep -Seconds 5
        
        if (-not (Get-Process -Id $flaskProcess.Id -ErrorAction SilentlyContinue)) {
            Write-Host "`n⚠️  Flask se detuvo inesperadamente" -ForegroundColor Yellow
            break
        }
    }
    
    # Limpiar
    Stop-Process -Id $flaskProcess.Id -ErrorAction SilentlyContinue
    Write-Host "`n✅ Sistema detenido" -ForegroundColor Green
}

# ============================================================
# OPCIÓN 5: DOCUMENTACIÓN
# ============================================================

function Show-Docs {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║  DOCUMENTACIÓN DISPONIBLE                                   ║" -ForegroundColor Blue
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
    
    $docs = @(
        @{ name = "README_EXTENDED.md"; desc = "Documentación técnica completa" },
        @{ name = "INICIO_RAPIDO.md"; desc = "Guía rápida de inicio" },
        @{ name = "wokwi_esp32_simulator\README_WOKWI.md"; desc = "Documentación del simulador Wokwi" },
        @{ name = "MANUAL_USUARIO.md"; desc = "Manual de usuario" }
    )
    
    Write-Host "📚 Documentos disponibles:" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($doc in $docs) {
        if (Test-Path $doc.name) {
            $lines = (Get-Content $doc.name | Measure-Object -Line).Lines
            Write-Host "   ✅ $($doc.name)" -ForegroundColor Green
            Write-Host "      $($doc.desc) ($lines líneas)" -ForegroundColor Gray
        } else {
            Write-Host "   ❌ $($doc.name)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    $option = Read-Host "¿Abrir algún documento? (nombre o 'N' para volver)"
    
    if ($option -ne "N" -and $option -ne "n" -and $option -ne "") {
        if (Test-Path $option) {
            Invoke-Item $option
        } else {
            Write-Host "❌ Archivo no encontrado" -ForegroundColor Red
        }
    }
}

# ============================================================
# BUCLE PRINCIPAL
# ============================================================

while ($true) {
    Clear-Host
    Show-Menu
    
    $choice = Read-Host "Seleccione una opción (1-6)"
    
    switch ($choice) {
        "1" { Initialize-DB }
        "2" { Show-Wokwi }
        "3" { Start-Server; pause }
        "4" { Start-Complete }
        "5" { Show-Docs }
        "6" { 
            Write-Host "`n👋 ¡Hasta luego!" -ForegroundColor Cyan
            exit 0
        }
        default {
            Write-Host "`n❌ Opción inválida" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}
