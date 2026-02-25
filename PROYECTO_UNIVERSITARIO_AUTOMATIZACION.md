# PROYECTO DE AUTOMATIZACIÓN
## Sistema Integrado de Monitoreo y Control para Estaciones de Bombeo y Meteorológicas

---

## 1. PLANTEAMIENTO DEL PROBLEMA

### 1.1 Descripción de la Situación Actual

En las operaciones agroindustriales modernas, especialmente en cultivos de palma africana como los gestionados por Promotora Palmera de Antioquia, las estaciones de bombeo operan tradicionalmente de forma manual o semi-automática, sin integración con datos meteorológicos en tiempo real. Esta desconexión entre sistemas críticos genera múltiples ineficiencias operativas y económicas.

### 1.2 Problemas Identificados

**🔴 Monitoreo Reactivo:**
- Supervisión manual por turnos, generando brechas temporales sin vigilancia
- Detección tardía de fallas o anomalías en el sistema de bombeo
- Imposibilidad de conocer el estado en tiempo real sin presencia física

**🔴 Gestión Ineficiente de Recursos:**
- Operación de bombas sin considerar precipitaciones recientes o pronósticos
- Riego excesivo o deficiente por falta de datos climáticos integrados
- Consumo energético elevado por operación en horarios de alta tarifa

**🔴 Falta de Trazabilidad:**
- Ausencia de registro histórico de caudal, presión y consumo energético
- Sin correlación entre eventos climáticos y desempeño operativo
- Dificultad para planificar mantenimiento preventivo

**🔴 Respuesta Lenta a Emergencias:**
- Sin alertas automáticas por niveles críticos de presión o caudal
- Pérdida de producción por fallas no detectadas oportunamente
- Riesgo de daños mayores en equipos por falta de monitoreo continuo

**🔴 Desintegración de Sistemas:**
- Datos climáticos, bombeo y gestión operativa en plataformas separadas
- Decisiones basadas en información incompleta o desactualizada
- Duplicación de esfuerzos en recolección manual de datos

---

## 2. JUSTIFICACIÓN

### 2.1 Justificación Económica

**Reducción de Costos Operativos:**
- **40% de ahorro** en consumo energético mediante programación inteligente basada en demanda y tarifas
- **30% de reducción** en uso de agua al integrar datos de precipitación y humedad del suelo
- **25% menos** en costos de mantenimiento correctivo mediante gestión preventiva

**Retorno de Inversión:**
- Inversión inicial estimada: $8,000,000 - $12,000,000 COP
- Ahorro mensual proyectado: $1,500,000 COP
- ROI esperado: 6-8 meses

### 2.2 Justificación Ambiental

**Sostenibilidad Hídrica:**
- Optimización del uso de recursos hídricos mediante datos climáticos en tiempo real
- Reducción de escorrentía y contaminación por riego excesivo
- Contribución a certificaciones ambientales (ISO 14001, RSPO)

**Eficiencia Energética:**
- Menor huella de carbono por reducción de consumo eléctrico
- Operación en horarios de menor demanda energética del sistema nacional
- Potencial integración con energías renovables (solar/eólica)

### 2.3 Justificación Tecnológica

**Transformación Digital:**
- Aplicación práctica de tecnologías IoT en entornos agroindustriales
- Integración de sensores, telemetría y sistemas de gestión empresarial
- Generación de big data para análisis predictivo y machine learning

**Escalabilidad:**
- Sistema replicable en múltiples fincas (Administración, Playa, Plana, Bendición)
- Arquitectura modular que permite agregar nuevas estaciones
- Integración con sistemas existentes (PQRSF, Productividad PPA, Intranet)

### 2.4 Justificación Social

**Mejora en Condiciones Laborales:**
- Eliminación de tareas manuales repetitivas en campo
- Monitoreo remoto que reduce exposición a condiciones climáticas adversas
- Capacitación del personal en tecnologías de la Industria 4.0

**Gestión del Conocimiento:**
- Registro histórico que preserva conocimiento operativo
- Datos objetivos para toma de decisiones técnicas
- Base para investigación y desarrollo continuo

---

## 3. OBJETIVOS

### 3.1 Objetivo General

Diseñar e implementar un sistema IoT integrado que automatice el monitoreo y control de estaciones de bombeo, utilizando datos meteorológicos en tiempo real para optimizar el uso de recursos hídricos y energéticos en operaciones agroindustriales.

### 3.2 Objetivos Específicos

**OE1 - Telemetría de Bombeo:**
Implementar sensores de caudal, presión y consumo energético en estaciones de bombeo con transmisión de datos en tiempo real al sistema centralizado.

**OE2 - Estación Meteorológica:**
Instalar y configurar sensores de lluvia, viento, temperatura y humedad con envío automático de datos cada 5-10 minutos.

**OE3 - Sistema de Control Automatizado:**
Desarrollar lógica de control que active/desactive bombas según umbrales configurables de presión, nivel, clima y horarios tarifarios.

**OE4 - Dashboard Integrado:**
Crear interfaz web centralizada que visualice datos de bombeo, clima, alertas y KPIs operativos junto a sistemas existentes (PQRSF, PPA).

**OE5 - Sistema de Alertas:**
Implementar notificaciones automáticas por WhatsApp, email y SMS para eventos críticos (fallas, niveles anormales, clima adverso).

**OE6 - Registro Histórico:**
Almacenar y procesar datos históricos para análisis de tendencias, mantenimiento preventivo y optimización continua.

