-- ============================================================
-- SISTEMA IoT ESTACIÓN DE BOMBEO - SQLite Database Schema
-- Promotora Palmera de Antioquia S.A.S.
-- Fecha: 20 de febrero de 2026
-- ============================================================

-- Tabla: Estaciones de Monitoreo
CREATE TABLE IF NOT EXISTS monitoring_station (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200),
    latitude REAL,
    longitude REAL,
    elevation_m REAL,
    station_type VARCHAR(50),
    is_active BOOLEAN DEFAULT 1,
    auto_control_enabled BOOLEAN DEFAULT 1,
    installation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_maintenance_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: Estaciones de Bombeo
CREATE TABLE IF NOT EXISTS pumping_station (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    pump_type VARCHAR(50),
    max_capacity_m3h REAL,
    rated_power_kw REAL,
    min_water_level_m REAL DEFAULT 0.5,
    max_water_level_m REAL DEFAULT 3.0,
    is_active BOOLEAN DEFAULT 1,
    installation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id)
);

-- Tabla: Datos Meteorológicos
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
);

-- Índice para consultas rápidas por estación y fecha
CREATE INDEX IF NOT EXISTS idx_meteorological_station_time 
ON meteorological_data(station_id, timestamp DESC);

-- Tabla: Telemetría de Bomba
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
);

-- Índice para consultas rápidas
CREATE INDEX IF NOT EXISTS idx_pump_telemetry_pump_time 
ON pump_telemetry(pump_id, timestamp DESC);

-- Tabla: Nivel de Agua
CREATE TABLE IF NOT EXISTS water_level (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id INTEGER NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    level_m REAL NOT NULL,
    volume_m3 REAL,
    trend VARCHAR(20),
    source_device VARCHAR(50),
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id)
);

CREATE INDEX IF NOT EXISTS idx_water_level_station_time 
ON water_level(station_id, timestamp DESC);

-- Tabla: Estado de Compuertas
CREATE TABLE IF NOT EXISTS gate_status (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id INTEGER NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    gate_number INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'CLOSED',
    opening_percent REAL DEFAULT 0.0,
    flow_rate_m3s REAL DEFAULT 0.0,
    position_sensor_value REAL,
    source_device VARCHAR(50),
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id)
);

-- Tabla: Alertas del Sistema
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
    resolved_by VARCHAR(100),
    resolution_notes TEXT,
    notification_sent BOOLEAN DEFAULT 0,
    notification_channels TEXT,
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id),
    FOREIGN KEY (pump_id) REFERENCES pumping_station (id)
);

CREATE INDEX IF NOT EXISTS idx_system_alert_severity_time 
ON system_alert(severity, timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_system_alert_resolved 
ON system_alert(is_resolved, timestamp DESC);

-- Tabla: Umbrales de Alerta
CREATE TABLE IF NOT EXISTS alert_threshold (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    parameter_name VARCHAR(50) NOT NULL UNIQUE,
    min_value REAL,
    max_value REAL,
    alert_level VARCHAR(20) DEFAULT 'MEDIUM',
    description TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: Log de Control Automático
CREATE TABLE IF NOT EXISTS automatic_control_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id INTEGER NOT NULL,
    pump_id INTEGER,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(20) NOT NULL,
    reason TEXT,
    water_level_m REAL,
    precipitation_mm REAL,
    tariff_period VARCHAR(20),
    motor_temperature_c REAL,
    decision_time_ms INTEGER,
    execution_status VARCHAR(20) DEFAULT 'SUCCESS',
    error_message TEXT,
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id),
    FOREIGN KEY (pump_id) REFERENCES pumping_station (id)
);

CREATE INDEX IF NOT EXISTS idx_control_log_station_time 
ON automatic_control_log(station_id, timestamp DESC);

-- Tabla: Contactos para Notificaciones
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
    receive_low BOOLEAN DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: Resumen de Flujo
CREATE TABLE IF NOT EXISTS flow_summary (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id INTEGER NOT NULL,
    date DATE NOT NULL,
    total_inflow_m3 REAL DEFAULT 0.0,
    total_outflow_m3 REAL DEFAULT 0.0,
    net_flow_m3 REAL DEFAULT 0.0,
    peak_inflow_m3h REAL DEFAULT 0.0,
    peak_outflow_m3h REAL DEFAULT 0.0,
    avg_water_level_m REAL,
    min_water_level_m REAL,
    max_water_level_m REAL,
    total_precipitation_mm REAL DEFAULT 0.0,
    pump_running_hours REAL DEFAULT 0.0,
    energy_consumption_kwh REAL DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (station_id) REFERENCES monitoring_station (id),
    UNIQUE (station_id, date)
);

-- ============================================================
-- DATOS INICIALES DE PRUEBA
-- ============================================================

-- Insertar Estaciones de Monitoreo
INSERT OR IGNORE INTO monitoring_station (id, name, location, latitude, longitude, station_type, auto_control_enabled)
VALUES 
(1, 'Estación Administración', 'Entrada principal - Chigorodó', 6.2442, -75.5812, 'COMBINED', 1),
(2, 'Estación Playa', 'Zona de trabajo Playa', 6.2455, -75.5825, 'METEOROLOGICAL', 1),
(3, 'Estación Bendición', 'Zona de trabajo Bendición', 6.2438, -75.5798, 'METEOROLOGICAL', 1),
(4, 'Estación Plana', 'Zona de trabajo Plana', 6.2429, -75.5834, 'METEOROLOGICAL', 1);

