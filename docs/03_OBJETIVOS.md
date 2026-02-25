# 3. OBJETIVOS

**Promotora Palmera de Antioquia S.A.S.**  
**Proyecto Universitario de Automatización IoT**  
**Sistema de Control Inteligente para Estaciones de Bombeo**  
**Fecha: Febrero 2026**

---

## 3.1 Objetivo General

**Diseñar, implementar y validar un sistema IoT de automatización inteligente para estaciones de bombeo agrícola que integre monitoreo meteorológico en tiempo real, control automático multi-factor, alertas contextuales multi-canal y analítica de datos, logrando una reducción mínima del 60% en costos operativos y un incremento del 95% en la confiabilidad del sistema de riego en Promotora Palmera de Antioquia S.A.S., durante el período febrero-octubre 2026.**

---

## 3.2 Objetivos Específicos

### OE1: Implementar Sistema de Telemetría Completa para Bombas

**Descripción:**  
Diseñar e instalar un sistema de sensores que capture en tiempo real las variables críticas de operación de cada estación de bombeo, almacenándolas en base de datos centralizada con frecuencia de muestreo de 10 segundos.

**Variables a medir:**
- Estado operacional (ON/OFF)
- Caudal real (m³/h) mediante sensor electromagnético
- Presión de entrada y salida (bar) mediante transductores 4-20mA
- Consumo energético instantáneo (kWh) mediante medidor digital
- Temperatura del motor (°C) mediante termocupla tipo K
- Horas de operación acumuladas (h)

**Indicadores de logro:**
- ✅ 100% de estaciones con telemetría completa instalada
- ✅ Disponibilidad de datos >99.5% (máximo 7 horas offline/año)
- ✅ Precisión de medición: ±2% en caudal, ±1% en presión
- ✅ Latencia <5 segundos desde sensor hasta dashboard

**Meta cuantitativa:**  
4 estaciones de bombeo con 6 variables monitoreadas = **24 canales de telemetría activos**

**Plazo:** Semana 7 del cronograma (instalación hardware)

---

### OE2: Integrar Estación Meteorológica con Predicción de Eventos

**Descripción:**  
Instalar y configurar sensores meteorológicos en 2 ubicaciones estratégicas del predio que permitan correlacionar variables climáticas con decisiones de bombeo, generando alertas predictivas ante eventos extremos.

**Variables a medir:**
- Precipitación (mm) con resolución 0.1 mm
- Velocidad y dirección del viento (km/h, grados)
- Temperatura ambiente (°C)
- Humedad relativa (%)
- Presión atmosférica (hPa)
- Radiación solar (W/m²)

**Algoritmos a implementar:**
- Acumulación de lluvia en ventanas móviles (última hora, últimas 2 horas, últimas 24 horas)
- Cálculo de índice de riesgo de tormenta (presión < 1005 hPa + viento > 50 km/h)
- Estimación de evapotranspiración potencial (fórmula FAO-Penman-Monteith simplificada)

**Indicadores de logro:**
- ✅ 2 estaciones meteorológicas instaladas y calibradas
- ✅ Precisión pluviómetro: ±3% en lluvia >10mm
- ✅ 100% de eventos de lluvia >30mm/2h generan alerta automática
- ✅ Dashboard muestra datos meteorológicos con <10 segundos de latencia

**Meta cuantitativa:**  
**12 variables meteorológicas** monitoreadas en tiempo real con histórico de 2 años

**Plazo:** Semana 7 del cronograma

---

### OE3: Desarrollar Algoritmo de Control Automático Multi-Factor

**Descripción:**  
Implementar un sistema de control basado en reglas que tome decisiones de encendido/apagado de bombas considerando simultáneamente 4 tipos de variables: hidráulicas, meteorológicas, energéticas y de mantenimiento.

**Reglas de decisión a implementar:**

