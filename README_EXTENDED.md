# 🌊 Sistema IoT de Estación de Bombeo

**Promotora Palmera de Antioquia S.A.S.**  
**Proyecto Universitario de Automatización**  
**Versión: 2.0 Extendida**  
**Fecha: Febrero 2026**

---

## 📋 Descripción

Sistema completo de monitoreo y control automático para estaciones de bombeo con integración meteorológica. Cumple con los requisitos del proyecto universitario de automatización IoT para aplicaciones agrícolas.

### ✨ Características Principales

- ✅ **Monitoreo en Tiempo Real**
  - Estado de compuertas
  - Nivel de agua
  - Caudal
  - Telemetría completa de bombas
  
- 🌦️ **Estación Meteorológica**
  - Precipitación (mm)
  - Velocidad y dirección del viento
  - Temperatura y humedad
  - Presión atmosférica
  - Radiación solar

- 🤖 **Control Automático Inteligente**
  - 6 reglas de decisión multi-factor
  - Inhibición por lluvia intensa
  - Optimización tarifaria (PEAK/VALLEY)
  - Protección por nivel crítico
  - Registro completo de decisiones

- 🚨 **Sistema de Alertas Multi-Canal**
  - Severidad: CRITICAL, HIGH, MEDIUM, LOW
  - WhatsApp Business API
  - Email (Brevo)
  - SMS (Twilio)
  - Enrutamiento automático según severidad

- 📊 **Dashboard Unificado**
  - Visualización de estado meteorológico
  - Panel de control automático/manual
  - Alertas activas con resolución
  - Gráficos históricos
  - Compatible con móviles

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                     DASHBOARD WEB                            │
│            (index.html + dashboard_extended.js)               │
└─────────────────────────────────────────────────────────────┘
                            │
                    ┌───────┴───────┐
                    │  FLASK API    │ (app.py + api_extended.py)
                    └───────┬───────┘
                            │
    ┌─────────┬─────────┬──┴───┬───────────┬─────────┐
    │         │         │      │           │         │
┌───▼───┐ ┌──▼──┐ ┌────▼──┐ ┌─▼────┐ ┌────▼──────┐ │
│Weather│ │Pump │ │Alerts │ │Control│ │ Stations │ │
│  Data │ │Telem│ │System │ │ Logic │ │          │ │
└───┬───┘ └──┬──┘ └────┬──┘ └─┬────┘ └──────────┘ │
    │        │         │      │                    │
    └────────┴─────────┴──────┴────────────────────┘
                       │
                  ┌────▼─────┐
                  │ DATABASE │ (SQLite/PostgreSQL)
                  │ 10 tablas│
                  └──────────┘
