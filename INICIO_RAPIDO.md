# 🚀 GUÍA DE INICIO RÁPIDO

**Sistema IoT de Estación de Bombeo**  
**Promotora Palmera de Antioquia S.A.S.**  
**Fecha: 20 de febrero de 2026**

---

## ⚡ Inicio en 3 Pasos

### PASO 1: Ejecutar Script de Inicio

```powershell
cd c:\inetpub\promotorapalmera\project_estacion_bombeo
.\start_system.ps1
```

**El script automáticamente:**
- ✅ Verifica Python instalado
- ✅ Verifica/crea base de datos
- ✅ Instala dependencias faltantes
- ✅ Muestra menú interactivo

### PASO 2: Seleccionar Opción

```
┌────────────────────────────────────────┐
│   OPCIONES DE INICIO                   │
├────────────────────────────────────────┤
│ 1. Solo Servidor Flask                │
│ 2. Solo Simulador                      │
│ 3. AMBOS (Sistema Completo) ← ELEGIR  │
│ 4. Generar Datos Históricos            │
│ 5. Salir                               │
└────────────────────────────────────────┘
```

**Recomendado:** Opción **3** para sistema completo

### PASO 3: Acceder al Dashboard

Abrir navegador y visitar:
```
http://localhost:5000
```

✅ **¡Listo!** El sistema está funcionando.

---

## 📊 ¿Qué Verá en el Dashboard?

### Panel Meteorológico
```
┌─────────────────────────────────────┐
│ ☁️ Lluvia | 💨 Viento | 🌡️ Temp    │
│  5.2 mm   | 12.5 km/h | 28.3°C      │
└─────────────────────────────────────┘
```

### Panel de Control
```
┌─────────────────────────────────────┐
│ ⚙️ Bomba: 🟢 EN OPERACIÓN           │
│ Caudal: 85.2 m³/h                   │
│ Temp Motor: 68°C                    │
└─────────────────────────────────────┘
```

### Panel de Alertas
```
┌─────────────────────────────────────┐
│ 🔔 Alertas: [🔴 2] [🟠 1] [🔵 0]   │
└─────────────────────────────────────┘
```

---

## 🔄 Flujo de Operación Normal

```
1. Sistema monitorea clima y bomba cada 10 segundos
                    ↓
2. ¿Nivel bajo Y sin lluvia?
   SÍ → Inicia bomba automáticamente
   NO → Mantiene estado actual
                    ↓
3. ¿Lluvia >30mm O motor >85°C?
   SÍ → Detiene bomba + envía alerta
   NO → Continúa monitoreando
                    ↓
4. Usuario recibe alertas por:
   • WhatsApp (críticas)
   • Email (todas)
   • SMS (muy críticas)
                    ↓
5. Usuario verifica dashboard
   → Resuelve alertas cuando problema solucionado
```

---

## 🎯 Tooltips Informativos

### ¿Qué son?

Al pasar el cursor sobre elementos del dashboard, aparecen **tooltips flotantes** con información adicional:

```
╔═════════════════════════════════╗
║ Precipitación acumulada.        ║
║ >20mm/2h genera alerta.         ║
║ >30mm/2h detiene bomba         ║
║ automáticamente.                ║
╚═════════════════════════════════╝
        ▼
   [ 5.2 mm ]
```

### Elementos con Tooltips

| Elemento | Información que Muestra |
|----------|-------------------------|
| **🌧️ Precipitación** | Umbrales de alerta y acción automática |
| **💨 Viento** | Niveles de viento y alerta de vendaval |
| **🌡️ Temperatura** | Rangos normales de operación |
| **📏 Presión** | Interpretación de presión atmosférica |
| **Toggle Automático** | Diferencia entre modo manual y automático |
| **Botón INICIAR** | Precauciones antes de iniciar bomba |
| **Botón DETENER** | Advertencia sobre reinicio automático |
| **Contadores de Alertas** | Significado de cada nivel de severidad |

### Tipos de Tooltips

🔵 **AZUL (Info):** Información general  
🟠 **NARANJA (Warning):** Advertencia/precaución  
🔴 **ROJO (Critical):** Acción crítica, leer con atención  
🟢 **VERDE (Success):** Confirmación/éxito

---

## 🛠️ Funciones Principales

### 1. Modo Automático (Recomendado)

**Cuándo usar:** Operación 24/7 sin supervisión

**Qué hace:**
- ✅ Monitorea nivel de agua, lluvia, temperatura
- ✅ Decide cuándo encender/apagar bomba
- ✅ Optimiza horario (evita tarifa PICO)
- ✅ Envía alertas automáticamente
- ✅ Registra todas las decisiones

**Cómo activar:**
1. Toggle en posición DERECHA (verde)
2. Confirmar cambio
3. Verificar que dice "Modo Automático"

### 2. Modo Manual

**Cuándo usar:** 
- Mantenimiento programado
- Pruebas de funcionamiento
- Emergencias que requieren control directo

**Qué hace:**
- ✅ Usted decide cuándo encender/apagar
- ❌ Sistema NO toma decisiones automáticas
- ⚠️ Bomba NO se reinicia sola después de STOP manual

**Cómo usar:**
1. Toggle en posición IZQUIERDA (gris)
2. Aparecen botones INICIAR/DETENER
3. Clic en botón deseado
4. Confirmar acción

### 3. Resolver Alertas

**Cuándo:** Cuando problema esté solucionado

**Cómo:**
1. Leer alerta completa
2. Ejecutar acción correctiva según tipo
3. Verificar que métricas normalizaron
4. Clic en botón "✅ Resolver"
5. Confirmar resolución

