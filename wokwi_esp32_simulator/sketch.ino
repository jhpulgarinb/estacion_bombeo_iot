/*
 * Sistema IoT de Estación de Bombeo - ESP32 DevKit
 * Promotora Palmera de Antioquia S.A.S.
 * Fecha: 20 de febrero de 2026
 * 
 * Sensores simulados en Wokwi:
 * - DHT22: Temperatura y humedad
 * - HC-SR04: Nivel de agua (ultrasonido)
 * - Joystick Analógico: Simula presión entrada/salida y caudal
 * - LEDs: Indicadores de estado (bomba ON/OFF, alertas)
 * - Botones: Control manual bomba (START/STOP)
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>
#include <ArduinoJson.h>

// ===========================
// CONFIGURACIÓN WiFi
// ===========================
const char* ssid = "Wokwi-GUEST";  // WiFi de Wokwi simulator
const char* password = "";
const char* serverURL = "http://192.168.1.100:5000/api";  // Cambiar por IP del servidor Flask

// ===========================
// CONFIGURACIÓN SENSORES
// ===========================
#define DHT_PIN 15           // DHT22 temperatura/humedad
#define DHT_TYPE DHT22
#define TRIG_PIN 5           // HC-SR04 ultrasonido (nivel agua)
#define ECHO_PIN 18
#define JOYSTICK_VERT 34     // Joystick vertical (simula presión entrada)
#define JOYSTICK_HORZ 35     // Joystick horizontal (simula presión salida)
#define JOYSTICK_BTN 32      // Botón joystick (simula caudal)

// LEDs indicadores
#define LED_PUMP_ON 2        // LED verde = bomba encendida
#define LED_ALERT 4          // LED rojo = alerta activa
#define LED_WIFI 16          // LED azul = WiFi conectado

// Botones control manual
#define BTN_START 21         // Botón verde = iniciar bomba
#define BTN_STOP 19          // Botón rojo = detener bomba

// ===========================
// VARIABLES GLOBALES
// ===========================
DHT dht(DHT_PIN, DHT_TYPE);
bool pumpRunning = false;
bool autoMode = true;
unsigned long lastSendTime = 0;
const unsigned long SEND_INTERVAL = 10000;  // Enviar datos cada 10 segundos
int stationID = 1;
int pumpID = 1;

// ===========================
// FUNCIONES DE SENSORES
// ===========================

float readWaterLevel() {
  // Leer nivel de agua con sensor ultrasonido HC-SR04
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  
  long duration = pulseIn(ECHO_PIN, HIGH);
  float distance_cm = duration * 0.034 / 2;  // Convertir a cm
  
  // Tanque de 300 cm de altura, sensor en la parte superior
  // Nivel de agua = altura del tanque - distancia medida
  float waterLevel_cm = 300.0 - distance_cm;
  
  // Convertir a metros
  float waterLevel_m = waterLevel_cm / 100.0;
  
  // Limitar entre 0 y 3 metros
  if (waterLevel_m < 0) waterLevel_m = 0;
  if (waterLevel_m > 3.0) waterLevel_m = 3.0;
  
  return waterLevel_m;
}

float readTemperature() {
  float temp = dht.readTemperature();
  if (isnan(temp)) {
    Serial.println("⚠️  Error leyendo DHT22");
    return 25.0;  // Valor por defecto
  }
  return temp;
}

float readHumidity() {
  float hum = dht.readHumidity();
  if (isnan(hum)) {
    return 70.0;  // Valor por defecto
  }
  return hum;
}

float readPressure(int analogPin) {
  // Leer valor analógico (0-4095) y convertir a presión (0-10 bar)
  int rawValue = analogRead(analogPin);
  float pressure_bar = (rawValue / 4095.0) * 10.0;
  return pressure_bar;
}

float readFlowRate() {
  // Simular caudal basado en si la bomba está encendida
  if (!pumpRunning) {
    return 0.0;
  }
  
  // Caudal variable entre 60 y 95 m³/h cuando bomba está ON
  float baseFlow = 75.0;
  float variation = random(-15, 20);  // Variación aleatoria
  float flowRate = baseFlow + variation;
  
  if (flowRate < 0) flowRate = 0;
  if (flowRate > 120) flowRate = 120;
  
  return flowRate;
}

float simulateRainfall() {
  // Simular lluvia (datos sintéticos)
  int rainChance = random(0, 100);
  
  if (rainChance < 70) {  // 70% sin lluvia
    return 0.0;
  } else if (rainChance < 90) {  // 20% lluvia ligera
    return random(1, 50) / 10.0;  // 0.1 - 5.0 mm
  } else {  // 10% lluvia fuerte
    return random(50, 300) / 10.0;  // 5.0 - 30.0 mm
  }
}

float simulateWindSpeed() {
  // Viento generalmente suave, ocasionalmente fuerte
  if (random(0, 100) < 85) {
    return random(0, 250) / 10.0;  // 0 - 25 km/h
  } else {
    return random(250, 600) / 10.0;  // 25 - 60 km/h
  }
}

// ===========================
// FUNCIONES DE COMUNICACIÓN
// ===========================

void sendMeteorologicalData() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("⚠️  WiFi desconectado");
    return;
  }
  
  HTTPClient http;
  String endpoint = String(serverURL) + "/meteorology";
  
  // Crear JSON con datos meteorológicos
  StaticJsonDocument<512> doc;
  doc["estacion_id"] = stationID;
  doc["temperatura_c"] = readTemperature();
  doc["humedad_porcentaje"] = readHumidity();
  doc["precipitacion_mm"] = simulateRainfall();
  doc["velocidad_viento_kmh"] = simulateWindSpeed();
  doc["direccion_viento_grados"] = random(0, 360);
  doc["presion_atmosferica_hpa"] = random(1000, 1020);
  doc["radiacion_solar_wm2"] = random(200, 1000);
  doc["indice_uv"] = random(1, 11);
  doc["evapotranspiracion_mm"] = random(10, 50) / 10.0;
  doc["humedad_suelo_porcentaje"] = random(30, 80);
  doc["temperatura_suelo_c"] = random(20, 30);
  doc["humedad_hoja_porcentaje"] = random(0, 100);
  doc["dispositivo_origen"] = "ESP32_WOKWI_01";
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  http.begin(endpoint);
  http.addHeader("Content-Type", "application/json");
  
  int httpCode = http.POST(jsonString);
  
  if (httpCode > 0) {
    Serial.printf("✅ Datos meteorológicos enviados (HTTP %d)\n", httpCode);
    if (httpCode == 200 || httpCode == 201) {
      String response = http.getString();
      Serial.println("   Respuesta: " + response);
    }
  } else {
    Serial.printf("❌ Error enviando datos: %s\n", http.errorToString(httpCode).c_str());
  }
  
  http.end();
}

void sendPumpTelemetry() {
  if (WiFi.status() != WL_CONNECTED) {
    return;
  }
  
  HTTPClient http;
  String endpoint = String(serverURL) + "/pump/telemetry";
  
  // Crear JSON con telemetría de bomba
  StaticJsonDocument<512> doc;
  doc["bomba_id"] = pumpID;
  doc["estado"] = pumpRunning ? "ENCENDIDO" : "APAGADO";
  doc["caudal_m3h"] = readFlowRate();
  doc["presion_entrada_bar"] = readPressure(JOYSTICK_VERT);
  doc["presion_salida_bar"] = readPressure(JOYSTICK_HORZ);
  doc["consumo_energia_kw"] = pumpRunning ? random(80, 120) / 10.0 : 0.0;
  doc["temperatura_motor_c"] = pumpRunning ? random(55, 85) : random(25, 35);
  doc["nivel_vibracion"] = pumpRunning ? random(1, 8) : 0;
  doc["horas_operacion"] = random(1000, 5000);
  doc["modo_operacion"] = autoMode ? "AUTO" : "MANUAL";
  doc["dispositivo_origen"] = "ESP32_WOKWI_01";
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  http.begin(endpoint);
  http.addHeader("Content-Type", "application/json");
  
  int httpCode = http.POST(jsonString);
  
  if (httpCode > 0) {
    Serial.printf("✅ Telemetría bomba enviada (HTTP %d)\n", httpCode);
  } else {
    Serial.printf("❌ Error enviando telemetría: %s\n", http.errorToString(httpCode).c_str());
  }
  
  http.end();
}

void updatePumpStatus(bool shouldRun) {
  if (pumpRunning != shouldRun) {
    pumpRunning = shouldRun;
    digitalWrite(LED_PUMP_ON, pumpRunning ? HIGH : LOW);
    
    Serial.println(pumpRunning ? "🟢 BOMBA INICIADA" : "🔴 BOMBA DETENIDA");
    
    // Enviar log al servidor
    if (WiFi.status() == WL_CONNECTED) {
      HTTPClient http;
      String endpoint = String(serverURL) + "/control/log";
      
      StaticJsonDocument<256> doc;
      doc["estacion_id"] = stationID;
      doc["accion"] = pumpRunning ? "INICIAR" : "DETENER";
      doc["razon"] = autoMode ? "DESICION_AUTO" : "OVERRIDE_MANUAL";
      doc["nivel_agua_m"] = readWaterLevel();
      doc["precipitacion_mm"] = simulateRainfall();
      
      String jsonString;
      serializeJson(doc, jsonString);
      
      http.begin(endpoint);
      http.addHeader("Content-Type", "application/json");
      http.POST(jsonString);
      http.end();
    }
  }
}

// ===========================
// CONTROL AUTOMÁTICO
// ===========================

void checkAutomaticControl() {
  if (!autoMode) return;  // Solo en modo automático
  
  float waterLevel = readWaterLevel();
  float rainfall = simulateRainfall();
  float motorTemp = readTemperature();
  
  // Regla 1: Lluvia fuerte > 30mm → DETENER
  if (rainfall > 30.0 && pumpRunning) {
    Serial.println("⚠️  Lluvia fuerte detectada → Deteniendo bomba");
    updatePumpStatus(false);
    digitalWrite(LED_ALERT, HIGH);
    return;
  }
  
  // Regla 2: Temperatura motor > 85°C → DETENER
  if (motorTemp > 85.0 && pumpRunning) {
    Serial.println("🔥 Temperatura motor crítica → Deteniendo bomba");
    updatePumpStatus(false);
    digitalWrite(LED_ALERT, HIGH);
    return;
  }
  
  // Regla 3: Nivel bajo < 0.5m Y sin lluvia → INICIAR
  if (waterLevel < 0.5 && rainfall < 15.0 && !pumpRunning) {
    Serial.println("💧 Nivel bajo detectado → Iniciando bomba");
    updatePumpStatus(true);
    digitalWrite(LED_ALERT, LOW);
    return;
  }
  
  // Regla 4: Nivel alto > 2.8m → DETENER
  if (waterLevel > 2.8 && pumpRunning) {
    Serial.println("🌊 Nivel alto alcanzado → Deteniendo bomba");
    updatePumpStatus(false);
    digitalWrite(LED_ALERT, LOW);
    return;
  }
}

// ===========================
// SETUP
// ===========================

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("\n\n");
  Serial.println("═══════════════════════════════════════════════");
  Serial.println("  Sistema IoT - Estación de Bombeo ESP32      ");
  Serial.println("  Promotora Palmera de Antioquia S.A.S.       ");
  Serial.println("  Simulador Wokwi - Versión 1.0               ");
  Serial.println("═══════════════════════════════════════════════");
  
  // Configurar pines
  pinMode(LED_PUMP_ON, OUTPUT);
  pinMode(LED_ALERT, OUTPUT);
  pinMode(LED_WIFI, OUTPUT);
  pinMode(BTN_START, INPUT_PULLUP);
  pinMode(BTN_STOP, INPUT_PULLUP);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  
  // Estado inicial
  digitalWrite(LED_PUMP_ON, LOW);
  digitalWrite(LED_ALERT, LOW);
  digitalWrite(LED_WIFI, LOW);
  
  // Inicializar DHT22
  dht.begin();
  Serial.println("✅ Sensor DHT22 inicializado");
  
  // Conectar a WiFi
  Serial.print("📡 Conectando a WiFi");
  WiFi.begin(ssid, password);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ WiFi conectado");
    Serial.print("   IP: ");
    Serial.println(WiFi.localIP());
    digitalWrite(LED_WIFI, HIGH);
  } else {
    Serial.println("\n⚠️  WiFi no conectado (modo offline)");
  }
  
  Serial.println("\n📊 Configuración de sensores:");
  Serial.println("   • DHT22 (Pin 15): Temperatura y humedad");
  Serial.println("   • HC-SR04 (Pins 5/18): Nivel de agua");
  Serial.println("   • Joystick (Pins 34/35): Presión entrada/salida");
  Serial.println("   • LEDs (Pins 2/4/16): Estado bomba/alerta/WiFi");
  Serial.println("   • Botones (Pins 21/19): Control manual");
  
  Serial.println("\n🚀 Sistema iniciado correctamente");
  Serial.println("   Modo: AUTOMÁTICO");
  Serial.println("   Intervalo de envío: 10 segundos\n");
}

// ===========================
// LOOP PRINCIPAL
// ===========================

void loop() {
  unsigned long currentTime = millis();
  
  // Verificar botones de control manual
  if (digitalRead(BTN_START) == LOW) {
    autoMode = false;
    Serial.println("🔧 Modo MANUAL activado");
    updatePumpStatus(true);
    delay(500);  // Debounce
  }
  
  if (digitalRead(BTN_STOP) == LOW) {
    autoMode = false;
    Serial.println("🔧 Modo MANUAL activado");
    updatePumpStatus(false);
    delay(500);  // Debounce
  }
  
  // Ejecutar control automático
  checkAutomaticControl();
  
  // Enviar datos al servidor cada 10 segundos
  if (currentTime - lastSendTime >= SEND_INTERVAL) {
    Serial.println("\n📤 Enviando datos al servidor...");
    
    // Mostrar lecturas actuales
    Serial.println("📊 Lecturas actuales:");
    Serial.printf("   💧 Nivel agua: %.2f m\n", readWaterLevel());
    Serial.printf("   🌡️  Temperatura: %.1f °C\n", readTemperature());
    Serial.printf("   💦 Humedad: %.1f %%\n", readHumidity());
    Serial.printf("   ⚙️  Bomba: %s\n", pumpRunning ? "ON" : "OFF");
    Serial.printf("   🔄 Caudal: %.1f m³/h\n", readFlowRate());
    
    sendMeteorologicalData();
    sendPumpTelemetry();
    
    lastSendTime = currentTime;
    Serial.println("");
  }
  
  // Parpadear LED WiFi si está conectado
  static unsigned long lastBlink = 0;
  if (currentTime - lastBlink >= 1000) {
    if (WiFi.status() == WL_CONNECTED) {
      digitalWrite(LED_WIFI, !digitalRead(LED_WIFI));
    }
    lastBlink = currentTime;
  }
  
  delay(100);  // Pequeña pausa para estabilidad
}