| ID | Condición | Acción | Prioridad |
|----|-----------|--------|-----------|
| **R1** | Nivel < 50% mínimo AND lluvia_2h < 15mm | INICIAR bomba | CRÍTICA |
| **R2** | Lluvia_2h > 30mm | DETENER bomba | CRÍTICA |
| **R3** | Nivel ≥ máximo | DETENER bomba | ALTA |
| **R4** | Tarifa = PICO AND nivel > 70% mín | ESPERAR (solo si urgente) | MEDIA |
| **R5** | Nivel < mínimo AND condiciones OK | INICIAR bomba | ALTA |
| **R6** | Motor_temp > 85°C | DETENER bomba + alerta | CRÍTICA |

**Parámetros configurables:**
- Umbrales de nivel de agua (mín, máx) por estación
- Umbrales de precipitación (inhibición, advertencia)
- Horarios de tarifas eléctricas (PICO, VALLE, ESTÁNDAR)
- Temperaturas críticas de motor

**Indicadores de logro:**
- ✅ 6 reglas implementadas y probadas
- ✅ Tiempo de respuesta <30 segundos desde evento crítico hasta acción
- ✅ 0 falsos positivos en 1 mes de piloto (no arrancar si nivel es suficiente)
- ✅ 100% de eventos críticos (nivel <25% mínimo) activan bomba automáticamente

**Meta cuantitativa:**  
Reducir en **40% las horas de bombeo en horario PICO** y **eliminar 100% bombeo durante lluvia >30mm**

**Plazo:** Semana 4 (desarrollo sw) + Semana 8 (validación)

---

### OE4: Crear Dashboard Web Integrado con Sistema Empresarial

**Descripción:**  
Desarrollar una interfaz web responsiva que unifique visualización de datos meteorológicos, telemetría de bombas, alertas activas y controles de operación, integrándola visualmente con el sistema PQRSF existente de la empresa.

**Componentes del dashboard:**
1. **Panel meteorológico:** 4 widgets (lluvia, viento, temperatura, presión)
2. **Panel de control:** Toggle automático/manual, botones START/STOP, última decisión
3. **Panel de telemetría:** 6 métricas por bomba en tiempo real
4. **Panel de alertas:** Lista de alertas activas con botón resolver
5. **Gráficos históricos:** Series temporales de últimas 24h (nivel agua, caudal, consumo)

**Requisitos técnicos:**
- Responsive (desktop, tablet, móvil)
- Auto-refresh cada 10 segundos
- Compatible con Chrome, Edge, Firefox
- Tiempo de carga <3 segundos
- Accesibilidad WCAG 2.1 nivel AA

**Indicadores de logro:**
- ✅ Dashboard accesible desde 100% de dispositivos de supervisores
- ✅ 90% de usuarios califica interfaz como "fácil de usar" (encuesta post-capacitación)
- ✅ Tiempo promedio de capacitación <2 horas
- ✅ 0 errores críticos de diseño reportados en 1 mes

**Meta cuantitativa:**  
**5 paneles interactivos** con **25+ widgets** de visualización en tiempo real

**Plazo:** Semana 3 (desarrollo) + Semana 6 (refinamiento)

---

### OE5: Implementar Sistema de Alertas Multi-Canal con Enrutamiento Inteligente

**Descripción:**  
Configurar un sistema de notificaciones que envíe alertas automáticas por WhatsApp, Email y SMS según la severidad del evento, garantizando que personal crítico reciba información en tiempo real.

**Canales de notificación:**
- **WhatsApp Business API:** Mensajes instantáneos con formato rico (emojis, negritas)
- **Email (Brevo):** Plantillas HTML con detalles completos y gráficos
- **SMS (Twilio):** Mensajes de texto cortos para redundancia

**Matriz de enrutamiento:**

| Severidad | Ejemplo Evento | WhatsApp | Email | SMS |
|-----------|----------------|----------|-------|-----|
| CRITICAL | Motor >85°C, Nivel <25% mín | ✅ | ✅ | ✅ |
| HIGH | Lluvia >30mm/2h, Presión <1.5bar | ✅ | ✅ | ❌ |
| MEDIUM | Nivel <50% mín, Viento >50km/h | ❌ | ✅ | ❌ |
| LOW | Info operacional, Mantenimiento | ❌ | ✅ | ❌ |