**OE7 - Integración Empresarial:**
Conectar el sistema de automatización con plataformas existentes de gestión (PQRSF, Intranet, Reportes) para visión holística.

---

## 4. ALCANCE DEL PROYECTO

### 4.1 Estaciones Cubiertas

**Fase 1 - Piloto (3 meses):**
- 1 estación de bombeo principal (Finca Administración)
- 1 estación meteorológica central

**Fase 2 - Expansión (6 meses):**
- 4 estaciones de bombeo adicionales (Playa, Plana, Bendición)
- 3 estaciones meteorológicas distribuidas

**Fase 3 - Consolidación (3 meses):**
- Análisis predictivo y machine learning
- Optimización automática de operación

### 4.2 Variables Monitoreadas

**Estaciones de Bombeo:**
- Caudal (L/min o m³/h)
- Presión de entrada y salida (PSI o bar)
- Consumo energético (kWh)
- Temperatura del motor (°C)
- Horas de operación acumuladas
- Estado operativo (ON/OFF/FALLA)

**Estaciones Meteorológicas:**
- Precipitación acumulada (mm)
- Velocidad y dirección del viento (km/h, grados)
- Temperatura ambiente (°C)
- Humedad relativa (%)
- Presión atmosférica (hPa)
- Radiación solar (opcional, W/m²)

### 4.3 Funcionalidades del Sistema

✅ Monitoreo 24/7 en tiempo real  
✅ Control remoto de encendido/apagado de bombas  
✅ Alertas configurables por umbrales  
✅ Registro histórico con mínimo 2 años de retención  
✅ Dashboard web responsive (PC/tablet/móvil)  
✅ Reportes automatizados semanales y mensuales  
✅ Integración con sistema PQRSF y PPA existente  
✅ Respaldo de datos en la nube  
✅ Sistema de permisos por roles de usuario  

---

## 5. MARCO TEÓRICO

### 5.1 Internet de las Cosas (IoT)

El Internet de las Cosas se refiere a la interconexión de dispositivos físicos mediante internet, permitiendo recolección, intercambio y análisis de datos en tiempo real. En aplicaciones agroindustriales, IoT transforma operaciones tradicionales en sistemas inteligentes y adaptativos.

**Componentes Clave:**
- **Sensores:** Dispositivos que miden variables físicas (presión, temperatura, caudal)
- **Conectividad:** Redes que transmiten datos (WiFi, LoRa, 4G/5G, Ethernet)
- **Procesamiento:** Análisis de datos en edge computing o en la nube
- **Actuadores:** Dispositivos que ejecutan acciones (relés, válvulas, motores)

### 5.2 Sistemas SCADA

SCADA (Supervisory Control and Data Acquisition) son plataformas que permiten supervisar y controlar procesos industriales de forma remota. Integran:
- Adquisición de datos de múltiples puntos
- Visualización en tiempo real (HMI - Human Machine Interface)
- Control supervisorio de equipos
- Registro histórico de eventos y alarmas

### 5.3 Telemetría y Telecontrol

**Telemetría:** Transmisión automática de mediciones desde ubicaciones remotas al sistema central.

**Telecontrol:** Capacidad de operar equipos remotamente desde un centro de control.

En este proyecto, ambas técnicas se integran para lograr gestión completa sin presencia física.

### 5.4 Agricultura de Precisión

Metodología que utiliza tecnología para optimizar producción agrícola mediante:
- Monitoreo detallado de condiciones del cultivo y clima
- Aplicación variable de insumos según necesidad real
- Decisiones basadas en datos cuantitativos
- Reducción de desperdicio y mejora de sostenibilidad

### 5.5 Estaciones Meteorológicas Automáticas

Sistemas que miden variables atmosféricas sin intervención humana:
- **Pluviómetros:** Miden precipitación acumulada
- **Anemómetros:** Velocidad y dirección del viento
- **Termo-higrómetros:** Temperatura y humedad relativa
- **Barómetros:** Presión atmosférica

Estos datos son críticos para:
- Programación de riego eficiente
- Predicción de condiciones adversas
- Correlación entre clima y productividad

---

## 6. METODOLOGÍA

### 6.1 Tipo de Investigación

**Investigación Aplicada:** El proyecto busca resolver un problema operacional concreto mediante aplicación de tecnología IoT, generando valor práctico inmediato.

**Investigación Experimental:** Se implementará un sistema piloto cuyos resultados se medirán y compararán con el método tradicional (antes/después).

### 6.2 Fases del Proyecto

#### **FASE 1: Análisis y Diseño (Mes 1-2)**

**Actividades:**
1. Levantamiento de información en campo
2. Identificación de puntos de instalación de sensores
3. Evaluación de infraestructura de red existente
4. Diseño de arquitectura del sistema (hardware + software)
5. Selección de componentes y proveedores
6. Diseño de dashboard e interfaces de usuario
7. Definición de protocolos de comunicación

**Entregables:**
- Documento de requisitos técnicos
- Diagramas de arquitectura
- Listado de materiales y presupuesto
- Cronograma detallado de implementación

#### **FASE 2: Adquisición e Instalación (Mes 2-3)**

**Actividades:**
1. Compra de sensores, controladores y equipos
2. Instalación de estación meteorológica piloto
3. Instalación de sensores en estación de bombeo
4. Cableado y conexión de red
5. Montaje de panel de control y relés
6. Pruebas de conectividad y comunicación

**Entregables:**
- Equipos instalados y operativos
- Diagramas de conexión eléctrica
- Registro fotográfico de instalación
- Manuales de equipos instalados

