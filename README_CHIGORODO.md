# 🌊 Sistema de Monitoreo Río León - Chigorodó, Antioquia

**🎯 Sistema especializado de monitoreo hidrológico para el río León en Chigorodó, con simulación avanzada de niveles freáticos y patrones climáticos específicos de la región de Urabá.**

## 📍 Ubicación Específica

- **Municipio**: Chigorodó, Antioquia, Colombia
- **Región**: Urabá Antioqueño
- **Cuenca**: Río León - Subcuenca del Atrato
- **Coordenadas**: 7°40'N, 76°41'W
- **Elevación**: 28 msnm
- **Zona climática**: Tropical húmedo de bosque muy húmedo (bmh-T)

## 🏞️ Características del Río León

### Datos Hidrológicos
- **Longitud**: 85.2 km
- **Ancho promedio**: 45 metros
- **Profundidad máxima**: 8.5 metros
- **Régimen**: Tropical pluvial con dos picos
- **Precipitación anual**: ~2,800 mm
- **Nivel de inundación**: 6.5 m
- **Nivel crítico**: 7.2 m
- **Nivel de sequía**: 0.8 m

### Patrones Estacionales Específicos
- **Época seca**: Enero-Febrero, Julio-Agosto (veranillo)
- **Primera época lluviosa**: Abril-Mayo
- **Segunda época lluviosa**: Septiembre-Noviembre
- **Transición**: Marzo, Junio, Diciembre

## 🏭 Estaciones de Monitoreo - Finca La Plana

### Estación 1: Río León - Entrada
- **Ubicación**: Finca La Plana, Sector Entrada
- **Coordenadas**: 7.6652°N, 76.6841°W
- **Elevación**: 32 msnm
- **Tipo**: Estación Principal
- **Compuerta**: Radial Ø3.2m x 8.0m
- **Caudal diseño**: 25.0 m³/s
- **Área de drenaje**: 85.3 km²

### Estación 2: Río León - Control
- **Ubicación**: Finca La Plana, Sector Control
- **Coordenadas**: 7.6671°N, 76.6825°W
- **Elevación**: 29 msnm
- **Tipo**: Estación Secundaria
- **Compuerta**: Deslizante Ø2.8m x 6.5m
- **Caudal diseño**: 18.0 m³/s
- **Área de drenaje**: 45.8 km²

## 🔧 Sensores Virtuales Especializados

### 🚪 Sensores de Compuertas (4 sensores)
| ID  | Nombre | Ubicación | Tipo | Intervalo |
|-----|--------|-----------|------|-----------|
| 104 | Compuerta Radial Principal | Estructura Control Entrada | Encoder absoluto | 10s |
| 204 | Compuerta Deslizante Control | Estructura Control Secundario | Potenciómetro lineal | 12s |

### 🌊 Sensores de Nivel Freático (2 sensores especializados)
| ID  | Nombre | Ubicación | Rango | Precisión | Tipo |
|-----|--------|-----------|-------|-----------|------|
| 101 | Nivel Freático - Entrada | Sector Entrada | 0.5-6.0m | 2mm | Piezómetro |
| 201 | Nivel Freático - Control | Sector Control | 0.3-5.5m | 2mm | Transductor presión |

### 🏞️ Sensores de Nivel de Río (2 sensores)
| ID  | Nombre | Ubicación | Rango | Influencia |
|-----|--------|-----------|-------|-------------|
| 102 | Nivel Río León - Entrada | Cauce Principal | 0.2-7.5m | Mareal mínima |
| 202 | Nivel Río León - Control | Cauce Control | 0.1-6.5m | Mareal mínima |

### 💧 Sensores de Velocidad de Flujo (2 sensores)
| ID  | Nombre | Ubicación | Rango | Tipo |
|-----|--------|-----------|-------|------|
| 103 | Velocidad Flujo - Entrada | Cauce Principal | 0.1-4.5 m/s | Doppler |
| 203 | Velocidad Flujo - Control | Cauce Control | 0.05-3.8 m/s | Electromagnético |

## 🌧️ Modelado Climático Específico

### Patrones de Precipitación de Urabá
- **Enero**: 45 mm/día promedio (seco)
- **Abril-Mayo**: 185-220 mm/día (primera época lluviosa)
- **Julio-Agosto**: 85-95 mm/día (veranillo)
- **Septiembre-Noviembre**: 195-245 mm/día (segunda época lluviosa)