-- Insertar Estaciones de Bombeo
INSERT OR IGNORE INTO pumping_station (id, station_id, name, pump_type, max_capacity_m3h, rated_power_kw, min_water_level_m, max_water_level_m)
VALUES 
(1, 1, 'Bomba Principal Norte', 'Centrífuga', 120.0, 15.0, 0.5, 3.0),
(2, 1, 'Bomba Auxiliar Sur', 'Sumergible', 80.0, 9.5, 0.6, 2.8),
(3, 1, 'Bomba Respaldo Este', 'Centrífuga', 100.0, 11.0, 0.5, 3.0);

-- Insertar Umbrales de Alerta
INSERT OR IGNORE INTO alert_threshold (parameter_name, min_value, max_value, alert_level, description)
VALUES 
('water_level', 0.5, 3.0, 'HIGH', 'Nivel de agua crítico (mínimo 0.5m, máximo 3.0m)'),
('precipitation', 0.0, 50.0, 'MEDIUM', 'Precipitación acumulada en 2 horas (alerta >20mm, crítico >30mm)'),
('motor_temperature_c', 0.0, 85.0, 'CRITICAL', 'Temperatura del motor (alerta >75°C, crítico >85°C)'),
('inlet_pressure_bar', 2.0, 5.0, 'HIGH', 'Presión de entrada fuera de rango (normal 2.0-5.0 bar)'),
('wind_speed_kmh', 0.0, 60.0, 'MEDIUM', 'Velocidad del viento (alerta vendaval >60 km/h)');

-- Insertar Contactos de Notificación
INSERT OR IGNORE INTO notification_contact (name, role, email, phone, whatsapp_number, receive_critical, receive_high, receive_medium)
VALUES 
('Supervisor Operaciones', 'Supervisor', 'supervisor@promotorapalmera.com', '+573001234567', '+573001234567', 1, 1, 1),
('Técnico de Campo', 'Técnico', 'tecnico@promotorapalmera.com', '+573007654321', '+573007654321', 1, 1, 0);

-- ============================================================
-- VIEWS ÚTILES
-- ============================================================

-- Vista: Últimos datos meteorológicos por estación
CREATE VIEW IF NOT EXISTS v_latest_meteorological AS
SELECT 
    ms.id AS station_id,
    ms.name AS station_name,
    md.temperature_c,
    md.humidity_percent,
    md.precipitation_mm,
    md.wind_speed_kmh,
    md.wind_direction_deg,
    md.atmospheric_pressure_hpa,
    md.timestamp
FROM meteorological_data md
INNER JOIN monitoring_station ms ON md.station_id = ms.id
WHERE md.id IN (
    SELECT MAX(id) 
    FROM meteorological_data 
    GROUP BY station_id
);

-- Vista: Estado actual de bombas
CREATE VIEW IF NOT EXISTS v_pump_status AS
SELECT 
    ps.id AS pump_id,
    ps.name AS pump_name,
    ms.name AS station_name,
    pt.status,
    pt.flow_rate_m3h,
    pt.power_consumption_kw,
    pt.motor_temperature_c,
    pt.operational_mode,
    pt.timestamp
FROM pump_telemetry pt
INNER JOIN pumping_station ps ON pt.pump_id = ps.id
INNER JOIN monitoring_station ms ON ps.station_id = ms.id
WHERE pt.id IN (
    SELECT MAX(id) 
    FROM pump_telemetry 
    GROUP BY pump_id
);

-- Vista: Alertas activas
CREATE VIEW IF NOT EXISTS v_active_alerts AS
SELECT 
    sa.id,
    ms.name AS station_name,
    ps.name AS pump_name,
    sa.alert_type,
    sa.severity,
    sa.title,
    sa.description,
    sa.timestamp,
    CAST((julianday('now') - julianday(sa.timestamp)) * 24 * 60 AS INTEGER) AS minutes_ago
FROM system_alert sa
LEFT JOIN monitoring_station ms ON sa.station_id = ms.id
LEFT JOIN pumping_station ps ON sa.pump_id = ps.id
WHERE sa.is_resolved = 0
ORDER BY 
    CASE sa.severity 
        WHEN 'CRITICAL' THEN 1 
        WHEN 'HIGH' THEN 2 
        WHEN 'MEDIUM' THEN 3 
        ELSE 4 
    END,
    sa.timestamp DESC;

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Trigger: Actualizar timestamp de monitoring_station al modificar
CREATE TRIGGER IF NOT EXISTS trig_monitoring_station_updated
AFTER UPDATE ON monitoring_station
BEGIN
    UPDATE monitoring_station 
    SET updated_at = CURRENT_TIMESTAMP 
    WHERE id = NEW.id;
END;

-- Trigger: Actualizar timestamp de pumping_station al modificar
CREATE TRIGGER IF NOT EXISTS trig_pumping_station_updated
AFTER UPDATE ON pumping_station
BEGIN
    UPDATE pumping_station 
    SET updated_at = CURRENT_TIMESTAMP 
    WHERE id = NEW.id;
END;

-- ============================================================
-- VERIFICACIÓN
-- ============================================================

-- Mostrar resumen de tablas creadas
SELECT 'TABLAS CREADAS:' AS status;
SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;

SELECT 'VISTAS CREADAS:' AS status;
SELECT name FROM sqlite_master WHERE type='view' ORDER BY name;

SELECT 'DATOS INSERTADOS:' AS status;
SELECT COUNT(*) AS estaciones FROM monitoring_station;
SELECT COUNT(*) AS bombas FROM pumping_station;
SELECT COUNT(*) AS umbrales FROM alert_threshold;
SELECT COUNT(*) AS contactos FROM notification_contact;

SELECT '✅ Base de datos inicializada correctamente' AS mensaje;