#### **FASE 3: Desarrollo de Software (Mes 3-5)**

**Actividades:**
1. Desarrollo de firmware para controladores (ESP32/Arduino)
2. Programación de lógica de control automático
3. Desarrollo de API backend para recepción de datos
4. Creación de base de datos para almacenamiento
5. Desarrollo de dashboard web integrado
6. Implementación de sistema de alertas (WhatsApp/Email/SMS)
7. Integración con sistemas existentes (PQRSF, Intranet)

**Entregables:**
- Código fuente documentado (GitHub)
- Dashboard funcional accesible vía web
- API REST documentada
- Base de datos estructurada

#### **FASE 4: Pruebas y Ajustes (Mes 5-6)**

**Actividades:**
1. Pruebas de funcionalidad de sensores
2. Calibración de mediciones vs. equipos de referencia
3. Pruebas de control automático (simulaciones)
4. Validación de alertas y notificaciones
5. Pruebas de carga y estrés del sistema
6. Ajustes de umbrales y parámetros
7. Capacitación a usuarios finales

**Entregables:**
- Protocolo de pruebas con resultados
- Certificados de calibración
- Manual de usuario
- Videos de capacitación

#### **FASE 5: Operación y Evaluación (Mes 6-12)**

**Actividades:**
1. Operación continua del sistema piloto
2. Recolección de datos operativos (6 meses mínimo)
3. Análisis comparativo antes/después
4. Medición de KPIs: consumo energético, uso de agua, fallas
5. Encuestas de satisfacción a usuarios
6. Documentación de lecciones aprendidas
7. Propuesta de mejoras y expansión

**Entregables:**
- Reporte de operación mensual
- Dashboard de KPIs comparativos
- Análisis costo-beneficio real
- Informe final del proyecto

### 6.3 Técnicas de Recolección de Datos

**Datos Primarios:**
- Mediciones directas de sensores (automáticas, cada 5-10 min)
- Observación participante durante instalación y operación
- Entrevistas con operadores y personal de mantenimiento
- Encuestas de satisfacción post-implementación

**Datos Secundarios:**
- Registros históricos de consumo energético
- Facturas de servicios públicos (agua, electricidad)
- Registros de mantenimiento correctivo previos
- Datos climáticos históricos de estaciones cercanas (IDEAM)

### 6.4 Indicadores de Éxito

| Indicador | Meta | Método de Medición |
|-----------|------|-------------------|
| Reducción consumo energético | ≥30% | Comparación kWh antes/después |
| Reducción uso de agua | ≥25% | Comparación m³ antes/después |
| Disponibilidad del sistema | ≥98% | Uptime mensual (logs automáticos) |
| Tiempo de respuesta a fallas | <15 min | Tiempo desde alerta hasta acción |
| Satisfacción de usuarios | ≥4/5 | Encuesta estructurada (escala Likert) |
| Reducción mantenimiento correctivo | ≥20% | Número de intervenciones de emergencia |

---

## 7. ARQUITECTURA DEL SISTEMA

### 7.1 Capa de Sensores (Edge Layer)

#### **Estación de Bombeo:**
- **Caudalímetro electromagnético:** Medición de flujo (ej: SITRANS FM MAG 5100W)
- **Transductores de presión:** Entrada y salida (ej: Siemens SITRANS P300, 0-10 bar)
- **Medidor de energía:** Consumo trifásico (ej: Schneider iEM3000)
- **Sensor de temperatura:** Motor/ambiente (ej: DS18B20)
- **Relés de estado sólido:** Control ON/OFF de bombas (25-40A)

#### **Estación Meteorológica:**
- **Pluviómetro de balancín:** Precipitación con resolución 0.2mm (ej: Davis Instruments)
- **Anemómetro:** Velocidad y dirección (ej: Inspeed Vortex)
- **Termo-higrómetro:** DHT22 o BME280 (±2% humedad, ±0.5°C temperatura)
- **Barómetro:** BMP280 (presión atmosférica)
- **Piranómetro (opcional):** Radiación solar

### 7.2 Capa de Control (Controller Layer)

**Controlador Principal:**
- **Opción 1:** ESP32 DevKit (WiFi/Bluetooth, bajo costo, ideal para prototipo)
- **Opción 2:** Raspberry Pi 4 (más capacidad de procesamiento, Python)
- **Opción 3:** PLC industrial (mayor robustez, entornos críticos)

**Funciones:**
- Lectura de sensores cada 5-10 minutos
- Ejecución de lógica de control (if-then-else, PID)
- Transmisión de datos al servidor vía MQTT/HTTP
- Recepción de comandos remotos
- Almacenamiento local temporal (backup)

**Protocolo de Comunicación:**
- MQTT (ideal para IoT, pub/sub, bajo ancho de banda)
- Broker: Mosquitto o HiveMQ Cloud
- Tópicos: `ppa/bombeo/finca1/caudal`, `ppa/clima/finca1/lluvia`

### 7.3 Capa de Red (Network Layer)

**Conectividad:**
- **Red primaria:** Ethernet (cable UTP Cat6) si hay infraestructura
- **Red secundaria:** WiFi (2.4GHz, mayor alcance) con repetidores si necesario
- **Respaldo:** 4G/LTE con módem USB o tarjeta SIM integrada (ESP32-CAM)

**Seguridad:**
- VPN (WireGuard o OpenVPN) para acceso remoto seguro
- Certificados SSL/TLS para encriptación de datos
- Autenticación por tokens (JWT)
- Firewall a nivel de red y aplicación

