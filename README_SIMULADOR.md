# 🔬 Simulador de Datos Virtuales

## Descripción

El simulador de datos virtuales es un componente avanzado del sistema de monitoreo que genera datos realistas para estaciones de bombeo. Proporciona una fuente confiable de datos de prueba que simula condiciones reales de operación.

## 🚀 Características Principales

### 🏭 Estaciones Simuladas
- **4 estaciones diferentes** con características únicas
- **Estación Principal Norte** - Sector Norte (Φ 2.0m)
- **Estación Principal Sur** - Sector Sur (Φ 2.0m)  
- **Estación Auxiliar Este** - Sector Este (Φ 1.5m)
- **Estación de Emergencia** - Sector Central (Φ 1.0m)

### 📊 Sensores Virtuales (10 tipos)
1. **Temperatura** - Rangos realistas 15-30°C
2. **pH** - Control de calidad del agua 6.5-8.5
3. **Turbidez** - Medición de claridad 0-10 NTU
4. **Presión** - Monitoreo del sistema 20-80 PSI
5. **Conductividad** - Análisis químico 200-800 μS/cm
6. **Oxígeno Disuelto** - Calidad ambiental 4-12 mg/L
7. **Velocidad de Flujo** - Medición hidrodinámica 0-5 m/s
8. **Vibración de Compuerta** - Estado mecánico 0-0.1 mm
9. **Corriente del Motor** - Monitoreo eléctrico 0-50 A
10. **Consumo de Energía** - Eficiencia operacional 0-2000 W

### 🔄 Patrones Realistas
- **Variaciones diarias** - Patrones de demanda por horarios
- **Influencia climática** - Simulación de efectos meteorológicos
- **Cálculos hidráulicos** - Ecuaciones de vertedero precisas
- **Estados de compuerta** - Lógica operacional realista
- **Alertas inteligentes** - Detección automática de anomalías

## 🛠️ Instalación y Uso

### Requisitos Previos
```bash
pip install flask requests numpy scipy
```

### Inicio Rápido

#### Opción 1: Solo Simulador
```powershell
.\iniciar_simulador.ps1
```

#### Opción 2: Sistema Completo
```powershell
.\iniciar_sistema_con_simulador.ps1
```

#### Opción 3: Manual
```python
python data_simulator.py
```

### Configuración de Puertos
- **Puerto por defecto:** 5001
- **Puerto personalizado:** `python data_simulator.py --port 5002`

## 🌐 API Endpoints

### Estado del Simulador
```
GET http://localhost:5001/api/simulator/status
```
**Respuesta:**
```json
{
  "running": true,
  "stations": [1, 2, 3, 4],
  "sensors_count": 10,
  "last_update": "2024-01-15T10:30:45.123456"
}
```

### Dashboard de Estación
```
GET http://localhost:5001/api/simulator/dashboard?station_id=1&hours=24
```
**Respuesta:**
```json
{
  "current_status": {
    "position_percent": 67.3,
    "level_m": 2.145,
    "flow_m3s": 3.4521,
    "status": "ABIERTA",
    "last_update": "2024-01-15T10:30:45.123456"
  },
  "historical_data": [...],
  "daily_summary": {
    "date": "2024-01-15",
    "total_m3": 8245.6,
    "peak_flow_m3s": 5.234,
    "gate_open_hours": 14.5
  },
  "virtual_sensors": {...},
  "station_info": {
    "name": "Estación Principal Norte",
    "location": "Sector Norte",
    "gate_diameter": 2.0,
    "weir_type": "rectangular",
    "weir_width": 2.0,
    "cd_coefficient": 0.62
  }
}
```

### Sensores por Estación
```
GET http://localhost:5001/api/simulator/sensors?station_id=1
```
**Respuesta:**
```json
{
  "temperature": {
    "name": "Temperature",
    "value": 22.34,
    "unit": "°C",
    "status": "normal",
    "percentage": 45.6,
    "timestamp": "2024-01-15T10:30:45.123456"
  },
  "ph": {
    "name": "Ph",
    "value": 7.12,
    "unit": "pH", 
    "status": "normal",
    "percentage": 31.0,
    "timestamp": "2024-01-15T10:30:45.123456"
  }
  // ... más sensores
}
```

### Control del Simulador
```
POST http://localhost:5001/api/simulator/start
POST http://localhost:5001/api/simulator/stop
```

## 🔧 Integración con Dashboard

### Configuración Automática
El dashboard principal detecta automáticamente la disponibilidad del simulador:

```javascript
// El dashboard intenta usar el simulador por defecto
this.simulatorUrl = 'http://localhost:5001';
this.useSimulator = true;
```

