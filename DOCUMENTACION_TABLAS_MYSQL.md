# 📊 DOCUMENTACIÓN DE BASE DE DATOS MYSQL - SISTEMA IoT ESTACIÓN DE BOMBEO

**Promotora Palmera de Antioquia S.A.S.**  
**Fecha:** 21 de febrero de 2026  
**Base de datos:** `promotorapalmera_db`  
**Prefijo de tablas:** `iot_`

---

## 📋 ÍNDICE

1. [Estructura General](#estructura-general)
2. [Tablas Principales](#tablas-principales)
3. [Vistas](#vistas)
4. [Procedimientos Almacenados](#procedimientos-almacenados)
5. [Eventos Programados](#eventos-programados)
6. [Instalación](#instalación)
7. [Configuración](#configuración)
8. [Migraciones](#migraciones)

---

## 🗄️ ESTRUCTURA GENERAL

### Base de Datos

**Nombre:** `promotorapalmera_db` (utiliza la base existente)  
**Motor:** MySQL 5.7+ / MariaDB 10.3+  
**Charset:** `utf8mb4`  
**Collation:** `utf8mb4_unicode_ci`

### Convención de Nombres

- **Tablas:** Prefijo `iot_` + nombre descriptivo en singular  
  Ejemplo: `iot_monitoring_station`, `iot_pump_telemetry`
  
- **Vistas:** Prefijo `v_iot_` + descripción de contenido  
  Ejemplo: `v_iot_latest_meteorological`, `v_iot_pump_status`
  
- **Procedimientos:** Prefijo `sp_` + verbo + sustantivo  
  Ejemplo: `sp_check_and_create_alert`, `sp_insert_pump_telemetry`
  
- **Eventos:** Prefijo `evt_` + descripción de acción  
  Ejemplo: `evt_cleanup_old_telemetry`, `evt_generate_daily_summary`

---

## 📊 TABLAS PRINCIPALES

### 1. iot_monitoring_station

**Descripción:** Estaciones de monitoreo distribuidas geográficamente

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| name | VARCHAR(100) | NOT NULL | Nombre de la estación |
| location | VARCHAR(200) | | Ubicación descriptiva |
| latitude | DECIMAL(10,7) | | Latitud GPS |
| longitude | DECIMAL(10,7) | | Longitud GPS |
| elevation_m | DECIMAL(7,2) | | Elevación sobre nivel del mar (metros) |
| station_type | VARCHAR(50) | | Tipo: METEOROLOGICAL, COMBINED |
| is_active | BOOLEAN | DEFAULT 1 | Estado activo/inactivo |
| auto_control_enabled | BOOLEAN | DEFAULT 1 | Control automático habilitado |
| installation_date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha de instalación |
| last_maintenance_date | TIMESTAMP | NULL | Última fecha de mantenimiento |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha de creación |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Última actualización |

**Índices:**
- `idx_station_active` en `is_active`
- `idx_station_type` en `station_type`

**Datos iniciales:** 4 estaciones (Administración, Playa, Bendición, Plana)

---

### 2. iot_pumping_station

**Descripción:** Estaciones de bombeo asociadas a estaciones de monitoreo

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| station_id | INT | NOT NULL, FK → iot_monitoring_station | Estación de monitoreo asociada |
| name | VARCHAR(100) | NOT NULL | Nombre de la bomba |
| pump_type | VARCHAR(50) | | Tipo: Centrífuga, Sumergible, etc. |
| max_capacity_m3h | DECIMAL(8,2) | | Capacidad máxima (m³/hora) |
| rated_power_kw | DECIMAL(7,2) | | Potencia nominal (kW) |
| min_water_level_m | DECIMAL(5,2) | DEFAULT 0.5 | Nivel mínimo para operar (metros) |
| max_water_level_m | DECIMAL(5,2) | DEFAULT 3.0 | Nivel máximo seguro (metros) |
| is_active | BOOLEAN | DEFAULT 1 | Estado activo/inactivo |
| installation_date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha de instalación |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha de creación |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Última actualización |

**Índices:**
- `idx_pump_station` en `station_id`
- `idx_pump_active` en `is_active`

**Relaciones:**
- `station_id` → `iot_monitoring_station.id` (CASCADE)

**Datos iniciales:** 3 bombas (Principal Norte, Auxiliar Sur, Respaldo Este)

---

### 3. iot_meteorological_data

**Descripción:** Datos meteorológicos capturados por sensores

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| station_id | INT | NOT NULL, FK → iot_monitoring_station | Estación que reporta |
| timestamp | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Momento de la medición |
| temperature_c | DECIMAL(5,2) | | Temperatura (°C) |
| humidity_percent | DECIMAL(5,2) | | Humedad relativa (%) |
| precipitation_mm | DECIMAL(7,2) | | Precipitación acumulada (mm) |
| wind_speed_kmh | DECIMAL(6,2) | | Velocidad del viento (km/h) |
| wind_direction_deg | INT | | Dirección del viento (0-360°) |
| atmospheric_pressure_hpa | DECIMAL(7,2) | | Presión atmosférica (hPa) |
| solar_radiation_wm2 | DECIMAL(7,2) | | Radiación solar (W/m²) |
| uv_index | DECIMAL(4,2) | | Índice UV |
| evapotranspiration_mm | DECIMAL(6,3) | | Evapotranspiración (mm) |
| soil_moisture_percent | DECIMAL(5,2) | | Humedad del suelo (%) |
| soil_temperature_c | DECIMAL(5,2) | | Temperatura del suelo (°C) |
| leaf_wetness_percent | DECIMAL(5,2) | | Humedad de hoja (%) |
| source_device | VARCHAR(50) | | Identificador del dispositivo fuente |

**Índices:**
- `idx_meteorological_station_time` en (`station_id`, `timestamp DESC`)
- `idx_meteorological_timestamp` en `timestamp DESC`

**Frecuencia de actualización:** Cada 10 segundos (simulador Wokwi)

---

### 4. iot_pump_telemetry

**Descripción:** Telemetría operacional de las bombas

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| pump_id | INT | NOT NULL, FK → iot_pumping_station | Bomba que reporta |
| timestamp | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Momento de la medición |
| status | VARCHAR(20) | DEFAULT 'OFF' | Estado: ON, OFF, ERROR, MAINTENANCE |
| flow_rate_m3h | DECIMAL(8,2) | DEFAULT 0.0 | Caudal actual (m³/hora) |
| inlet_pressure_bar | DECIMAL(6,2) | | Presión de entrada (bar) |
| outlet_pressure_bar | DECIMAL(6,2) | | Presión de salida (bar) |
| power_consumption_kw | DECIMAL(7,2) | DEFAULT 0.0 | Consumo eléctrico (kW) |
| motor_temperature_c | DECIMAL(5,2) | | Temperatura del motor (°C) |
| vibration_level | INT | DEFAULT 0 | Nivel de vibración (0-100) |
| running_hours | DECIMAL(10,2) | | Horas acumuladas de operación |
| operational_mode | VARCHAR(20) | DEFAULT 'AUTO' | Modo: AUTO, MANUAL, SCHEDULED |
| source_device | VARCHAR(50) | | Identificador del dispositivo fuente |

**Índices:**
- `idx_pump_telemetry_pump_time` en (`pump_id`, `timestamp DESC`)
- `idx_pump_telemetry_status` en `status`
- `idx_pump_telemetry_timestamp` en `timestamp DESC`

**Trigger automático:** Al insertar, verifica temperatura y presión para crear alertas

---

### 5. iot_water_level

**Descripción:** Mediciones de nivel de agua

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| station_id | INT | NOT NULL, FK → iot_monitoring_station | Estación que reporta |
| timestamp | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Momento de la medición |
| level_m | DECIMAL(6,3) | NOT NULL | Nivel de agua (metros) |
| volume_m3 | DECIMAL(12,2) | | Volumen calculado (m³) |
| trend | VARCHAR(20) | | Tendencia: RISING, FALLING, STABLE |
| source_device | VARCHAR(50) | | Identificador del dispositivo fuente |

**Índices:**
- `idx_water_level_station_time` en (`station_id`, `timestamp DESC`)
- `idx_water_level_timestamp` en `timestamp DESC`

**Sensor:** HC-SR04 en ESP32 Wokwi (Pin 5/18)

---

### 6. iot_gate_status

**Descripción:** Estado de compuertas/válvulas

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| station_id | INT | NOT NULL, FK → iot_monitoring_station | Estación que reporta |
| timestamp | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Momento del registro |
| gate_number | INT | NOT NULL | Número de compuerta |
| status | VARCHAR(20) | DEFAULT 'CLOSED' | Estado: OPEN, CLOSED, PARTIAL |
| opening_percent | DECIMAL(5,2) | DEFAULT 0.0 | Apertura (%) |
| flow_rate_m3s | DECIMAL(8,4) | DEFAULT 0.0 | Caudal (m³/segundo) |
| position_sensor_value | DECIMAL(8,3) | | Valor del sensor de posición |
| source_device | VARCHAR(50) | | Identificador del dispositivo fuente |

**Índices:**
- `idx_gate_station_time` en (`station_id`, `timestamp DESC`)
- `idx_gate_number` en `gate_number`

---

### 7. iot_system_alert

**Descripción:** Alertas generadas por el sistema

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| station_id | INT | FK → iot_monitoring_station | Estación relacionada |
| pump_id | INT | FK → iot_pumping_station | Bomba relacionada |
| timestamp | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Momento de la alerta |
| alert_type | VARCHAR(50) | NOT NULL | Tipo de alerta |
| severity | ENUM | DEFAULT 'MEDIUM' | CRITICAL, HIGH, MEDIUM, LOW |
| title | VARCHAR(200) | NOT NULL | Título descriptivo |
| description | TEXT | | Descripción detallada |
| parameter_name | VARCHAR(50) | | Parámetro que causó la alerta |
| parameter_value | DECIMAL(10,3) | | Valor medido |
| threshold_value | DECIMAL(10,3) | | Valor umbral excedido |
| is_resolved | BOOLEAN | DEFAULT 0 | Estado resuelto/pendiente |
| resolved_at | TIMESTAMP | NULL | Fecha de resolución |
| resolved_by | VARCHAR(100) | | Usuario que resolvió |
| resolution_notes | TEXT | | Notas de resolución |
| notification_sent | BOOLEAN | DEFAULT 0 | Notificación enviada |
| notification_channels | TEXT | | Canales usados (email, sms, whatsapp) |

**Índices:**
- `idx_system_alert_severity_time` en (`severity`, `timestamp DESC`)
- `idx_system_alert_resolved` en (`is_resolved`, `timestamp DESC`)
- `idx_system_alert_type` en `alert_type`

**Severidades:**
- **CRITICAL:** Requiere acción inmediata (motor >85°C, lluvia >30mm)
- **HIGH:** Requiere atención pronto (nivel bajo/alto)
- **MEDIUM:** Monitorear (viento fuerte, precipitación moderada)
- **LOW:** Informativo

---

### 8. iot_alert_threshold

**Descripción:** Configuración de umbrales para alertas automáticas

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| parameter_name | VARCHAR(50) | NOT NULL, UNIQUE | Nombre del parámetro |
| min_value | DECIMAL(10,3) | | Valor mínimo aceptable |
| max_value | DECIMAL(10,3) | | Valor máximo aceptable |
| alert_level | ENUM | DEFAULT 'MEDIUM' | CRITICAL, HIGH, MEDIUM, LOW |
| description | TEXT | | Descripción del umbral |
| is_active | BOOLEAN | DEFAULT 1 | Umbral activo/inactivo |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha de creación |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Última actualización |

**Índices:**
- `idx_threshold_active` en `is_active`
- `idx_threshold_parameter` en `parameter_name`

**Umbrales predefinidos:**
1. `water_level`: 0.5 - 3.0m (HIGH)
2. `precipitation`: 0.0 - 50.0mm (MEDIUM, crítico >30mm)
3. `motor_temperature_c`: 0.0 - 85.0°C (CRITICAL)
4. `inlet_pressure_bar`: 2.0 - 5.0 bar (HIGH)
5. `wind_speed_kmh`: 0.0 - 60.0 km/h (MEDIUM)

---

### 9. iot_automatic_control_log

**Descripción:** Registro de decisiones del sistema de control automático

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| station_id | INT | NOT NULL, FK → iot_monitoring_station | Estación que decidió |
| pump_id | INT | FK → iot_pumping_station | Bomba controlada |
| timestamp | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Momento de la decisión |
| action | VARCHAR(20) | NOT NULL | Acción: START, STOP, WAIT, ALERT |
| reason | TEXT | | Razón de la decisión |
| water_level_m | DECIMAL(6,3) | | Nivel de agua al decidir |
| precipitation_mm | DECIMAL(7,2) | | Precipitación al decidir |
| tariff_period | VARCHAR(20) | | Tarifa eléctrica: BASE, PICO, VALLE |
| motor_temperature_c | DECIMAL(5,2) | | Temperatura del motor |
| decision_time_ms | INT | | Tiempo de procesamiento (ms) |
| execution_status | VARCHAR(20) | DEFAULT 'SUCCESS' | SUCCESS, FAILED, PENDING |
| error_message | TEXT | | Mensaje de error si falló |

**Índices:**
- `idx_control_log_station_time` en (`station_id`, `timestamp DESC`)
- `idx_control_log_action` en `action`
- `idx_control_log_timestamp` en `timestamp DESC`

**Reglas implementadas en ESP32 Wokwi:**
1. Lluvia >30mm → STOP (CRITICAL)
2. Motor >85°C → STOP (CRITICAL)
3. Nivel <0.5m Y lluvia <15mm → START (HIGH)
4. Nivel >2.8m → STOP (HIGH)

---

### 10. iot_notification_contact

**Descripción:** Contactos para envío de notificaciones

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| name | VARCHAR(100) | NOT NULL | Nombre del contacto |
| role | VARCHAR(50) | | Rol: Supervisor, Técnico, etc. |
| email | VARCHAR(100) | | Dirección de correo |
| phone | VARCHAR(20) | | Número telefónico |
| whatsapp_number | VARCHAR(20) | | Número de WhatsApp |
| receive_critical | BOOLEAN | DEFAULT 1 | Recibir alertas CRITICAL |
| receive_high | BOOLEAN | DEFAULT 1 | Recibir alertas HIGH |
| receive_medium | BOOLEAN | DEFAULT 0 | Recibir alertas MEDIUM |
| receive_low | BOOLEAN | DEFAULT 0 | Recibir alertas LOW |
| is_active | BOOLEAN | DEFAULT 1 | Contacto activo/inactivo |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha de creación |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Última actualización |

**Índices:**
- `idx_contact_active` en `is_active`
- `idx_contact_email` en `email`

**Contactos iniciales:**
1. Supervisor Operaciones (CRITICAL, HIGH, MEDIUM)
2. Técnico de Campo (CRITICAL, HIGH)

---

### 11. iot_flow_summary

**Descripción:** Resumen diario de flujo y operación

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Identificador único |
| station_id | INT | NOT NULL, FK → iot_monitoring_station | Estación |
| date | DATE | NOT NULL | Fecha del resumen |
| total_inflow_m3 | DECIMAL(12,2) | DEFAULT 0.0 | Entrada total (m³) |
| total_outflow_m3 | DECIMAL(12,2) | DEFAULT 0.0 | Salida total (m³) |
| net_flow_m3 | DECIMAL(12,2) | DEFAULT 0.0 | Flujo neto (m³) |
| peak_inflow_m3h | DECIMAL(8,2) | DEFAULT 0.0 | Pico entrada (m³/h) |
| peak_outflow_m3h | DECIMAL(8,2) | DEFAULT 0.0 | Pico salida (m³/h) |
| avg_water_level_m | DECIMAL(6,3) | | Nivel promedio (m) |
| min_water_level_m | DECIMAL(6,3) | | Nivel mínimo (m) |
| max_water_level_m | DECIMAL(6,3) | | Nivel máximo (m) |
| total_precipitation_mm | DECIMAL(8,2) | DEFAULT 0.0 | Precipitación total (mm) |
| pump_running_hours | DECIMAL(8,2) | DEFAULT 0.0 | Horas de bombeo |
| energy_consumption_kwh | DECIMAL(10,2) | DEFAULT 0.0 | Consumo energético (kWh) |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha de creación |

**Índices:**
- `unique_station_date` en (`station_id`, `date`) - UNIQUE
- `idx_flow_summary_date` en `date DESC`
- `idx_flow_summary_station` en `station_id`

**Generación automática:** Evento programado a las 23:59 diariamente

---

## 👁️ VISTAS

### v_iot_latest_meteorological

**Descripción:** Últimas mediciones meteorológicas de cada estación

**Columnas:**
- station_id, station_name, location
- temperature_c, humidity_percent, precipitation_mm
- wind_speed_kmh, wind_direction_deg, atmospheric_pressure_hpa
- solar_radiation_wm2, uv_index
- timestamp, source_device

**Uso:** Dashboard para mostrar condiciones actuales

---

### v_iot_pump_status

**Descripción:** Estado operacional actual de todas las bombas

**Columnas:**
- pump_id, pump_name, pump_type, max_capacity_m3h, rated_power_kw
- station_name, station_location
- status, flow_rate_m3h, inlet_pressure_bar, outlet_pressure_bar
- power_consumption_kw, motor_temperature_c, vibration_level
- operational_mode, timestamp, source_device

**Uso:** Panel de control de bombas en tiempo real

---

### v_iot_active_alerts

**Descripción:** Alertas activas ordenadas por severidad

**Columnas:**
- id, alert_type, severity, title, description
- parameter_name, parameter_value, threshold_value
- station_name, pump_name
- timestamp, minutes_ago
- notification_sent, notification_channels

**Uso:** Panel de alertas en dashboard

---

### v_iot_flow_summary_monthly

**Descripción:** Resúmenes diarios del último mes

**Columnas:**
- date, station_name
- total_inflow_m3, total_outflow_m3, net_flow_m3
- peak_inflow_m3h, avg_water_level_m
- total_precipitation_mm, pump_running_hours
- energy_consumption_kwh, estimated_cost_cop

**Uso:** Reportes mensuales y análisis de tendencias

---

### v_iot_current_water_level

**Descripción:** Nivel actual de agua con clasificación de estado

**Columnas:**
- station_id, station_name, location
- level_m, volume_m3, trend
- timestamp, source_device
- status_nivel (CRÍTICO BAJO, BAJO, NORMAL, ALTO, CRÍTICO ALTO)

**Uso:** Monitoreo de niveles críticos

---

### v_iot_control_history

**Descripción:** Últimas 100 decisiones de control automático

**Columnas:**
- id, timestamp, station_name, pump_name
- action, reason
- water_level_m, precipitation_mm, motor_temperature_c
- tariff_period, execution_status, decision_time_ms

**Uso:** Auditoría y análisis de decisiones automáticas

---

## ⚙️ PROCEDIMIENTOS ALMACENADOS

### sp_check_and_create_alert

**Descripción:** Verifica umbral y crea alerta si se excede

**Parámetros:**
- `p_station_id` (INT): ID de la estación
- `p_pump_id` (INT): ID de la bomba (NULL si no aplica)
- `p_parameter_name` (VARCHAR): Nombre del parámetro
- `p_parameter_value` (DECIMAL): Valor medido

**Lógica:**
1. Busca umbral configurado para el parámetro
2. Compara valor medido con min/max
3. Si excede, verifica que no exista alerta sin resolver en la última hora
4. Crea alerta con severidad y descripción correspondiente

**Ejemplo de uso:**
```sql
CALL sp_check_and_create_alert(1, 1, 'motor_temperature_c', 88.5);
```

---

### sp_insert_pump_telemetry

**Descripción:** Registra telemetría de bomba y verifica alertas automáticamente

**Parámetros:**
- `p_pump_id` (INT): ID de la bomba
- `p_status` (VARCHAR): Estado (ON/OFF)
- `p_flow_rate_m3h` (DECIMAL): Caudal
- `p_inlet_pressure_bar` (DECIMAL): Presión entrada
- `p_outlet_pressure_bar` (DECIMAL): Presión salida
- `p_power_consumption_kw` (DECIMAL): Consumo
- `p_motor_temperature_c` (DECIMAL): Temperatura
- `p_vibration_level` (INT): Vibración
- `p_running_hours` (DECIMAL): Horas acumuladas
- `p_operational_mode` (VARCHAR): Modo (AUTO/MANUAL)
- `p_source_device` (VARCHAR): Dispositivo fuente

**Lógica:**
1. Inserta registro de telemetría
2. Obtiene station_id de la bomba
3. Llama a `sp_check_and_create_alert` para temperatura del motor
4. Llama a `sp_check_and_create_alert` para presión de entrada

**Ejemplo de uso:**
```sql
CALL sp_insert_pump_telemetry(
    1, 'ON', 95.5, 3.2, 4.8, 12.3, 68.5, 5, 1234.5, 'AUTO', 'ESP32_WOKWI_01'
);
```

---

## ⏰ EVENTOS PROGRAMADOS

**Nota:** Requiere `event_scheduler = ON` en MySQL

### evt_cleanup_old_telemetry

**Descripción:** Limpieza automática de datos antiguos (>90 días)

**Programación:** Cada 1 día  
**Inicio:** Al crear el evento

**Acciones:**
- Elimina telemetría de bombas >90 días
- Elimina datos meteorológicos >90 días
- Elimina nivel de agua >90 días
- Elimina estado de compuertas >90 días

**Propósito:** Optimizar tamaño de base de datos manteniendo rendimiento

---

### evt_generate_daily_summary

**Descripción:** Genera resumen diario automático

**Programación:** Cada 1 día a las 23:59  
**Inicio:** Al alcanzar las 23:59 del día actual

**Acciones:**
- Calcula promedios, mínimos y máximos de nivel de agua
- Suma precipitación total del día
- Calcula horas de operación de bombas
- Calcula consumo energético total
- Inserta o actualiza `iot_flow_summary`

**Propósito:** Reportes diarios automáticos sin intervención manual

---

## 🚀 INSTALACIÓN

### Método 1: Navegador web (recomendado)

1. Acceder a `http://localhost/project_estacion_bombeo/init_database_mysql.php`
2. El script ejecutará automáticamente
3. Verificar el reporte visual completo

### Método 2: MySQL CLI

```bash
# Conectar a MySQL
mysql -u root -p

# Ejecutar script
source C:/inetpub/promotorapalmera/project_estacion_bombeo/init_database_mysql.sql
```

### Método 3: PHPMyAdmin

1. Acceder a phpMyAdmin
2. Seleccionar base de datos `promotorapalmera_db`
3. Pestaña SQL
4. Copiar contenido de `init_database_mysql.sql`
5. Ejecutar

---

## ⚙️ CONFIGURACIÓN

### Activar Event Scheduler

```sql
SET GLOBAL event_scheduler = ON;
```

Para hacerlo permanente, editar `my.ini` o `my.cnf`:

```ini
[mysqld]
event_scheduler = ON
```

### Verificar Configuración

```sql
-- Verificar event scheduler
SHOW VARIABLES LIKE 'event_scheduler';

-- Ver eventos programados
SHOW EVENTS FROM promotorapalmera_db;

-- Ver procedimientos
SHOW PROCEDURE STATUS WHERE Db = 'promotorapalmera_db';

-- Verificar tablas creadas
SELECT TABLE_NAME, TABLE_ROWS 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'promotorapalmera_db' 
  AND TABLE_NAME LIKE 'iot_%';
```

---

## 🔄 MIGRACIONES

### Migrar de SQLite a MySQL

**Archivo:** `config.py` (Flask)

**Antes (SQLite):**
```python
SQLALCHEMY_DATABASE_URI = 'sqlite:///monitoring.db'
```

**Después (MySQL):**
```python
SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:@localhost:3306/promotorapalmera_db'
```

**Instalar dependencias:**
```bash
pip install pymysql
```

### Script de Migración de Datos

Si tienes datos en SQLite y quieres migrarlos a MySQL:

```python
# migrate_sqlite_to_mysql.py
import sqlite3
import pymysql

# Conectar a SQLite
sqlite_conn = sqlite3.connect('monitoring.db')
sqlite_cur = sqlite_conn.cursor()

# Conectar a MySQL
mysql_conn = pymysql.connect(
    host='localhost', user='root', password='', 
    database='promotorapalmera_db', charset='utf8mb4'
)
mysql_cur = mysql_conn.cursor()

# Migrar estaciones
sqlite_cur.execute("SELECT * FROM monitoring_station")
for row in sqlite_cur.fetchall():
    mysql_cur.execute(
        "INSERT INTO iot_monitoring_station VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
        row
    )

mysql_conn.commit()
print("✅ Migración completada")
```

---

## 📊 CONSULTAS ÚTILES

### Dashboard en Tiempo Real

```sql
-- Estado general del sistema
SELECT 
    (SELECT COUNT(*) FROM iot_monitoring_station WHERE is_active = 1) AS estaciones_activas,
    (SELECT COUNT(*) FROM iot_pumping_station WHERE is_active = 1) AS bombas_activas,
    (SELECT COUNT(*) FROM iot_system_alert WHERE is_resolved = 0) AS alertas_pendientes,
    (SELECT COUNT(*) FROM v_iot_pump_status WHERE status = 'ON') AS bombas_operando;
```

### Últimas Mediciones

```sql
-- Últimas 10 mediciones meteorológicas
SELECT * FROM v_iot_latest_meteorological ORDER BY timestamp DESC LIMIT 10;

-- Estado actual de bombas
SELECT * FROM v_iot_pump_status;

-- Alertas críticas pendientes
SELECT * FROM v_iot_active_alerts WHERE severity = 'CRITICAL';
```

### Reportes

```sql
-- Consumo energético último mes
SELECT 
    DATE_FORMAT(date, '%Y-%m') AS mes,
    SUM(energy_consumption_kwh) AS kwh_total,
    SUM(energy_consumption_kwh) * 650 AS costo_cop_estimado
FROM iot_flow_summary
WHERE date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE_FORMAT(date, '%Y-%m');

-- Horas de operación por bomba
SELECT 
    ps.name,
    SUM(fs.pump_running_hours) AS horas_totales,
    AVG(fs.pump_running_hours) AS horas_promedio_dia
FROM iot_flow_summary fs
JOIN iot_pumping_station ps ON fs.station_id = ps.station_id
WHERE fs.date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY ps.name;
```

---

## 🔐 SEGURIDAD Y RESPALDO

### Backup Diario

```bash
# Crear backup completo
mysqldump -u root -p promotorapalmera_db > backup_iot_$(date +%Y%m%d).sql

# Backup solo tablas IoT
mysqldump -u root -p promotorapalmera_db iot_% > backup_iot_tablas_$(date +%Y%m%d).sql
```

### Restauración

```bash
mysql -u root -p promotorapalmera_db < backup_iot_20260221.sql
```

### Permisos Recomendados

```sql
-- Crear usuario específico para aplicación IoT
CREATE USER 'iot_app'@'localhost' IDENTIFIED BY 'password_seguro';

-- Otorgar permisos solo en tablas IoT
GRANT SELECT, INSERT, UPDATE ON promotorapalmera_db.iot_* TO 'iot_app'@'localhost';
GRANT SELECT ON promotorapalmera_db.v_iot_* TO 'iot_app'@'localhost';
GRANT EXECUTE ON PROCEDURE promotorapalmera_db.sp_check_and_create_alert TO 'iot_app'@'localhost';
GRANT EXECUTE ON PROCEDURE promotorapalmera_db.sp_insert_pump_telemetry TO 'iot_app'@'localhost';

FLUSH PRIVILEGES;
```

---

## 📞 SOPORTE Y DOCUMENTACIÓN ADICIONAL

**Archivos relacionados:**
- `init_database_mysql.sql` - Script de creación
- `init_database_mysql.php` - Script de inicialización web
- `RESUMEN_INICIO_COMPLETO.md` - Resumen del sistema completo
- `wokwi_esp32_simulator/README_WOKWI.md` - Documentación del simulador

**Contacto:**
- Promotora Palmera de Antioquia S.A.S.
- Sistema IoT Estación de Bombeo
- Febrero 2026

---

✅ **Base de datos MySQL lista para producción**