### 7.4 Capa de Aplicación (Application Layer)

#### **Backend (Servidor):**
- **Lenguaje:** Node.js (JavaScript) o Python (Flask/Django)
- **Base de datos:** MySQL (actual del sistema PPA) para datos estructurados
- **Base de datos de series temporales (opcional):** InfluxDB para métricas
- **Servidor web:** IIS (actual) o Apache/Nginx
- **Sistema operativo:** Windows Server (actual) o Linux

**Funcionalidades:**
- API REST para recibir datos de sensores (POST /api/telemetria)
- API para enviar comandos (POST /api/control/bomba/on)
- Procesamiento de reglas de alertas
- Generación de reportes automáticos
- Integración con BrevoEmailHelper (sistema actual de emails)

#### **Frontend (Dashboard Web):**
- **Framework:** HTML5 + CSS3 + JavaScript (vanilla o Vue.js)
- **Visualización de datos:** Chart.js (actual), D3.js o Highcharts
- **Diseño responsive:** Compatible PC, tablet, móvil
- **Integración:** Mismo diseño que dashboard PQRSF y PPA

**Pantallas Principales:**
1. **Vista General:** Mapa con estado de todas las estaciones
2. **Detalle de Bombeo:** Gráficos de caudal, presión, energía en tiempo real
3. **Clima:** Dashboard meteorológico con gráficos históricos
4. **Alertas:** Lista de eventos y notificaciones
5. **Reportes:** Exportación a PDF/Excel
6. **Configuración:** Umbrales, contactos, horarios

### 7.5 Integración con Sistemas Existentes

El sistema de automatización se integrará con:

**Sistema PQRSF:**
- Solicitudes de mantenimiento automáticas ante fallas
- Registro de incidencias operativas como PQRSF interno
- Dashboard unificado con PQRSF y automatización

**Sistema PPA (Productividad Palmera Antioquia):**
- Correlación de consumo hídrico/energético con producción
- KPIs operativos integrados en reportes PPA
- Análisis de eficiencia por finca

**Intranet Corporativa:**
- Acceso desde menú principal de intranet
- Permisos según roles de usuario (LDAP/Active Directory)
- Notificaciones integradas con sistema de avisos

---

## 8. DIAGRAMA DE ARQUITECTURA

```
┌─────────────────────────────────────────────────────────────────┐
│                        CAPA DE USUARIO                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │   PC     │  │  Tablet  │  │  Móvil   │  │ WhatsApp │       │
│  │Dashboard │  │Dashboard │  │Dashboard │  │ Alertas  │       │
│  └─────┬────┘  └─────┬────┘  └─────┬────┘  └─────┬────┘       │
└────────┼─────────────┼─────────────┼─────────────┼─────────────┘
         │             │             │             │
         └─────────────┴─────────────┴─────────────┘
                           │ HTTPS
         ┌─────────────────┴─────────────────┐
         │                                    │
┌────────▼───────────────────────────────────▼────────────────────┐
│                   CAPA DE APLICACIÓN                            │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              SERVIDOR WEB (IIS/Apache)                    │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │  │
│  │  │ Dashboard    │  │  API REST    │  │  Sistema de  │   │  │
│  │  │ Automatización│  │  Telemetría  │  │  Alertas     │   │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘   │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │  │
│  │  │ Integración  │  │ Generación   │  │  Control     │   │  │
│  │  │ PQRSF/PPA    │  │ Reportes     │  │  Remoto      │   │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘   │  │
│  └───────────────────────┬───────────────────────────────────┘  │
│                          │                                       │
│  ┌───────────────────────▼───────────────────────────────────┐  │
│  │            BASE DE DATOS (MySQL/InfluxDB)                 │  │
│  │  - Telemetría histórica    - Alertas y eventos            │  │
│  │  - Configuración umbrales  - Usuarios y permisos          │  │
│  └───────────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────────┘
                           │ MQTT/HTTP
         ┌─────────────────┴─────────────────┐
         │                                    │
┌────────▼───────────────────────────────────▼────────────────────┐
│                   CAPA DE RED                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Ethernet     │  │  WiFi 2.4GHz │  │  4G/LTE      │         │
│  │ (Cable UTP)  │  │  (Repetidor) │  │  (Backup)    │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└──────────────────────────┬──────────────────────────────────────┘
                           │
         ┌─────────────────┴─────────────────┐
         │                                    │
┌────────▼─────────────────┐  ┌──────────────▼──────────────────┐
│   ESTACIÓN DE BOMBEO     │  │  ESTACIÓN METEOROLÓGICA         │
│  ┌───────────────────┐   │  │  ┌───────────────────┐          │
│  │ Controlador       │   │  │  │ Controlador       │          │
│  │ ESP32/Raspberry Pi│   │  │  │ ESP32/Arduino     │          │
│  └─────┬─────────────┘   │  │  └─────┬─────────────┘          │
│        │                 │  │        │                         │
│  ┌─────▼─────────────┐   │  │  ┌─────▼─────────────┐          │
│  │ SENSORES:         │   │  │  │ SENSORES:         │          │
│  │ - Caudalímetro    │   │  │  │ - Pluviómetro     │          │
│  │ - Transductor     │   │  │  │ - Anemómetro      │          │
│  │   presión         │   │  │  │ - Termo-higrómetro│          │
│  │ - Medidor energía │   │  │  │ - Barómetro       │          │
│  │ - Temperatura     │   │  │  │ - Piranómetro     │          │
│  └───────────────────┘   │  │  └───────────────────┘          │
│  ┌───────────────────┐   │  │                                 │
│  │ ACTUADORES:       │   │  │                                 │
│  │ - Relés ON/OFF    │   │  │                                 │
│  │ - Válvulas (opc.) │   │  │                                 │
│  └───────────────────┘   │  │                                 │
└──────────────────────────┘  └─────────────────────────────────┘
```