**Tipos comunes:**

| Alerta | Acción Inmediata |
|--------|------------------|
| **Temp Motor >80°C** | 1. Verificar ventilación<br>2. Detener bomba si >85°C<br>3. Llamar técnico |
| **Lluvia >30mm** | 1. Verificar que bomba esté OFF<br>2. Esperar a que pare lluvia<br>3. Sistema reinicia solo |
| **Nivel <25% mín** | 1. Verificar que bomba inicie<br>2. Si no, cambiar a manual<br>3. Llamar supervisor |
| **Presión <2.0 bar** | 1. Verificar válvula succión<br>2. Revisar filtros<br>3. Llamar técnico |

---

## ⚙️ Configuración Avanzada

### Cambiar Intervalo de Auto-Refresh

**Archivo:** `dashboard_extended.js`  
**Línea:** ~28

```javascript
refreshInterval = setInterval(() => {
    loadAllData();
}, 10000); // ← Cambiar a valor deseado (en milisegundos)
```

**Valores recomendados:**
- 5000 = 5 segundos (máxima velocidad)
- 10000 = 10 segundos (predeterminado)
- 30000 = 30 segundos (ahorro de recursos)

### Cambiar Umbrales de Alerta

⚠️ **Solo personal autorizado**

**Archivo:** SQLite database `monitoring.db`  
**Tabla:** `alert_thresholds`

**Campos editables:**
- `min_value`: Valor mínimo aceptable
- `max_value`: Valor máximo aceptable
- `alert_level`: CRITICAL, HIGH, MEDIUM, LOW
- `is_active`: true/false

**Herramienta sugerida:** DB Browser for SQLite

---

## 📞 Contacto y Soporte

### Usuario Final

**Dudas sobre dashboard:**
- 📧 Email: soporte@promotorapalmera.com
- ☎️ Ext: 1500
- 💬 WhatsApp: +57 300 100 2000

**Horario:** L-V 7am-5pm

### Emergencias 24/7

**Solo fallos críticos:**
- 📱 +57 300 999 8888

**Definición de fallo crítico:**
- ❌ Sistema completamente caído (no carga)
- ❌ Todas las bombas detenidas sin razón
- ❌ Temperatura motor >90°C
- ❌ Nivel agua <20% mínimo y bomba no inicia

### Soporte Técnico (Sistemas)

**Configuración y desarrollo:**
- 👨‍💻 Ingeniero de Sistemas (Ext. 1234)
- 📧 sistemas@promotorapalmera.com

---

## 📚 Documentación Adicional

| Documento | Contenido |
|-----------|-----------|
| **README_EXTENDED.md** | Documentación técnica completa (8,500 palabras) |
| **MANUAL_USUARIO.md** | Manual de usuario detallado (9,000 palabras) |
| **01_PLANTEAMIENTO_PROBLEMA.md** | Análisis del problema (académico) |
| **02_JUSTIFICACION.md** | Justificación económica/técnica/social |
| **03_OBJETIVOS.md** | Objetivos generales y específicos |
| **ANALISIS_Y_PLAN_IMPLEMENTACION.md** | Plan de desarrollo del proyecto |

**Ubicación:** Carpeta `docs/`

---

## 🎓 Modo de Prueba (Para Capacitación)

Si desea practicar sin afectar bombas reales:

1. Ejecutar solo simulador (Opción 2 del menú)
2. Usar modo MANUAL en dashboard
3. Practicar encendido/apagado con botones
4. Observar cómo cambian métricas simuladas
5. Resolver alertas de prueba

**Datos simulados incluyen:**
- Lluvia variable (0-30mm)
- Viento (0-60 km/h)
- Temperatura (18-35°C)
- Bomba enciende/apaga según condiciones simuladas

---

## ✅ Checklist de Verificación

Antes de dar por terminada la instalación, verificar:

- [ ] Script `.\start_system.ps1` ejecuta sin errores
- [ ] Base de datos `monitoring.db` existe (750 KB aprox)
- [ ] Flask inicia en http://localhost:5000
- [ ] Dashboard carga completamente (<3 segundos)
- [ ] Panel meteorológico muestra datos (no `--`)
- [ ] Panel de bomba muestra métricas
- [ ] Toggle automático/manual funciona
- [ ] Botones INICIAR/DETENER aparecen en modo manual
- [ ] Tooltips aparecen al pasar cursor sobre elementos
- [ ] Datos se actualizan automáticamente cada 10s
- [ ] No hay errores en consola del navegador (F12)

**Si todos ✅:** Sistema funcional 100%  
**Si algún ❌:** Consultar sección "Solución de Problemas" en MANUAL_USUARIO.md

---

## 🎯 Siguientes Pasos

Después de verificar que todo funciona:

1. **Semana 1-2:** Operar en modo MANUAL supervisado
   - Personal se familiariza con interfaz
   - Se validan sensores instalados
   - Se ajustan umbrales si es necesario

2. **Semana 3-4:** Activar Modo AUTOMÁTICO en 1 estación piloto
   - Monitoreo continuo durante 1 semana
   - Validar decisiones automáticas
   - Ajustar algoritmo si es necesario

3. **Semana 5-8:** Desplegar en las 4 estaciones
   - Activar control automático gradualmente
   - Capacitación final a operadores
   - Medición de ahorros energéticos

4. **Mes 6:** Evaluación de resultados
   - Informe de ROI real vs proyectado
   - Identificación de mejoras
   - Planificación de Fase 2 (ML, predicción)

---

**¡El sistema está listo para usarse!** 🎉

**Promotora Palmera de Antioquia S.A.S.**  
*Tecnología al Servicio del Campo*

