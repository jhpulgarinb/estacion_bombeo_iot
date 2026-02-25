# 🚰 Sistema de Monitoreo de Estación de Bombeo

**🎯 Un sistema completo para el monitoreo y control de estaciones de bombeo con compuertas hidráulicas y sensores virtuales.**

## 🌟 Características Principales

- **🎛️ Dashboard en tiempo real**: Interfaz web moderna y responsiva con visualizaciones avanzadas
- **🔧 Sensores virtuales**: Simulación realista de compuertas y niveles de agua con patrones naturales
- **📊 Gestión de compuertas**: Monitoreo del estado, posición y movimiento de compuertas
- **🌊 Medición de flujo**: Cálculo automático de caudales basado en datos de sensores
- **🗃️ Base de datos completa**: SQLite con datos históricos y de prueba (>30 días)
- **🔌 API REST**: Endpoints completos para recepción y consulta de datos
- **⚡ Inicio automático**: Scripts para inicializar todo el sistema con un solo comando
- **🧮 Cálculos hidráulicos**: Fórmulas precisas para diferentes tipos de vertederos
- **⚠️ Sistema de alertas**: Notificaciones en tiempo real de estados críticos
- **📱 Interfaz responsive**: Compatible con móvil, tablet y desktop

## 🏗️ Arquitectura del Sistema

```
📦 project_estacion_bombeo/
├── 🐍 app.py                           # Aplicación Flask principal
├── 🗄️ database.py                      # Modelos de base de datos SQLAlchemy
├── 🧮 calculations.py                  # Cálculos hidráulicos avanzados
├── ⚙️ config.py                        # Configuración del sistema
├── 📋 requirements.txt                 # Dependencias Python
├── 🌐 index.html                       # Dashboard web mejorado
├── 🎨 styles.css                       # Estilos CSS responsivos
├── ⚡ script.js                        # JavaScript avanzado con tiempo real
├── 🔧 virtual_sensors.py               # Simulador de sensores virtuales
├── 🗃️ initialize_test_data.py          # Inicializador de datos de prueba
├── 🚀 iniciar_sistema_completo_nuevo.ps1 # Script de inicio automático
├── 💾 bd-estacion-bombeo.sql           # Schema de base de datos
├── 📚 docs/                            # Documentación adicional
├── 🧪 monitoring.db                    # Base de datos SQLite (generada)
└── 📁 venv/                            # Entorno virtual Python
```

## 🚀 Inicio Rápido (Un Solo Comando)

El sistema incluye un script de PowerShell que inicializa todo automáticamente:

### Windows (PowerShell)
```powershell
# Ejecutar desde el directorio del proyecto
.\iniciar_sistema_completo_nuevo.ps1
```

**🎉 ¡Eso es todo!** Este comando automáticamente:

1. ✅ Verifica y crea el entorno Python virtual
2. 📦 Instala todas las dependencias necesarias
3. 🗄️ Inicializa la base de datos con datos de prueba realistas
4. 🌐 Inicia la aplicación web en `http://localhost:5000`
5. 🔧 Activa los sensores virtuales con patrones realistas
6. 📊 Comienza a generar datos en tiempo real automáticamente

### Opciones Avanzadas del Script

```powershell
# Ver ayuda completa
.\iniciar_sistema_completo_nuevo.ps1 -h

# Ejemplos de uso:
.\iniciar_sistema_completo_nuevo.ps1                    # Inicio completo normal
.\iniciar_sistema_completo_nuevo.ps1 -Port 8080         # Puerto personalizado
.\iniciar_sistema_completo_nuevo.ps1 -ResetData         # Recrear datos desde cero
.\iniciar_sistema_completo_nuevo.ps1 -SkipSensors       # Sin sensores virtuales
.\iniciar_sistema_completo_nuevo.ps1 -SkipDatabase      # Omitir inicialización BD
```

## 🎮 Controles Durante la Ejecución

Una vez iniciado el sistema, el script ofrece controles interactivos:

- **[S]** - Mostrar estado completo del sistema
- **[L]** - Ver logs en tiempo real de sensores
- **[R]** - Reiniciar sensores virtuales
- **[O]** - Abrir dashboard en navegador
- **[Q]** - Detener y salir del sistema

## 🌐 Dashboard Web Avanzado

### 📊 Tarjetas de Estado Inteligentes