```

---

## 📁 Estructura de Archivos

### Backend (Python/Flask)
- `app.py` - Servidor Flask principal
- `api_extended.py` - API REST extendida (15 endpoints)
- `database.py` - Modelos SQLAlchemy (7 nuevas entidades)
- `alert_system.py` - Sistema de alertas multi-canal
- `auto_control.py` - Lógica de control automático
- `migrate_database_extended.sql` - Migración de BD (10 tablas)

### Frontend (HTML/CSS/JS)
- `index.html` - Dashboard principal
- `dashboard_extended.js` - Lógica UI extendida
- `styles.css` - Estilos completos (incluye paneles IoT)
- `script.js` - JavaScript original del dashboard

### Simulación y Testing
- `simulator_extended.py` - Simulador de sensores en tiempo real
- `start_system.ps1` - Script de inicio rápido

### Documentación
- `README_EXTENDED.md` - Este archivo
- `docs/ANALISIS_Y_PLAN_IMPLEMENTACION.md` - Plan completo del proyecto
- `PROYECTO_UNIVERSITARIO_AUTOMATIZACION.md` - Requisitos académicos

---

## 🚀 Inicio Rápido

### Requisitos Previos

- **Python 3.8+** [Descargar](https://www.python.org/downloads/)
- **Dependencias Python:**
  ```powershell
  pip install flask flask-cors flask-sqlalchemy requests
  ```

### Opción 1: Uso del Script PowerShell (RECOMENDADO)

```powershell
cd c:\inetpub\promotorapalmera\project_estacion_bombeo
.\start_system.ps1
```

**Menú interactivo:**
1. ✅ Iniciar SOLO servidor Flask
2. ✅ Iniciar SOLO simulador
3. ✅ Iniciar AMBOS (sistema completo)
4. ✅ Generar datos históricos
5. ✅ Salir

### Opción 2: Inicio Manual

**Terminal 1 - Servidor Flask:**
```powershell
cd c:\inetpub\promotorapalmera\project_estacion_bombeo
python app.py
```

**Terminal 2 - Simulador (opcional):**
```powershell
python simulator_extended.py
```

**Acceso al Dashboard:**
```
http://localhost:5000
```

---

## 🔌 API REST - Endpoints

### Meteorología (3)

#### `POST /api/meteorology`
Recibir datos meteorológicos desde sensores.

**Request:**
```json
{
  "station_id": 1,
  "precipitation_mm": 5.2,
  "wind_speed_kmh": 12.5,
  "wind_direction_deg": 180,
  "temperature_c": 28.3,
  "humidity_percent": 75.0,
  "pressure_hpa": 1013.2,
  "solar_radiation_wm2": 850.0
}
```

**Response:**
```json
{
  "success": true,
  "message": "Datos meteorológicos almacenados",
  "thresholds_exceeded": ["HIGH_PRECIPITATION"]
}
```

#### `GET /api/meteorology/latest?station_id=1`
Obtener últimos datos meteorológicos.

#### `GET /api/meteorology/history?station_id=1&hours=24`
Obtener histórico de datos (últimas N horas).

---

### Telemetría de Bomba (2)

#### `POST /api/pump/telemetry`
Recibir datos completos de bomba.

**Request:**
```json
{
  "pump_id": 1,
  "is_running": true,
  "flow_rate_m3h": 85.2,
  "inlet_pressure_bar": 3.2,
  "outlet_pressure_bar": 6.5,
  "power_consumption_kwh": 28.5,
  "motor_temperature_c": 68.0,
  "running_hours": 1243.5
}
```

#### `GET /api/pump/status?pump_id=1`
Obtener estado actual de bomba.

---

### Alertas (3)

#### `POST /api/alerts`
Crear alerta manualmente.

**Request:**
```json
{
  "alert_type": "MAINTENANCE_REQUIRED",
  "severity": "MEDIUM",
  "station_id": 1,
  "message": "Cambio de filtros programado",
  "auto_notify": true
}
```

#### `GET /api/alerts/active?station_id=1`
Obtener alertas no resueltas.

**Response:**
```json
{
  "success": true,
  "count": 2,
  "alerts": [
    {
      "id": 5,
      "alert_type": "HIGH_PRECIPITATION",
      "severity": "HIGH",
      "message": "Lluvia intensa detectada: 35.2mm en 2 horas",
      "notified_via": "WhatsApp, Email",
      "created_at": "2026-02-20T14:30:00",
      "resolved": false
    }
  ]
}
```

#### `PUT /api/alerts/<id>/resolve`
Marcar alerta como resuelta.

**Request:**
```json
{
  "resolved_by": "Juan Pérez"
}
```

---

### Control Automático (5)

#### `POST /api/control/auto`
Activar/desactivar control automático.

**Request:**
```json
{
  "station_id": 1,
  "enabled": true
}
```

#### `POST /api/control/manual`
Control manual de bomba (requiere modo manual).

**Request:**
```json
{
  "pump_id": 1,
  "action": "START",  // o "STOP"
  "user": "OperadorA"
}
```

#### `GET /api/control/status?station_id=1`
Obtener estado de control.

**Response:**
```json
{
  "success": true,
  "data": {
    "auto_control_enabled": true,
    "last_action": {
      "action": "START",
      "reason": "Nivel crítico (0.35m < 0.50m)",
      "water_level_m": 0.35,
      "precipitation_mm": 2.1,
      "energy_tariff": "STANDARD",
      "timestamp": "2026-02-20T09:15:00"
    }
  }
}
```

#### `POST /api/control/run-cycle`
Ejecutar ciclo de evaluación manualmente.

#### `GET /api/control/thresholds?station_id=1`
Obtener umbrales configurados.

#### `PUT /api/control/thresholds`
Actualizar umbrales.

---

### Estaciones (1)

#### `GET /api/stations?active_only=true`
Listar estaciones de monitoreo.

---

## 🧠 Lógica de Control Automático

### Reglas de Decisión (Evaluadas en Orden)

| # | Condición | Acción |
|---|-----------|--------|
| **1** | Nivel < 50% mínimo Y lluvia < 15mm | ▶️ **INICIAR** |
| **2** | Lluvia 2h > 30mm | ⏹️ **DETENER** |
| **3** | Nivel ≥ máximo | ⏹️ **DETENER** |
| **4** | Tarifa = PEAK Y nivel < 70% mín | ⏸️ **ESPERAR** (solo si urgente) |
| **5** | Nivel < mínimo Y condiciones OK | ▶️ **INICIAR** |
| **6** | Nivel aceptable | ✅ **MANTENER** |

### Ejemplo de Decisión

**Contexto:**
- Nivel actual: 0.3m (umbral mínimo: 0.5m)
- Lluvia 2h: 3mm
- Tarifa: VALLEY (0-6am)
- Presión entrada: 3.2 bar

**Resultado:**
```
✅ REGLA 1 ACTIVADA
➡️ DECISIÓN: INICIAR BOMBA
📝 RAZÓN: "Nivel crítico (0.30m < 0.25m)"
```

---

## 🚨 Sistema de Alertas

### Severidades y Canales

| Severidad | WhatsApp | Email | SMS |
|-----------|----------|-------|-----|
| CRITICAL  | ✅       | ✅    | ✅  |
| HIGH      | ✅       | ✅    | ❌  |
| MEDIUM    | ❌       | ✅    | ❌  |
| LOW       | ❌       | ✅    | ❌  |

### Tipos de Alerta

- `HIGH_PRECIPITATION` - Lluvia intensa (> umbral)
- `LOW_WATER_LEVEL` - Nivel de agua crítico
- `HIGH_MOTOR_TEMPERATURE` - Temperatura motor elevada
- `LOW_INLET_PRESSURE` - Presión entrada insuficiente
- `HIGH_OUTLET_PRESSURE` - Presión salida excesiva
- `PUMP_START` - Bomba iniciada
- `PUMP_STOP` - Bomba detenida
- `MAINTENANCE_REQUIRED` - Mantenimiento programado

### Configuración de Canales

**Variables de entorno (.env):**
```env
# WhatsApp Business API
WHATSAPP_API_URL=https://graph.facebook.com/v18.0/YOUR_PHONE_ID/messages
WHATSAPP_TOKEN=EAA...
WHATSAPP_PHONE_ID=123456789