### Factores Horarios Tropicales
- **14:00-18:00**: Pico de lluvias (factor 2.5x)
- **19:00-22:00**: Lluvias nocturnas (factor 1.8x)
- **03:00-06:00**: Mínimo nocturno (factor 0.4x)
- **07:00-13:00**: Incremento matutino (factor 0.6-1.2x)

### Influencias Ambientales
- **Golfo de Urabá**: Influencia mareal mínima (~5cm)
- **Evapotranspiración**: 4.2 mm/día promedio
- **Humedad relativa**: 82% promedio
- **Temperatura**: 24°C - 32°C

## 🚀 Inicio Rápido

### Un Solo Comando
```powershell
# Iniciar sistema completo específico para Chigorodó
.\iniciar_chigorodo_completo.ps1
```

### Opciones Avanzadas
```powershell
# Ver ayuda completa
.\iniciar_chigorodo_completo.ps1 -h

# Ejemplos específicos:
.\iniciar_chigorodo_completo.ps1                    # Inicio completo Chigorodó
.\iniciar_chigorodo_completo.ps1 -Port 8080         # Puerto personalizado
.\iniciar_chigorodo_completo.ps1 -ResetData         # Recrear datos desde cero
.\iniciar_chigorodo_completo.ps1 -UseTestData       # Usar datos generales
```

## 🎮 Controles Interactivos

Durante la ejecución del sistema:
- **[S]** - Estado del sistema Chigorodó
- **[L]** - Logs de sensores Río León en tiempo real
- **[R]** - Reiniciar sensores específicos
- **[O]** - Abrir dashboard en navegador
- **[C]** - Información climática actual de Urabá
- **[Q]** - Detener sistema

## 📊 Datos Generados

### Volumen de Datos Históricos
- **Período**: 45 días de datos históricos
- **Estaciones**: 2 estaciones específicas
- **Sensores virtuales**: 8 sensores especializados
- **Puntos de datos**: ~15,000-25,000 registros
- **Patrones**: Específicos del clima tropical de Urabá

### Escenarios Preconfigurados
- **Creciente por lluvia intensa**: Nivel 5.8m, compuerta 95% abierta
- **Época seca**: Nivel 0.9m, compuerta 25% cerrada
- **Operación normal**: Variaciones tropicales por hora del día

## 🔍 Características Técnicas Específicas

### Modelo Hidrológico Avanzado
- **Coeficiente de escorrentía**: 0.45 (suelos aluviales)
- **Tiempo de concentración**: 4.5 horas
- **Infiltración**: 35% (suelos permeables de Urabá)
- **Factor de rugosidad**: 0.92 (vegetación tropical)

### Simulación de Niveles Freáticos
- **Correlación río-freático**: 85%
- **Permeabilidad diferencial**:
  - Estación Entrada: Factor 1.2 (más permeable)
  - Estación Control: Factor 0.9 (menos permeable)
- **Influencia de bombeos agrícolas**: Ciclos de 1 hora
- **Retraso de infiltración**: Factor 0.95

### Control de Compuertas Tropical
- **Modo AUTO**: Basado en precipitación y estacionalidad
- **Modo MANUAL**: Operación simulada por operador
- **Modo EMERGENCY**: Apertura automática en crecientes
- **Velocidad de movimiento**: 0.5-3.0 %/segundo

## 🌡️ Alertas Específicas para Chigorodó

| Tipo | Umbral | Mensaje | Acciones |
|------|--------|---------|----------|
| 🔴 **Crítico** | 7.2m | Nivel crítico río León - Riesgo inundación | Apertura automática, notificación, evacuación |
| 🟠 **Inundación** | 6.5m | Nivel de inundación río León | Incrementar descarga, monitoreo continuo |
| 🟡 **Sequía** | 0.8m | Nivel de sequía río León | Reducir descargas, conservar agua |
| 🔵 **Técnico** | 5min | Falla comunicación estación | Verificar conectividad, protocolo manual |

## 🔬 Validación Científica

### Parámetros Calibrados
- **Coeficientes de Manning**:
  - Canal principal: 0.025
  - Cauce natural: 0.035
  - Zona inundación: 0.045

- **Coeficientes de descarga**:
  - Vertedero rectangular: 0.62
  - Vertedero triangular: 0.58
  - Compuerta libre: 0.60
  - Compuerta sumergida: 0.58

- **Tasas de infiltración**:
  - Suelo arenoso: 25.0 mm/h
  - Suelo arcilloso: 8.0 mm/h
  - Suelo orgánico: 15.0 mm/h
  - Roca fracturada: 2.0 mm/h