1. **🚪 Estado de Compuerta**
   - Posición actual con gauge animado
   - Estados: ABIERTA, CERRADA, MOVIMIENTO, PARCIAL
   - Colores dinámicos según el porcentaje
   - Timestamp de última actualización

2. **🌊 Nivel de Agua**
   - Medición precisa en metros (3 decimales)
   - Indicador visual tipo tanque
   - Rangos de color (Bajo/Normal/Alto)
   - Límites mínimos y máximos

3. **💧 Caudal Actual**
   - Calculado automáticamente (m³/s)
   - Indicador de tendencia (↑↓→)
   - Colores según flujo (Verde/Amarillo/Rojo)
   - Promedio y valores pico

4. **📈 Volumen Diario**
   - Acumulado del día actual
   - Barra de progreso hacia meta diaria
   - Meta configurable (default: 10,000 m³)
   - Proyección de cumplimiento

### 📈 Gráficos en Tiempo Real

- **Variación de Caudal**: Tendencias con estadísticas (promedio, pico)
- **Nivel de Agua**: Rangos históricos y valores actuales  
- **Estado de Compuertas**: Timeline de movimientos y posiciones
- **Controles de tiempo**: 1h, 6h, 24h, 1 semana
- **Zoom y pan interactivos** con tooltips informativos

### 🔧 Panel de Sensores Virtuales

Visualización en tiempo real de todos los sensores:

- **Compuertas**: Estado, posición, modo de operación
- **Niveles**: Valores actuales, rangos, tendencias
- **Estado de conexión**: Indicadores visuales de actividad
- **Control de simulación**: Activar/desactivar desde la interfaz

### ⚠️ Sistema de Alertas Inteligente

- **Alertas automáticas** para condiciones críticas
- **Tipos**: Error (🔴), Advertencia (🟡), Info (🔵), Éxito (🟢)
- **Condiciones monitoreadas**:
  - Nivel de agua > 4.0m
  - Caudal > 10.0 m³/s
  - Falta de datos recientes (>5 min)
  - Cambios bruscos de posición
- **Panel desplegable** con historial de alertas

## 🔧 Sensores Virtuales Incluidos

### 🚪 Compuertas (3 sensores)
| ID | Nombre | Ubicación | Características |
|----|--------|-----------|-----------------|
| 1 | Compuerta Principal A | Canal Principal - Entrada | Actualización cada 15s, ruido 3% |
| 2 | Compuerta Principal B | Canal Principal - Salida | Actualización cada 20s, ruido 3% |
| 3 | Compuerta Auxiliar 1 | Canal Auxiliar Norte | Actualización cada 30s, ruido 5% |

### 🌊 Niveles de Agua (3 sensores)
| ID | Nombre | Ubicación | Rango |
|----|--------|-----------|-------|
| 11 | Nivel Embalse Principal | Embalse - Zona Central | 0.2 - 4.5m |
| 12 | Nivel Canal Entrada | Canal de Entrada | 0.1 - 2.8m |
| 13 | Nivel Canal Salida | Canal de Salida | 0.05 - 3.2m |

### 🎯 Características de la Simulación

- **📈 Patrones realistas**:
  - Variaciones diarias (mayor actividad 8:00-17:00)
  - Simulación climática (lluvia, drenaje)
  - Respuesta dinámica entre sensores
  - Tendencias estacionales

- **🎲 Ruido natural**:
  - 2-5% de variación aleatoria
  - Distribución gaussiana
  - Factores ambientales simulados

- **🔄 Modos de operación**:
  - AUTO: Operación automática basada en niveles
  - MANUAL: Control manual simulado
  - EMERGENCY: Apertura completa automática

## 🏭 Estaciones Preconfiguradas

| ID | Nombre | Ubicación | Especificaciones |
|----|--------|-----------|------------------|
| 1 | Estación Principal Norte | Canal Norte - Km 12.5 | Compuerta Ø2.5m, Vertedero 3.2m |
| 2 | Estación Principal Sur | Canal Sur - Km 8.3 | Compuerta Ø2.0m, Vertedero 2.8m |
| 3 | Estación Auxiliar Este | Canal Auxiliar Este | Compuerta Ø1.8m, Vertedero triangular |
| 4 | Estación de Emergencia | Canal Desagüe Principal | Compuerta Ø3.0m, Vertedero 4.0m |

## 🗄️ Datos de Prueba Incluidos