**Destinatarios configurados:**
- Supervisor de operaciones: Todos los niveles
- Técnico de campo: CRITICAL y HIGH
- Gerente general: Solo CRITICAL
- Sistema (dashboard): Todos

**Indicadores de logro:**
- ✅ 100% de alertas CRITICAL entregan en <60 segundos
- ✅ 95% de destinatarios confirman recepción de alertas test
- ✅ 0 alertas perdidas por fallas de canal (redundancia SMS)
- ✅ Tasa de falsos positivos <5%

**Meta cuantitativa:**  
**3 canales de comunicación** atendiendo **4 niveles de severidad** a **5+ contactos configurados**

**Plazo:** Semana 5 (desarrollo) + Semana 7 (pruebas)

---

### OE6: Garantizar Registro Histórico de Datos con Retención Mínima de 2 Años

**Descripción:**  
Diseñar esquema de base de datos optimizado para almacenar series temporales de alta frecuencia, implementar respaldos automáticos y garantizar consultas rápidas para análisis retrospectivo.

**Estructura de almacenamiento:**
- **meteorological_data:** Registro cada 60 segundos × 6 variables = 8,640 registros/día
- **pump_telemetry:** Registro cada 10 segundos × 24 canales = 207,360 registros/día
- **system_alerts:** Todos los eventos (estimado 50/día)
- **automatic_control_log:** Todas las decisiones (estimado 100/día)

**Volumen estimado 2 años:**
```
Meteorológicos: 8,640 × 730 días = 6,307,200 registros (~1.5 GB)
Telemetría: 207,360 × 730 = 151,372,800 registros (~35 GB)
Alertas: 50 × 730 = 36,500 registros (~5 MB)
Control: 100 × 730 = 73,000 registros (~10 MB)

TOTAL: ~37 GB (comprimido ~12 GB)
```

**Estrategia de respaldo:**
- Backup incremental diario (23:00 cada noche)
- Backup completo semanal (domingos 02:00)
- Almacenamiento en 3 ubicaciones (servidor, NAS local, nube)
- Tiempo de retención: 5 años

**Indicadores de logro:**
- ✅ 0 pérdida de datos en 6 meses de operación
- ✅ Tiempo de consulta de datos históricos <5 segundos para ventana de 7 días
- ✅ Índices de BD optimizados (query plan <100ms)
- ✅ Espacio en disco disponible >50% (margen para 4 años adicionales)

**Meta cuantitativa:**  
**>150 millones de registros** almacenados con disponibilidad del **99.99%**

**Plazo:** Semana 2 (diseño BD) + Semana 3 (implementación)

---

### OE7: Integrar Sistema IoT con Infraestructura Tecnológica Empresarial Existente

**Descripción:**  
Conectar el nuevo sistema de bombeo con los servicios tecnológicos ya desplegados en la empresa (servidor IIS, base de datos MySQL, servicio de email Brevo, red corporativa), evitando redundancias y aprovechando inversiones previas.

**Puntos de integración:**

1. **Servidor IIS Windows:**
   - Alojar dashboard en subdirectorio `/bombeo/`
   - Compartir certificado SSL existente
   - Usar misma configuración de firewall

2. **Base de datos:**
   - Opción A (piloto): SQLite independiente
   - Opción B (producción): Misma instancia MySQL que PQRSF
   - Esquema separado (`bombeo_*` vs `pqrsf_*`)

3. **Servicio de email Brevo:**
   - Reutilizar cuenta corporativa existente
   - Usar misma clase `BrevoEmailHelperV2`
   - Plantillas de email consistentes con marca corporativa

4. **Red y acceso:**
   - Un solo login corporativo (Active Directory)
   - Misma política de contraseñas
   - Logs unificados en Event Viewer

**Indicadores de logro:**
- ✅ 0 conflictos de puertos/servicios con sistemas existentes
- ✅ Reutilización de al menos 3 componentes tecnológicos
- ✅ Reducción 40% en tiempo de configuración vs solución standalone
- ✅ Dashboard accesible desde intranet corporativa sin VPN adicional

