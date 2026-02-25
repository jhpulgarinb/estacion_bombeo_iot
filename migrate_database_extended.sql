-- =====================================================================
-- MIGRACIÓN DE BASE DE DATOS - SISTEMA DE AUTOMATIZACIÓN COMPLETO
-- Promotora Palmera de Antioquia S.A.S.
-- Fecha: 20 de febrero de 2026
-- =====================================================================

-- TABLA 1: Datos meteorológicos
CREATE TABLE IF NOT EXISTS meteorological_data (
    id SERIAL PRIMARY KEY,
    station_id INT NOT NULL,
    precipitation_mm DECIMAL(6,2) DEFAULT 0.0,
    wind_speed_kmh DECIMAL(5,2) DEFAULT 0.0,
    wind_direction_deg INT DEFAULT 0,
    temperature_c DECIMAL(4,2),
    humidity_percent DECIMAL(5,2),
    pressure_hpa DECIMAL(6,2),
    solar_radiation_wm2 DECIMAL(7,2),
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_device VARCHAR(50)
);

CREATE INDEX idx_meteorological_timestamp ON meteorological_data(timestamp);
CREATE INDEX idx_meteorological_station ON meteorological_data(station_id);

-- TABLA 2: Telemetría de bomba extendida
CREATE TABLE IF NOT EXISTS pump_telemetry (
    id SERIAL PRIMARY KEY,
    pump_id INT NOT NULL,
    is_running BOOLEAN NOT NULL DEFAULT FALSE,
    flow_rate_m3h DECIMAL(8,3) DEFAULT 0.0,
    inlet_pressure_bar DECIMAL(6,3) DEFAULT 0.0,
    outlet_pressure_bar DECIMAL(6,3) DEFAULT 0.0,
    power_consumption_kwh DECIMAL(10,3) DEFAULT 0.0,
    motor_temperature_c DECIMAL(5,2),
    running_hours DECIMAL(12,2) DEFAULT 0.0,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_device VARCHAR(50)
);

CREATE INDEX idx_pump_telemetry_timestamp ON pump_telemetry(timestamp);
CREATE INDEX idx_pump_telemetry_pump ON pump_telemetry(pump_id);

-- TABLA 3: Alertas y eventos del sistema
CREATE TABLE IF NOT EXISTS system_alerts (
    id SERIAL PRIMARY KEY,
    alert_type VARCHAR(50) NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    station_id INT NOT NULL,
    message TEXT NOT NULL,
    notified_via VARCHAR(100),
    resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolved_by VARCHAR(100)
);

CREATE INDEX idx_alerts_severity ON system_alerts(severity);
CREATE INDEX idx_alerts_resolved ON system_alerts(resolved);
CREATE INDEX idx_alerts_created ON system_alerts(created_at);

