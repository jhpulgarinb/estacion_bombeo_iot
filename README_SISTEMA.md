# 🚀 Sistema de Monitoreo Estación de Bombeo

## Descripción General

Sistema completo de monitoreo para una estación de bombeo con simulación de sensores ESP32. Incluye:

- **Dashboard de Bombeo**: Monitoreo de compuertas, niveles de agua y caudales
- **Dashboard Meteorológico**: Temperatura, humedad, viento, presión y radiación solar
- **Simulador ESP32**: Genera datos realistas de sensores automáticamente
- **API REST**: Endpoints para recibir y consultar datos
- **Base de Datos MySQL**: Almacenamiento persistente de datos

## Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                      NAVEGADOR (Cliente)                         │
│  http://localhost:9000 → Interfaz Web Interactiva               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              SERVIDOR FLASK (app.py)                             │
│  Puerto 9000                                                      │
│  - Sirve HTML/CSS/JS de dashboards                              │
│  - API REST endpoints                                            │
│  - Manejo de CORS                                                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              SIMULADOR ESP32 (simulador_esp32.py)                │
│  Genera datos realistas cada 10 segundos:                        │
│  - Meteorología: Temp, Humedad, Viento, Presión, etc.          │
│  - Bombeo: Posición compuerta, Nivel agua, Caudal               │
│  - Envía POST a http://localhost:9000/api/meteorology           │
│  - Envía POST a http://localhost:9000/api/data                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│            BASE DE DATOS MYSQL (localhost:3306)                  │
│  Base: promotorapalmera_db                                       │
│  Tablas:                                                          │
│    - iot_estado_compuerta (datos de compuertas)                 │
│    - iot_nivel_agua (niveles y caudales)                        │
│    - meteorologia_data (datos meteorológicos)                    │
│    - y más...                                                     │
└─────────────────────────────────────────────────────────────────┘
```

## Instalación y Configuración

### 1. Requisitos Previos

- Python 3.10+
- MySQL Server corriendo en localhost:3306
- Credenciales MySQL: root / (sin contraseña)

### 2. Dependencias Python

```bash
pip install flask flask-cors flask-sqlalchemy sqlalchemy pymysql requests
```

### 3. Estructura de Archivos

```
project_estacion_bombeo/
├── app.py                      # Servidor Flask principal
├── simulador_esp32.py          # Simulador de sensores
├── database.py                 # Modelos de BD
├── config.py                   # Configuración
├── index.html                  # Dashboard de Bombeo
├── meteorologia.html           # Dashboard Meteorológico
├── inicio.html                 # Página de inicio
├── script.js                   # JavaScript del Dashboard de Bombeo
├── styles.css                  # Estilos
└── INICIAR_TODO.ps1           # Script para iniciar sistema
```

## Uso del Sistema

### Opción 1: Iniciar Todo de Una Vez (Recomendado)

```powershell
cd c:\inetpub\promotorapalmera\project_estacion_bombeo
powershell -ExecutionPolicy Bypass -File INICIAR_TODO.ps1
```

### Opción 2: Iniciar Manualmente

**Terminal 1 - Flask:**
```bash
cd c:\inetpub\promotorapalmera\project_estacion_bombeo
python app.py
```

**Terminal 2 - Simulador:**
```bash
cd c:\inetpub\promotorapalmera\project_estacion_bombeo
python simulador_esp32.py
```

### Accediendo a los Dashboards

Espere 3-5 segundos después de iniciar para que Flask se levante completamente.

**Página Principal (Estado del Sistema):**
```
http://localhost:9000
```

**Dashboard de Bombeo:**
```
http://localhost:9000/index.html
```

**Dashboard Meteorológico:**
```
http://localhost:9000/meteorologia.html
```

## Descripción de Dashboards

### Dashboard de Bombeo
- **Indicadores Principales:**
  - Estado de compuerta (% apertura)
  - Nivel de agua (metros)
  - Caudal actual (m³/s)
  - Volumen diario (m³)
  
- **Gráficos (últimas 24h):**
  - Caudal vs tiempo
  - Nivel de agua vs tiempo
  - Posición de compuerta vs tiempo

- **Características:**
  - Auto-actualización cada 30 segundos
  - Selector de estación
  - Control de rango temporal
  - Alertas de errores

### Dashboard Meteorológico
- **Indicadores Principales:**
  - Temperatura (°C)
  - Humedad relativa (%)
  - Velocidad del viento (m/s)
  - Presión atmosférica (hPa)
  - Radiación solar (W/m²)
  - Precipitación acumulada (mm)

- **Gráficos (últimas 24h):**
  - Temperatura vs tiempo
  - Humedad vs tiempo
  - Velocidad del viento vs tiempo
  - Radiación solar vs tiempo

- **Características:**
  - Datos actualizados cada 10 segundos
  - Cálculos en tiempo real
  - Visualización de tendencias

## Simulador ESP32

El simulador genera datos realistas que simulan sensores físicos reales:

### Datos Meteorológicos Simulados

```
Temperatura:           15°C - 40°C (variación ±0.5°C por ciclo)
Humedad:               30% - 95% (variación ±2% por ciclo)
Velocidad del Viento:  0 - 30 m/s (con rachas aleatorias)
Presión:               ±5 hPa alrededor de 1013 hPa
Radiación Solar:       0 - 1000 W/m² (varía con hora del día)
Precipitación:         0 - 5 mm (10% probabilidad por ciclo)
Dirección del Viento:  0° - 360° (aleatorio)
```

### Datos de Bombeo Simulados

```
Posición Compuerta:    0% - 100% (cambios aleatorios)
Nivel de Agua:         0.5 - 5.0 metros
Caudal:                0 - 5 m³/s (proporcional a apertura)
```

### Intervalo de Simulación

- Cada 10 segundos se envían nuevos datos
- Los datos varían de forma realista (cambios graduales)
- Incluye correlaciones: caudal afectado por apertura de compuerta

## API REST Endpoints

### Recibir Datos de Bombeo
```
POST /api/data
Body: {
  "estacion_id": 1,
  "numero_compuerta": 1,
  "apertura_porcentaje": 50.0,
  "nivel_m": 2.5,
  "caudal_m3s": 2.5,
  "fecha_hora": "2026-02-22T15:30:00",
  "dispositivo_origen": "ESP32_SIMULADO"
}
```

### Recibir Datos Meteorológicos
```
POST /api/meteorology
Body: {
  "estacion_id": 1,
  "temperatura_c": 25.5,
  "humedad_porcentaje": 65.0,
  "precipitacion_mm": 0.0,
  "presion_hpa": 1013.2,
  "velocidad_viento_ms": 5.0,
  "direccion_viento_grados": 180,
  "radiacion_solar_wm2": 800.0,
  "fecha_hora": "2026-02-22T15:30:00",
  "dispositivo_origen": "ESP32_SIMULADO"
}
```

### Consultar Datos de Dashboard
```
GET /api/dashboard?station_id=1&hours=24

