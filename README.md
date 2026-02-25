# Sistema de Monitoreo de Estaciones de Bombeo

[![Estado](https://img.shields.io/badge/Estado-Funcional-brightgreen.svg)](#)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](#)
[![Flask](https://img.shields.io/badge/Flask-Enabled-orange.svg)](#)
[![Licencia](https://img.shields.io/badge/Licencia-Propietaria-red.svg)](#)

---

## 📞 Índice de Contenidos

- [🏭 Descripción](#-descripción)
- [✨ Características Principales](#-características-principales)
- [🚀 Inicio Rápido](#-inicio-rápido)
- [📋 Requisitos del Sistema](#-requisitos-del-sistema)
- [🗺️ Estructura del Proyecto](#%EF%B8%8F-estructura-del-proyecto)
- [🛠️ Scripts Disponibles](#%EF%B8%8F-scripts-disponibles)
- [📚 Documentación](#-documentación)
- [🔌 API Endpoints](#-api-endpoints)
- [🎨 Dashboard Features](#-dashboard-features)
- [🧮 Cálculos Hidráulicos](#-cálculos-hidráulicos)
- [🗄️ Base de Datos](#%EF%B8%8F-base-de-datos)
- [🚀 ¡Comience Ahora!](#-comience-ahora)

---

## 🏭 Descripción

Sistema web completo para el **monitoreo en tiempo real** de estaciones de bombeo con compuertas circulares de 2 metros de diámetro. 

Incluye:
- 📊 Dashboard interactivo responsivo
- 🧮 Cálculos hidráulicos automáticos
- 🗄️ Base de datos robusta (PostgreSQL/SQLite)
- 📚 Documentación técnica completa integrada
- 🔌 API REST con endpoints documentados

---

## ✨ Características Principales

<table>
<tr>
<td width="50%">

### 📊 Monitoreo en Tiempo Real
- Dashboard interactivo con gráficos dinámicos
- Actualización automática cada 60 segundos
- Indicadores visuales de estado
- Compatible con dispositivos móviles

### 🧮 Cálculos Hidráulicos
- Fórmulas de vertedero rectangular
- Cálculo automático de caudales
- Volumen acumulado diario
- Coeficientes configurables

</td>
<td width="50%">

### 🗄️ Sistema de Base de Datos
- PostgreSQL para producción
- SQLite para desarrollo/demo
- Respaldo automático
- Integridad referencial

### 🛠️ Facilidad de Uso
- Instalación automatizada
- Scripts de inicio inteligentes
- Documentación web integrada
- API REST completa

</td>
</tr>
</table>

---

## 🚀 Inicio Rápido

> ⚡ **Instalación en menos de 5 minutos**

### 🎆 Opción 1: Instalación Automática (Recomendada)

```powershell
# 🔧 1. Ejecutar instalador completo
.\instalar_sistema.ps1

# 🚀 2. Iniciar sistema completo (con navegador automático)
.\iniciar_sistema_completo.ps1

# ⚡ 3. O iniciar solo la aplicación
.\iniciar_aplicacion.ps1
```

### 💻 Opción 2: Solo Iniciar (si ya está instalado)

```powershell
# 🎡 Inicio simple
.\iniciar_aplicacion.ps1

# 🔧 Inicio avanzado con opciones
.\iniciar_sistema_completo.ps1 -Development -Port 5001
```

### 🌍 Acceder al Sistema

Una vez iniciado, abra su navegador en:

| 🔗 Enlace | 📝 Descripción | 🌐 URL |
|---------|-------------|-----|
| **🏠 Dashboard Principal** | Interface principal de monitoreo | [http://localhost:5000/](http://localhost:5000/) |
| **📚 Documentación** | Manuales técnicos integrados | [http://localhost:5000/docs/](http://localhost:5000/docs/) |
| **🔌 API Dashboard** | Datos JSON del dashboard | [http://localhost:5000/api/dashboard](http://localhost:5000/api/dashboard) |
| **🏢 API Estaciones** | Lista de estaciones | [http://localhost:5000/api/stations](http://localhost:5000/api/stations) |

---

## 📋 Requisitos del Sistema

<table>
<tr>
<td width="50%">

### 💻 Hardware Mínimo

| Componente | Mínimo | Recomendado |
|------------|---------|-------------|
| 💽 **CPU** | Intel i3 / AMD equivalente | Intel i5 / AMD Ryzen 5 |
| 💾 **RAM** | 4 GB | 8 GB |
| 📀 **Almacenamiento** | 2 GB libres | 5 GB libres |
| 🌐 **Red** | Internet (instalación) | Ethernet 100 Mbps |

</td>
<td width="50%">

### 🛠️ Software Requerido

| Software | Versión | Estado |
|----------|---------|--------|
| 🎨 **Windows** | 10/11 (64-bit) | ✅ Requerido |
| 🐍 **Python** | 3.8+ | ✅ Requerido |
| 🐘 **PostgreSQL** | 12+ | ⚠️ Opcional* |
| 🌍 **Navegador** | Moderno | ✅ Requerido |

*SQLite incluido para demo

</td>
</tr>
</table>

## 🗂️ Estructura del Proyecto

```
project_estacion_bombeo/
├── 📁 docs/                          # Documentación web integrada
│   ├── index.html                     # Portal de documentación
│   ├── docs-styles.css                # Estilos de documentación
│   ├── docs-script.js                 # JavaScript de documentación
│   ├── MANUAL_INSTALACION.md          # Manual de instalación
│   ├── MANUAL_USUARIO.md              # Manual de usuario
│   └── MANUAL_TECNICO.md              # Manual técnico
├── 📁 logs/                           # Archivos de log del sistema
├── 📁 venv/                           # Entorno virtual Python
├── 🐍 app.py                         # Servidor Flask principal
├── 🗄️ database.py                    # Modelos de base de datos
├── 📊 calculations.py                 # Cálculos hidráulicos
├── ⚙️ config.py                       # Configuración del sistema
├── 🌐 index.html                      # Dashboard web
├── 🎨 styles.css                      # Estilos del dashboard
├── 💻 script.js                       # JavaScript del dashboard
├── 🗃️ bd-estacion-bombeo.sql          # Esquema de base de datos
├── 📦 requirements.txt                # Dependencias Python
├── 🔧 instalar_sistema.ps1            # Instalador automático
├── 🗄️ setup_database.ps1              # Configurador de BD
├── 🚀 iniciar_sistema_completo.ps1    # Iniciador maestro
├── ▶️ iniciar_aplicacion.ps1          # Iniciador simple
├── 📝 README.md                       # Este archivo
└── 📋 contenido-del-archivo.txt       # Estructura de archivos
```

## 🛠️ Scripts Disponibles

### Instalación
- **`instalar_sistema.ps1`** - Instalador automático completo
- **`setup_database.ps1`** - Solo configuración de base de datos

### Ejecución
- **`iniciar_sistema_completo.ps1`** - Iniciador maestro con verificaciones
- **`iniciar_aplicacion.ps1`** - Inicio simple y rápido

### Parámetros Avanzados

```powershell
# Modo desarrollo
.\iniciar_sistema_completo.ps1 -Development

# Cambiar puerto
.\iniciar_sistema_completo.ps1 -Port 8080

# Omitir verificaciones de BD
.\iniciar_sistema_completo.ps1 -SkipDB

# Combinaciones
.\iniciar_sistema_completo.ps1 -Development -Port 3000 -SkipDB
```

---

## 📚 Documentación

> 🎯 **Documentación completa integrada en el sistema**

### 🔗 Acceso Rápido

| Método | Descripción | Enlace |
|--------|-------------|--------|
| 🏠 **Desde Dashboard** | Botón "📚 Documentación" superior derecho | En el dashboard |
| 🌍 **Acceso Directo** | URL directa al portal | [http://localhost:5000/docs/](http://localhost:5000/docs/) |
| 📁 **Archivos Locales** | Archivos Markdown en carpeta docs | [./docs/](./docs/) |

### 📖 Manuales Incluidos

<table>
<tr>
<td width="33%" align="center">

#### 🔧 Manual de Instalación
**Guía Completa de Setup**

- Requisitos del sistema
- Instalación automatizada
- Configuración de BD
- Solución de problemas

[🔗 Ver Manual](docs/MANUAL_INSTALACION.md)

</td>
<td width="33%" align="center">

#### 👤 Manual de Usuario
**Cómo Usar el Dashboard**

- Interface del dashboard
- Interpretación de datos
- Monitoreo en tiempo real
- Uso en móviles

[🔗 Ver Manual](docs/MANUAL_USUARIO.md)

</td>
<td width="33%" align="center">

#### ⚙️ Manual Técnico
**Arquitectura y Desarrollo**

- API REST endpoints
- Modelos de base de datos
- Extensión del sistema
- Configuración avanzada

[🔗 Ver Manual](docs/MANUAL_TECNICO.md)

</td>
</tr>
</table>

### 🎯 Características de la Documentación

- 📱 **Diseño responsivo** - Compatible con todos los dispositivos
- 🔍 **Navegación intuitiva** - Tabla de contenidos interactiva
- 💡 **Sintaxis destacada** - Código con colores y formato
- 🔄 **Carga dinámica** - Contenido Markdown renderizado en vivo
- 🔍 **Búsqueda integrada** - Encuentra información rápidamente

## 🔌 API Endpoints

### Principales Endpoints

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/` | Dashboard principal |
| GET | `/docs/` | Portal de documentación |
| GET | `/api/dashboard` | Datos para dashboard |
| POST | `/api/data` | Recibir datos de sensores |
| GET | `/api/stations` | Lista de estaciones |
| POST | `/api/init-db` | Inicializar base de datos |

### Ejemplo de Uso

```javascript
// Obtener datos del dashboard
fetch('http://localhost:5000/api/dashboard?station_id=1&hours=24')
  .then(response => response.json())
  .then(data => console.log(data));

// Enviar datos de sensores
fetch('http://localhost:5000/api/data', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    gate_id: 1,
    timestamp: '2024-12-20T15:30:00Z',
    position_percent: 75.5,
    level_m: 1.234,
    source_device: 'sensor_001'
  })
});
```

## 🎨 Dashboard Features

### 📊 Tarjetas de Estado
- **🚪 Estado de Compuerta** - Porcentaje de apertura con indicador visual
- **🌊 Nivel de Agua** - Medición en metros con 3 decimales
- **💧 Caudal Actual** - Calculado automáticamente en m³/s
- **📈 Volumen Diario** - Acumulado del día actual

### 📈 Gráficos Interactivos
- **Caudal vs Tiempo** - Tendencias de las últimas 24 horas
- **Nivel vs Tiempo** - Variaciones del nivel de agua
- **Zoom y pan** interactivos
- **Tooltips informativos**

### 🔄 Actualización Automática
- **Frecuencia:** Cada 60 segundos
- **Indicador visual** de última actualización
- **Manejo de errores** automático

## 🧮 Cálculos Hidráulicos

### Fórmulas Implementadas

#### Vertedero Rectangular
```
Q = Cd × b × √(2g) × h^(3/2)
```

Donde:
- Q = Caudal (m³/s)
- Cd = Coeficiente de descarga (0.62)
- b = Ancho del vertedero (m)
- g = Aceleración gravitacional (9.81 m/s²)
- h = Altura de agua sobre vertedero (m)

#### Volumen Acumulado
```
V = ∫ Q(t) dt
```

## 🗄️ Base de Datos

### Tablas Principales
- **`gate_status`** - Estado histórico de compuertas
- **`water_level`** - Niveles de agua y caudales
- **`flow_summary`** - Resúmenes diarios
- **`pumping_stations`** - Configuración de estaciones

### Backup Automático
```sql
-- Backup diario
pg_dump monitoring_db > backup_$(Get-Date -Format "yyyyMMdd").sql
```

## 🛠️ Desarrollo

### Extensión del Sistema

```python
# Agregar nuevos sensores
class WaterLevel(db.Model):
    temperature_c = db.Column(db.Numeric(4,1))  # Nuevo campo
    ph_level = db.Column(db.Numeric(3,1))       # Nuevo campo
```

### Integración MQTT

```python
# Ejemplo de integración MQTT
import paho.mqtt.client as mqtt

def on_message(client, userdata, message):
    data = json.loads(message.payload.decode())
    requests.post('http://localhost:5000/api/data', json=data)
```

## 🔧 Solución de Problemas

### Problemas Comunes

#### Python no reconocido
```powershell
# Verificar instalación
python --version
pip --version

# Reinstalar con PATH
# https://www.python.org/downloads/
```

#### PostgreSQL no conecta
```powershell
# Verificar servicio
Get-Service postgresql*

# Iniciar servicio
Start-Service postgresql-x64-13
```

#### Puerto en uso
```powershell
# Usar puerto alternativo
.\iniciar_sistema_completo.ps1 -Port 8080
```

### Logs del Sistema
```powershell
# Ver logs
Get-Content logs\system_startup.log -Tail 50
```

## 🤝 Contribución

### Estructura para Nuevas Características
1. **Backend:** Agregar endpoint en `app.py`
2. **Frontend:** Actualizar `script.js` y `index.html`
3. **Base de Datos:** Modificar modelos en `database.py`
4. **Documentación:** Actualizar manuales en `docs/`

### Convenciones
- **Python:** PEP 8
- **JavaScript:** ES6+
- **CSS:** BEM methodology
- **SQL:** Snake_case

## 📄 Licencia

Este proyecto está desarrollado para uso en sistemas de monitoreo de estaciones de bombeo. Consulte los términos específicos con el administrador del sistema.

## 📞 Soporte

### Recursos de Ayuda
1. **📚 Documentación Integrada** - http://localhost:5000/docs/
2. **🛠️ Manual Técnico** - Para administradores
3. **👤 Manual de Usuario** - Para operadores
4. **📋 Logs del Sistema** - `logs/system_startup.log`

### Contacto
- **Documentación Técnica:** Ver Manual Técnico integrado
- **Issues:** Reportar al administrador del sistema
- **Desarrollo:** Consultar código fuente y documentación

---

## 🚀 ¡Comience Ahora!

<div align="center">

### ✨ **¡Su Sistema de Monitoreo en Minutos!** ✨

</div>

```powershell
# 📆 Instalación completa en 3 pasos:

# 1️⃣ Descargar/clonar proyecto
# 2️⃣ Ejecutar instalador automático
.\instalar_sistema.ps1

# 3️⃣ Iniciar sistema completo
.\iniciar_sistema_completo.ps1
```

<div align="center">

### 🎆 **¡LISTO!** 🎆

**Su sistema de monitoreo profesional estará funcionando en menos de 5 minutos**

---

| 🔗 Acceso Rápido | 🌐 URL |
|-------------------|-----|
| 🏠 **Dashboard** | [localhost:5000](http://localhost:5000/) |
| 📚 **Documentación** | [localhost:5000/docs/](http://localhost:5000/docs/) |
| 🔌 **API** | [localhost:5000/api/dashboard](http://localhost:5000/api/dashboard) |

---

### 📞 Soporte y Ayuda

¿**Necesita ayuda?** 🤔

1. 📚 **Consulte la [Documentación Integrada](http://localhost:5000/docs/)**
2. 🔍 **Revise los [Manuales Técnicos](./docs/)**
3. 📝 **Verifique los logs del sistema en `logs/`**

### 🌟 ¡Gracias por usar nuestro sistema!

</div>