**Meta cuantitativa:**  
**100% de servicios compartidos** (servidor, email, red) con **0 dependencias externas obligatorias**

**Plazo:** Semana 1 (análisis) + Semana 8 (validación integración)

---

## 3.3 Objetivos Transversales (No Técnicos)

### OT1: Capacitación y Transferencia de Conocimiento

**Meta:**  
Capacitar al 100% del personal operativo (4 personas) en el uso del sistema, logrando autonomía completa en operación básica y 80% de autonomía en mantenimiento nivel 1.

**Entregables:**
- Manual de usuario impreso (50 páginas)
- 3 videos tutoriales (<10 min cada uno)
- 24 horas presenciales de capacitación
- Certificado de competencia interna

**Plazo:** Semana 8

---

### OT2: Documentación Académica Completa

**Meta:**  
Producir documentación de grado universitario que cumpla con estándares de investigación aplicada, permitiendo posterior publicación en revista indexada.

**Entregables:**
- 6 documentos metodológicos (este es el 3° de 6)
- Artículo científico de 12-15 páginas
- Poster académico para congreso
- Repositorio de código fuente en GitHub

**Plazo:** Semana 6

---

### OT3: Demostración de Retorno de Inversión

**Meta:**  
Comprobar mediante mediciones reales durante 6 meses de operación que el sistema logra ahorros superiores a $70M COP (50% de ROI proyectado).

**Métricas a validar:**
- Reducción consumo energético en horario PICO: >35%
- Eliminación de bombeo durante lluvia: >90%
- Reducción de paradas no programadas: >70%
- Tiempo de resolución de alertas: <15 minutos promedio

**Plazo:** Octubre 2026 (informe final)

---

## 3.4 Matriz de Objetivos vs Indicadores

| Objetivo | Indicador Principal | Meta | Método de Medición |
|----------|---------------------|------|--------------------|
| **OE1** | Canales telemetría activos | 24 | Query BD: `COUNT(DISTINCT parameter_name × station_id)` |
| **OE2** | Variables meteorológicas | 12 | Query BD: `SELECT COUNT(*) FROM meteorological_data` |
| **OE3** | Reducción bombeo PICO | 40% | Comparar kWh PICO (antes vs después) × 100 |
| **OE4** | Widgets en dashboard | 25+ | Inspección manual + checklist |
| **OE5** | Canales de alerta activos | 3 | Verificación logs API (WhatsApp, Email, SMS) |
| **OE6** | Registros almacenados | >150M | Query BD: `SELECT SUM(rows) FROM all_tables` |
| **OE7** | Componentes reutilizados | 3+ | Documentación arquitectura |

---

## 3.5 Alineación con Requisitos del Cliente

| Requisito Cliente | Objetivo que lo Cumple | Sección Detalle |
|-------------------|------------------------|-----------------|
| "Reducir costos operativos" | OE3 (control automático) | Sección 3.2.3 |
| "Monitoreo en tiempo real" | OE1 + OE2 | Secciones 3.2.1 y 3.2.2 |
| "Alertas inmediatas" | OE5 | Sección 3.2.5 |
| "Integración con sistemas actuales" | OE7 | Sección 3.2.7 |
| "Interfaz amigable" | OE4 | Sección 3.2.4 |
| "Sin pérdida de datos" | OE6 | Sección 3.2.6 |

---

## 3.6 Conclusión

Los objetivos planteados son:

- ✅ **Específicos:** Cada objetivo detalla exactamente qué se va a lograr
- ✅ **Medibles:** Todos tienen indicadores cuantitativos claros
- ✅ **Alcanzables:** Tecnología y recursos están disponibles
- ✅ **Relevantes:** Alineados con necesidades reales de la empresa
- ✅ **Temporales:** Plazos definidos dentro de las 8 semanas de proyecto

**Resultado esperado:** Al cumplir 100% de objetivos específicos, se logrará el objetivo general de **reducir costos en 60% y aumentar confiabilidad en 95%**.

---

**Documento elaborado por:**  
Equipo de Desarrollo de Sistemas  
Promotora Palmera de Antioquia S.A.S.  
Febrero 2026
