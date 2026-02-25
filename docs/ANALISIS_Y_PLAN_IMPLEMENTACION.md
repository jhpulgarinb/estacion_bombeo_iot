# ANÁLISIS Y PLAN DE ADECUACIÓN DEL PROYECTO
## Sistema de Automatización de Estación de Bombeo
**Fecha:** 20 de febrero de 2026  
**Estado actual:** Sistema básico de monitoreo de compuertas  
**Estado objetivo:** Sistema IoT completo según PROYECTO_UNIVERSITARIO_AUTOMATIZACION.md

---

## 1. ANÁLISIS DE BRECHA (GAP ANALYSIS)

### 1.1 Lo que EXISTE actualmente

✅ **Backend funcional:**
- Flask app con API REST básica
- Base de datos con tablas: gate_status, water_level, flow_summary, pumping_stations
- Cálculos hidráulicos (flow, volume)
- Dashboard HTML responsive

✅ **Frontend funcional:**
- index.html con Chart.js
- Visualización de estado de compuertas
- Gráficos de nivel de agua y caudal
- Auto-refresh cada 60 segundos

✅ **Infraestructura:**
- Scripts PowerShell para iniciar sistema
- Configuración para múltiples estaciones
- SQLite/PostgreSQL soportado

### 1.2 Lo que FALTA según requisitos universitarios

❌ **Estación Meteorológica:**
- No hay tablas para datos climáticos (lluvia, viento, temperatura, humedad, presión)
- No hay API endpoints para recibir datos meteorológicos
- No hay visualización de clima en dashboard

❌ **Telemetría Completa de Bombeo:**
- Falta: Consumo energético (kWh)
- Falta: Temperatura del motor
- Falta: Presión de entrada/salida
- Falta: Horas de operación acumuladas

❌ **Control Automático:**
- No hay lógica para activar/desactivar bombas automáticamente
- No hay integración con umbrales configurables
- No hay consideración de datos climáticos para decisiones

❌ **Sistema de Alertas:**
- No hay notificaciones por WhatsApp
- No hay envío de emails automáticos
- No hay SMS para emergencias
- No hay sistema de umbrales configurables

❌ **Integración Empresarial:**
- No está integrado con sistema PQRSF
- No comparte diseño/estilos con intranet PPA
- No usa sistema de usuarios/permisos existente

❌ **Documentación Académica:**
- Falta: Planteamiento del problema detallado
- Falta: Justificación económica/ambiental/social
- Falta: Marco teórico completo
- Falta: Metodología de investigación
- Falta: Análisis de resultados esperados

---

## 2. PLAN DE IMPLEMENTACIÓN FASE POR FASE

### FASE 1: AMPLIACIÓN DE BASE DE DATOS (Prioridad ALTA)

**Objetivo:** Agregar tablas para telemetría completa

**Nuevas tablas necesarias:**

```sql
-- TABLA: Datos meteorológicos
CREATE TABLE meteorological_data (
    id SERIAL PRIMARY KEY,
    station_id INT NOT NULL,
    precipitation_mm DECIMAL(6,2),
    wind_speed_kmh DECIMAL(5,2),
    wind_direction_deg INT,
    temperature_c DECIMAL(4,2),
    humidity_percent DECIMAL(5,2),
    pressure_hpa DECIMAL(6,2),
    solar_radiation_wm2 DECIMAL(7,2),
    timestamp TIMESTAMP NOT NULL,
    source_device VARCHAR(50)
);

-- TABLA: Telemetría de bomba (extendida)
CREATE TABLE pump_telemetry (
    id SERIAL PRIMARY KEY,
    pump_id INT NOT NULL,
    is_running BOOLEAN NOT NULL,
    flow_rate_m3h DECIMAL(8,3),
    inlet_pressure_bar DECIMAL(6,3),
    outlet_pressure_bar DECIMAL(6,3),
    power_consumption_kwh DECIMAL(10,3),
    motor_temperature_c DECIMAL(5,2),
    running_hours DECIMAL(12,2),
    timestamp TIMESTAMP NOT NULL,
    source_device VARCHAR(50)
);

-- TABLA: Alertas y eventos
CREATE TABLE system_alerts (
    id SERIAL PRIMARY KEY,
    alert_type VARCHAR(50) NOT NULL,
    severity VARCHAR(20) CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    station_id INT NOT NULL,
    message TEXT NOT NULL,
    notified_via VARCHAR(100),
    resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMP
);

-- TABLA: Umbrales configurables
CREATE TABLE alert_thresholds (
    id SERIAL PRIMARY KEY,
    station_id INT NOT NULL,
    parameter_name VARCHAR(100) NOT NULL,
    min_value DECIMAL(12,4),
    max_value DECIMAL(12,4),
    alert_level VARCHAR(20),
    notification_method VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE
);

-- TABLA: Control automático (logs)
CREATE TABLE automatic_control_log (
    id SERIAL PRIMARY KEY,
    pump_id INT NOT NULL,
    action VARCHAR(20) CHECK (action IN ('START', 'STOP')),
    reason TEXT,
    water_level_m DECIMAL(6,3),
    precipitation_mm DECIMAL(6,2),
    energy_tariff VARCHAR(20),
    timestamp TIMESTAMP NOT NULL DEFAULT NOW()
);
```