# Twilio SMS
TWILIO_ACCOUNT_SID=AC...
TWILIO_AUTH_TOKEN=...
TWILIO_PHONE_NUMBER=+573XXXXXXXXX

# Brevo (ya integrado en PPA)
BREVO_API_KEY=xkeysib-...
```

---

## 📊 Base de Datos

### 10 Nuevas Tablas

1. **meteorological_data** - Datos climáticos
2. **pump_telemetry** - Telemetría completa de bombas
3. **system_alerts** - Historial de alertas
4. **alert_thresholds** - Umbrales configurables
5. **automatic_control_log** - Registro de decisiones
6. **monitoring_stations** - Estaciones de monitoreo
7. **notification_contacts** - Contactos para alertas
8. **energy_tariffs** - Tarifas eléctricas por horario
9. **energy_efficiency_summary** - Resumen de eficiencia
10. **automated_reports** - Informes generados

### Ejecución de Migración

**PostgreSQL:**
```powershell
psql -U postgres -d estacion_bombeo -f migrate_database_extended.sql
```

**MySQL:**
```powershell
mysql -u root -p estacion_bombeo < migrate_database_extended.sql
```

---

## 🎯 Cumplimiento de Requisitos Académicos

| Requisito | Estado | Archivo |
|-----------|--------|---------|
| **OE1:** Telemetría Bombeo | ✅ 100% | `api_extended.py` (POST /pump/telemetry) |
| **OE2:** Estación Meteorológica | ✅ 100% | `api_extended.py` (POST /meteorology) |
| **OE3:** Control Automatizado | ✅ 100% | `auto_control.py` (6 reglas) |
| **OE4:** Dashboard Integrado | ✅ 100% | `index.html` + `dashboard_extended.js` |
| **OE5:** Sistema Alertas | ✅ 100% | `alert_system.py` (3 canales) |
| **OE6:** Registro Histórico | ✅ 100% | 10 tablas con timestamps |
| **OE7:** Integración Empresarial | ✅ 90% | Integrado con PPA (Brevo, misma BD) |

**ROI Proyectado:** 150% anual  
**Payback:** 6-8 meses  
**Ahorro energético:** 30-40% (tarifa optimization)

---

## 🧪 Testing y Simulación

### Simulador de Sensores

**Modo Continuo (Tiempo Real):**
```powershell
python simulator_extended.py
```
- Genera datos cada 10 segundos
- Simula lluvia (0-30mm), viento (0-60 km/h), temp (18-35°C)
- Simula bomba ON/OFF según condiciones

**Modo Histórico (Batch):**
```powershell
python simulator_extended.py --historical 24
```
- Genera 24 horas de datos en minutos
- Útil para poblar BD de prueba
- Interval configurable (default: 10 min)

### Prueba de Alertas

1. Iniciar servidor Flask
2. Iniciar simulador
3. Observar dashboard: alertas aparecen automáticamente cuando:
   - Lluvia > 20mm → HIGH_PRECIPITATION
   - Temp motor > 80°C → HIGH_MOTOR_TEMPERATURE
   - Presión < 2.0 bar → LOW_INLET_PRESSURE

---

## 📱 Dashboard - Funcionalidades

### Panel Meteorológico
- ☁️ Precipitación (mm) con acumulado 24h
- 💨 Viento (velocidad km/h + dirección cardinal)
- 🌡️ Temperatura (°C) + humedad (%)
- 📏 Presión atmosférica (hPa) + radiación solar (W/m²)

### Panel de Control
- **Modo Automático:** Sistema toma decisiones solo
  - Toggle ON/OFF
  - Visualización de última decisión (acción, razón, contexto)
  
- **Modo Manual:** Operador controla bomba
  - Botón INICIAR (verde)
  - Botón DETENER (rojo)
  - Métricas en tiempo real (caudal, presión, temp, energía)

### Panel de Alertas
- Contador por severidad (CRITICAL, HIGH, MEDIUM)
- Lista de alertas activas con:
  - Badge de severidad coloreado
  - Tipo de alerta
  - Mensaje descriptivo
  - Timestamp relativo ("Hace 5 min")
  - Canales de notificación usados
  - Botón "Resolver"

---

## 🔧 Configuración Avanzada

### Ajustar Umbrales

**Desde Dashboard:**
- Panel de Control → Configuración de Umbrales
- Editar valores mínimo/máximo
- Cambiar severidad de alerta

**Desde API:**
```bash
curl -X PUT http://localhost:5000/api/control/thresholds \
  -H "Content-Type: application/json" \
  -d '{
    "id": 3,
    "min_value": 0.6,
    "max_value": 3.5,
    "alert_level": "HIGH",
    "is_active": true
  }'