### 📊 Volumen de Datos
- **Período histórico**: Últimos 30 días
- **Frecuencia de datos**: Cada 15-60 minutos (variable)
- **Puntos por estación**: ~2,000-8,000 registros
- **Total aproximado**: >20,000 puntos de datos
- **Resúmenes diarios**: 120 entradas estadísticas

### 🎯 Escenarios Especiales
- **Emergencia reciente**: Estación 4 abierta al 100% hace 2 horas
- **Mantenimiento**: Estación 2 cerrada hace 6 horas
- **Operación normal**: Variaciones realistas en estaciones 1-3
- **Datos históricos**: Patrones de 30 días con tendencias

## 🔌 API REST Completa

### 📤 Endpoint de Datos (POST /api/data)

```json
{
    "gate_id": 1,
    "timestamp": "2024-01-15T10:30:00Z",
    "position_percent": 75.5,
    "level_m": 2.345,
    "source_device": "virtual_gate_1",
    "operation_mode": "AUTO",
    "status": "MOVING"
}
```

### 📥 Endpoint de Dashboard (GET /api/dashboard)

**Parámetros**:
- `station_id`: ID de estación (1-4)
- `hours`: Horas de histórico (1, 6, 24, 168)

**Respuesta**:
```json
{
    "current_status": {
        "position_percent": 75.5,
        "level_m": 2.345,
        "flow_m3s": 4.123,
        "status": "MOVING",
        "last_update": "2024-01-15T10:30:00"
    },
    "historical_data": [
        {
            "timestamp": "2024-01-15T10:00:00",
            "level_m": 2.234,
            "flow_m3s": 3.891
        }
    ],
    "daily_summary": {
        "date": "2024-01-15",
        "total_m3": 15840.5,
        "peak_flow_m3s": 8.456,
        "gate_open_hours": 16.2
    }
}
```

## 🧮 Cálculos Hidráulicos Avanzados

### 📐 Fórmulas Implementadas

#### 🏞️ Vertedero Rectangular
```
Q = Cd × L × H^(3/2) × √(2g)
```

#### 🔺 Vertedero Triangular  
```
Q = Cd × (8/15) × √(2g) × tan(θ/2) × H^(5/2)
```

#### ⭕ Compuerta Circular
```
Q = Cd × A × √(2g × H)
```

#### 📊 Parámetros por Defecto
- **Cd (Coeficiente de descarga)**: 0.58 - 0.65
- **g (Gravedad)**: 9.81 m/s²
- **Anchos típicos**: 2.0m - 4.0m
- **Diámetros**: 1.5m - 3.0m

### 🎯 Precisión de Cálculos
- **Caudal**: 4 decimales (±0.0001 m³/s)
- **Nivel**: 3 decimales (±1 mm)
- **Posición**: 2 decimales (±0.01%)
- **Volumen**: 1 decimal (±0.1 m³)

## 🛠️ Instalación Manual (Opcional)

Si prefiere una instalación paso a paso:

### Prerrequisitos
- 🐍 Python 3.8+ 
- 📦 pip (gestor de paquetes)
- 💻 PowerShell 5.0+ (Windows)

### Pasos Detallados

1. **Preparar entorno**
```bash
# Navegar al directorio
cd project_estacion_bombeo

# Crear entorno virtual
python -m venv venv

# Activar entorno (Windows)
.\venv\Scripts\Activate.ps1

# Activar entorno (Linux/Mac)
source venv/bin/activate
```

2. **Instalar dependencias**
```bash
pip install -r requirements.txt
```

3. **Inicializar datos**
```bash
python initialize_test_data.py
```

4. **Iniciar aplicación**
```bash
python app.py
```

5. **Iniciar sensores (nueva terminal)**
```bash
python virtual_sensors.py
```

## 🔧 Configuración Avanzada

### ⚙️ Archivo config.py
```python
# Base de datos
SQLALCHEMY_DATABASE_URI = 'sqlite:///monitoring.db'
SQLALCHEMY_TRACK_MODIFICATIONS = False

# Aplicación
DEBUG = True
SECRET_KEY = 'sistema-bombeo-2024'
HOST = '0.0.0.0'
PORT = 5000
```