**Archivos a modificar:**
- `database.py` → Agregar modelos SQLAlchemy
- `bd-estacion-bombeo.sql` → Agregar CREATE TABLE
- `app.py` → Agregar endpoints para nuevas tablas

---

### FASE 2: API EXTENDIDA (Prioridad ALTA)

**Nuevos endpoints necesarios:**

```python
# METEOROLOGÍA
POST /api/meteorology          # Recibir datos clima
GET  /api/meteorology/latest   # Último registro clima
GET  /api/meteorology/history  # Histórico clima

# TELEMETRÍA BOMBA
POST /api/pump/telemetry       # Recibir datos bomba completos
GET  /api/pump/status          # Estado actual bomba
GET  /api/pump/energy          # Consumo energético

# ALERTAS
POST /api/alerts               # Generar alerta manual
GET  /api/alerts/active        # Alertas activas
PUT  /api/alerts/:id/resolve   # Resolver alerta

# CONTROL AUTOMÁTICO
POST /api/control/auto         # Activar/desactivar modo automático
POST /api/control/manual       # Control manual ON/OFF
GET  /api/control/status       # Estado control
PUT  /api/control/thresholds   # Configurar umbrales

# REPORTES
GET  /api/reports/daily        # Reporte diario
GET  /api/reports/energy       # Reporte energético
GET  /api/reports/efficiency   # KPIs de eficiencia
```

---

### FASE 3: SISTEMA DE ALERTAS (Prioridad ALTA)

**Integración con servicios existentes:**

Archivo: `alert_system.py` (NUEVO)

```python
from brevo_config import send_email  # Ya existe en sistema PPA
import requests  # Para WhatsApp Business API
from twilio.rest import Client  # Para SMS

class AlertManager:
    def __init__(self):
        self.whatsapp_api = "https://graph.facebook.com/v18.0/{phone_id}/messages"
        self.twilio_client = Client(account_sid, auth_token)
    
    def send_alert(self, alert_type, severity, message, recipients):
        """Enviar alerta por múltiples canales"""
        
        if severity in ['HIGH', 'CRITICAL']:
            # Enviar por los 3 canales
            self.send_whatsapp(message, recipients['whatsapp'])
            self.send_email_alert(message, recipients['email'])
            self.send_sms(message, recipients['phone'])
        elif severity == 'MEDIUM':
            # Solo WhatsApp y Email
            self.send_whatsapp(message, recipients['whatsapp'])
            self.send_email_alert(message, recipients['email'])
        else:
            # Solo Email
            self.send_email_alert(message, recipients['email'])
    
    def send_whatsapp(self, message, phone):
        # Implementar con WhatsApp Business API
        pass
    
    def send_email_alert(self, message, email):
        # Usar BrevoEmailHelper existente
        from BrevoEmailHelperV2 import enviar_email_brevo
        enviar_email_brevo(
            destinatario=email,
            asunto=f"[ALERTA] {message[:50]}",
            contenido_html=f"<p>{message}</p>"
        )
    
    def send_sms(self, message, phone):
        # Usar Twilio
        self.twilio_client.messages.create(
            body=message,
            from_='+57XXXXXXXXXX',
            to=phone
        )
```

---

### FASE 4: DASHBOARD INTEGRADO (Prioridad MEDIA)

**Mejoras necesarias en index.html:**

1. **Agregar sección meteorológica:**
```html
<section class="weather-panel">
    <h2><i class="fas fa-cloud-rain"></i> Estación Meteorológica</h2>
    <div class="weather-grid">
        <div class="weather-card">
            <span class="weather-icon">🌧️</span>
            <div class="weather-value" id="rainfall">-</div>
            <div class="weather-label">Precipitación (mm)</div>
        </div>
        <div class="weather-card">
            <span class="weather-icon">💨</span>
            <div class="weather-value" id="windSpeed">-</div>
            <div class="weather-label">Viento (km/h)</div>
        </div>
        <!-- Más cards... -->
    </div>
</section>
```