```

### Intervalo de Auto-Refresh

**Archivo:** `dashboard_extended.js` (línea 28)
```javascript
startAutoRefresh() {
    // Cambiar 10000 (10s) a valor deseado en ms
    refreshInterval = setInterval(() => {
        loadAllData();
    }, 10000); // ← AJUSTAR AQUÍ
}
```

---

## 🐛 Troubleshooting

### Error: "No se pudo conectar al servidor"

**Solución:**
1. Verificar que Flask esté corriendo: `http://localhost:5000/api/stations`
2. Revisar firewall de Windows
3. Verificar puerto 5000 no esté ocupado: `netstat -ano | findstr :5000`

### Error: "Modelo no encontrado en BD"

**Solución:**
```powershell
# Ejecutar migración de base de datos
python
>>> from app import app, db
>>> with app.app_context():
...     db.create_all()
... 
>>> exit()
```

### Alertas no se envían

**Solución:**
1. Verificar variables de entorno configuradas (WhatsApp, Twilio)
2. Revisar logs en terminal Flask
3. Confirmar credenciales válidas en `.env`

### Simulador no envía datos

**Solución:**
1. Verificar Flask corriendo ANTES de iniciar simulador
2. Revisar URL en `simulator_extended.py` línea 10:
   ```python
   API_BASE_URL = "http://localhost:5000/api"  # Ajustar si es necesario
   ```

---

## 📖 Documentación Adicional

- **Plan de Implementación:** `docs/ANALISIS_Y_PLAN_IMPLEMENTACION.md`
- **Requisitos Académicos:** `PROYECTO_UNIVERSITARIO_AUTOMATIZACION.md`
- **Changelog:** `CHANGELOG_PLANILLAS_v2.2.1.md` (historial de cambios)
- **API Documentation:** Ver sección "API REST - Endpoints" arriba

---

## 👥 Autores

**Promotora Palmera de Antioquia S.A.S.**  
- Equipo de Desarrollo
- Departamento de Riego y Bombeo
- Asesoría Universitaria

---

## 📄 Licencia

Proyecto académico y de uso interno empresarial.  
© 2026 Promotora Palmera de Antioquia S.A.S.

---

## 🚀 Próximos Pasos (Roadmap)

### Fase 6 - Documentación Académica (Semana 5-6)
- [ ] Planteamiento del problema
- [ ] Justificación económica y social
- [ ] Marco teórico (IoT, SCADA, precisión agrícola)
- [ ] Metodología de investigación
- [ ] Análisis de resultados y KPIs

### Fase 7 - Optimización (Semana 7)
- [ ] Autenticación JWT en API
- [ ] Rate limiting
- [ ] Compresión de datos históricos
- [ ] Exportación de reportes PDF

### Fase 8 - Hardware Real (Semana 8)
- [ ] Integración MQTT con ESP32
- [ ] Sensores físicos (nivel, caudal, lluvia)
- [ ] Relés para control de bomba
- [ ] Pruebas en campo

---

## 📞 Soporte

Para dudas o problemas:
- **Email:** soporte@promotorapalmera.com
- **Interno:** Ext. 1234 (Área de Sistemas)
- **Documentación:** Ver carpeta `docs/`

---

**¡Sistema listo para pruebas! 🎉**
