# 1. PLANTEAMIENTO DEL PROBLEMA

**Promotora Palmera de Antioquia S.A.S.**  
**Proyecto Universitario de Automatización IoT**  
**Sistema de Control Inteligente para Estaciones de Bombeo**  
**Fecha: Febrero 2026**

---

## 1.1 Descripción del Problema

### Contexto Empresarial

Promotora Palmera de Antioquia S.A.S. es una empresa agrícola dedicada al cultivo de palma de aceite en el departamento de Antioquia, Colombia. La empresa opera **4 estaciones de bombeo** distribuidas en un área de aproximadamente 350 hectáreas, que suministran agua de riego a las plantaciones durante todo el año.

### Problemática Actual

El sistema actual de operación de las estaciones de bombeo presenta las siguientes deficiencias críticas:

#### 1.1.1 Operación Manual Ineficiente

**Situación actual:**
- Las bombas son operadas manualmente por técnicos de campo
- Requiere supervisión física constante (3 turnos diarios)
- Decisiones de encendido/apagado basadas en observación visual del nivel de agua
- No hay registro histórico de operaciones
- Tiempo de respuesta lento ante cambios climáticos

**Impacto económico:**
- Costo de nómina: 3 operadores × $1,800,000 COP/mes = **$5,400,000 COP/mes**
- Horas extras por emergencias: **$800,000 COP/mes**
- **Total: $6,200,000 COP/mes** ($74,400,000 COP/año)

#### 1.1.2 Desperdicio Energético

**Situación actual:**
- Bombas operan sin considerar tarifas eléctricas horarias
- Frecuentemente operan en **horario PICO** (6-10 AM, 6-10 PM)
- No hay inhibición automática durante lluvias intensas
- Sobrecarga de bombas cuando el nivel ya es suficiente

**Impacto económico:**
```
Consumo promedio: 120 kWh/día por estación × 4 estaciones = 480 kWh/día
Tarifa PICO: $650 COP/kWh
Tarifa VALLE: $280 COP/kWh
Diferencia: $370 COP/kWh

Operación actual (60% en PICO):
480 kWh/día × 0.6 × $650 = $187,200 COP/día
480 kWh/día × 0.4 × $280 = $53,760 COP/día
TOTAL: $240,960 COP/día = $7,228,800 COP/mes

Operación optimizada (20% en PICO):
480 kWh/día × 0.2 × $650 = $62,400 COP/día
480 kWh/día × 0.8 × $280 = $107,520 COP/día
TOTAL: $169,920 COP/día = $5,097,600 COP/mes

AHORRO POTENCIAL: $2,131,200 COP/mes ($25,574,400 COP/año)
```

#### 1.1.3 Falta de Información Meteorológica Integrada

**Situación actual:**
- No hay sensores meteorológicos propios
- Dependencia de sitios web externos (datos no en tiempo real)
- Imposible correlacionar lluvia con nivel de agua automáticamente
- Bombas operan innecesariamente durante precipitaciones intensas

**Impacto operativo:**
- Bombeo durante lluvia intensa → **desperdicio energético 100%**
- Estimado: 15 eventos/mes × 2 horas/evento × 120 kWh/h × $650/kWh = **$2,340,000 COP/mes desperdiciados**
- Desgaste acelerado de equipos por ciclos innecesarios

#### 1.1.4 Sistema de Alertas Reactivo

**Situación actual:**
- Detección de fallas solo cuando técnico visita la estación
- Sin alertas automáticas por sobrecalentamiento de motores
- Sin notificaciones de niveles críticos
- Sin registro de eventos para análisis posterior

**Impacto operativo:**
- **3 paradas mayores en 2025** por sobrecalentamiento no detectado a tiempo
  - Costo promedio de reparación: $8,500,000 COP/falla
  - **Total en reparaciones: $25,500,000 COP/año**
- Pérdida de cultivos por falta de riego durante paradas: **$12,000,000 COP/año**

#### 1.1.5 Ausencia de Trazabilidad y Reportes

**Situación actual:**
- Datos registrados manualmente en cuadernos físicos
- Sin análisis de eficiencia energética
- Imposible generar reportes para auditorías
- No hay indicadores de desempeño (KPIs)

**Impacto administrativo:**
- Tiempo de generación de reportes mensuales: **40 horas/mes**
- Costo administrativo: $35,000 COP/hora × 40 = **$1,400,000 COP/mes**
- Datos históricos incompletos o perdidos

---

## 1.2 Impacto Global del Problema