---

## 9. COMPONENTES Y PRESUPUESTO

### 9.1 Hardware - Estación de Bombeo

| Componente | Especificaciones | Cantidad | Precio Unit. | Total |
|------------|------------------|----------|--------------|-------|
| ESP32 DevKit | WiFi/BT, 240MHz, 4MB | 1 | $35,000 | $35,000 |
| Caudalímetro electromagnético | 0-100 m³/h, 4-20mA | 1 | $1,200,000 | $1,200,000 |
| Transductor presión entrada | 0-10 bar, 4-20mA | 1 | $350,000 | $350,000 |
| Transductor presión salida | 0-10 bar, 4-20mA | 1 | $350,000 | $350,000 |
| Medidor energía trifásico | Modbus RTU, LCD | 1 | $450,000 | $450,000 |
| Sensor temperatura DS18B20 | -55°C a +125°C | 2 | $15,000 | $30,000 |
| Relé estado sólido 40A | 3-32VDC in, 480VAC out | 2 | $85,000 | $170,000 |
| Módulo 4-20mA a digital | ADC 16-bit | 3 | $45,000 | $135,000 |
| Gabinete IP65 | Policarbonato 300x400mm | 1 | $180,000 | $180,000 |
| Fuente 12V 5A | Switching, protecciones | 1 | $55,000 | $55,000 |
| Cables y conectores | Cable apantallado, borneras | - | $120,000 | $120,000 |
| **SUBTOTAL BOMBEO** | | | | **$3,075,000** |

### 9.2 Hardware - Estación Meteorológica

| Componente | Especificaciones | Cantidad | Precio Unit. | Total |
|------------|------------------|----------|--------------|-------|
| ESP32 DevKit | WiFi/BT, 240MHz, 4MB | 1 | $35,000 | $35,000 |
| Pluviómetro basculante | Resolución 0.2mm, salida pulsos | 1 | $280,000 | $280,000 |
| Anemómetro digital | 0-180 km/h, dirección 16 puntos | 1 | $420,000 | $420,000 |
| Sensor BME280 | Temp/Hum/Presión, I2C | 1 | $35,000 | $35,000 |
| Piranómetro (opcional) | 0-1500 W/m², 0-5V | 1 | $650,000 | $650,000 |
| Poste meteorológico | 3m altura, acero galvanizado | 1 | $320,000 | $320,000 |
| Panel solar 20W | 12V, regulador carga incluido | 1 | $150,000 | $150,000 |
| Batería 12V 18Ah | AGM, ciclo profundo | 1 | $180,000 | $180,000 |
| Gabinete IP65 exterior | Policarbonato 250x300mm | 1 | $160,000 | $160,000 |
| Cables y conectores | Exterior, UV-resistente | - | $80,000 | $80,000 |
| **SUBTOTAL CLIMA** | | | | **$2,310,000** |

### 9.3 Infraestructura de Red

| Componente | Especificaciones | Cantidad | Precio Unit. | Total |
|------------|------------------|----------|--------------|-------|
| Switch PoE 8 puertos | Gigabit, 802.3af | 1 | $280,000 | $280,000 |
| Repetidor WiFi exterior | 2.4GHz, IP67, 300m alcance | 2 | $120,000 | $240,000 |
| Cable UTP Cat6 exterior | Caja 305m, negro | 1 | $450,000 | $450,000 |
| Conectores RJ45 Cat6 | Blindados | 20 | $3,000 | $60,000 |
| Módem 4G backup | Huawei E3372, SIM | 1 | $180,000 | $180,000 |
| Canaleta exterior | 2x2 pulgadas | 100m | $8,000 | $800,000 |
| **SUBTOTAL RED** | | | | **$2,010,000** |

### 9.4 Software y Servicios

| Ítem | Descripción | Cantidad | Precio Unit. | Total |
|------|-------------|----------|--------------|-------|
| Dominio y SSL | .com + certificado anual | 1 año | $120,000 | $120,000 |
| Hosting/VPS Cloud | 4GB RAM, 80GB SSD (DigitalOcean) | 12 meses | $80,000 | $960,000 |
| Plan SMS | 1000 SMS/mes (Twilio) | 6 meses | $150,000 | $900,000 |
| WhatsApp Business API | 1000 mensajes/mes | 6 meses | $180,000 | $1,080,000 |
| Base datos InfluxDB Cloud | 10GB almacenamiento | 12 meses | $60,000 | $720,000 |
| **SUBTOTAL SOFTWARE** | | | | **$3,780,000** |

### 9.5 Instalación y Puesta en Marcha

| Ítem | Descripción | Cantidad | Precio | Total |
|------|-------------|----------|--------|-------|
| Mano de obra instalación | Técnico electricista | 5 días | $150,000 | $750,000 |
| Mano de obra programación | Ingeniero software | 10 días | $250,000 | $2,500,000 |
| Calibración sensores | Equipo de referencia | 1 servicio | $800,000 | $800,000 |
| Capacitación usuarios | 10 personas, 4 horas | 1 sesión | $450,000 | $450,000 |
| Documentación técnica | Manuales e instructivos | 1 lote | $300,000 | $300,000 |
| **SUBTOTAL INSTALACIÓN** | | | | **$4,800,000** |