-- TABLA 4: Umbrales configurables para alertas
CREATE TABLE IF NOT EXISTS alert_thresholds (
    id SERIAL PRIMARY KEY,
    station_id INT NOT NULL,
    parameter_name VARCHAR(100) NOT NULL,
    min_value DECIMAL(12,4),
    max_value DECIMAL(12,4),
    alert_level VARCHAR(20) CHECK (alert_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    notification_method VARCHAR(100) DEFAULT 'EMAIL',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_thresholds_station ON alert_thresholds(station_id);
CREATE INDEX idx_thresholds_active ON alert_thresholds(is_active);

-- TABLA 5: Log de control automático
CREATE TABLE IF NOT EXISTS automatic_control_log (
    id SERIAL PRIMARY KEY,
    pump_id INT NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('START', 'STOP', 'MANUAL_OVERRIDE')),
    reason TEXT,
    water_level_m DECIMAL(6,3),
    precipitation_mm DECIMAL(6,2),
    energy_tariff VARCHAR(20),
    threshold_triggered VARCHAR(100),
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_control_log_pump ON automatic_control_log(pump_id);
CREATE INDEX idx_control_log_timestamp ON automatic_control_log(timestamp);

-- TABLA 6: Estaciones de monitoreo (extendida)
CREATE TABLE IF NOT EXISTS monitoring_stations (
    id SERIAL PRIMARY KEY,
    station_name VARCHAR(100) NOT NULL UNIQUE,
    station_type VARCHAR(50) CHECK (station_type IN ('PUMPING', 'METEOROLOGICAL', 'COMBINED')),
    location VARCHAR(255),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    is_active BOOLEAN DEFAULT TRUE,
    auto_control_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLA 7: Contactos para notificaciones
CREATE TABLE IF NOT EXISTS notification_contacts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(20),
    whatsapp_number VARCHAR(20),
    role VARCHAR(50),
    station_id INT,
    receive_critical BOOLEAN DEFAULT TRUE,
    receive_high BOOLEAN DEFAULT TRUE,
    receive_medium BOOLEAN DEFAULT FALSE,
    receive_low BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_contacts_station ON notification_contacts(station_id);
CREATE INDEX idx_contacts_active ON notification_contacts(is_active);

-- TABLA 8: Configuración de tarifas energéticas
CREATE TABLE IF NOT EXISTS energy_tariffs (
    id SERIAL PRIMARY KEY,
    tariff_name VARCHAR(50) NOT NULL,
    hour_start TIME NOT NULL,
    hour_end TIME NOT NULL,
    tariff_type VARCHAR(20) CHECK (tariff_type IN ('PEAK', 'VALLEY', 'STANDARD')),
    cost_per_kwh DECIMAL(10,4),
    days_of_week VARCHAR(50) DEFAULT '1,2,3,4,5,6,7',
    is_active BOOLEAN DEFAULT TRUE
);

-- TABLA 9: Resúmenes de eficiencia energética
CREATE TABLE IF NOT EXISTS energy_efficiency_summary (
    id SERIAL PRIMARY KEY,
    pump_id INT NOT NULL,
    date DATE NOT NULL,
    total_kwh DECIMAL(12,3),
    total_cost DECIMAL(12,2),
    running_hours DECIMAL(8,2),
    water_pumped_m3 DECIMAL(12,3),
    efficiency_kwh_per_m3 DECIMAL(8,4),
    peak_hours DECIMAL(6,2),
    valley_hours DECIMAL(6,2)
);

CREATE INDEX idx_efficiency_pump_date ON energy_efficiency_summary(pump_id, date);

-- TABLA 10: Reportes automáticos generados
CREATE TABLE IF NOT EXISTS automated_reports (
    id SERIAL PRIMARY KEY,
    report_type VARCHAR(50) NOT NULL,
    station_id INT,
    date_from DATE NOT NULL,
    date_to DATE NOT NULL,
    file_path VARCHAR(255),
    sent_to VARCHAR(500),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- DATOS INICIALES (SEED DATA)
-- =====================================================================

-- Insertar estaciones de ejemplo
INSERT INTO monitoring_stations (station_name, station_type, location, is_active, auto_control_enabled) VALUES
('Estación Principal Finca Administración', 'COMBINED', 'Finca Administración - Sector Norte', TRUE, TRUE),
('Estación Meteorológica Playa', 'METEOROLOGICAL', 'Finca La Playa - Zona Central', TRUE, FALSE),
('Bomba Auxiliar La Bendición', 'PUMPING', 'Finca La Bendición - Lote 5', TRUE, FALSE),
('Estación Plana', 'COMBINED', 'Finca La Plana - Entrada Principal', TRUE, TRUE);

-- Insertar umbrales de ejemplo
INSERT INTO alert_thresholds (station_id, parameter_name, min_value, max_value, alert_level, notification_method) VALUES
(1, 'water_level_m', 0.5, 3.0, 'HIGH', 'WHATSAPP,EMAIL'),
(1, 'flow_rate_m3h', 10.0, 200.0, 'MEDIUM', 'EMAIL'),
(1, 'motor_temperature_c', NULL, 85.0, 'CRITICAL', 'WHATSAPP,EMAIL,SMS'),
(1, 'inlet_pressure_bar', 2.0, 8.0, 'HIGH', 'WHATSAPP,EMAIL'),
(1, 'precipitation_mm', NULL, 50.0, 'MEDIUM', 'EMAIL');

-- Insertar contactos de ejemplo
INSERT INTO notification_contacts (name, email, phone, whatsapp_number, role, station_id) VALUES
('Jorge Hugo Pulgarin', 'jhpulgarin@gmail.com', '+573135609535', '+573135609535', 'Administrador', 1),
('Supervisor de Campo', 'supervisor@ppasas.com', '+573001234567', '+573001234567', 'Operador', 1);

-- Insertar tarifas energéticas (ejemplo Colombia)
INSERT INTO energy_tariffs (tariff_name, hour_start, hour_end, tariff_type, cost_per_kwh) VALUES
('Tarifa Valle Madrugada', '00:00:00', '06:00:00', 'VALLEY', 450.00),
('Tarifa Pico Mañana', '06:00:00', '10:00:00', 'PEAK', 850.00),
('Tarifa Estándar Día', '10:00:00', '18:00:00', 'STANDARD', 600.00),
('Tarifa Pico Noche', '18:00:00', '22:00:00', 'PEAK', 850.00),
('Tarifa Valle Noche', '22:00:00', '23:59:59', 'VALLEY', 450.00);

-- =====================================================================
-- VISTAS ÚTILES
-- =====================================================================

-- Vista: Estado actual de todas las estaciones
CREATE OR REPLACE VIEW v_current_station_status AS
SELECT 
    ms.id,
    ms.station_name,
    ms.station_type,
    ms.auto_control_enabled,
    pt.is_running,
    pt.flow_rate_m3h,
    pt.power_consumption_kwh,
    pt.motor_temperature_c,
    pt.timestamp as last_pump_update,
    md.temperature_c,
    md.precipitation_mm,
    md.wind_speed_kmh,
    md.timestamp as last_weather_update
FROM monitoring_stations ms
LEFT JOIN LATERAL (
    SELECT * FROM pump_telemetry 
    WHERE pump_id = ms.id 
    ORDER BY timestamp DESC 
    LIMIT 1
) pt ON TRUE
LEFT JOIN LATERAL (
    SELECT * FROM meteorological_data 
    WHERE station_id = ms.id 
    ORDER BY timestamp DESC 
    LIMIT 1
) md ON TRUE
WHERE ms.is_active = TRUE;

-- Vista: Alertas activas pendientes
CREATE OR REPLACE VIEW v_active_alerts AS
SELECT 
    sa.id,
    sa.alert_type,
    sa.severity,
    ms.station_name,
    sa.message,
    sa.created_at,
    EXTRACT(EPOCH FROM (NOW() - sa.created_at))/3600 as hours_open
FROM system_alerts sa
JOIN monitoring_stations ms ON sa.station_id = ms.id
WHERE sa.resolved = FALSE
ORDER BY 
    CASE sa.severity
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
    END,
    sa.created_at ASC;

-- =====================================================================
-- COMENTARIOS FINALES
-- =====================================================================

COMMENT ON TABLE meteorological_data IS 'Datos de sensores meteorológicos (lluvia, viento, temperatura, etc.)';
COMMENT ON TABLE pump_telemetry IS 'Telemetría completa de bombas (caudal, presión, energía, temperatura)';
COMMENT ON TABLE system_alerts IS 'Registro de alertas y eventos del sistema';
COMMENT ON TABLE alert_thresholds IS 'Umbrales configurables para generación automática de alertas';
COMMENT ON TABLE automatic_control_log IS 'Historial de decisiones del sistema de control automático';
COMMENT ON TABLE energy_tariffs IS 'Configuración de tarifas energéticas para optimización de costos';

-- Finalizado: 20 de febrero de 2026