2. **Panel de control automático:**
```html
<section class="auto-control-panel">
    <h2><i class="fas fa-robot"></i> Control Automático</h2>
    <div class="control-status">
        <label class="switch">
            <input type="checkbox" id="autoMode">
            <span class="slider"></span>
        </label>
        <span>Modo Automático: <span id="autoStatus">DESACTIVADO</span></span>
    </div>
    <div class="threshold-config">
        <!-- Configuración de umbrales -->
    </div>
</section>
```

3. **Integración visual con sistema PPA:**
- Copiar estilos del dashboard PQRSF (colores, tipografía)
- Usar mismo header que intranet PPA
- Menú lateral con navegación integrada

**Archivos de referencia:**
- `c:\inetpub\promotorapalmera\pqrsf\consulta-publica.html` (estilos)
- `c:\inetpub\promotorapalmera\precipitacion.html` (gráficos)

---

### FASE 5: LÓGICA DE CONTROL AUTOMÁTICO (Prioridad MEDIA)

Archivo: `auto_control.py` (NUEVO)

```python
from datetime import datetime, timedelta
from database import db, WaterLevel, meteorological_data, pump_telemetry
from alert_system import AlertManager

class AutomaticController:
    def __init__(self, pump_id):
        self.pump_id = pump_id
        self.alert_manager = AlertManager()
    
    def evaluate_and_act(self):
        """Evaluar condiciones y decidir acción"""
        
        # 1. Obtener datos actuales
        water_level = self.get_current_water_level()
        rainfall = self.get_recent_rainfall(hours=2)
        tariff = self.get_current_tariff()
        pump_status = self.get_pump_status()
        
        # 2. Evaluar umbrales
        thresholds = self.get_thresholds()
        
        # 3. Decidir acción
        should_run = self.decision_logic(
            water_level, rainfall, tariff, pump_status, thresholds
        )
        
        # 4. Ejecutar acción
        if should_run and not pump_status['is_running']:
            self.start_pump(reason=f"Nivel bajo: {water_level}m, Lluvia: {rainfall}mm")
        elif not should_run and pump_status['is_running']:
            self.stop_pump(reason=f"Condiciones satisfechas")
    
    def decision_logic(self, level, rain, tariff, status, thresholds):
        """Lógica de decisión basada en múltiples factores"""
        
        # Condiciones para ENCENDER:
        # - Nivel < 50% del mínimo
        # - Lluvia en últimas 2h < 5mm
        # - Presión de red > umbral mínimo
        # - NO estamos en tarifa pico
        
        if level < (thresholds['min_water_level'] * 0.5):
            if rain < 5.0:
                if tariff != 'PEAK':
                    return True
        
        return False
    
    def start_pump(self, reason):
        """Activar bomba y registrar"""
        # Enviar comando a hardware (MQTT/HTTP)
        # Registrar en automatic_control_log
        # Generar alerta INFO
        pass
    
    def stop_pump(self, reason):
        """Apagar bomba y registrar"""
        pass
```

---

### FASE 6: DOCUMENTACIÓN ACADÉMICA (Prioridad BAJA - FINAL)

**Archivos a crear/modificar:**

1. **`docs/01_PLANTEAMIENTO_PROBLEMA.md`**
   - Redactar situación actual basado en operación real
   - Identificar problemas concretos observados
   - Cuantificar impactos económicos

2. **`docs/02_JUSTIFICACION.md`**
   - Calcular ROI con datos reales de la empresa
   - Justificar ambiental (ahorro de agua/energía)
   - Justificar social (mejora condiciones laborales)

3. **`docs/03_OBJETIVOS.md`**
   - Listar objetivos específicos alcanzados
   - Métricas de éxito (antes/después)

4. **`docs/04_MARCO_TEORICO.md`**
   - IoT aplicado a agroindustria
   - SCADA y telemetría
   - Agricultura de precisión

5. **`docs/05_METODOLOGIA.md`**
   - Fases ejecutadas
   - Técnicas de recolección de datos
   - Indicadores de éxito medidos

6. **`docs/06_RESULTADOS.md`**
   - Gráficas comparativas antes/después
   - Análisis de datos recolectados
   - KPIs alcanzados

7. **`docs/07_CONCLUSIONES.md`**
   - Resumen de logros
   - Lecciones aprendidas
   - Recomendaciones

---

## 3. CRONOGRAMA DE IMPLEMENTACIÓN