### 9.6 PRESUPUESTO TOTAL

| Categoría | Subtotal |
|-----------|----------|
| Hardware Bombeo | $3,075,000 |
| Hardware Clima | $2,310,000 |
| Infraestructura Red | $2,010,000 |
| Software y Servicios | $3,780,000 |
| Instalación | $4,800,000 |
| **TOTAL INVERSIÓN** | **$15,975,000** |
| Imprevistos (10%) | $1,597,500 |
| **TOTAL CON IMPREVISTOS** | **$17,572,500** |

**Nota:** Precios en COP (pesos colombianos) estimados a febrero de 2026.

---

## 10. CRONOGRAMA (Diagrama de Gantt)

```
ACTIVIDAD                    │MES 1│MES 2│MES 3│MES 4│MES 5│MES 6│MES 7-12│
─────────────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼────────┤
Análisis y Diseño            │████ │     │     │     │     │     │        │
Adquisición de equipos       │     │████ │     │     │     │     │        │
Instalación hardware         │     │ ████│███  │     │     │     │        │
Desarrollo firmware          │     │     │ ████│███  │     │     │        │
Desarrollo backend           │     │     │  ███│████ │     │     │        │
Desarrollo dashboard         │     │     │     │ ████│███  │     │        │
Sistema de alertas           │     │     │     │  ███│████ │     │        │
Pruebas y calibración        │     │     │     │     │ ████│███  │        │
Capacitación usuarios        │     │     │     │     │     │ ███ │        │
Operación piloto             │     │     │     │     │     │  ███│████████│
Evaluación y reportes        │     │     │     │     │     │     │    ████│
```

---

## 11. RESULTADOS ESPERADOS

### 11.1 Productos Tangibles

**📦 Entregables Técnicos:**
1. Sistema de telemetría instalado y operativo en 1 estación de bombeo
2. Estación meteorológica automática funcional
3. Dashboard web responsive integrado con sistemas PPA
4. API REST documentada (Swagger/OpenAPI)
5. Base de datos estructurada con 6 meses de datos históricos
6. Sistema de alertas multi-canal (WhatsApp, Email, SMS)

**📄 Entregables Documentales:**
1. Manual técnico de instalación y mantenimiento
2. Manual de usuario del dashboard
3. Protocolos de calibración de sensores
4. Diagramas eléctricos y de conexión
5. Código fuente comentado en repositorio GitHub
6. Informe final con análisis costo-beneficio real

### 11.2 Indicadores de Impacto

| Indicador | Línea Base | Meta | Método de Verificación |
|-----------|------------|------|------------------------|
| **Consumo energético** | 100% | ≤70% | Facturas energéticas comparadas |
| **Consumo hídrico** | 100% | ≤75% | Medición caudalímetro vs. histórico |
| **Disponibilidad bombeo** | 94% | ≥98% | Logs de operación automáticos |
| **Fallas por mes** | 3-4 | ≤1 | Registro de mantenimiento |
| **Tiempo respuesta fallas** | 45 min | ≤15 min | Timestamp alertas vs. acción |
| **Satisfacción usuarios** | N/A | ≥4/5 | Encuesta post-implementación |

### 11.3 Contribución Científica

**Artículos y Publicaciones:**
- Ponencia en congreso nacional de ingeniería agroindustrial
- Artículo en revista científica sobre IoT en agricultura

**Conocimiento Generado:**
- Dataset de 6-12 meses de datos climáticos y operativos
- Modelos predictivos de consumo basados en clima
- Correlación entre variables meteorológicas y desempeño de bombeo

**Transferencia Tecnológica:**
- Sistema replicable en otras empresas del sector palmicultor
- Código abierto disponible en GitHub para comunidad académica
- Casos de estudio para cursos de IoT y automatización

---

## 12. ANÁLISIS DE RIESGOS

### 12.1 Matriz de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| **Falla de conectividad** | Media | Alto | Sistema de backup 4G, almacenamiento local temporal |
| **Daño por rayos** | Baja | Alto | Supresores de transientes, puesta a tierra adecuada |
| **Incompatibilidad sensores** | Baja | Medio | Validación técnica previa, compra a proveedores confiables |
| **Retraso en entrega equipos** | Media | Medio | Adelantar compras, proveedores alternativos identificados |
| **Resistencia al cambio** | Media | Medio | Capacitación temprana, involucrar usuarios desde diseño |
| **Sobrecostos** | Media | Medio | Buffer 10% incluido, priorización de funcionalidades core |
| **Ciberseguridad** | Baja | Alto | VPN, encriptación, autenticación robusta, auditorías |
| **Fallo de energía** | Alta | Medio | UPS para equipos críticos, panel solar en estación clima |

### 12.2 Plan de Contingencia

**Conectividad:**
- Si falla WiFi → activación automática de respaldo 4G
- Si falla todo → datos almacenados localmente, sincronización posterior

**Hardware:**
- Inventario de sensores críticos de repuesto (caudalímetro, relés)
- Contacto directo con proveedores para soporte técnico

**Software:**
- Respaldos automáticos diarios de base de datos
- Repositorio de código en GitHub con control de versiones
- Documentación completa para recuperación rápida

---

## 13. SOSTENIBILIDAD DEL PROYECTO

### 13.1 Sostenibilidad Técnica

