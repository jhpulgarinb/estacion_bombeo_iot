# Manual Técnico - Sistema de Monitoreo de Estaciones de Bombeo

## Tabla de Contenidos
1. [Arquitectura del Sistema](#arquitectura-del-sistema)
2. [Componentes Técnicos](#componentes-técnicos)
3. [Base de Datos](#base-de-datos)
4. [API REST](#api-rest)
5. [Frontend](#frontend)
6. [Configuración Avanzada](#configuración-avanzada)
7. [Mantenimiento](#mantenimiento)
8. [Solución de Problemas Técnicos](#solución-de-problemas-técnicos)
9. [Desarrollo y Extensiones](#desarrollo-y-extensiones)

## Arquitectura del Sistema

### Diseño General

El sistema sigue una arquitectura de 3 capas:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Frontend     │    │     Backend     │    │   Base de Datos │
│   (HTML/CSS/JS) │◄───┤   (Flask/Python)│◄───┤   (PostgreSQL)  │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Componentes Principales

- **Frontend Web:** Dashboard responsivo en HTML5/CSS3/JavaScript
- **API REST:** Servidor Flask con endpoints RESTful
- **Base de Datos:** PostgreSQL para almacenamiento persistente
- **Cálculos:** Módulo de cálculos hidráulicos

### Flujo de Datos

1. **Sensores** → **API REST** → **Base de Datos**
2. **Base de Datos** → **API REST** → **Frontend**
3. **Frontend** → **Visualización** → **Usuario**

## Componentes Técnicos

### Backend (Python/Flask)

#### Estructura de Archivos
```
project_estacion_bombeo/
├── app.py              # Aplicación Flask principal
├── database.py         # Modelos SQLAlchemy
├── calculations.py     # Funciones de cálculo hidráulico
├── config.py          # Configuración de la aplicación
└── requirements.txt   # Dependencias Python
```

#### Dependencias Principales
- **Flask 2.3.3:** Framework web minimalista
- **Flask-SQLAlchemy 3.0.5:** ORM para base de datos
- **Flask-CORS 4.0.0:** Manejo de CORS
- **psycopg2-binary 2.9.7:** Driver PostgreSQL
- **paho-mqtt 1.6.1:** Cliente MQTT (futuro uso)

#### Configuración (`config.py`)
```python
import os

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
SQLALCHEMY_DATABASE_URI = 'postgresql://usuario:password@localhost:5432/monitoring_db'
SQLALCHEMY_TRACK_MODIFICATIONS = False
SECRET_KEY = 'clave-secreta-para-aplicacion'
```

### Frontend (HTML/CSS/JavaScript)

#### Tecnologías Utilizadas
- **HTML5:** Estructura semántica
- **CSS3:** Estilos modernos con Grid y Flexbox
- **JavaScript ES6+:** Lógica de cliente
- **Chart.js:** Biblioteca de gráficos
- **Fetch API:** Comunicación con backend

#### Características del Frontend
- **Responsivo:** Compatible con dispositivos móviles
- **Tiempo Real:** Actualización automática cada 60s
- **Interactivo:** Gráficos dinámicos
- **Accesible:** Diseño inclusivo

## Base de Datos

### Esquema de Datos

#### Tabla: `gate_status`
Almacena el estado de las compuertas.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | SERIAL | PRIMARY KEY | Identificador único |
| gate_id | INT | NOT NULL | ID de la compuerta |
| position_percent | DECIMAL(5,2) | | Porcentaje apertura (0-100) |
| event_type | VARCHAR(20) | CHECK (OPEN/CLOSE/MOVING) | Tipo de evento |
| timestamp | TIMESTAMP | NOT NULL | Momento del registro |
| source_device | VARCHAR(50) | | Dispositivo origen |

#### Tabla: `water_level`
Registra niveles de agua y caudales calculados.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | SERIAL | PRIMARY KEY | Identificador único |
| location_id | INT | NOT NULL | ID de ubicación |
| level_m | DECIMAL(6,3) | NOT NULL | Nivel en metros |
| flow_m3s | DECIMAL(12,4) | | Caudal calculado |
| timestamp | TIMESTAMP | NOT NULL | Momento del registro |
| source_device | VARCHAR(50) | | Dispositivo origen |

#### Tabla: `flow_summary`
Resúmenes diarios de operación.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | SERIAL | PRIMARY KEY | Identificador único |
| location_id | INT | | ID de ubicación |
| date | DATE | NOT NULL | Fecha del resumen |
| total_m3 | DECIMAL(14,3) | NOT NULL | Volumen total diario |
| peak_flow_m3s | DECIMAL(12,4) | | Pico de caudal |
| gate_open_hours | DECIMAL(8,2) | | Horas compuerta abierta |

#### Tabla: `pumping_stations`
Configuración de estaciones de bombeo.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | SERIAL | PRIMARY KEY | Identificador único |
| name | VARCHAR(100) | NOT NULL | Nombre estación |
| location | VARCHAR(255) | | Ubicación geográfica |
| gate_diameter | DECIMAL(4,2) | DEFAULT 2.0 | Diámetro compuerta |
| gate_length | DECIMAL(4,1) | DEFAULT 5.0 | Longitud compuerta |
| weir_type | VARCHAR(50) | | Tipo de vertedero |
| weir_width | DECIMAL(6,3) | | Ancho del vertedero |
| cd_coefficient | DECIMAL(5,3) | DEFAULT 0.62 | Coeficiente descarga |

### Índices Recomendados
```sql
-- Mejorar rendimiento consultas frecuentes
CREATE INDEX idx_gate_status_gate_timestamp ON gate_status(gate_id, timestamp DESC);
CREATE INDEX idx_water_level_location_timestamp ON water_level(location_id, timestamp DESC);
CREATE INDEX idx_flow_summary_location_date ON flow_summary(location_id, date);
```

### Backup y Mantenimiento
```sql
-- Backup diario
pg_dump monitoring_db > backup_$(date +%Y%m%d).sql

-- Limpieza datos antiguos (>6 meses)
DELETE FROM gate_status WHERE timestamp < NOW() - INTERVAL '6 months';
DELETE FROM water_level WHERE timestamp < NOW() - INTERVAL '6 months';
```

## API REST

### Endpoints Disponibles

#### POST `/api/data`
Recibe datos de sensores externos.

**Ejemplo de payload:**
```json
{
    "gate_id": 1,
    "timestamp": "2024-12-20T15:30:00Z",
    "position_percent": 75.5,
    "level_m": 1.234,
    "source_device": "sensor_001"
}
```

**Respuesta exitosa:**
```json
{
    "message": "Data received successfully"
}
```

#### GET `/api/dashboard?station_id=1&hours=24`
Obtiene datos para el dashboard.

**Parámetros:**
- `station_id`: ID de la estación (default: 1)
- `hours`: Horas de histórico (default: 24)

**Respuesta:**
```json
{
    "current_status": {
        "position_percent": 75.0,
        "level_m": 1.234,
        "flow_m3s": 0.8756,
        "status": "PARCIAL",
        "last_update": "2024-12-20T15:30:00"
    },
    "historical_data": [...],
    "daily_summary": {
        "date": "2024-12-20",
        "total_m3": 12453.7,
        "peak_flow_m3s": 1.2345,
        "gate_open_hours": 18.5
    }
}
```

#### GET `/api/stations`
Lista todas las estaciones configuradas.

#### POST `/api/init-db`
Inicializa base de datos con datos de ejemplo.

### Códigos de Error
- **400:** Bad Request - Datos malformados
- **404:** Not Found - Recurso no encontrado
- **500:** Internal Server Error - Error del servidor

## Frontend

### Arquitectura JavaScript

#### Clase Principal: `MonitoringDashboard`
```javascript
class MonitoringDashboard {
    constructor() {
        this.stationId = 1;
        this.flowChart = null;
        this.levelChart = null;
        this.init();
    }
    
    // Métodos principales
    init()                    // Inicializar dashboard
    initCharts()             // Configurar gráficos
    bindEvents()             // Vincular eventos
    loadData()               // Cargar datos del API
    updateDashboard(data)    // Actualizar tarjetas
    updateCharts(data)       // Actualizar gráficos
}
```

#### Configuración de Gráficos (Chart.js)
```javascript
// Configuración base para gráficos
const chartConfig = {
    type: 'line',
    data: {
        labels: [],
        datasets: [{
            label: 'Valor',
            data: [],
            borderColor: 'rgb(75, 192, 192)',
            tension: 0.1
        }]
    },
    options: {
        responsive: true,
        plugins: {
            title: {
                display: true,
                text: 'Título del Gráfico'
            }
        }
    }
}
```

### CSS Avanzado

#### Sistema de Grid
```css
.dashboard {
    display: grid;
    gap: 30px;
}

.status-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
}

.charts {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}
```

#### Diseño Responsivo
```css
@media (max-width: 768px) {
    .charts {
        grid-template-columns: 1fr;
    }
    
    .status-cards {
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    }
}
```

## Configuración Avanzada

### Variables de Entorno
```bash
# Crear archivo .env
DATABASE_URL=postgresql://usuario:password@localhost:5432/monitoring_db
SECRET_KEY=clave-secreta-muy-segura
FLASK_ENV=production
FLASK_DEBUG=False
CORS_ORIGINS=http://localhost:3000,https://midominio.com
```

### Configuración de Producción
```python
# config_production.py
import os
from datetime import timedelta

class ProductionConfig:
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    SECRET_KEY = os.environ.get('SECRET_KEY')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    PERMANENT_SESSION_LIFETIME = timedelta(hours=24)
    
    # Configuración CORS
    CORS_ORIGINS = os.environ.get('CORS_ORIGINS', '').split(',')
    
    # Configuración de logging
    LOG_LEVEL = 'INFO'
    LOG_FILE = 'logs/application.log'
```

### Configuración del Servidor Web

#### nginx (Recomendado para Producción)
```nginx
server {
    listen 80;
    server_name tu-dominio.com;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /static/ {
        alias /path/to/static/;
        expires 1y;
    }
}
```

#### Gunicorn (WSGI Server)
```bash
# Instalar gunicorn
pip install gunicorn

# Ejecutar en producción
gunicorn --workers 4 --bind 0.0.0.0:5000 app:app
```

## Mantenimiento

### Monitoreo del Sistema

#### Logs de Aplicación
```python
import logging

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/app.log'),
        logging.StreamHandler()
    ]
)
```

#### Métricas de Rendimiento
```sql
-- Consultas de monitoreo
SELECT COUNT(*) as total_registros FROM water_level;
SELECT MAX(timestamp) as ultimo_registro FROM gate_status;

-- Verificar integridad de datos
SELECT location_id, COUNT(*) as registros_por_dia 
FROM water_level 
WHERE DATE(timestamp) = CURRENT_DATE 
GROUP BY location_id;
```

### Tareas de Mantenimiento

#### Script de Backup Automático
```powershell
# backup_daily.ps1
$fecha = Get-Date -Format "yyyyMMdd"
$backupFile = "backup_$fecha.sql"

pg_dump -h localhost -U usuario monitoring_db > $backupFile

# Comprimir backup
Compress-Archive -Path $backupFile -DestinationPath "$backupFile.zip"
Remove-Item $backupFile
```

#### Limpieza de Datos Antiguos
```sql
-- Ejecutar mensualmente
DELETE FROM gate_status 
WHERE timestamp < NOW() - INTERVAL '6 months';

DELETE FROM water_level 
WHERE timestamp < NOW() - INTERVAL '6 months';

-- Actualizar estadísticas
ANALYZE gate_status;
ANALYZE water_level;
VACUUM gate_status;
VACUUM water_level;
```

### Actualización del Sistema

#### Procedimiento de Actualización
1. **Backup completo** de base de datos
2. **Detener aplicación**
3. **Actualizar código fuente**
4. **Ejecutar migraciones** (si aplica)
5. **Reiniciar aplicación**
6. **Verificar funcionamiento**

## Solución de Problemas Técnicos

### Problemas Comunes

#### Error de Conexión a Base de Datos
```python
# Verificar conexión
from sqlalchemy import create_engine
engine = create_engine('postgresql://usuario:password@localhost:5432/monitoring_db')
try:
    conn = engine.connect()
    print("Conexión exitosa")
except Exception as e:
    print(f"Error de conexión: {e}")
```

#### Memoria Alta en PostgreSQL
```sql
-- Verificar consultas lentas
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- Optimizar configuración
-- En postgresql.conf:
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
```

#### Frontend No Se Actualiza
1. Verificar JavaScript console (F12)
2. Confirmar endpoint API funciona
3. Revisar CORS headers
4. Verificar conectividad red

### Herramientas de Debug

#### Debug Flask
```python
# Habilitar debug mode
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```

#### Debug JavaScript
```javascript
// Agregar logs detallados
console.log('Datos cargados:', data);
console.error('Error al cargar datos:', error);

// Verificar estado de conexión
fetch('/api/dashboard')
    .then(response => {
        console.log('Status:', response.status);
        return response.json();
    })
    .catch(error => console.error('Error:', error));
```

## Desarrollo y Extensiones

### Agregar Nuevos Sensores

#### 1. Extender Base de Datos
```sql
ALTER TABLE water_level ADD COLUMN temperature_c DECIMAL(4,1);
ALTER TABLE water_level ADD COLUMN ph_level DECIMAL(3,1);
```

#### 2. Actualizar Modelos
```python
class WaterLevel(db.Model):
    # ... campos existentes ...
    temperature_c = db.Column(db.Numeric(4,1))
    ph_level = db.Column(db.Numeric(3,1))
```

#### 3. Modificar API
```python
@app.route('/api/data', methods=['POST'])
def receive_data():
    # ... validaciones existentes ...
    water_level = WaterLevel(
        # ... campos existentes ...
        temperature_c=data.get('temperature_c'),
        ph_level=data.get('ph_level')
    )
```

### Integración MQTT

```python
# mqtt_client.py
import paho.mqtt.client as mqtt
import json
import requests

def on_message(client, userdata, message):
    try:
        data = json.loads(message.payload.decode())
        # Enviar a API REST
        requests.post('http://localhost:5000/api/data', json=data)
    except Exception as e:
        print(f"Error procesando mensaje MQTT: {e}")

client = mqtt.Client()
client.on_message = on_message
client.connect("broker.mqtt.com", 1883, 60)
client.subscribe("estacion/+/data")
client.loop_forever()
```

### Alertas por Email

```python
# alerts.py
import smtplib
from email.mime.text import MIMEText

def enviar_alerta(nivel_agua, umbral=2.5):
    if nivel_agua > umbral:
        msg = MIMEText(f"ALERTA: Nivel de agua alto: {nivel_agua}m")
        msg['Subject'] = 'Alerta Estación de Bombeo'
        msg['From'] = 'sistema@empresa.com'
        msg['To'] = 'operadores@empresa.com'
        
        smtp = smtplib.SMTP('smtp.empresa.com')
        smtp.send_message(msg)
        smtp.quit()
```

### API Extensions

#### Endpoint de Alertas
```python
@app.route('/api/alerts', methods=['GET'])
def get_alerts():
    # Buscar condiciones de alerta
    high_water = WaterLevel.query.filter(
        WaterLevel.level_m > 2.5,
        WaterLevel.timestamp >= datetime.utcnow() - timedelta(hours=1)
    ).all()
    
    return jsonify({
        'alerts': [{
            'type': 'HIGH_WATER',
            'level': float(record.level_m),
            'timestamp': record.timestamp.isoformat(),
            'location_id': record.location_id
        } for record in high_water]
    })
```

---

## Contacto Técnico

Para consultas técnicas avanzadas:
- **Documentación adicional:** Consultar código fuente
- **Issues:** Reportar en sistema de tickets
- **Desarrollo:** Contactar equipo de desarrollo
