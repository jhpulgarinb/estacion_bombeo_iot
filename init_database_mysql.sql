-- ============================================================
-- SISTEMA IoT ESTACIÓN DE BOMBEO - MySQL Database Schema
-- Promotora Palmera de Antioquia S.A.S.
-- Fecha: 21 de febrero de 2026
-- Base de datos: promotorapalmera_db
-- ============================================================

-- Usar la base de datos existente
USE promotorapalmera_db;

-- ============================================================
-- TABLAS PARA SISTEMA DE ESTACIÓN DE BOMBEO
-- ============================================================

-- Tabla: Estaciones de Monitoreo
CREATE TABLE IF NOT EXISTS iot_monitoring_station (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200),
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    elevation_m DECIMAL(7,2),
    station_type VARCHAR(50),
    is_active BOOLEAN DEFAULT 1,
    auto_control_enabled BOOLEAN DEFAULT 1,
    installation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_maintenance_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_station_active (is_active),
    INDEX idx_station_type (station_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: Estaciones de Bombeo
CREATE TABLE IF NOT EXISTS iot_pumping_station (
    id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    pump_type VARCHAR(50),
    max_capacity_m3h DECIMAL(8,2),
    rated_power_kw DECIMAL(7,2),
    min_water_level_m DECIMAL(5,2) DEFAULT 0.5,
    max_water_level_m DECIMAL(5,2) DEFAULT 3.0,
    is_active BOOLEAN DEFAULT 1,
    installation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (station_id) REFERENCES iot_monitoring_station (id) ON DELETE CASCADE,
    INDEX idx_pump_station (station_id),
    INDEX idx_pump_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: Datos Meteorológicos
CREATE TABLE IF NOT EXISTS iot_meteorological_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    temperature_c DECIMAL(5,2),
    humidity_percent DECIMAL(5,2),
    precipitation_mm DECIMAL(7,2),
    wind_speed_kmh DECIMAL(6,2),
    wind_direction_deg INT,
    atmospheric_pressure_hpa DECIMAL(7,2),
    solar_radiation_wm2 DECIMAL(7,2),
    uv_index DECIMAL(4,2),
    evapotranspiration_mm DECIMAL(6,3),
    soil_moisture_percent DECIMAL(5,2),
    soil_temperature_c DECIMAL(5,2),
    leaf_wetness_percent DECIMAL(5,2),
    source_device VARCHAR(50),
    FOREIGN KEY (station_id) REFERENCES iot_monitoring_station (id) ON DELETE CASCADE,
    INDEX idx_meteorological_station_time (station_id, timestamp DESC),
    INDEX idx_meteorological_timestamp (timestamp DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: Telemetría de Bomba
CREATE TABLE IF NOT EXISTS iot_pump_telemetry (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pump_id INT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'OFF',
    flow_rate_m3h DECIMAL(8,2) DEFAULT 0.0,
    inlet_pressure_bar DECIMAL(6,2),
    outlet_pressure_bar DECIMAL(6,2),
    power_consumption_kw DECIMAL(7,2) DEFAULT 0.0,
    motor_temperature_c DECIMAL(5,2),
    vibration_level INT DEFAULT 0,
    running_hours DECIMAL(10,2),
    operational_mode VARCHAR(20) DEFAULT 'AUTO',
    source_device VARCHAR(50),
    FOREIGN KEY (pump_id) REFERENCES iot_pumping_station (id) ON DELETE CASCADE,
    INDEX idx_pump_telemetry_pump_time (pump_id, timestamp DESC),
    INDEX idx_pump_telemetry_status (status),
    INDEX idx_pump_telemetry_timestamp (timestamp DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: Nivel de Agua
CREATE TABLE IF NOT EXISTS iot_water_level (
    id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    level_m DECIMAL(6,3) NOT NULL,
    volume_m3 DECIMAL(12,2),
    trend VARCHAR(20),
    source_device VARCHAR(50),
    FOREIGN KEY (station_id) REFERENCES iot_monitoring_station (id) ON DELETE CASCADE,
    INDEX idx_water_level_station_time (station_id, timestamp DESC),
    INDEX idx_water_level_timestamp (timestamp DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: Estado de Compuertas
CREATE TABLE IF NOT EXISTS iot_gate_status (
    id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    gate_number INT NOT NULL,
    status VARCHAR(20) DEFAULT 'CLOSED',
    opening_percent DECIMAL(5,2) DEFAULT 0.0,
    flow_rate_m3s DECIMAL(8,4) DEFAULT 0.0,
    position_sensor_value DECIMAL(8,3),
    source_device VARCHAR(50),
    FOREIGN KEY (station_id) REFERENCES iot_monitoring_station (id) ON DELETE CASCADE,
    INDEX idx_gate_station_time (station_id, timestamp DESC),
    INDEX idx_gate_number (gate_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: Alertas del Sistema
CREATE TABLE IF NOT EXISTS iot_system_alert (
    id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT,
    pump_id INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    alert_type VARCHAR(50) NOT NULL,
    severity ENUM('CRITICAL', 'HIGH', 'MEDIUM', 'LOW') DEFAULT 'MEDIUM',
    title VARCHAR(200) NOT NULL,
    description TEXT,
    parameter_name VARCHAR(50),
    parameter_value DECIMAL(10,3),
    threshold_value DECIMAL(10,3),
    is_resolved BOOLEAN DEFAULT 0,
    resolved_at TIMESTAMP NULL,
    resolved_by VARCHAR(100),
    resolution_notes TEXT,
    notification_sent BOOLEAN DEFAULT 0,
    notification_channels TEXT,
    FOREIGN KEY (station_id) REFERENCES iot_monitoring_station (id) ON DELETE SET NULL,
    FOREIGN KEY (pump_id) REFERENCES iot_pumping_station (id) ON DELETE SET NULL,
    INDEX idx_system_alert_severity_time (severity, timestamp DESC),
    INDEX idx_system_alert_resolved (is_resolved, timestamp DESC),
    INDEX idx_system_alert_type (alert_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: Umbrales de Alerta
CREATE TABLE IF NOT EXISTS iot_alert_threshold (
    id INT AUTO_INCREMENT PRIMARY KEY,
    parameter_name VARCHAR(50) NOT NULL UNIQUE,
    min_value DECIMAL(10,3),
    max_value DECIMAL(10,3),
    alert_level ENUM('CRITICAL', 'HIGH', 'MEDIUM', 'LOW') DEFAULT 'MEDIUM',
    description TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_threshold_active (is_active),
    INDEX idx_threshold_parameter (parameter_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: Log de Control Automático
CREATE TABLE IF NOT EXISTS iot_automatic_control_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    pump_id INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(20) NOT NULL,
    reason TEXT,
    water_level_m DECIMAL(6,3),
    precipitation_mm DECIMAL(7,2),
    tariff_period VARCHAR(20),
    motor_temperature_c DECIMAL(5,2),
    decision_time_ms INT,
    execution_status VARCHAR(20) DEFAULT 'SUCCESS',
    error_message TEXT,
    FOREIGN KEY (station_id) REFERENCES iot_monitoring_station (id) ON DELETE CASCADE,
    FOREIGN KEY (pump_id) REFERENCES iot_pumping_station (id) ON DELETE SET NULL,
    INDEX idx_control_log_station_time (station_id, timestamp DESC),
    INDEX idx_control_log_action (action),
    INDEX idx_control_log_timestamp (timestamp DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: Contactos para Notificaciones
CREATE TABLE IF NOT EXISTS iot_notification_contact (
    id INT AUTO_INCREMENT PRIMARY KEY,
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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_contact_active (is_active),
    INDEX idx_contact_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: Resumen de Flujo Diario
CREATE TABLE IF NOT EXISTS iot_flow_summary (
    id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    date DATE NOT NULL,
    total_inflow_m3 DECIMAL(12,2) DEFAULT 0.0,
    total_outflow_m3 DECIMAL(12,2) DEFAULT 0.0,
    net_flow_m3 DECIMAL(12,2) DEFAULT 0.0,
    peak_inflow_m3h DECIMAL(8,2) DEFAULT 0.0,
    peak_outflow_m3h DECIMAL(8,2) DEFAULT 0.0,
    avg_water_level_m DECIMAL(6,3),
    min_water_level_m DECIMAL(6,3),
    max_water_level_m DECIMAL(6,3),
    total_precipitation_mm DECIMAL(8,2) DEFAULT 0.0,
    pump_running_hours DECIMAL(8,2) DEFAULT 0.0,
    energy_consumption_kwh DECIMAL(10,2) DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (station_id) REFERENCES iot_monitoring_station (id) ON DELETE CASCADE,
    UNIQUE KEY unique_station_date (station_id, date),
    INDEX idx_flow_summary_date (date DESC),
    INDEX idx_flow_summary_station (station_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- DATOS INICIALES DE PRUEBA
-- ============================================================

-- Insertar Estaciones de Monitoreo
INSERT IGNORE INTO iot_monitoring_station (id, name, location, latitude, longitude, station_type, auto_control_enabled)
VALUES 
(1, 'Estación Administración', 'Entrada principal - Chigorodó, Antioquia', 6.2442, -75.5812, 'COMBINED', 1),
(2, 'Estación Playa', 'Zona de trabajo Playa - Chigorodó', 6.2455, -75.5825, 'METEOROLOGICAL', 1),
(3, 'Estación Bendición', 'Zona de trabajo Bendición - Chigorodó', 6.2438, -75.5798, 'METEOROLOGICAL', 1),
(4, 'Estación Plana', 'Zona de trabajo Plana - Chigorodó', 6.2429, -75.5834, 'METEOROLOGICAL', 1);

-- Insertar Estaciones de Bombeo
INSERT IGNORE INTO iot_pumping_station (id, station_id, name, pump_type, max_capacity_m3h, rated_power_kw, min_water_level_m, max_water_level_m)
VALUES 
(1, 1, 'Bomba Principal Norte', 'Centrífuga', 120.0, 15.0, 0.5, 3.0),
(2, 1, 'Bomba Auxiliar Sur', 'Sumergible', 80.0, 9.5, 0.6, 2.8),
(3, 1, 'Bomba Respaldo Este', 'Centrífuga', 100.0, 11.0, 0.5, 3.0);

-- Insertar Umbrales de Alerta
INSERT IGNORE INTO iot_alert_threshold (parameter_name, min_value, max_value, alert_level, description)
VALUES 
('water_level', 0.5, 3.0, 'HIGH', 'Nivel de agua crítico (mínimo 0.5m, máximo 3.0m)'),
('precipitation', 0.0, 50.0, 'MEDIUM', 'Precipitación acumulada en 2 horas (alerta >20mm, crítico >30mm)'),
('motor_temperature_c', 0.0, 85.0, 'CRITICAL', 'Temperatura del motor (alerta >75°C, crítico >85°C)'),
('inlet_pressure_bar', 2.0, 5.0, 'HIGH', 'Presión de entrada fuera de rango (normal 2.0-5.0 bar)'),
('wind_speed_kmh', 0.0, 60.0, 'MEDIUM', 'Velocidad del viento (alerta vendaval >60 km/h)');

-- Insertar Contactos de Notificación
INSERT IGNORE INTO iot_notification_contact (name, role, email, phone, whatsapp_number, receive_critical, receive_high, receive_medium)
VALUES 
('Supervisor Operaciones', 'Supervisor', 'supervisor@promotorapalmera.com', '+573001234567', '+573001234567', 1, 1, 1),
('Técnico de Campo', 'Técnico', 'tecnico@promotorapalmera.com', '+573007654321', '+573007654321', 1, 1, 0);

-- ============================================================
-- VISTAS ÚTILES
-- ============================================================

-- Vista: Últimos datos meteorológicos por estación
CREATE OR REPLACE VIEW v_iot_latest_meteorological AS
SELECT 
    ms.id AS station_id,
    ms.name AS station_name,
    ms.location,
    md.temperature_c,
    md.humidity_percent,
    md.precipitation_mm,
    md.wind_speed_kmh,
    md.wind_direction_deg,
    md.atmospheric_pressure_hpa,
    md.solar_radiation_wm2,
    md.uv_index,
    md.timestamp,
    md.source_device
FROM iot_meteorological_data md
INNER JOIN iot_monitoring_station ms ON md.station_id = ms.id
INNER JOIN (
    SELECT station_id, MAX(id) AS max_id
    FROM iot_meteorological_data
    GROUP BY station_id
) latest ON md.station_id = latest.station_id AND md.id = latest.max_id;

-- Vista: Estado actual de bombas
CREATE OR REPLACE VIEW v_iot_pump_status AS
SELECT 
    ps.id AS pump_id,
    ps.name AS pump_name,
    ps.pump_type,
    ps.max_capacity_m3h,
    ps.rated_power_kw,
    ms.name AS station_name,
    ms.location AS station_location,
    pt.status,
    pt.flow_rate_m3h,
    pt.inlet_pressure_bar,
    pt.outlet_pressure_bar,
    pt.power_consumption_kw,
    pt.motor_temperature_c,
    pt.vibration_level,
    pt.operational_mode,
    pt.timestamp,
    pt.source_device
FROM iot_pump_telemetry pt
INNER JOIN iot_pumping_station ps ON pt.pump_id = ps.id
INNER JOIN iot_monitoring_station ms ON ps.station_id = ms.id
INNER JOIN (
    SELECT pump_id, MAX(id) AS max_id
    FROM iot_pump_telemetry
    GROUP BY pump_id
) latest ON pt.pump_id = latest.pump_id AND pt.id = latest.max_id;

-- Vista: Alertas activas ordenadas por severidad
CREATE OR REPLACE VIEW v_iot_active_alerts AS
SELECT 
    sa.id,
    sa.alert_type,
    sa.severity,
    sa.title,
    sa.description,
    sa.parameter_name,
    sa.parameter_value,
    sa.threshold_value,
    ms.name AS station_name,
    ps.name AS pump_name,
    sa.timestamp,
    TIMESTAMPDIFF(MINUTE, sa.timestamp, NOW()) AS minutes_ago,
    sa.notification_sent,
    sa.notification_channels
FROM iot_system_alert sa
LEFT JOIN iot_monitoring_station ms ON sa.station_id = ms.id
LEFT JOIN iot_pumping_station ps ON sa.pump_id = ps.id
WHERE sa.is_resolved = 0
ORDER BY 
    FIELD(sa.severity, 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'),
    sa.timestamp DESC;

-- Vista: Resumen diario último mes
CREATE OR REPLACE VIEW v_iot_flow_summary_monthly AS
SELECT 
    fs.date,
    ms.name AS station_name,
    fs.total_inflow_m3,
    fs.total_outflow_m3,
    fs.net_flow_m3,
    fs.peak_inflow_m3h,
    fs.avg_water_level_m,
    fs.total_precipitation_mm,
    fs.pump_running_hours,
    fs.energy_consumption_kwh,
    ROUND(fs.energy_consumption_kwh * 650, 2) AS estimated_cost_cop
FROM iot_flow_summary fs
INNER JOIN iot_monitoring_station ms ON fs.station_id = ms.id
WHERE fs.date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY fs.date DESC, ms.name;

-- Vista: Estado del agua actual
CREATE OR REPLACE VIEW v_iot_current_water_level AS
SELECT 
    ms.id AS station_id,
    ms.name AS station_name,
    ms.location,
    wl.level_m,
    wl.volume_m3,
    wl.trend,
    wl.timestamp,
    wl.source_device,
    CASE 
        WHEN wl.level_m < 0.5 THEN 'CRÍTICO BAJO'
        WHEN wl.level_m > 2.8 THEN 'CRÍTICO ALTO'
        WHEN wl.level_m < 1.0 THEN 'BAJO'
        WHEN wl.level_m > 2.3 THEN 'ALTO'
        ELSE 'NORMAL'
    END AS status_nivel
FROM iot_water_level wl
INNER JOIN iot_monitoring_station ms ON wl.station_id = ms.id
INNER JOIN (
    SELECT station_id, MAX(id) AS max_id
    FROM iot_water_level
    GROUP BY station_id
) latest ON wl.station_id = latest.station_id AND wl.id = latest.max_id;

-- Vista: Historial de control automático (últimas 100 acciones)
CREATE OR REPLACE VIEW v_iot_control_history AS
SELECT 
    acl.id,
    acl.timestamp,
    ms.name AS station_name,
    ps.name AS pump_name,
    acl.action,
    acl.reason,
    acl.water_level_m,
    acl.precipitation_mm,
    acl.motor_temperature_c,
    acl.tariff_period,
    acl.execution_status,
    acl.decision_time_ms
FROM iot_automatic_control_log acl
INNER JOIN iot_monitoring_station ms ON acl.station_id = ms.id
LEFT JOIN iot_pumping_station ps ON acl.pump_id = ps.id
ORDER BY acl.timestamp DESC
LIMIT 100;

-- ============================================================
-- PROCEDIMIENTOS ALMACENADOS
-- ============================================================

DELIMITER //

-- Procedimiento: Crear alerta automática al detectar umbral excedido
CREATE PROCEDURE IF NOT EXISTS sp_check_and_create_alert(
    IN p_station_id INT,
    IN p_pump_id INT,
    IN p_parameter_name VARCHAR(50),
    IN p_parameter_value DECIMAL(10,3)
)
BEGIN
    DECLARE v_threshold_min DECIMAL(10,3);
    DECLARE v_threshold_max DECIMAL(10,3);
    DECLARE v_alert_level VARCHAR(20);
    DECLARE v_description TEXT;
    DECLARE v_alert_title VARCHAR(200);
    
    -- Obtener umbral configurado
    SELECT min_value, max_value, alert_level, description
    INTO v_threshold_min, v_threshold_max, v_alert_level, v_description
    FROM iot_alert_threshold
    WHERE parameter_name = p_parameter_name AND is_active = 1
    LIMIT 1;
    
    -- Verificar si se excede el umbral
    IF (p_parameter_value < v_threshold_min OR p_parameter_value > v_threshold_max) THEN
        
        -- Construir título de alerta
        SET v_alert_title = CONCAT('Alerta: ', p_parameter_name, ' fuera de rango');
        
        -- Insertar alerta solo si no existe una alerta sin resolver del mismo tipo
        INSERT INTO iot_system_alert (
            station_id, pump_id, alert_type, severity, title, description,
            parameter_name, parameter_value, threshold_value, notification_sent
        )
        SELECT 
            p_station_id, p_pump_id, p_parameter_name, v_alert_level, v_alert_title, v_description,
            p_parameter_name, p_parameter_value, 
            IF(p_parameter_value < v_threshold_min, v_threshold_min, v_threshold_max),
            0
        FROM DUAL
        WHERE NOT EXISTS (
            SELECT 1 FROM iot_system_alert
            WHERE parameter_name = p_parameter_name
              AND is_resolved = 0
              AND station_id = p_station_id
              AND IFNULL(pump_id, 0) = IFNULL(p_pump_id, 0)
              AND timestamp > DATE_SUB(NOW(), INTERVAL 1 HOUR)
        );
    END IF;
END//

-- Procedimiento: Registrar telemetría de bomba con verificación automática
CREATE PROCEDURE IF NOT EXISTS sp_insert_pump_telemetry(
    IN p_pump_id INT,
    IN p_status VARCHAR(20),
    IN p_flow_rate_m3h DECIMAL(8,2),
    IN p_inlet_pressure_bar DECIMAL(6,2),
    IN p_outlet_pressure_bar DECIMAL(6,2),
    IN p_power_consumption_kw DECIMAL(7,2),
    IN p_motor_temperature_c DECIMAL(5,2),
    IN p_vibration_level INT,
    IN p_running_hours DECIMAL(10,2),
    IN p_operational_mode VARCHAR(20),
    IN p_source_device VARCHAR(50)
)
BEGIN
    DECLARE v_station_id INT;
    
    -- Insertar telemetría
    INSERT INTO iot_pump_telemetry (
        pump_id, status, flow_rate_m3h, inlet_pressure_bar, outlet_pressure_bar,
        power_consumption_kw, motor_temperature_c, vibration_level, running_hours,
        operational_mode, source_device
    ) VALUES (
        p_pump_id, p_status, p_flow_rate_m3h, p_inlet_pressure_bar, p_outlet_pressure_bar,
        p_power_consumption_kw, p_motor_temperature_c, p_vibration_level, p_running_hours,
        p_operational_mode, p_source_device
    );
    
    -- Obtener station_id de la bomba
    SELECT station_id INTO v_station_id
    FROM iot_pumping_station
    WHERE id = p_pump_id;
    
    -- Verificar temperatura del motor
    CALL sp_check_and_create_alert(v_station_id, p_pump_id, 'motor_temperature_c', p_motor_temperature_c);
    
    -- Verificar presión de entrada
    CALL sp_check_and_create_alert(v_station_id, p_pump_id, 'inlet_pressure_bar', p_inlet_pressure_bar);
END//

DELIMITER ;

-- ============================================================
-- EVENTOS PROGRAMADOS (requiere event_scheduler = ON)
-- ============================================================

-- Evento: Limpiar datos antiguos de telemetría (más de 90 días)
CREATE EVENT IF NOT EXISTS evt_cleanup_old_telemetry
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DELETE FROM iot_pump_telemetry WHERE timestamp < DATE_SUB(NOW(), INTERVAL 90 DAY);
    DELETE FROM iot_meteorological_data WHERE timestamp < DATE_SUB(NOW(), INTERVAL 90 DAY);
    DELETE FROM iot_water_level WHERE timestamp < DATE_SUB(NOW(), INTERVAL 90 DAY);
    DELETE FROM iot_gate_status WHERE timestamp < DATE_SUB(NOW(), INTERVAL 90 DAY);
END;

-- Evento: Generar resumen diario automático a las 23:59
CREATE EVENT IF NOT EXISTS evt_generate_daily_summary
ON SCHEDULE EVERY 1 DAY
STARTS CONCAT(CURDATE(), ' 23:59:00')
DO
BEGIN
    INSERT INTO iot_flow_summary (
        station_id, date, total_inflow_m3, total_outflow_m3, 
        avg_water_level_m, min_water_level_m, max_water_level_m,
        total_precipitation_mm, pump_running_hours, energy_consumption_kwh
    )
    SELECT 
        ms.id AS station_id,
        CURDATE() AS date,
        0 AS total_inflow_m3,
        0 AS total_outflow_m3,
        AVG(wl.level_m) AS avg_water_level_m,
        MIN(wl.level_m) AS min_water_level_m,
        MAX(wl.level_m) AS max_water_level_m,
        SUM(md.precipitation_mm) AS total_precipitation_mm,
        SUM(CASE WHEN pt.status = 'ON' THEN 0.25 ELSE 0 END) AS pump_running_hours,
        SUM(CASE WHEN pt.status = 'ON' THEN pt.power_consumption_kw * 0.25 ELSE 0 END) AS energy_consumption_kwh
    FROM iot_monitoring_station ms
    LEFT JOIN iot_water_level wl ON wl.station_id = ms.id AND DATE(wl.timestamp) = CURDATE()
    LEFT JOIN iot_meteorological_data md ON md.station_id = ms.id AND DATE(md.timestamp) = CURDATE()
    LEFT JOIN iot_pumping_station ps ON ps.station_id = ms.id
    LEFT JOIN iot_pump_telemetry pt ON pt.pump_id = ps.id AND DATE(pt.timestamp) = CURDATE()
    GROUP BY ms.id
    ON DUPLICATE KEY UPDATE
        avg_water_level_m = VALUES(avg_water_level_m),
        min_water_level_m = VALUES(min_water_level_m),
        max_water_level_m = VALUES(max_water_level_m),
        total_precipitation_mm = VALUES(total_precipitation_mm),
        pump_running_hours = VALUES(pump_running_hours),
        energy_consumption_kwh = VALUES(energy_consumption_kwh);
END;

-- ============================================================
-- VERIFICACIÓN E INFORMACIÓN
-- ============================================================

-- Mostrar resumen de tablas creadas
SELECT 'TABLAS CREADAS:' AS status;
SELECT TABLE_NAME, TABLE_ROWS, 
       ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024, 2) AS size_kb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'promotorapalmera_db'
  AND TABLE_NAME LIKE 'iot_%'
ORDER BY TABLE_NAME;

SELECT 'VISTAS CREADAS:' AS status;
SELECT TABLE_NAME AS view_name
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'promotorapalmera_db'
  AND TABLE_NAME LIKE 'v_iot_%'
ORDER BY TABLE_NAME;

SELECT 'DATOS INSERTADOS:' AS status;
SELECT 
    (SELECT COUNT(*) FROM iot_monitoring_station) AS estaciones,
    (SELECT COUNT(*) FROM iot_pumping_station) AS bombas,
    (SELECT COUNT(*) FROM iot_alert_threshold) AS umbrales,
    (SELECT COUNT(*) FROM iot_notification_contact) AS contactos;

SELECT '✅ Base de datos MySQL inicializada correctamente en promotorapalmera_db' AS mensaje;
SELECT 'Prefijo de tablas: iot_' AS info;
SELECT 'Total de tablas creadas: 11' AS info;
SELECT 'Total de vistas creadas: 5' AS info;
SELECT 'Total de procedimientos: 2' AS info;
SELECT 'Total de eventos programados: 2' AS info;