**Mantenimiento Preventivo:**
- Limpieza trimestral de sensores expuestos (pluviómetro, anemómetro)
- Calibración anual de caudalímetro y transductores de presión
- Revisión semestral de conexiones eléctricas y cableado

**Escalabilidad:**
- Arquitectura modular permite agregar estaciones sin rediseño
- Base de datos escalable horizontalmente (sharding si necesario)
- API RESTful facilita integración con nuevos sistemas

### 13.2 Sostenibilidad Económica

**Costos Operativos Anuales:**
- Hosting/VPS Cloud: $960,000
- SMS/WhatsApp: $2,160,000
- Mantenimiento preventivo: $1,200,000
- **Total anual:** $4,320,000

**Ahorro Proyectado Anual:**
- Energía eléctrica (40%): $18,000,000
- Agua (30%): $9,000,000
- Mantenimiento correctivo (25%): $4,500,000
- **Total ahorro:** $31,500,000

**ROI:** (Ahorro - Costo operativo) / Inversión = ($31.5M - $4.3M) / $17.6M = **155% anual**

**Recuperación:** 7-8 meses aproximadamente

### 13.3 Sostenibilidad Ambiental

- Reducción de 12 toneladas CO₂/año por menor consumo energético
- Ahorro de 15,000 m³ de agua anualmente
- Contribución a certificación RSPO (Roundtable on Sustainable Palm Oil)
- Datos para reportes de sostenibilidad corporativa

### 13.4 Transferencia de Conocimiento

**Capacitación Continua:**
- Sesiones trimestrales de actualización para usuarios
- Documentación viva en wiki interna
- Videos tutoriales alojados en intranet

**Apropiación Institucional:**
- Equipo interno formado en mantenimiento básico
- Protocolo de soporte técnico definido (L1, L2, L3)
- Presupuesto anual asignado para mejoras

---

## 14. REFERENCIAS BIBLIOGRÁFICAS

1. **Atzori, L., Iera, A., & Morabito, G.** (2010). The Internet of Things: A survey. *Computer Networks*, 54(15), 2787-2805.

2. **Gubbi, J., Buyya, R., Marusic, S., & Palaniswami, M.** (2013). Internet of Things (IoT): A vision, architectural elements, and future directions. *Future Generation Computer Systems*, 29(7), 1645-1660.

3. **Zamora-Izquierdo, M. A., Santa, J., Martínez, J. A., Martínez, V., & Skarmeta, A. F.** (2019). Smart farming IoT platform based on edge and cloud computing. *Biosystems Engineering*, 177, 4-17.

4. **Kaloxylos, A., Eigenmann, R., Teye, F., et al.** (2012). Farm management systems and the Future Internet era. *Computers and Electronics in Agriculture*, 89, 130-144.

5. **Ojha, T., Misra, S., & Raghuwanshi, N. S.** (2015). Wireless sensor networks for agriculture: The state-of-the-art in practice and future challenges. *Computers and Electronics in Agriculture*, 118, 66-84.

6. **Wolfert, S., Ge, L., Verdouw, C., & Bogaardt, M. J.** (2017). Big Data in Smart Farming – A review. *Agricultural Systems*, 153, 69-80.

7. **Tzounis, A., Katsoulas, N., Bartzanas, T., & Kittas, C.** (2017). Internet of Things in agriculture, recent advances and future challenges. *Biosystems Engineering*, 164, 31-48.

8. **Ferreira, L., Putnik, G., Cunha, M., Putnik, Z., Castro, H., Fontana, R. D. B., & Carmo-Silva, S.** (2023). Internet of Things and Smart Farming: Opportunities and Challenges. *International Journal of Networked and Distributed Computing*, 11(1), 48-67.

9. **Prabha, R., Sinitambirivoutin, E., Passelaigue, I., & Ramesh, M. V.** (2021). IoT based automated irrigation system using ESP8266 and Raspberry Pi. *Journal of Physics: Conference Series*, 1964(4), 042011.

10. **FAO.** (2020). *E-agriculture in action: Drones for agriculture*. Food and Agriculture Organization of the United Nations.

11. **Siemens AG.** (2024). *SCADA Systems - Supervisory Control and Data Acquisition*. Technical Documentation.

12. **IDEAM.** (2025). *Estaciones Meteorológicas Automáticas en Colombia - Guía Técnica*. Instituto de Hidrología, Meteorología y Estudios Ambientales.

13. **MQTT.org.** (2024). *MQTT Version 5.0 Specification*. OASIS Standard.

14. **Eclipse Foundation.** (2024). *Eclipse Mosquitto - An open source MQTT broker*. Documentation.

15. **InfluxData.** (2025). *InfluxDB Documentation - Time Series Database*. Technical Guide.

---

## 15. ANEXOS

### ANEXO A: Diagramas de Flujo

**A.1 Flujo de Datos - Telemetría**
```
[Sensor] → [Lectura cada 5min] → [Validación local] → 
→ [Envío MQTT] → [Broker] → [Backend] → [Base Datos] → 
→ [Dashboard (actualización en vivo)]
```

**A.2 Flujo de Control - Alerta Automática**
```
[Sensor lee presión baja] → [Comparación con umbral] → 
→ [Si < umbral] → [Genera alerta] → [API Alertas] → 
→ [Envío simultáneo: WhatsApp + Email + SMS] → 
→ [Registro en BD] → [Notificación en dashboard]
```