### 🔧 Configuración de Sensores
```python
# En virtual_sensors.py - Ejemplo de configuración
SensorConfig(
    sensor_id=1,
    sensor_type='gate',
    name='Compuerta Principal A',
    location='Canal Principal - Entrada',
    min_value=0,
    max_value=100,
    noise_factor=0.03,      # 3% de ruido
    update_interval=15      # Actualizar cada 15 segundos
)
```

## 🔍 Monitoreo y Diagnósticos

### 📊 Estado del Sistema
```powershell
# Durante la ejecución, presionar 'S' para ver:
# - Estado de base de datos (tamaño, registros)
# - Estado de aplicación web (puerto, conectividad)
# - Estado de sensores virtuales (activos, datos enviados)
# - URLs importantes y archivos de configuración
```

### 📝 Logs en Tiempo Real
```powershell
# Durante la ejecución, presionar 'L' para ver:
# - Logs de sensores virtuales (últimos 20)
# - Logs de aplicación web (últimos 10)
# - Errores de conectividad
# - Estadísticas de envío de datos
```

## 🚨 Resolución de Problemas

### ⚡ Problemas Comunes

#### "Puerto ya en uso"
```powershell
# Opción 1: Usar puerto diferente
.\iniciar_sistema_completo_nuevo.ps1 -Port 8080

# Opción 2: Terminar proceso existente
netstat -ano | findstr :5000
taskkill /PID <process_id> /F
```

#### "Módulo no encontrado"
```powershell
# Verificar entorno virtual
Get-Command python
where python

# Reinstalar dependencias
pip install -r requirements.txt --upgrade --force-reinstall
```

#### "Base de datos corrupta"
```powershell
# Recrear base de datos completa
.\iniciar_sistema_completo_nuevo.ps1 -ResetData
```

#### "Sensores no envían datos"
```powershell
# Verificar conectividad API
Invoke-WebRequest http://localhost:5000/api/dashboard?station_id=1

# Reiniciar solo sensores (durante ejecución)
# Presionar 'R' en la consola del script
```

### 🔍 Debugging Avanzado

```python
# Activar logs detallados en virtual_sensors.py
logging.basicConfig(level=logging.DEBUG)

# Verificar estado de base de datos
python -c "
from app import app
from database import *
with app.app_context():
    print(f'Estaciones: {PumpingStation.query.count()}')
    print(f'Registros compuertas: {GateStatus.query.count()}')
    print(f'Registros nivel: {WaterLevel.query.count()}')
"
```

## 🎯 Casos de Uso

### 🏭 Aplicaciones Industriales
- **Gestión de recursos hídricos** municipales
- **Control de sistemas de riego** automatizado  
- **Monitoreo de plantas de tratamiento** de agua
- **Supervisión de canales** de drenaje urbano
- **Control de compuertas** en presas y embalses

### 📚 Aplicaciones Educativas
- **Enseñanza de hidráulica** práctica
- **Simulación de sistemas reales** sin riesgos
- **Proyectos de ingeniería** civil/ambiental
- **Investigación hidrológica** aplicada
- **Validación de teorías** hidráulicas

### 🔬 Desarrollo y Testing
- **Prototipado de sistemas SCADA** industriales
- **Testing de algoritmos** de control automático
- **Desarrollo de interfaces HMI** personalizadas
- **Validación de sensores** antes de implementación
- **Simulación de escenarios** de emergencia

## 🚀 Extensiones y Personalización

### ➕ Agregar Nueva Estación

1. **Modificar initialize_test_data.py**:
```python
stations_config.append({
    'name': 'Estación Personalizada',
    'location': 'Canal Norte - Km 15.2',
    'gate_diameter': 2.2,
    'gate_length': 5.5,
    'weir_type': 'rectangular',
    'weir_width': 3.0,
    'cd_coefficient': 0.62
})
```

2. **Actualizar selector en index.html**:
```html
<option value="5">Estación Personalizada</option>
```

### 🔧 Agregar Nuevo Tipo de Sensor

```python
# En virtual_sensors.py
class FlowSensor(VirtualSensor):
    """Sensor de flujo directo"""
    
    def update_value(self):
        # Lógica específica para flujo
        flow_variation = math.sin(time.time() / 1800) * 0.5
        self.current_value += flow_variation
        self.current_value = self.add_noise(self.current_value)

# Configuración
SensorConfig(
    sensor_id=20,
    sensor_type='flow',
    name='Sensor Flujo Directo',
    location='Canal Secundario',
    min_value=0,
    max_value=50,
    update_interval=10
)
```