| Fase | Duración | Dependencias | Prioridad |
|------|----------|--------------|-----------|
| Fase 1: Base de datos | 1 semana | Ninguna | CRÍTICA |
| Fase 2: API extendida | 1 semana | Fase 1 | CRÍTICA |
| Fase 3: Alertas | 1 semana | Fase 2 | ALTA |
| Fase 4: Dashboard | 2 semanas | Fase 2, 3 | ALTA |
| Fase 5: Control auto | 1 semana | Fase 1,2,3 | MEDIA |
| Fase 6: Documentación | 2 semanas | Todas | BAJA |

**Total estimado: 8 semanas (2 meses)**

---

## 4. RECURSOS NECESARIOS

### 4.1 Servicios Cloud (Ya existen algunos)

✅ **Ya disponibles:**
- Servidor IIS (Windows Server)
- MySQL (promotorapalmera_db)
- BrevoEmailHelper (envío de emails)

❌ **Necesarios:**
- WhatsApp Business API ($180,000 COP/mes)
- Twilio SMS ($150,000 COP/mes)
- MQTT Broker (HiveMQ Cloud - Gratis tier pequeño)

### 4.2 Hardware de Simulación

Durante desarrollo (sin sensores físicos):

```python
# virtual_sensors.py (YA EXISTE)
# Simular sensores meteorológicos:
- Lluvia: Valores aleatorios 0-50mm
- Viento: 0-80 km/h
- Temperatura: 18-32°C
- Humedad: 40-95%

# Simular telemetría bomba:
- Consumo: 15-45 kWh según estado
- Temperatura motor: 40-80°C
- Presión: 2-8 bar
```

---

## 5. PRÓXIMOS PASOS INMEDIATOS

### Paso 1: Extender base de datos
```bash
# Ejecutar:
python migrate_database.py  # Crear nuevo script
```

### Paso 2: Probar con simulador
```bash
# Ejecutar:
python data_simulator.py  # Ya existe, extender
```

### Paso 3: Desarrollar endpoints clima
```python
# En app.py agregar:
@app.route('/api/meteorology', methods=['POST'])
```

### Paso 4: Integrar alertas básicas
```python
# Crear alert_system.py
# Integrar con Brevo
```

### Paso 5: Modificar dashboard
```html
<!-- index.html: Agregar sección clima -->
```

---

## 6. CHECKLIST DE CUMPLIMIENTO REQUISITOS

### Objetivos Específicos del Proyecto (OE1-OE7)

- [ ] **OE1 - Telemetría Bombeo:** Sensores caudal, presión, energía ✅ (parcial, falta energía/presión)
- [ ] **OE2 - Estación Meteorológica:** Lluvia, viento, temp, humedad ❌ (no implementado)
- [ ] **OE3 - Control Automatizado:** Lógica activar/desactivar bombas ❌ (no implementado)
- [ ] **OE4 - Dashboard Integrado:** Interfaz web centralizada ✅ (parcial, falta clima/alertas)
- [ ] **OE5 - Sistema Alertas:** WhatsApp/Email/SMS ❌ (no implementado)
- [ ] **OE6 - Registro Histórico:** Almacenamiento 2+ años ✅ (estructura existe)
- [ ] **OE7 - Integración Empresarial:** PQRSF/PPA ❌ (no implementado)

### Variables Monitoreadas

**Bombeo:**
- [x] Caudal (L/min o m³/h)
- [ ] Presión entrada/salida
- [ ] Consumo energético (kWh)
- [ ] Temperatura motor
- [ ] Horas operación
- [x] Estado ON/OFF/FALLA

**Meteorología:**
- [ ] Precipitación (mm)
- [ ] Velocidad/dirección viento
- [ ] Temperatura (°C)
- [ ] Humedad (%)
- [ ] Presión atmosférica

### Funcionalidades

- [x] Monitoreo 24/7 en tiempo real
- [ ] Control remoto ON/OFF bombas
- [ ] Alertas configurables
- [x] Registro histórico
- [x] Dashboard responsive
- [ ] Reportes automatizados
- [ ] Integración PQRSF/PPA
- [ ] Sistema permisos/roles

---

## CONCLUSIÓN DEL ANÁLISIS

**Estado actual: 35% completo**

El sistema base está funcional para monitoreo de compuertas y nivel de agua, pero requiere expansiones significativas para cumplir requisitos universitarios de automatización IoT completa.

**Prioridades inmediatas:**
1. Extender base de datos (meteorología + telemetría completa)
2. Implementar API para nuevos sensores
3. Crear sistema de alertas multi-canal
4. Integrar con dashboard unificado estilo PPA

**Ventaja:** La infraestructura base (Flask, BD, dashboard) está sólida y puede extenderse sin refactorización mayor.

---

**Elaborado:** 20 de febrero de 2026  
**Próxima revisión:** Al completar Fase 1