**A.3 Flujo de Control Automático - Bomba**
```
[Decisión cada 10min]
    ↓
[Verificar: Nivel tanque]
    ↓
[Verificar: Presión red]
    ↓
[Verificar: Lluvia últimas 2h]
    ↓
[Verificar: Horario tarifario]
    ↓
[SI: nivel<50% AND presión>30 PSI AND lluvia<5mm AND tarifa=baja]
    ↓
[Activar Relé → Bomba ON]
[SINO]
    ↓
[Desactivar Relé → Bomba OFF]
```

### ANEXO B: Código de Ejemplo

**B.1 Lectura de Sensor (Arduino/ESP32)**
```cpp
// Lectura de caudalímetro con pulsos
volatile int pulseCount = 0;
float caudal = 0.0;

void IRAM_ATTR pulseCounter() {
  pulseCount++;
}

void setup() {
  pinMode(SENSOR_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(SENSOR_PIN), pulseCounter, FALLING);
}

void loop() {
  delay(1000); // Esperar 1 segundo
  
  detachInterrupt(digitalPinToInterrupt(SENSOR_PIN));
  caudal = (pulseCount / 7.5); // L/min según calibración
  pulseCount = 0;
  attachInterrupt(digitalPinToInterrupt(SENSOR_PIN), pulseCounter, FALLING);
  
  enviarMQTT("ppa/bombeo/finca1/caudal", caudal);
}
```

**B.2 API REST - Recepción de Datos (Node.js)**
```javascript
const express = require('express');
const mysql = require('mysql2/promise');
const app = express();

app.use(express.json());

app.post('/api/telemetria', async (req, res) => {
  const { estacion, variable, valor, timestamp } = req.body;
  
  const connection = await mysql.createConnection({
    host: 'localhost',
    user: 'ppa_user',
    password: 'password',
    database: 'promotorapalmera_db'
  });
  
  await connection.execute(
    'INSERT INTO telemetria (estacion, variable, valor, timestamp) VALUES (?, ?, ?, ?)',
    [estacion, variable, valor, timestamp]
  );
  
  // Verificar umbrales y generar alertas si necesario
  verificarUmbrales(estacion, variable, valor);
  
  res.json({ success: true, message: 'Datos recibidos' });
});

app.listen(3000, () => console.log('API corriendo en puerto 3000'));
```

### ANEXO C: Especificaciones Técnicas Detalladas

**C.1 Caudalímetro Electromagnético**
- Principio: Ley de Faraday
- Rango: 0-100 m³/h
- Precisión: ±0.5% del valor medido
- Salida: 4-20 mA (aislada)
- Alimentación: 24 VDC
- Protección: IP67

**C.2 Transductor de Presión**
- Tipo: Piezorresistivo
- Rango: 0-10 bar
- Precisión: ±0.25% FS
- Salida: 4-20 mA
- Compensación: Temperatura -10°C a +80°C
- Roscado: G1/2"

**C.3 ESP32 DevKit**
- MCU: Xtensa dual-core 32-bit LX6 @240MHz
- RAM: 520 KB SRAM
- Flash: 4 MB
- WiFi: 802.11 b/g/n (2.4 GHz)
- Bluetooth: v4.2 BR/EDR y BLE
- GPIO: 34 pines programables
- ADC: 18 canales de 12 bits
- Consumo: 80 mA activo, 5 µA deep sleep

### ANEXO D: Glosario

- **4-20 mA:** Señal analógica estándar industrial (4mA=0%, 20mA=100%)
- **ADC:** Analog-to-Digital Converter (conversor analógico-digital)
- **API REST:** Application Programming Interface - Representational State Transfer
- **Edge Computing:** Procesamiento de datos cerca de la fuente (sensor)
- **HMI:** Human-Machine Interface (interfaz humano-máquina)
- **IoT:** Internet of Things (Internet de las Cosas)
- **MQTT:** Message Queuing Telemetry Transport (protocolo de mensajería)
- **PLC:** Programmable Logic Controller (controlador lógico programable)
- **RSPO:** Roundtable on Sustainable Palm Oil
- **SCADA:** Supervisory Control and Data Acquisition
- **Telemetría:** Medición y transmisión automática de datos remotos
- **Uptime:** Tiempo de disponibilidad operativa de un sistema

---

## CONCLUSIONES

Este proyecto de automatización de estaciones de bombeo y meteorológicas representa una oportunidad significativa para aplicar tecnologías de la Industria 4.0 en el sector agroindustrial colombiano. 

Los beneficios esperados trascienden lo meramente económico, generando impacto ambiental positivo mediante uso eficiente de recursos naturales, y social al mejorar condiciones laborales y desarrollar capacidades técnicas del personal.

La integración con sistemas empresariales existentes (PQRSF, PPA, Intranet) garantiza visión holística de la operación, facilitando toma de decisiones informadas basadas en datos cuantitativos y en tiempo real.

El diseño modular y escalable permite replicación en otras unidades productivas, multiplicando el impacto del proyecto. La documentación completa y código abierto contribuyen a la democratización del conocimiento tecnológico en el sector.

Con un ROI superior al 150% anual y recuperación de inversión en menos de 8 meses, el proyecto es financieramente viable y técnicamente factible con tecnología disponible comercialmente.

---

**Elaborado por:** [Tu Nombre]  
**Programa Académico:** [Tu Carrera]  
**Universidad:** [Tu Universidad]  
**Fecha:** 3 de febrero de 2026

---

*Nota: Este documento está basado en la implementación real del sistema de gestión de Promotora Palmera de Antioquia, adaptando la sección de automatización existente para fines académicos.*