### Fallback Inteligente
Si el simulador no está disponible, el dashboard automáticamente:
1. Intenta conectar al simulador
2. Si falla, usa la API principal
3. Muestra el estado de la fuente de datos
4. Permite cambio manual entre fuentes

### Indicadores Visuales
- **Estado de conexión** - Muestra fuente de datos activa
- **Icono de simulador** - Indica cuando usa datos simulados
- **Alertas de estado** - Notifica cambios de fuente

## 📈 Algoritmos de Simulación

### Cálculo de Caudal
Utiliza la ecuación de vertedero rectangular:
```
Q = Cd × b × √(2g) × h^(3/2)
```
Donde:
- Q = Caudal (m³/s)
- Cd = Coeficiente de descarga
- b = Ancho del vertedero (m)
- g = Aceleración gravitacional (9.81 m/s²)
- h = Altura del agua sobre el vertedero (m)

### Patrones Diarios
```python
def simulate_daily_pattern(base_value, amplitude, hour):
    daily_factor = 1 + amplitude * sin((hour - 6) * π / 12)
    noise = random.uniform(-0.1, 0.1)
    return base_value * daily_factor * (1 + noise)
```

### Estados de Compuerta
```python
if flow < 0.1:
    gate_position = random.uniform(0, 15)    # Cerrada
    gate_status = 'CERRADA'
elif flow < 0.5:
    gate_position = random.uniform(15, 45)   # Parcial
    gate_status = 'PARCIAL'
else:
    gate_position = random.uniform(45, 90)   # Abierta
    gate_status = 'ABIERTA'
```

## 🔍 Monitoreo y Debug

### Logs del Simulador
```
Simulador de datos iniciado
Acceso: http://localhost:5001
Dashboard simulado: http://localhost:5001/api/simulator/dashboard
```

### Verificación de Estado
```bash
curl http://localhost:5001/api/simulator/status
```

### Datos en Tiempo Real
El simulador actualiza datos cada **5 segundos** automáticamente.

## ⚡ Rendimiento

### Especificaciones
- **Estaciones simultáneas:** 4
- **Sensores por estación:** 10
- **Frecuencia de actualización:** 5 segundos
- **Historial mantenido:** 1000 registros por estación
- **Memoria promedio:** < 100 MB
- **CPU promedio:** < 5%

### Optimizaciones
- Cálculos matemáticos optimizados con NumPy
- Caché de datos históricos
- Limpieza automática de memoria
- Threading para no bloquear requests

## 🚨 Alertas y Monitoreo

### Condiciones de Alerta
```python
# Nivel alto de agua
if level_m > 4.0:
    alert_type = 'warning'
    
# Caudal elevado  
if flow_m3s > 10.0:
    alert_type = 'warning'
    
# Sensores fuera de rango
if percentage < 10 or percentage > 90:
    alert_type = 'alert'
```

### Estados de Sensores
- **Normal** - Operación estándar
- **Warning** - Valores en límites
- **Alert** - Valores críticos
- **Error** - Fallo de comunicación

## 🔒 Seguridad

### Configuración de Red
- Puerto configurable
- CORS habilitado para desarrollo
- Rate limiting implementado
- Logs de acceso detallados

### Validación de Datos
- Rangos de sensores validados
- Tipos de datos verificados
- Sanitización de parámetros
- Manejo de errores robusto

## 📚 Documentación Adicional

### Archivos Relacionados
- `data_simulator.py` - Código principal del simulador
- `script.js` - Integración con dashboard
- `iniciar_simulador.ps1` - Script de inicio
- `iniciar_sistema_con_simulador.ps1` - Script maestro

### Configuración Avanzada
Para personalizar el simulador, edita las constantes en `data_simulator.py`:

```python
# Estaciones disponibles
self.stations = {
    1: {
        'name': 'Tu Estación Personalizada',
        'location': 'Tu Ubicación',
        'gate_diameter': 2.5,  # Personalizar
        'weir_width': 2.5,     # Personalizar
        'cd_coefficient': 0.65  # Personalizar
    }
}

# Sensores disponibles
self.virtual_sensors = {
    'tu_sensor': {
        'value': 100, 
        'min': 0, 
        'max': 200, 
        'unit': 'unidad'
    }
}
```

## 🤝 Soporte

Para problemas o preguntas sobre el simulador:
1. Verificar logs en consola
2. Revisar estado con `/api/simulator/status`  
3. Reiniciar usando `iniciar_simulador.ps1`
4. Verificar puertos disponibles
5. Consultar documentación técnica

---

💡 **Tip:** El simulador está diseñado para proporcionar datos de prueba realistas. Para producción, reemplaza las llamadas del simulador con tu API real de sensores.