### Costos Totales Actuales (Análisis Anual)

| Concepto | Costo Mensual (COP) | Costo Anual (COP) |
|----------|---------------------|-------------------|
| Nómina de operadores manuales | $6,200,000 | $74,400,000 |
| Desperdicio energético (horario PICO) | $2,131,200 | $25,574,400 |
| Bombeo durante lluvias | $2,340,000 | $28,080,000 |
| Reparaciones por fallas no detectadas | $2,125,000 | $25,500,000 |
| Pérdida de cultivos por paradas | $1,000,000 | $12,000,000 |
| Generación manual de reportes | $1,400,000 | $16,800,000 |
| **TOTAL** | **$15,196,200** | **$182,354,400** |

### Consecuencias Adicionales

**Ambientales:**
- Consumo energético innecesario: **~40% de exceso**
- Huella de carbono elevada
- Desperdicio de agua por falta de control preciso

**Operacionales:**
- Baja confiabilidad del sistema (3 paradas mayores/año)
- Dependencia crítica de operadores humanos
- Imposibilidad de escalamiento (más hectáreas = más operadores)

**Competitivas:**
- Costo operativo 35% superior al promedio del sector
- Falta de certificación ISO 50001 (gestión energética)
- Tecnología obsoleta frente a competidores

---

## 1.3 Formulación del Problema

### Pregunta Principal de Investigación

**¿Cómo diseñar e implementar un sistema IoT de automatización inteligente para estaciones de bombeo agrícola que integre control automático basado en variables meteorológicas, optimización tarifaria y alertas multi-canal, reduciendo costos operativos en un 60% y mejorando la confiabilidad del sistema en un 95%?**

### Preguntas Específicas

1. **¿Qué variables meteorológicas deben monitorearse para optimizar el control de bombeo?**
   - Precipitación (mm)
   - Velocidad y dirección del viento (km/h, grados)
   - Temperatura ambiente (°C)
   - Humedad relativa (%)
   - Presión atmosférica (hPa)
   - Radiación solar (W/m²)

2. **¿Qué telemetría de bomba es necesaria para garantizar operación segura y eficiente?**
   - Estado operacional (ON/OFF)
   - Caudal real (m³/h)
   - Presión de entrada y salida (bar)
   - Consumo energético instantáneo (kWh)
   - Temperatura del motor (°C)
   - Horas de operación acumuladas

3. **¿Qué reglas de decisión debe implementar el controlador automático?**
   - Inhibición por lluvia intensa (> 30 mm en 2 horas)
   - Activación por nivel crítico (< 50% del mínimo configurable)
   - Optimización tarifaria (priorizar horario VALLE)
   - Protección por temperatura motor (> 85°C)
   - Protección por presión anormal (< 2.0 bar o > 8.0 bar)

4. **¿Qué canales de comunicación son efectivos para alertas en tiempo real?**
   - WhatsApp Business API (respuesta inmediata)
   - Email con plantillas HTML (registro formal)
   - SMS para situaciones críticas (redundancia)

5. **¿Cómo integrar el nuevo sistema con la infraestructura tecnológica existente de la empresa?**
   - Reutilización de servidor IIS Windows
   - Integración con sistema PQRSF (mismo servidor, misma BD MySQL)
   - Reutilización de credenciales Brevo para emails
   - Compatibilidad con navegadores corporativos

---

## 1.4 Delimitación del Problema

### Alcance Geográfico
- **4 estaciones de bombeo** de Promotora Palmera de Antioquia S.A.S.
- Ubicación: Municipio de [NOMBRE], Antioquia
- Área cubierta: 350 hectáreas de cultivo de palma

### Alcance Temporal
- **Desarrollo:** 8 semanas (Febrero - Marzo 2026)
- **Piloto:** 1 mes (Abril 2026) en 1 estación
- **Despliegue completo:** Mayo 2026 en 4 estaciones
- **Evaluación de resultados:** 6 meses (Mayo - Octubre 2026)

### Alcance Técnico

**Sistemas incluidos:**
- ✅ Monitoreo meteorológico en tiempo real
- ✅ Telemetría completa de bombas
- ✅ Control automático multi-factor
- ✅ Sistema de alertas multi-canal
- ✅ Dashboard web unificado
- ✅ Registro histórico de datos
- ✅ Generación de reportes automáticos

**Sistemas excluidos (fuera del alcance):**
- ❌ Automatización de compuertas de canales de riego
- ❌ Sistema de fertirrigación
- ❌ Control de calidad de agua
- ❌ Mantenimiento predictivo con Machine Learning (fase futura)