### 🎨 Personalizar Dashboard

1. **Estilos CSS** (styles.css):
```css
/* Tema personalizado */
:root {
    --primary-color: #your-color;
    --secondary-color: #your-secondary;
}
```

2. **Funcionalidad JavaScript** (script.js):
```javascript
// Extender clase principal
class CustomDashboard extends AdvancedMonitoringDashboard {
    constructor() {
        super();
        this.customFeature = true;
    }
    
    customMethod() {
        // Funcionalidad personalizada
    }
}
```

## 📈 Roadmap y Mejoras Futuras

### 🔜 Próximas Versiones (v2.0)
- 🌐 **Interfaz multiidioma** (Español, Inglés, Portugués)
- 📱 **App móvil nativa** (React Native)
- ☁️ **Integración cloud** (AWS, Azure, GCP)
- 🤖 **Machine Learning** para predicciones
- 📧 **Notificaciones push** (email, SMS, WhatsApp)
- 🔐 **Sistema de usuarios** y permisos
- 📊 **Reportes PDF** automatizados
- 🔄 **API GraphQL** avanzada

### 🎯 Funcionalidades Planeadas
- **Gemelos digitales** de infraestructura
- **Realidad aumentada** para mantenimiento
- **Blockchain** para trazabilidad de datos
- **Edge computing** para procesamiento local
- **5G/IoT** para sensores reales
- **Digital twin** de cuencas hidrográficas

## 🤝 Contribuir al Proyecto

¡Las contribuciones son muy bienvenidas! 

### 📋 Cómo Contribuir
1. 🍴 **Fork** del repositorio
2. 🌿 **Crear rama** para feature (`git checkout -b feature/nueva-funcionalidad`)
3. 💾 **Commit** cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. 📤 **Push** a la rama (`git push origin feature/nueva-funcionalidad`)
5. 🔄 **Crear Pull Request** con descripción detallada

### 🐛 Reportar Issues
- **Bugs**: Usar template de bug report
- **Features**: Usar template de feature request
- **Documentación**: Mejoras o correcciones
- **Performance**: Optimizaciones sugeridas

### 💡 Ideas de Contribución
- 🌍 Traducciones a otros idiomas
- 🎨 Mejoras de UI/UX
- 📊 Nuevos tipos de gráficos
- 🔧 Nuevos tipos de sensores
- 📚 Documentación técnica
- 🧪 Tests automatizados
- 🚀 Optimizaciones de rendimiento

## 📄 Licencia

Este proyecto está bajo la **Licencia MIT**. Ver archivo `LICENSE` para detalles completos.

```
MIT License - Libre para uso comercial y personal
- ✅ Uso comercial permitido
- ✅ Modificación permitida  
- ✅ Distribución permitida
- ✅ Uso privado permitido
- ❌ Sin garantía
- ❌ Sin responsabilidad del autor
```

## 📞 Soporte y Contacto

### 🆘 Obtener Ayuda
- 🐛 **Issues GitHub**: Para bugs y problemas técnicos
- 💬 **Discussions**: Para preguntas generales y ideas
- 📧 **Email**: soporte.estacion.bombeo@example.com
- 📚 **Documentación**: Carpeta `docs/` con manuales completos

### 🔗 Enlaces Útiles
- 📊 **Demo Online**: [Ver demo en vivo]
- 📹 **Videos Tutoriales**: [Canal de YouTube]
- 📘 **Documentación API**: [Swagger/OpenAPI]
- 👥 **Comunidad**: [Discord/Slack Channel]

### 👨‍💻 Equipo de Desarrollo
- **Arquitectura**: Sistemas hidráulicos y backend
- **Frontend**: Dashboard y experiencia de usuario  
- **DevOps**: Automatización e infraestructura
- **QA**: Testing y garantía de calidad

---

## 🎉 ¡Listo para Empezar!

**El sistema está completamente listo para usar. Simplemente ejecute:**

```powershell
.\iniciar_sistema_completo_nuevo.ps1
```

**En menos de 2 minutos tendrá:**
- ✅ Sistema completo funcionando
- ✅ Base de datos con datos reales
- ✅ 6 sensores virtuales activos
- ✅ Dashboard web en tiempo real
- ✅ API REST completamente funcional

**🌐 Acceda al dashboard en: http://localhost:5000**

---

*Última actualización: Diciembre 2024 | Versión: 1.0.0*