Respuesta:
{
  "current_status": {
    "position_percent": 50.0,
    "level_m": 2.5,
    "flow_m3s": 2.5,
    "status": "OPEN",
    "last_update": "2026-02-22T15:30:00"
  },
  "historical_data": [...],
  "daily_summary": {
    "date": "2026-02-22",
    "total_m3": 180.5,
    "peak_flow_m3s": 5.0,
    "gate_open_hours": 8.5
  }
}
```

### Consultar Datos Meteorológicos Recientes
```
GET /api/meteorology/latest?station_id=1

Respuesta:
{
  "data": {
    "temperatura_c": 25.5,
    "humedad_porcentaje": 65.0,
    "precipitacion_mm": 0.0,
    "presion_hpa": 1013.2,
    "velocidad_viento_ms": 5.0,
    "direccion_viento_grados": 180,
    "radiacion_solar_wm2": 800.0,
    "fecha_hora": "2026-02-22T15:30:00"
  }
}
```

## Configuración MySQL

### Conexión Configurada
```
Host: localhost
Puerto: 3306
Usuario: root
Contraseña: (vacía)
Base de Datos: promotorapalmera_db
Charset: utf8mb4
```

### Crear Base de Datos (si no existe)
```sql
CREATE DATABASE promotorapalmera_db CHARACTER SET utf8mb4;
```

Las tablas se crean automáticamente cuando inicia Flask.

## Troubleshooting

### El simulador no envía datos
```
Verificar:
- Flask está corriendo en puerto 9000
- MySQL está disponible
- No hay errores de conexión en consola
- Revisar: http://localhost:9000/api/meteorology/latest
```

### Dashboard vacío / sin datos
```
Verificar:
- El simulador está enviando datos (ver consola)
- La BD tiene datos (revisar con MySQL Workbench)
- CORS está habilitado en Flask ✓
- No hay errores en consola del navegador (F12)
```

### Puerto 9000 en uso
```
Solución:
taskkill /F /IM python.exe
# O cambiar puerto en app.py línea final
app.run(host='0.0.0.0', port=8888, ...)
```

### Error de conexión a Base de Datos
```
Verificar:
- MySQL server está corriendo
- Credenciales en config.py son correctas
- Base de datos existe: promotorapalmera_db
- Usuario 'root' tiene permisos
```

## Características Futuras

- [ ] Autenticación de usuarios
- [ ] Alertas por email/SMS
- [ ] Exportación de datos a Excel
- [ ] Mantenimiento predictivo
- [ ] Machine Learning para predicciones
- [ ] Integración SCADA real
- [ ] Análisis de consumo energético

## Especificaciones Técnicas

| Componente | Especificación |
|-----------|----------------|
| Servidor Web | Flask 2.3.3 |
| Base de Datos | MySQL 8.0+ |
| Frontend | HTML5, CSS3, JavaScript |
| Gráficos | Chart.js |
| Protocolo API | REST JSON |
| Puerto Acceso | 9000 (HTTP) |
| Intervalo Simulación | 10 segundos |

## Autor

Sistema de Automatización
Promotora Palmera de Antioquia S.A.S.
Febrero 2026

---

Para más información o soporte, contacte al equipo de desarrollo.

