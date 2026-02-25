# guía de Próximos Pasos - Migración MySQL Completada

## ✅ ESTADO ACTUAL

La migración a MySQL ha sido **COMPLETADA EXITOSAMENTE**. 

- ✅ 11 tablas creadas en español
- ✅ 6 vistas funcionando
- ✅ 2 procedimientos almacenados
- ✅ 2 eventos programados
- ✅ Configuración Flask actualizada
- ✅ Modelos SQLAlchemy traducidos

---

## 🚀 CÓMO EJECUTAR AHORA

### Opción 1: Desde línea de comandos (Recomendado)

```bash
# 1. Asegurarse de que está en el directorio del proyecto
cd C:\inetpub\promotorapalmera\project_estacion_bombeo

# 2. Instalar pymysql si no lo tiene
pip install pymysql

# 3. Ejecutar Flask
python app.py

# 4. Abrir el navegador
# http://localhost:5000
```

### Opción 2: Hacer doble clic en el BAT

```
Abra: iniciar_flask.bat
```

### Opción 3: Desde PowerShell

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
python app.py
```

---

## 🔍 VERIFICAR QUE TODO FUNCIONA

### 1. Verificar MySQL
```bash
php verificar_mysql.php
```

**Esperado:**
```
✅ INSTALACIÓN EXITOSA - Todas las tablas y vistas están creadas
```

### 2. Verificar conexión Flask
```bash
python prueba_conexion.py
```

**Esperado:**
```
✅ Conexión a MySQL exitosa
   Estaciones de monitoreo: 4
   Estaciones de bombeo: 3
```

### 3. Abrir phpMyAdmin
```
http://localhost/phpmyadmin

Usuario: root
Contraseña: (dejar en blanco)
Base de datos: promotorapalmera_db
```

---

## 📊 DATOS DISPONIBLES EN MYSQL

### Estaciones de Monitoreo
```sql
SELECT * FROM iot_estacion_monitoreo;
-- Resultado: 4 estaciones en Chigorodó, Antioquia
```

### Bombas Configuradas
```sql
SELECT * FROM iot_estacion_bombeo;
-- Resultado: 3 bombas (Principal, Auxiliar, Respaldo)
```

### Umbrales de Alerta
```sql
SELECT * FROM iot_umbral_alerta;
-- Resultado: 5 umbrales configurados
```

### Contactos de Notificación
```sql
SELECT * FROM iot_contacto_notificacion;
-- Resultado: 6 contactos (Supervisores, Técnicos)
```

---

## 🛠️ TAREAS OPCIONALES

### 1. Activar Event Scheduler (para eventos automáticos)
```sql
SET GLOBAL event_scheduler = ON;
```

### 2. Ver vistas disponibles
```sql
SHOW TABLES WHERE Table_type='VIEW';
```

### 3. Ver procedimientos almacenados
```sql
SHOW PROCEDURE STATUS WHERE Db='promotorapalmera_db';
```

### 4. Insertar datos de prueba de sensores
```sql
INSERT INTO iot_datos_meteorologicos (
    estacion_id, temperatura_c, humedad_porcentaje, 
    precipitacion_mm, velocidad_viento_kmh, fecha_hora
) VALUES (
    1, 28.5, 65, 2.3, 12.5, NOW()
);
```

---

## 📋 ASIGNACIÓN DE TABLAS A MODELOS

| Tabla MySQL | Modelo Flask | Archivo |
|---|---|---|
| iot_estacion_monitoreo | MonitoringStation | database.py |
| iot_estacion_bombeo | PumpingStation | database.py |
| iot_datos_meteorologicos | MeteorologicalData | database.py |
| iot_telemetria_bomba | PumpTelemetry | database.py |
| iot_nivel_agua | WaterLevel | database.py |
| iot_estado_compuerta | GateStatus | database.py |
| iot_alerta_sistema | SystemAlert | database.py |
| iot_umbral_alerta | AlertThreshold | database.py |
| iot_log_control_automatico | AutomaticControlLog | database.py |
| iot_contacto_notificacion | NotificationContact | database.py |
| iot_resumen_flujo | FlowSummary | database.py |

---

## 🔗 URL DEL DASHBOARD

Una vez que Flask está ejecutándose:

```
http://localhost:5000
```

### Endpoints disponibles:
- GET `/api/stations` - Listar estaciones de monitoreo
- GET `/api/pumps` - Listar bombas
- GET `/api/alerts` - Listar alertas activas
- POST `/api/data` - Recibir datos de sensores
- GET `/dashboard` - Dashboard web

---

## 📞 SOPORTE

Si hay problemas:

1. **Python no encontrado:**
   - Instale Python 3.8+ desde python.org
   - Asegúrese de agregar Python al PATH

2. **pymysql no se instala:**
   - `pip install --upgrade pip`
   - `pip install pymysql`

3. **MySQL no conecta:**
   - Verifique que MySQL está corriendo
   - Verifique credenciales en `config.py`
   - Verifique que la DB `promotorapalmera_db` existe

4. **Puerto 5000 en uso:**
   - Cambie en `app.py`: `app.run(port=5001)`

---

## 📝 RESUMEN DE ARCHIVOS IMPORTANTES

| Archivo | Función |
|---|---|
| `config.py` | Configuración MySQL |
| `database.py` | Modelos SQLAlchemy (11 tablas) |
| `app.py` | Aplicación Flask principal |
| `api_extended.py` | API endpoints extendidos |
| `init_database_mysql_es.sql` | Schema MySQL completo |
| `iniciar_flask.bat` | Ejecutor rápido |
| `verificar_mysql.php` | Verificación de instalación |
| `MIGRACION_MYSQL_COMPLETADA.md` | Documentación completa |

---

## 🎯 PRÓXIMOS PASOS AVANZADOS

### 1. Integrar con Wokwi Simulator
Actualizar los endpoints para usar nombres en español:
```cpp
// En sketch.ino
"estacion_id": 1,
"temperatura_c": temp,
"humedad_porcentaje": humidity
```

### 2. Configurar Event Scheduler
```bash
# En MySQL
SET GLOBAL event_scheduler = ON;

# Verificar
SHOW VARIABLES LIKE 'event_scheduler';
```

### 3. Monitoreo de logs
```sql
SELECT * FROM iot_log_control_automatico 
ORDER BY fecha_hora DESC 
LIMIT 10;
```

### 4. Alertas activas
```sql
SELECT * FROM v_iot_alertas_activas;
```

---

**Estado:** ✅ LISTO PARA PRODUCCIÓN
**Fecha:** 21 de febrero de 2026
**Base de datos:** promotorapalmera_db
**Versión MySQL:** 5.7+ / MariaDB 10.3+
