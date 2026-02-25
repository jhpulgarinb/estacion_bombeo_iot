# 🎮 Simulador ESP32 con Wokwi

**Sistema IoT de Estación de Bombeo**  
**Promotora Palmera de Antioquia S.A.S.**

---

## 📋 Descripción

Este proyecto simula un ESP32 DevKit completo con sensores reales para el sistema de monitoreo de estación de bombeo. Utiliza **Wokwi Simulator** para crear un entorno virtual interactivo.

## 🔧 Componentes del Circuito

### Sensores

| Componente | Pin(es) | Función |
|------------|---------|---------|
| **DHT22** | 15 | Temperatura y humedad ambiente |
| **HC-SR04** | 5 (TRIG), 18 (ECHO) | Nivel de agua (ultrasonido) |
| **Joystick Analógico** | 34 (VERT), 35 (HORZ), 32 (BTN) | Presión entrada/salida/caudal |

### Indicadores

| LED | Pin | Color | Significado |
|-----|-----|-------|-------------|
| LED 1 | 2 | Verde | Bomba encendida |
| LED 2 | 4 | Rojo | Alerta activa |
| LED 3 | 16 | Azul | WiFi conectado (parpadea) |

### Controles

| Botón | Pin | Color | Función |
|-------|-----|-------|---------|
| START | 21 | Verde | Iniciar bomba (modo manual) |
| STOP | 19 | Rojo | Detener bomba (modo manual) |

## 🚀 Cómo Usar con Wokwi

### Opción 1: Wokwi Online (Recomendado para pruebas rápidas)

1. Visitar: https://wokwi.com/
2. Crear nuevo proyecto "ESP32"
3. Copiar contenido de `diagram.json` al editor de diagrama
4. Copiar contenido de `sketch.ino` al editor de código
5. Clic en "Start Simulation"

### Opción 2: Wokwi CLI (Para desarrollo local)

```bash
# Instalar Wokwi CLI
npm install -g wokwi-cli

# Navegar al directorio
cd c:\inetpub\promotorapalmera\project_estacion_bombeo\wokwi_esp32_simulator

# Iniciar simulación
wokwi-cli .
```

### Opción 3: VS Code Extension

1. Instalar extensión "Wokwi Simulator" en VS Code
2. Abrir carpeta `wokwi_esp32_simulator`
3. Presionar `F1` → "Wokwi: Start Simulator"

## ⚙️ Configuración Inicial

### IMPORTANTE: Cambiar IP del Servidor

**Archivo:** `sketch.ino`  
**Línea:** ~17

```cpp
const char* serverURL = "http://192.168.1.100:5000/api";
```

**Cambiar a:**
- `http://localhost:5000/api` si Wokwi corre en la misma máquina
- `http://[TU_IP]:5000/api` si Wokwi corre en otra máquina

### Obtener tu IP local

```powershell
# En PowerShell
ipconfig | Select-String "IPv4"
```

## 📊 Flujo de Operación

```
1. ESP32 inicia y conecta a WiFi "Wokwi-GUEST"
                ↓
2. Lee sensores cada 10 segundos:
   • DHT22 → Temperatura (°C) y Humedad (%)
   • HC-SR04 → Nivel de agua (m)
   • Joystick → Presión entrada/salida (bar)
                ↓
3. Genera datos meteorológicos sintéticos:
   • Lluvia (mm)
   • Viento (km/h)
   • Presión atmosférica (hPa)
   • Radiación solar (W/m²)
                ↓
4. Envía datos al servidor Flask:
   • POST /api/meteorology (datos meteorológicos)
   • POST /api/pump/telemetry (telemetría bomba)
                ↓
5. Control automático evalúa reglas:
   • Lluvia >30mm → STOP
   • Temp motor >85°C → STOP
   • Nivel <0.5m Y sin lluvia → START
   • Nivel >2.8m → STOP
                ↓
6. LEDs muestran estado:
   • Verde = Bomba ON
   • Rojo = Alerta activa
   • Azul parpadeante = WiFi OK
```

## 🎮 Interacción con el Simulador

### Simular Cambios de Nivel de Agua

En Wokwi, hacer clic en el sensor HC-SR04 y ajustar el parámetro `distance`:

- `50` cm = Nivel muy alto (2.5m) → Bomba se detendrá
- `150` cm = Nivel medio (1.5m) → Operación normal
- `250` cm = Nivel bajo (0.5m) → Bomba se iniciará

### Simular Cambios de Temperatura

Hacer clic en DHT22 y ajustar `temperature`:

- `88` °C = Temperatura crítica → Bomba se detendrá + alerta
- `28` °C = Temperatura normal

### Simular Cambios de Presión

Mover el joystick analógico:

- **Vertical (VERT):** Presión de entrada (0-10 bar)
- **Horizontal (HORZ):** Presión de salida (0-10 bar)

### Control Manual

- **Botón Verde (START):** Fuerza inicio de bomba (desactiva modo automático)
- **Botón Rojo (STOP):** Fuerza detención de bomba (desactiva modo automático)

## 📡 Datos Enviados al Servidor

### Endpoint: POST /api/meteorology

```json
{
  "station_id": 1,
  "temperature_c": 28.5,
  "humidity_percent": 75.0,
  "precipitation_mm": 5.2,
  "wind_speed_kmh": 12.3,
  "wind_direction_deg": 180,
  "atmospheric_pressure_hpa": 1013,
  "solar_radiation_wm2": 850,
  "uv_index": 8,
  "evapotranspiration_mm": 3.5,
  "soil_moisture_percent": 65,
  "soil_temperature_c": 25,
  "leaf_wetness_percent": 20,
  "source_device": "ESP32_WOKWI_01"
}
```

### Endpoint: POST /api/pump/telemetry

```json
{
  "pump_id": 1,
  "status": "ON",
  "flow_rate_m3h": 85.2,
  "inlet_pressure_bar": 3.5,
  "outlet_pressure_bar": 7.8,
  "power_consumption_kw": 9.5,
  "motor_temperature_c": 68,
  "vibration_level": 3,
  "running_hours": 2450,
  "operational_mode": "AUTO",
  "source_device": "ESP32_WOKWI_01"
}
```

## 🐛 Solución de Problemas

### WiFi no conecta

**Síntoma:** LED azul no parpadea, mensajes de error en Serial Monitor

**Solución:**
- En Wokwi online: WiFi "Wokwi-GUEST" se conecta automáticamente
- En Wokwi CLI: Verificar que `wokwi.toml` tenga configuración de red

### Servidor no recibe datos

**Síntoma:** HTTP 404 o Connection Refused

**Solución:**
1. Verificar que Flask esté corriendo: `python app.py`
2. Verificar IP en `sketch.ino` línea 17
3. Verificar firewall permite puerto 5000

### Sensores retornan valores extraños

**Síntoma:** Temperatura = `nan`, nivel = 0

**Solución:**
- Verificar conexiones en `diagram.json`
- En Wokwi, ajustar manualmente valores de sensores haciendo clic en ellos

### LEDs no encienden

**Síntoma:** Bomba debería estar ON pero LED verde apagado

**Solución:**
- Verificar pines en código: LED_PUMP_ON = 2
- En Wokwi, conexiones de LEDs deben ir de ánodo a pin GPIO

## 📚 Bibliotecas Utilizadas

- **WiFi.h** - Conexión WiFi (incluida en ESP32 core)
- **HTTPClient.h** - Cliente HTTP (incluida en ESP32 core)
- **DHT.h** - Sensor DHT22 (instalar: Adafruit DHT sensor library)
- **ArduinoJson.h** - Serialización JSON (instalar: ArduinoJson by Benoit Blanchon)

### Instalar Bibliotecas (Arduino IDE)

```
1. Menú: Herramientas → Administrar bibliotecas
2. Buscar: "DHT sensor library" → Instalar (Adafruit)
3. Buscar: "ArduinoJson" → Instalar (versión 6.x)
```

## 🔄 Integración con Sistema Real

Este simulador replica exactamente el comportamiento esperado del ESP32 físico. Para migrar a hardware real:

1. **Sensores reales:**
   - DHT22 → Mismo código, mismo pin
   - HC-SR04 → Mismo código, verificar distancia máxima del tanque
   - Presión → Reemplazar joystick por transductores 4-20mA

2. **WiFi:**
   - Cambiar SSID/password a red de producción
   - IP del servidor a servidor IIS/Flask real

3. **Control de bomba:**
   - Reemplazar `digitalWrite(LED_PUMP_ON)` por señal a relé/contactor
   - Añadir circuito de potencia (24V DC, aislamiento óptico)

## 📞 Soporte

**Desarrollador:** Ingeniero de Sistemas  
**Empresa:** Promotora Palmera de Antioquia S.A.S.  
**Email:** sistemas@promotorapalmera.com  
**Fecha:** 20 de febrero de 2026

---

## 🎯 Próximos Pasos

1. ✅ Iniciar servidor Flask: `python app.py`
2. ✅ Inicializar base de datos: `python init_database.py`
3. ✅ Abrir Wokwi: https://wokwi.com/
4. ✅ Copiar archivos `diagram.json` y `sketch.ino`
5. ✅ Ajustar IP del servidor en línea 17 de `sketch.ino`
6. ✅ Iniciar simulación
7. ✅ Observar datos en http://localhost:5000
8. ✅ Experimentar con sensores y botones

**¡Listo para simular!** 🚀
