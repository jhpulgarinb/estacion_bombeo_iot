-- ============================================================
-- SISTEMA IoT ESTACIÓN DE BOMBEO - MySQL Database Schema
-- Proyecto de grado
-- Fecha: 21 de febrero de 2026
-- Base de datos: estacion_bombeo
-- VERSIÓN EN ESPAÑOL
-- ============================================================

-- Usar la base de datos existente
USE estacion_bombeo;

-- ============================================================
-- TABLAS PARA SISTEMA DE ESTACIÓN DE BOMBEO
-- ============================================================

-- Tabla: Estaciones de Monitoreo
CREATE TABLE IF NOT EXISTS iot_estacion_monitoreo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(200),
    latitud DECIMAL(10,7),
    longitud DECIMAL(10,7),
    elevacion_m DECIMAL(7,2),
    tipo_estacion VARCHAR(50),
    activo BOOLEAN DEFAULT 1,
    control_automatico_habilitado BOOLEAN DEFAULT 1,
    fecha_instalacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_ultimo_mantenimiento TIMESTAMP NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_estacion_activo (activo),
    INDEX idx_tipo_estacion (tipo_estacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Estaciones de monitoreo distribuidas geográficamente';

-- Tabla: Estaciones de Bombeo
CREATE TABLE IF NOT EXISTS iot_estacion_bombeo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estacion_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    tipo_bomba VARCHAR(50),
    capacidad_maxima_m3h DECIMAL(8,2),
    potencia_nominal_kw DECIMAL(7,2),
    nivel_minimo_agua_m DECIMAL(5,2) DEFAULT 0.5,
    nivel_maximo_agua_m DECIMAL(5,2) DEFAULT 3.0,
    activo BOOLEAN DEFAULT 1,
    fecha_instalacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (estacion_id) REFERENCES iot_estacion_monitoreo (id) ON DELETE CASCADE,
    INDEX idx_bomba_estacion (estacion_id),
    INDEX idx_bomba_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Estaciones de bombeo asociadas a estaciones de monitoreo';

-- Tabla: Datos Meteorológicos
CREATE TABLE IF NOT EXISTS iot_datos_meteorologicos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estacion_id INT NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    temperatura_c DECIMAL(5,2),
    humedad_porcentaje DECIMAL(5,2),
    precipitacion_mm DECIMAL(7,2),
    velocidad_viento_kmh DECIMAL(6,2),
    direccion_viento_grados INT,
    presion_atmosferica_hpa DECIMAL(7,2),
    radiacion_solar_wm2 DECIMAL(7,2),
    indice_uv DECIMAL(4,2),
    evapotranspiracion_mm DECIMAL(6,3),
    humedad_suelo_porcentaje DECIMAL(5,2),
    temperatura_suelo_c DECIMAL(5,2),
    humedad_hoja_porcentaje DECIMAL(5,2),
    dispositivo_origen VARCHAR(50),
    FOREIGN KEY (estacion_id) REFERENCES iot_estacion_monitoreo (id) ON DELETE CASCADE,
    INDEX idx_meteorologico_estacion_fecha (estacion_id, fecha_hora DESC),
    INDEX idx_meteorologico_fecha (fecha_hora DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Datos meteorológicos capturados por sensores';

-- Tabla: Telemetría de Bomba
CREATE TABLE IF NOT EXISTS iot_telemetria_bomba (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bomba_id INT NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'APAGADO',
    caudal_m3h DECIMAL(8,2) DEFAULT 0.0,
    presion_entrada_bar DECIMAL(6,2),
    presion_salida_bar DECIMAL(6,2),
    consumo_energia_kw DECIMAL(7,2) DEFAULT 0.0,
    temperatura_motor_c DECIMAL(5,2),
    nivel_vibracion INT DEFAULT 0,
    horas_operacion DECIMAL(10,2),
    modo_operacion VARCHAR(20) DEFAULT 'AUTO',
    dispositivo_origen VARCHAR(50),
    FOREIGN KEY (bomba_id) REFERENCES iot_estacion_bombeo (id) ON DELETE CASCADE,
    INDEX idx_telemetria_bomba_fecha (bomba_id, fecha_hora DESC),
    INDEX idx_telemetria_estado (estado),
    INDEX idx_telemetria_fecha (fecha_hora DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Telemetría operacional de las bombas';

-- Tabla: Nivel de Agua
CREATE TABLE IF NOT EXISTS iot_nivel_agua (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estacion_id INT NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nivel_m DECIMAL(6,3) NOT NULL,
    volumen_m3 DECIMAL(12,2),
    tendencia VARCHAR(20),
    dispositivo_origen VARCHAR(50),
    FOREIGN KEY (estacion_id) REFERENCES iot_estacion_monitoreo (id) ON DELETE CASCADE,
    INDEX idx_nivel_estacion_fecha (estacion_id, fecha_hora DESC),
    INDEX idx_nivel_fecha (fecha_hora DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Mediciones de nivel de agua';

-- Tabla: Estado de Compuertas
CREATE TABLE IF NOT EXISTS iot_estado_compuerta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estacion_id INT NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    numero_compuerta INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'CERRADO',
    apertura_porcentaje DECIMAL(5,2) DEFAULT 0.0,
    caudal_m3s DECIMAL(8,4) DEFAULT 0.0,
    valor_sensor_posicion DECIMAL(8,3),
    dispositivo_origen VARCHAR(50),
    FOREIGN KEY (estacion_id) REFERENCES iot_estacion_monitoreo (id) ON DELETE CASCADE,
    INDEX idx_compuerta_estacion_fecha (estacion_id, fecha_hora DESC),
    INDEX idx_compuerta_numero (numero_compuerta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Estado de compuertas y válvulas';

-- Tabla: Alertas del Sistema
CREATE TABLE IF NOT EXISTS iot_alerta_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estacion_id INT,
    bomba_id INT,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_alerta VARCHAR(50) NOT NULL,
    severidad ENUM('CRITICO', 'ALTO', 'MEDIO', 'BAJO') DEFAULT 'MEDIO',
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    nombre_parametro VARCHAR(50),
    valor_parametro DECIMAL(10,3),
    valor_umbral DECIMAL(10,3),
    esta_resuelto BOOLEAN DEFAULT 0,
    fecha_resolucion TIMESTAMP NULL,
    resuelto_por VARCHAR(100),
    notas_resolucion TEXT,
    notificacion_enviada BOOLEAN DEFAULT 0,
    canales_notificacion TEXT,
    FOREIGN KEY (estacion_id) REFERENCES iot_estacion_monitoreo (id) ON DELETE SET NULL,
    FOREIGN KEY (bomba_id) REFERENCES iot_estacion_bombeo (id) ON DELETE SET NULL,
    INDEX idx_alerta_severidad_fecha (severidad, fecha_hora DESC),
    INDEX idx_alerta_resuelto (esta_resuelto, fecha_hora DESC),
    INDEX idx_alerta_tipo (tipo_alerta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Alertas generadas por el sistema';

-- Tabla: Umbrales de Alerta
CREATE TABLE IF NOT EXISTS iot_umbral_alerta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_parametro VARCHAR(50) NOT NULL UNIQUE,
    valor_minimo DECIMAL(10,3),
    valor_maximo DECIMAL(10,3),
    nivel_alerta ENUM('CRITICO', 'ALTO', 'MEDIO', 'BAJO') DEFAULT 'MEDIO',
    descripcion TEXT,
    activo BOOLEAN DEFAULT 1,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_umbral_activo (activo),
    INDEX idx_umbral_parametro (nombre_parametro)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Configuración de umbrales para alertas automáticas';

-- Tabla: Log de Control Automático
CREATE TABLE IF NOT EXISTS iot_log_control_automatico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estacion_id INT NOT NULL,
    bomba_id INT,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accion VARCHAR(20) NOT NULL,
    razon TEXT,
    nivel_agua_m DECIMAL(6,3),
    precipitacion_mm DECIMAL(7,2),
    periodo_tarifa VARCHAR(20),
    temperatura_motor_c DECIMAL(5,2),
    tiempo_decision_ms INT,
    estado_ejecucion VARCHAR(20) DEFAULT 'EXITOSO',
    mensaje_error TEXT,
    FOREIGN KEY (estacion_id) REFERENCES iot_estacion_monitoreo (id) ON DELETE CASCADE,
    FOREIGN KEY (bomba_id) REFERENCES iot_estacion_bombeo (id) ON DELETE SET NULL,
    INDEX idx_log_control_estacion_fecha (estacion_id, fecha_hora DESC),
    INDEX idx_log_control_accion (accion),
    INDEX idx_log_control_fecha (fecha_hora DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registro de decisiones del sistema de control automático';

-- Tabla: Contactos para Notificaciones
CREATE TABLE IF NOT EXISTS iot_contacto_notificacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cargo VARCHAR(50),
    correo VARCHAR(100),
    telefono VARCHAR(20),
    numero_whatsapp VARCHAR(20),
    recibir_critico BOOLEAN DEFAULT 1,
    recibir_alto BOOLEAN DEFAULT 1,
    recibir_medio BOOLEAN DEFAULT 0,
    recibir_bajo BOOLEAN DEFAULT 0,
    activo BOOLEAN DEFAULT 1,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_contacto_activo (activo),
    INDEX idx_contacto_correo (correo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Contactos para envío de notificaciones';

-- Tabla: Resumen de Flujo Diario
CREATE TABLE IF NOT EXISTS iot_resumen_flujo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estacion_id INT NOT NULL,
    fecha DATE NOT NULL,
    entrada_total_m3 DECIMAL(12,2) DEFAULT 0.0,
    salida_total_m3 DECIMAL(12,2) DEFAULT 0.0,
    flujo_neto_m3 DECIMAL(12,2) DEFAULT 0.0,
    pico_entrada_m3h DECIMAL(8,2) DEFAULT 0.0,
    pico_salida_m3h DECIMAL(8,2) DEFAULT 0.0,
    nivel_agua_promedio_m DECIMAL(6,3),
    nivel_agua_minimo_m DECIMAL(6,3),
    nivel_agua_maximo_m DECIMAL(6,3),
    precipitacion_total_mm DECIMAL(8,2) DEFAULT 0.0,
    horas_bombeo DECIMAL(8,2) DEFAULT 0.0,
    consumo_energia_kwh DECIMAL(10,2) DEFAULT 0.0,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (estacion_id) REFERENCES iot_estacion_monitoreo (id) ON DELETE CASCADE,
    UNIQUE KEY unico_estacion_fecha (estacion_id, fecha),
    INDEX idx_resumen_fecha (fecha DESC),
    INDEX idx_resumen_estacion (estacion_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Resumen diario de flujo y operación';

-- ============================================================
-- DATOS INICIALES DE PRUEBA
-- ============================================================

-- Insertar Estaciones de Monitoreo
INSERT IGNORE INTO iot_estacion_monitoreo (id, nombre, ubicacion, latitud, longitud, tipo_estacion, control_automatico_habilitado)
VALUES 
(1, 'Estación Administración', 'Entrada principal - Chigorodó, Antioquia', 6.2442, -75.5812, 'COMBINADO', 1),
(2, 'Estación Playa', 'Zona de trabajo Playa - Chigorodó', 6.2455, -75.5825, 'METEOROLOGICO', 1),
(3, 'Estación Bendición', 'Zona de trabajo Bendición - Chigorodó', 6.2438, -75.5798, 'METEOROLOGICO', 1),
(4, 'Estación Plana', 'Zona de trabajo Plana - Chigorodó', 6.2429, -75.5834, 'METEOROLOGICO', 1);

-- Insertar Estaciones de Bombeo
INSERT IGNORE INTO iot_estacion_bombeo (id, estacion_id, nombre, tipo_bomba, capacidad_maxima_m3h, potencia_nominal_kw, nivel_minimo_agua_m, nivel_maximo_agua_m)
VALUES 
(1, 1, 'Bomba Principal Norte', 'Centrífuga', 120.0, 15.0, 0.5, 3.0),
(2, 1, 'Bomba Auxiliar Sur', 'Sumergible', 80.0, 9.5, 0.6, 2.8),
(3, 1, 'Bomba Respaldo Este', 'Centrífuga', 100.0, 11.0, 0.5, 3.0);

-- Insertar Umbrales de Alerta
INSERT IGNORE INTO iot_umbral_alerta (nombre_parametro, valor_minimo, valor_maximo, nivel_alerta, descripcion)
VALUES 
('nivel_agua', 0.5, 3.0, 'ALTO', 'Nivel de agua crítico (mínimo 0.5m, máximo 3.0m)'),
('precipitacion', 0.0, 50.0, 'MEDIO', 'Precipitación acumulada en 2 horas (alerta >20mm, crítico >30mm)'),
('temperatura_motor_c', 0.0, 85.0, 'CRITICO', 'Temperatura del motor (alerta >75°C, crítico >85°C)'),
('presion_entrada_bar', 2.0, 5.0, 'ALTO', 'Presión de entrada fuera de rango (normal 2.0-5.0 bar)'),
('velocidad_viento_kmh', 0.0, 60.0, 'MEDIO', 'Velocidad del viento (alerta vendaval >60 km/h)');

-- Insertar Contactos de Notificación
INSERT IGNORE INTO iot_contacto_notificacion (nombre, cargo, correo, telefono, numero_whatsapp, recibir_critico, recibir_alto, recibir_medio)
VALUES 
('Supervisor Operaciones', 'Supervisor', 'supervisor@promotorapalmera.com', '+573001234567', '+573001234567', 1, 1, 1),
('Técnico de Campo', 'Técnico', 'tecnico@promotorapalmera.com', '+573007654321', '+573007654321', 1, 1, 0);

-- ============================================================
-- VISTAS ÚTILES
-- ============================================================

-- Vista: Últimos datos meteorológicos por estación
CREATE OR REPLACE VIEW v_iot_ultima_meteorologia AS
SELECT 
    em.id AS estacion_id,
    em.nombre AS nombre_estacion,
    em.ubicacion,
    dm.temperatura_c,
    dm.humedad_porcentaje,
    dm.precipitacion_mm,
    dm.velocidad_viento_kmh,
    dm.direccion_viento_grados,
    dm.presion_atmosferica_hpa,
    dm.radiacion_solar_wm2,
    dm.indice_uv,
    dm.fecha_hora,
    dm.dispositivo_origen
FROM iot_datos_meteorologicos dm
INNER JOIN iot_estacion_monitoreo em ON dm.estacion_id = em.id
INNER JOIN (
    SELECT estacion_id, MAX(id) AS max_id
    FROM iot_datos_meteorologicos
    GROUP BY estacion_id
) ultimo ON dm.estacion_id = ultimo.estacion_id AND dm.id = ultimo.max_id;

-- Vista: Estado actual de bombas
CREATE OR REPLACE VIEW v_iot_estado_bombas AS
SELECT 
    eb.id AS bomba_id,
    eb.nombre AS nombre_bomba,
    eb.tipo_bomba,
    eb.capacidad_maxima_m3h,
    eb.potencia_nominal_kw,
    em.nombre AS nombre_estacion,
    em.ubicacion AS ubicacion_estacion,
    tb.estado,
    tb.caudal_m3h,
    tb.presion_entrada_bar,
    tb.presion_salida_bar,
    tb.consumo_energia_kw,
    tb.temperatura_motor_c,
    tb.nivel_vibracion,
    tb.modo_operacion,
    tb.fecha_hora,
    tb.dispositivo_origen
FROM iot_telemetria_bomba tb
INNER JOIN iot_estacion_bombeo eb ON tb.bomba_id = eb.id
INNER JOIN iot_estacion_monitoreo em ON eb.estacion_id = em.id
INNER JOIN (
    SELECT bomba_id, MAX(id) AS max_id
    FROM iot_telemetria_bomba
    GROUP BY bomba_id
) ultimo ON tb.bomba_id = ultimo.bomba_id AND tb.id = ultimo.max_id;

-- Vista: Alertas activas ordenadas por severidad
CREATE OR REPLACE VIEW v_iot_alertas_activas AS
SELECT 
    sa.id,
    sa.tipo_alerta,
    sa.severidad,
    sa.titulo,
    sa.descripcion,
    sa.nombre_parametro,
    sa.valor_parametro,
    sa.valor_umbral,
    em.nombre AS nombre_estacion,
    eb.nombre AS nombre_bomba,
    sa.fecha_hora,
    TIMESTAMPDIFF(MINUTE, sa.fecha_hora, NOW()) AS minutos_transcurridos,
    sa.notificacion_enviada,
    sa.canales_notificacion
FROM iot_alerta_sistema sa
LEFT JOIN iot_estacion_monitoreo em ON sa.estacion_id = em.id
LEFT JOIN iot_estacion_bombeo eb ON sa.bomba_id = eb.id
WHERE sa.esta_resuelto = 0
ORDER BY 
    FIELD(sa.severidad, 'CRITICO', 'ALTO', 'MEDIO', 'BAJO'),
    sa.fecha_hora DESC;

-- Vista: Resumen diario último mes
CREATE OR REPLACE VIEW v_iot_resumen_mensual AS
SELECT 
    rf.fecha,
    em.nombre AS nombre_estacion,
    rf.entrada_total_m3,
    rf.salida_total_m3,
    rf.flujo_neto_m3,
    rf.pico_entrada_m3h,
    rf.nivel_agua_promedio_m,
    rf.precipitacion_total_mm,
    rf.horas_bombeo,
    rf.consumo_energia_kwh,
    ROUND(rf.consumo_energia_kwh * 650, 2) AS costo_estimado_cop
FROM iot_resumen_flujo rf
INNER JOIN iot_estacion_monitoreo em ON rf.estacion_id = em.id
WHERE rf.fecha >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY rf.fecha DESC, em.nombre;

-- Vista: Estado del agua actual
CREATE OR REPLACE VIEW v_iot_nivel_agua_actual AS
SELECT 
    em.id AS estacion_id,
    em.nombre AS nombre_estacion,
    em.ubicacion,
    na.nivel_m,
    na.volumen_m3,
    na.tendencia,
    na.fecha_hora,
    na.dispositivo_origen,
    CASE 
        WHEN na.nivel_m < 0.5 THEN 'CRÍTICO BAJO'
        WHEN na.nivel_m > 2.8 THEN 'CRÍTICO ALTO'
        WHEN na.nivel_m < 1.0 THEN 'BAJO'
        WHEN na.nivel_m > 2.3 THEN 'ALTO'
        ELSE 'NORMAL'
    END AS estado_nivel
FROM iot_nivel_agua na
INNER JOIN iot_estacion_monitoreo em ON na.estacion_id = em.id
INNER JOIN (
    SELECT estacion_id, MAX(id) AS max_id
    FROM iot_nivel_agua
    GROUP BY estacion_id
) ultimo ON na.estacion_id = ultimo.estacion_id AND na.id = ultimo.max_id;

-- Vista: Historial de control automático (últimas 100 acciones)
CREATE OR REPLACE VIEW v_iot_historial_control AS
SELECT 
    lca.id,
    lca.fecha_hora,
    em.nombre AS nombre_estacion,
    eb.nombre AS nombre_bomba,
    lca.accion,
    lca.razon,
    lca.nivel_agua_m,
    lca.precipitacion_mm,
    lca.temperatura_motor_c,
    lca.periodo_tarifa,
    lca.estado_ejecucion,
    lca.tiempo_decision_ms
FROM iot_log_control_automatico lca
INNER JOIN iot_estacion_monitoreo em ON lca.estacion_id = em.id
LEFT JOIN iot_estacion_bombeo eb ON lca.bomba_id = eb.id
ORDER BY lca.fecha_hora DESC
LIMIT 100;

-- ============================================================
-- PROCEDIMIENTOS ALMACENADOS
-- ============================================================

DELIMITER //

-- Procedimiento: Verificar y crear alerta automática al detectar umbral excedido
CREATE PROCEDURE IF NOT EXISTS sp_verificar_crear_alerta(
    IN p_estacion_id INT,
    IN p_bomba_id INT,
    IN p_nombre_parametro VARCHAR(50),
    IN p_valor_parametro DECIMAL(10,3)
)
BEGIN
    DECLARE v_valor_minimo DECIMAL(10,3);
    DECLARE v_valor_maximo DECIMAL(10,3);
    DECLARE v_nivel_alerta VARCHAR(20);
    DECLARE v_descripcion TEXT;
    DECLARE v_titulo_alerta VARCHAR(200);
    
    -- Obtener umbral configurado
    SELECT valor_minimo, valor_maximo, nivel_alerta, descripcion
    INTO v_valor_minimo, v_valor_maximo, v_nivel_alerta, v_descripcion
    FROM iot_umbral_alerta
    WHERE nombre_parametro = p_nombre_parametro AND activo = 1
    LIMIT 1;
    
    -- Verificar si se excede el umbral
    IF (p_valor_parametro < v_valor_minimo OR p_valor_parametro > v_valor_maximo) THEN
        
        -- Construir título de alerta
        SET v_titulo_alerta = CONCAT('Alerta: ', p_nombre_parametro, ' fuera de rango');
        
        -- Insertar alerta solo si no existe una alerta sin resolver del mismo tipo
        INSERT INTO iot_alerta_sistema (
            estacion_id, bomba_id, tipo_alerta, severidad, titulo, descripcion,
            nombre_parametro, valor_parametro, valor_umbral, notificacion_enviada
        )
        SELECT 
            p_estacion_id, p_bomba_id, p_nombre_parametro, v_nivel_alerta, v_titulo_alerta, v_descripcion,
            p_nombre_parametro, p_valor_parametro, 
            IF(p_valor_parametro < v_valor_minimo, v_valor_minimo, v_valor_maximo),
            0
        FROM DUAL
        WHERE NOT EXISTS (
            SELECT 1 FROM iot_alerta_sistema
            WHERE nombre_parametro = p_nombre_parametro
              AND esta_resuelto = 0
              AND estacion_id = p_estacion_id
              AND IFNULL(bomba_id, 0) = IFNULL(p_bomba_id, 0)
              AND fecha_hora > DATE_SUB(NOW(), INTERVAL 1 HOUR)
        );
    END IF;
END//

-- Procedimiento: Registrar telemetría de bomba con verificación automática
CREATE PROCEDURE IF NOT EXISTS sp_insertar_telemetria_bomba(
    IN p_bomba_id INT,
    IN p_estado VARCHAR(20),
    IN p_caudal_m3h DECIMAL(8,2),
    IN p_presion_entrada_bar DECIMAL(6,2),
    IN p_presion_salida_bar DECIMAL(6,2),
    IN p_consumo_energia_kw DECIMAL(7,2),
    IN p_temperatura_motor_c DECIMAL(5,2),
    IN p_nivel_vibracion INT,
    IN p_horas_operacion DECIMAL(10,2),
    IN p_modo_operacion VARCHAR(20),
    IN p_dispositivo_origen VARCHAR(50)
)
BEGIN
    DECLARE v_estacion_id INT;
    
    -- Insertar telemetría
    INSERT INTO iot_telemetria_bomba (
        bomba_id, estado, caudal_m3h, presion_entrada_bar, presion_salida_bar,
        consumo_energia_kw, temperatura_motor_c, nivel_vibracion, horas_operacion,
        modo_operacion, dispositivo_origen
    ) VALUES (
        p_bomba_id, p_estado, p_caudal_m3h, p_presion_entrada_bar, p_presion_salida_bar,
        p_consumo_energia_kw, p_temperatura_motor_c, p_nivel_vibracion, p_horas_operacion,
        p_modo_operacion, p_dispositivo_origen
    );
    
    -- Obtener estacion_id de la bomba
    SELECT estacion_id INTO v_estacion_id
    FROM iot_estacion_bombeo
    WHERE id = p_bomba_id;
    
    -- Verificar temperatura del motor
    CALL sp_verificar_crear_alerta(v_estacion_id, p_bomba_id, 'temperatura_motor_c', p_temperatura_motor_c);
    
    -- Verificar presión de entrada
    CALL sp_verificar_crear_alerta(v_estacion_id, p_bomba_id, 'presion_entrada_bar', p_presion_entrada_bar);
END//

DELIMITER ;

-- =================================================================================================================
-- EVENTOS PROGRAMADOS (requiere event_scheduler = ON)
-- ============================================================

DELIMITER //

-- Evento: Limpiar datos antiguos de telemetr\u00eda (m\u00e1s de 90 d\u00edas)
CREATE EVENT IF NOT EXISTS evt_limpiar_telemetria_antigua
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DELETE FROM iot_telemetria_bomba WHERE fecha_hora < DATE_SUB(NOW(), INTERVAL 90 DAY);
    DELETE FROM iot_datos_meteorologicos WHERE fecha_hora < DATE_SUB(NOW(), INTERVAL 90 DAY);
    DELETE FROM iot_nivel_agua WHERE fecha_hora < DATE_SUB(NOW(), INTERVAL 90 DAY);
    DELETE FROM iot_estado_compuerta WHERE fecha_hora < DATE_SUB(NOW(), INTERVAL 90 DAY);
END//

-- Evento: Generar resumen diario automático a las 23:59
CREATE EVENT IF NOT EXISTS evt_generar_resumen_diario
ON SCHEDULE EVERY 1 DAY
STARTS CONCAT(CURDATE(), ' 23:59:00')
DO
BEGIN
    INSERT INTO iot_resumen_flujo (
        estacion_id, fecha, entrada_total_m3, salida_total_m3, 
        nivel_agua_promedio_m, nivel_agua_minimo_m, nivel_agua_maximo_m,
        precipitacion_total_mm, horas_bombeo, consumo_energia_kwh
    )
    SELECT 
        em.id AS estacion_id,
        CURDATE() AS fecha,
        0 AS entrada_total_m3,
        0 AS salida_total_m3,
        AVG(na.nivel_m) AS nivel_agua_promedio_m,
        MIN(na.nivel_m) AS nivel_agua_minimo_m,
        MAX(na.nivel_m) AS nivel_agua_maximo_m,
        SUM(dm.precipitacion_mm) AS precipitacion_total_mm,
        SUM(CASE WHEN tb.estado = 'ENCENDIDO' THEN 0.25 ELSE 0 END) AS horas_bombeo,
        SUM(CASE WHEN tb.estado = 'ENCENDIDO' THEN tb.consumo_energia_kw * 0.25 ELSE 0 END) AS consumo_energia_kwh
    FROM iot_estacion_monitoreo em
    LEFT JOIN iot_nivel_agua na ON na.estacion_id = em.id AND DATE(na.fecha_hora) = CURDATE()
    LEFT JOIN iot_datos_meteorologicos dm ON dm.estacion_id = em.id AND DATE(dm.fecha_hora) = CURDATE()
    LEFT JOIN iot_estacion_bombeo eb ON eb.estacion_id = em.id
    LEFT JOIN iot_telemetria_bomba tb ON tb.bomba_id = eb.id AND DATE(tb.fecha_hora) = CURDATE()
    GROUP BY em.id
    ON DUPLICATE KEY UPDATE
        nivel_agua_promedio_m = VALUES(nivel_agua_promedio_m),
        nivel_agua_minimo_m = VALUES(nivel_agua_minimo_m),
        nivel_agua_maximo_m = VALUES(nivel_agua_maximo_m),
        precipitacion_total_mm = VALUES(precipitacion_total_mm),
        horas_bombeo = VALUES(horas_bombeo),
        consumo_energia_kwh = VALUES(consumo_energia_kwh);
END//

DELIMITER ;

-- ============================================================
-- VERIFICACIÓN E INFORMACIÓN
-- ============================================================

-- Mostrar resumen de tablas creadas
SELECT '✅ TABLAS CREADAS:' AS estado;
SELECT TABLE_NAME AS nombre_tabla, TABLE_ROWS AS filas, 
       ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024, 2) AS tamanio_kb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'promotorapalmera_db'
  AND TABLE_NAME LIKE 'iot_%'
ORDER BY TABLE_NAME;

SELECT '✅ VISTAS CREADAS:' AS estado;
SELECT TABLE_NAME AS nombre_vista
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'promotorapalmera_db'
  AND TABLE_NAME LIKE 'v_iot_%'
ORDER BY TABLE_NAME;

SELECT '✅ DATOS INSERTADOS:' AS estado;
SELECT 
    (SELECT COUNT(*) FROM iot_estacion_monitoreo) AS estaciones,
    (SELECT COUNT(*) FROM iot_estacion_bombeo) AS bombas,
    (SELECT COUNT(*) FROM iot_umbral_alerta) AS umbrales,
    (SELECT COUNT(*) FROM iot_contacto_notificacion) AS contactos;

SELECT '✅ Base de datos MySQL inicializada correctamente en promotorapalmera_db' AS mensaje;
SELECT 'Prefijo de tablas: iot_' AS informacion;
SELECT 'Idioma: ESPAÑOL' AS informacion;
SELECT 'Total de tablas: 11' AS informacion;
SELECT 'Total de vistas: 6' AS informacion;
SELECT 'Total de procedimientos: 2' AS informacion;
SELECT 'Total de eventos: 2' AS informacion;