## 🌐 API Específica

### Endpoints Especializados

#### Datos de Sensores con Geolocalización
```json
POST /api/data
{
    "gate_id": 1,
    "sensor_id": 101,
    "timestamp": "2024-12-20T15:30:00Z",
    "level_m": 2.345,
    "coordinates": {"lat": 7.6652, "lon": -76.6841},
    "sensor_type": "freatic_level",
    "quality_status": "GOOD",
    "source_device": "rio_leon_freatic_level_101"
}
```

#### Dashboard con Información Geográfica
```json
GET /api/dashboard?station_id=1&hours=24
{
    "location": "Chigorodó, Antioquia - Río León",
    "current_status": {
        "position_percent": 75.5,
        "level_m": 2.345,
        "freatic_level_m": 2.001,
        "flow_m3s": 4.123,
        "precipitation_factor": 1.2,
        "seasonal_factor": 0.8,
        "coordinates": {"lat": 7.6652, "lon": -76.6841}
    },
    "climate_info": {
        "season": "dry_season",
        "rainfall_expected": "low",
        "tidal_influence": 0.03
    }
}
```

## 🛠️ Instalación Manual (Opcional)

### Prerrequisitos Específicos
- Python 3.8+ con librerías científicas
- numpy, scipy (instalación automática)
- PowerShell 5.0+ (Windows)

### Pasos Detallados
```bash
# 1. Instalar dependencias específicas
pip install numpy scipy pandas matplotlib

# 2. Inicializar datos específicos de Chigorodó
python initialize_chigorodo_data.py

# 3. Iniciar sensores específicos del río León
python sensores_rio_leon.py

# 4. Iniciar aplicación web
python app.py
```

## 📈 Casos de Uso Específicos

### 🏞️ Gestión de Recursos Hídricos
- Monitoreo de caudales del río León
- Control de niveles freáticos en Finca La Plana
- Gestión de compuertas durante épocas lluviosas
- Prevención de inundaciones en Chigorodó

### 🌾 Agricultura de Urabá
- Monitoreo de agua para cultivos de banano
- Gestión de riego en época seca
- Control de drenaje en época lluviosa
- Optimización de recursos hídricos

### 🔬 Investigación Hidrológica
- Estudio de patrones climáticos de Urabá
- Análisis de niveles freáticos tropicales
- Validación de modelos hidrológicos
- Investigación de cuencas del Atrato

### 📚 Educación Ambiental
- Enseñanza de hidrología tropical
- Simulación de sistemas reales colombianos
- Estudios de caso específicos de Antioquia
- Formación en gestión de recursos hídricos

## 🔮 Desarrollos Futuros

### Versión 2.0 - Chigorodó Avanzado
- 🌐 Integración con IDEAM (Instituto de Meteorología)
- 📡 Conexión con estaciones reales del río León
- 🤖 Predicción de crecientes con ML
- 📱 App móvil específica para operadores locales

### Expansión Regional
- 🏞️ Integración con otros ríos de Urabá
- 🌊 Conexión con sistemas del Golfo de Urabá
- 🏘️ Monitoreo urbano de Chigorodó
- 🌿 Integración con ecosistemas del Darién

## 📞 Soporte Técnico

### Contactos Especializados
- 📧 **Email**: chigorodo@estacion-bombeo.co
- 📱 **WhatsApp**: +57 300 123 4567
- 🏢 **Oficina**: Chigorodó, Antioquia
- 🌐 **Web**: www.monitoreo-rio-leon.co

### Documentación Técnica
- 📊 **Informes técnicos**: `/docs/informes/`
- 📋 **Manuales de operación**: `/docs/manuales/`
- 🔬 **Estudios hidrológicos**: `/docs/estudios/`
- 📈 **Datos históricos**: `/docs/datos/`

---

## 🎉 Sistema Listo

**El sistema está completamente configurado para Chigorodó. Para iniciar:**

```powershell
.\iniciar_chigorodo_completo.ps1
```

**En menos de 3 minutos tendrá:**
- ✅ Sistema específico de Chigorodó funcionando
- ✅ Base de datos con patrones del río León
- ✅ 8 sensores virtuales especializados activos
- ✅ Simulación de niveles freáticos realista
- ✅ Patrones climáticos de Urabá integrados
- ✅ Dashboard web con información geográfica específica

**🌐 Acceda al dashboard en: http://localhost:5000**

---

*📍 Proyecto específico para Chigorodó, Antioquia - Río León | Versión: 1.0.0 | Diciembre 2024*
