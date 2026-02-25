# Manual de Usuario - Sistema de Monitoreo de Estaciones de Bombeo

## Tabla de Contenidos
1. [Introducción](#introducción)
2. [Acceso al Sistema](#acceso-al-sistema)
3. [Interface del Dashboard](#interface-del-dashboard)
4. [Monitoreo en Tiempo Real](#monitoreo-en-tiempo-real)
5. [Interpretación de Datos](#interpretación-de-datos)
6. [Alertas y Notificaciones](#alertas-y-notificaciones)
7. [Reportes y Análisis](#reportes-y-análisis)
8. [Preguntas Frecuentes](#preguntas-frecuentes)

## Introducción

El Sistema de Monitoreo de Estaciones de Bombeo es una aplicación web diseñada para supervisar en tiempo real el estado de compuertas circulares de 2 metros de diámetro en estaciones de bombeo. 

### Funcionalidades Principales
- **Monitoreo en tiempo real** del estado de compuertas
- **Medición continua** de niveles de agua
- **Cálculo automático** de caudales
- **Visualización gráfica** de tendencias históricas
- **Dashboard intuitivo** con métricas clave
- **Alertas** por condiciones anómalas

## Acceso al Sistema

### Inicio de Sesión

1. **Abrir el navegador web** (Chrome, Firefox, Safari, Edge)
2. **Navegar a la dirección:** `http://localhost:5000`
3. **Acceder al dashboard:** `http://localhost:5000/index.html`

> **Nota:** Si el sistema está instalado en un servidor remoto, reemplace `localhost` con la dirección IP o dominio correspondiente.

### Requisitos del Navegador
- **JavaScript habilitado**
- **Conexión a Internet** para cargar librerías de gráficos
- **Resolución mínima:** 1024x768 píxeles
- **Navegadores compatibles:** Chrome 70+, Firefox 65+, Safari 12+, Edge 79+

## Interface del Dashboard

### Vista General

El dashboard principal se compone de:

1. **Barra Superior**
   - Título del sistema
   - Selector de estación
   - Última actualización

2. **Tarjetas de Estado** (4 tarjetas principales)
   - Estado de la compuerta
   - Nivel de agua
   - Caudal actual
   - Volumen diario

3. **Gráficos Interactivos**
   - Gráfico de caudal vs. tiempo
   - Gráfico de nivel de agua vs. tiempo

### Tarjetas de Estado

#### 1. Estado de Compuerta
- **Valor:** Porcentaje de apertura (0-100%)
- **Estados posibles:**
  - `CERRADA` (0%)
  - `PARCIAL` (1-99%)
  - `ABIERTA` (100%)
- **Indicador visual:** Barra de progreso con colores
  - Rojo: Cerrada
  - Amarillo: Parcial  
  - Verde: Completamente abierta

#### 2. Nivel de Agua
- **Unidad:** Metros (m)
- **Precisión:** 3 decimales
- **Rango típico:** 0.000 - 5.000 m
- **Color:** Azul

#### 3. Caudal Actual
- **Unidad:** Metros cúbicos por segundo (m³/s)
- **Precisión:** 4 decimales
- **Cálculo:** Automático basado en nivel y tipo de vertedero
- **Color:** Verde

#### 4. Volumen Diario
- **Unidad:** Metros cúbicos (m³)
- **Periodo:** Acumulado del día actual (00:00 - 23:59)
- **Precisión:** 1 decimal
- **Color:** Púrpura

### Selector de Estación

Ubicado en la parte superior derecha, permite cambiar entre diferentes estaciones de monitoreo:
- **Estación 1:** Compuerta Circular 2m - Ubicación A
- **Estación 2:** Compuerta Circular 2m - Ubicación B

Al seleccionar una estación diferente, todos los datos se actualizan automáticamente.

## Monitoreo en Tiempo Real

### Actualización de Datos

- **Frecuencia:** Cada 60 segundos automáticamente
- **Indicador:** Timestamp en la parte superior
- **Manual:** La página se puede refrescar manualmente (F5)

### Estados de Conexión

El sistema puede mostrar diferentes estados:

1. **Conectado** (datos actualizándose normalmente)
   - Datos numéricos actuales
   - Gráficos con información reciente

2. **Sin Datos** (conexión perdida o sensores desconectados)
   - Valores mostrarán "-"
   - Mensaje "NO_DATA" en estado

3. **Error** (problema técnico)
   - Valores mostrarán "ERROR"
   - Consultar con el administrador del sistema

## Interpretación de Datos

### Cálculos Hidráulicos

El sistema utiliza fórmulas estándar para calcular el caudal:

#### Vertedero Rectangular
```
Q = Cd × b × √(2g) × h^(3/2)
```
Donde:
- Q = Caudal (m³/s)
- Cd = Coeficiente de descarga (0.62)
- b = Ancho del vertedero (m)
- g = Aceleración gravitacional (9.81 m/s²)
- h = Altura de agua sobre el vertedero (m)

### Rangos Normales de Operación

| Parámetro | Mínimo | Típico | Máximo |
|-----------|---------|---------|---------|
| Nivel de agua | 0.000 m | 0.500-2.000 m | 3.000 m |
| Caudal | 0.0000 m³/s | 0.1000-1.5000 m³/s | 3.0000 m³/s |
| Apertura compuerta | 0% | 25-75% | 100% |
| Volumen diario | 0 m³ | 5000-15000 m³ | 30000 m³ |

### Interpretación de Tendencias

#### Gráfico de Caudal
- **Tendencia ascendente:** Aumento del flujo de agua
- **Tendencia descendente:** Disminución del flujo
- **Fluctuaciones:** Operación normal de compuertas
- **Línea plana en cero:** Compuerta cerrada o sin agua

#### Gráfico de Nivel de Agua
- **Subida rápida:** Posible crecida o lluvia intensa
- **Bajada gradual:** Drenaje normal
- **Estable:** Condiciones normales de operación
- **Variaciones bruscas:** Revisar sensores o condiciones externas

## Alertas y Notificaciones

### Condiciones de Alerta

El sistema monitorea las siguientes condiciones:

1. **Nivel de Agua Alto** (>2.5m)
   - Posible inundación
   - Verificar compuertas

2. **Caudal Excesivo** (>2.0 m³/s)
   - Flujo anormalmente alto
   - Revisar condiciones aguas arriba

3. **Compuerta No Responde**
   - Estado no cambia por >30 minutos
   - Verificar sistemas mecánicos

4. **Pérdida de Datos**
   - Sin lecturas por >5 minutos
   - Verificar conectividad y sensores

### Respuesta a Alertas

Ante cualquier condición de alerta:

1. **Verificar visualmente** el estado físico de la instalación
2. **Revisar el dashboard** para confirmar lecturas
3. **Contactar al personal técnico** si es necesario
4. **Documentar** cualquier acción tomada

## Reportes y Análisis

### Datos Históricos

Los gráficos muestran datos de las últimas 24 horas por defecto:
- **Línea azul:** Nivel de agua
- **Línea verde:** Caudal
- **Ejes:** Tiempo (horizontal) y valores (vertical)

### Análisis de Patrones

#### Patrones Normales
- **Ciclos diarios:** Variaciones regulares según uso
- **Respuesta a lluvia:** Incrementos graduales
- **Operación manual:** Cambios controlados de compuertas

#### Patrones Anómalos
- **Variaciones extremas:** Investigar causas
- **Datos faltantes:** Problemas de comunicación
- **Valores constantes:** Posibles sensores bloqueados

### Exportación de Datos

Para obtener datos detallados:
1. Contactar al administrador del sistema
2. Los datos se almacenan en base PostgreSQL
3. Disponibles consultas personalizadas por fechas

## Uso en Dispositivos Móviles

### Compatibilidad
- **Diseño responsivo:** Funciona en tablets y smartphones
- **Navegadores móviles:** Safari, Chrome, Firefox
- **Orientación:** Tanto horizontal como vertical

### Limitaciones Móviles
- **Gráficos:** Mejor visualización en pantallas grandes
- **Interacción:** Uso táctil optimizado
- **Actualización:** Misma frecuencia que escritorio

## Preguntas Frecuentes

### ¿Con qué frecuencia se actualizan los datos?
Los datos se actualizan automáticamente cada 60 segundos.

### ¿Qué hacer si veo valores "-" o "ERROR"?
1. Verificar conexión a Internet
2. Refrescar la página (F5)
3. Si persiste, contactar soporte técnico

### ¿Puedo ver datos de días anteriores?
Actualmente el dashboard muestra las últimas 24 horas. Para datos históricos, contactar al administrador.

### ¿El sistema funciona en teléfonos móviles?
Sí, el dashboard es completamente responsivo y funciona en dispositivos móviles.

### ¿Qué significan los diferentes colores en las tarjetas?
- **Azul:** Nivel de agua
- **Verde:** Caudal
- **Púrpura:** Volumen diario
- **Variable:** Estado de compuerta (rojo/amarillo/verde según apertura)

### ¿Cómo interpretar el volumen diario?
Es la suma acumulada de agua que ha pasado por la compuerta durante el día actual, calculado en base al caudal promedio.

### ¿Qué hacer si la página no carga?
1. Verificar que el servidor esté ejecutándose
2. Confirmar la URL (http://localhost:5000)
3. Revisar conexión de red
4. Contactar al administrador del sistema

---

## Contacto y Soporte

Para soporte técnico o consultas adicionales:
- **Consultar:** Documentación técnica completa
- **Reportar:** Problemas al administrador del sistema
- **Verificar:** Estado del servidor y conectividad