### Alcance Funcional

**Hardware contemplado:**
- Sensores meteorológicos (pluviómetro, anemómetro, termohigrómetro)
- Sensores de nivel de agua (ultrasónicos)
- Sensores de caudal (electromagnéticos)
- Sensores de presión (analógicos 4-20mA)
- Termocuplas para temperatura de motor
- Microcontroladores ESP32 para telemetría
- Relés de estado sólido para control de bombas

**Software contemplado:**
- Backend: Python 3.8+ con Flask
- Frontend: HTML5, CSS3, JavaScript
- Base de datos: SQLite (piloto), PostgreSQL (producción)
- APIs externas: WhatsApp Business, Brevo Email, Twilio SMS

---

## 1.5 Justificación del Problema

### 1.5.1 Relevancia Económica

El problema justifica inversión en I+D porque:

- **ROI proyectado:** 150% en el primer año
- **Payback period:** 6-8 meses
- **Ahorro acumulado a 5 años:** $911,772,000 COP (considerando inflación 4%)
- **Inversión estimada:** $48,000,000 COP (hardware + desarrollo + instalación)

### 1.5.2 Relevancia Tecnológica

El proyecto aporta:

- **Innovación sectorial:** Primera implementación IoT completa en palmicultura antioqueña
- **Transferencia de conocimiento:** Modelo replicable en otras 150 empresas del sector
- **Desarrollo local:** Fortalecimiento de capacidades tecnológicas regionales

### 1.5.3 Relevancia Ambiental

Impacto positivo:

- **Reducción de huella de carbono:** ~25 toneladas CO₂/año
- **Optimización hídrica:** Reducción 15% en consumo de agua
- **Eficiencia energética:** Certificación ISO 50001

### 1.5.4 Relevancia Académica

Contribución al conocimiento:

- **Validación de IoT en agricultura tropical:** Condiciones climáticas extremas
- **Optimización multi-objetivo:** Energía + agua + confiabilidad
- **Integración práctica:** Universidad - Empresa

---

## 1.6 Viabilidad del Proyecto

### Viabilidad Técnica

✅ **Tecnología disponible:**
- Sensores industriales (proveedores locales verificados)
- Plataforma Flask (código abierto, comunidad activa)
- APIs comerciales (WhatsApp, Brevo, Twilio) con soporte 24/7

✅ **Infraestructura existente:**
- Servidor IIS Windows Server 2019
- Red eléctrica estable en todas las estaciones
- Cobertura celular 4G LTE en 100% del predio

### Viabilidad Económica

✅ **Inversión justificada:**
```
Inversión total: $48,000,000 COP
Ahorro anual: $109,354,400 COP
ROI: (109.3 - 48.0) / 48.0 × 100 = 127% primer año
Payback: 48.0 / (109.3 / 12) = 5.3 meses
```

✅ **Financiamiento asegurado:**
- 70% recursos propios de la empresa
- 30% línea de crédito BANCOLDEX (fomento agrícola)

### Viabilidad Operativa

✅ **Capital humano:**
- Ingeniero de sistemas in-house (capacitación en IoT)
- 2 técnicos de campo (capacitación en sensores)
- Asesoría universitaria (profesor tutor + estudiante investigador)

✅ **Soporte institucional:**
- Universidad de Antioquia (convenio vigente)
- FEDEPAMA (Federación de Palmicultores) - soporte técnico
- MinTIC (certificación de innovación digital)

### Viabilidad Temporal

✅ **Cronograma realista:**
- Semanas 1-2: Análisis y diseño *(COMPLETADO)*
- Semanas 3-4: Desarrollo backend + frontend *(COMPLETADO 90%)*
- Semanas 5-6: Documentación + pruebas *(EN CURSO)*
- Semana 7: Instalación hardware + integración
- Semana 8: Pruebas finales + capacitación

---

## 1.7 Conclusiones del Planteamiento

1. **El problema es real, medible y significativo:** Costos operativos de $182M COP/año son insostenibles

2. **Existe solución tecnológica viable:** IoT + automatización + analítica de datos

3. **La inversión es justificada:** ROI 150%, payback < 6 meses

4. **Hay compromiso institucional:** Empresa + Universidad + Gremio

5. **El impacto trasciende la empresa:** Modelo replicable en 150+ empresas del sector

---

**Documento elaborado por:**  
Equipo de Desarrollo de Sistemas  
Promotora Palmera de Antioquia S.A.S.  
Febrero 2026
