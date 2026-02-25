"""
Simulador de Sensores Extendido
Genera datos sintéticos para:
- Estación meteorológica (lluvia, viento, temperatura, humedad, presión)
- Telemetría de bomba (caudal, presión, energía, temperatura motor)

Promotora Palmera de Antioquia S.A.S.
Fecha: 20 de febrero de 2026
"""

import random
import time
import requests
from datetime import datetime
import json

# Configuración
API_BASE_URL = "http://localhost:5000/api"
STATION_ID = 1
PUMP_ID = 1
UPDATE_INTERVAL = 10  # segundos

class ExtendedSensorSimulator:
    def __init__(self):
        self.pump_running = False
        self.running_hours = 0.0
        self.last_rainfall = 0.0
    
    def generate_meteorological_data(self):
        """Generar datos meteorológicos sintéticos"""
        
        # Simular lluvia (con tendencia: a veces no llueve, a veces llueve fuerte)
        rain_probability = random.random()
        if rain_probability < 0.7:  # 70% sin lluvia
            precipitation = 0.0
        elif rain_probability < 0.9:  # 20% lluvia ligera
            precipitation = random.uniform(0.1, 5.0)
        else:  # 10% lluvia fuerte
            precipitation = random.uniform(5.0, 30.0)
        
        self.last_rainfall = precipitation
        
        # Viento (generalmente suave, ocasionalmente fuerte)
        if random.random() < 0.85:
            wind_speed = random.uniform(0, 25.0)  # Brisa suave
        else:
            wind_speed = random.uniform(25.0, 60.0)  # Viento fuerte
        
        wind_direction = random.randint(0, 359)
        
        # Temperatura (clima tropical: 18-35°C)
        hour = datetime.now().hour
        if 6 <= hour < 12:  # Mañana
            temperature = random.uniform(22.0, 28.0)
        elif 12 <= hour < 18:  # Tarde
            temperature = random.uniform(28.0, 35.0)
        else:  # Noche/Madrugada
            temperature = random.uniform(18.0, 24.0)
        
        # Humedad (mayor con lluvia)
        if precipitation > 0:
            humidity = random.uniform(80.0, 98.0)
        else:
            humidity = random.uniform(45.0, 75.0)
        
        # Presión atmosférica (Colombia: ~1013 hPa al nivel del mar)
        pressure = random.uniform(1008.0, 1018.0)
        
        # Radiación solar (depende de hora)
        if 6 <= hour < 18:  # Día
            solar_radiation = random.uniform(200.0, 1200.0)
        else:  # Noche
            solar_radiation = 0.0
        
        return {
            'station_id': STATION_ID,
            'precipitation_mm': round(precipitation, 2),
            'wind_speed_kmh': round(wind_speed, 2),
            'wind_direction_deg': wind_direction,
            'temperature_c': round(temperature, 2),
            'humidity_percent': round(humidity, 2),
            'pressure_hpa': round(pressure, 2),
            'solar_radiation_wm2': round(solar_radiation, 2),
            'timestamp': datetime.now().isoformat(),
            'source_device': 'SIMULATOR_WEATHER_01'
        }
    
    def generate_pump_telemetry(self):
        """Generar telemetría de bomba sintética"""
        
        # Decidir si bomba está encendida (simulación simple)
        # En la realidad, esto sería controlado por el sistema automático
        if self.last_rainfall > 20.0:
            # Lluvia fuerte, apagar bomba
            self.pump_running = False
        elif self.last_rainfall < 1.0 and random.random() < 0.3:
            # Sin lluvia, probabilidad de encender
            self.pump_running = True
        
        # Incrementar horas de operación
        if self.pump_running:
            self.running_hours += (UPDATE_INTERVAL / 3600.0)
        
        # Generar datos según estado
        if self.pump_running:
            flow_rate = random.uniform(60.0, 95.0)  # m³/h
            inlet_pressure = random.uniform(2.5, 4.0)  # bar
            outlet_pressure = random.uniform(5.5, 7.5)  # bar
            power_consumption = random.uniform(18.0, 35.0)  # kWh
            motor_temperature = random.uniform(55.0, 78.0)  # °C
        else:
            flow_rate = 0.0
            inlet_pressure = random.uniform(0.5, 2.0)
            outlet_pressure = random.uniform(0.8, 2.5)
            power_consumption = random.uniform(0.0, 2.0)  # Consumo standby
            motor_temperature = random.uniform(25.0, 35.0)  # Temperatura ambiente
        
        return {
            'pump_id': PUMP_ID,
            'is_running': self.pump_running,
            'flow_rate_m3h': round(flow_rate, 3),
            'inlet_pressure_bar': round(inlet_pressure, 3),
            'outlet_pressure_bar': round(outlet_pressure, 3),
            'power_consumption_kwh': round(power_consumption, 3),
            'motor_temperature_c': round(motor_temperature, 2),
            'running_hours': round(self.running_hours, 2),
            'timestamp': datetime.now().isoformat(),
            'source_device': 'SIMULATOR_PUMP_01'
        }
    
    def send_data(self, endpoint, data):
        """Enviar datos al API"""
        try:
            url = f"{API_BASE_URL}/{endpoint}"
            response = requests.post(url, json=data, timeout=5)
            
            if response.status_code == 200:
                print(f"✅ {endpoint}: {response.json().get('message', 'OK')}")
                return True
            else:
                print(f"❌ {endpoint}: Error {response.status_code} - {response.text}")
                return False
        
        except requests.exceptions.ConnectionError:
            print(f"❌ {endpoint}: No se pudo conectar al servidor")
            return False
        except Exception as e:
            print(f"❌ {endpoint}: {str(e)}")
            return False
    
    def run(self):
        """Ejecutar simulador en loop continuo"""
        print("\n" + "="*70)
        print("🌦️  SIMULADOR DE SENSORES EXTENDIDO")
        print(f"📡 Servidor: {API_BASE_URL}")
        print(f"🏭 Estación: {STATION_ID}")
        print(f"⚙️  Intervalo: {UPDATE_INTERVAL} segundos")
        print("="*70 + "\n")
        
        print("💡 Presiona Ctrl+C para detener\n")
        
        cycle = 0
        
        try:
            while True:
                cycle += 1
                print(f"\n--- Ciclo {cycle} ({datetime.now().strftime('%H:%M:%S')}) ---")
                
                # Generar y enviar datos meteorológicos
                weather_data = self.generate_meteorological_data()
                print(f"🌧️  Lluvia: {weather_data['precipitation_mm']}mm | "
                      f"🌡️  Temp: {weather_data['temperature_c']}°C | "
                      f"💨 Viento: {weather_data['wind_speed_kmh']} km/h")
                
                self.send_data('meteorology', weather_data)
                
                # Generar y enviar telemetría de bomba
                pump_data = self.generate_pump_telemetry()
                status_emoji = "🟢" if pump_data['is_running'] else "🔴"
                print(f"{status_emoji} Bomba: {'ON' if pump_data['is_running'] else 'OFF'} | "
                      f"Caudal: {pump_data['flow_rate_m3h']} m³/h | "
                      f"Motor: {pump_data['motor_temperature_c']}°C")
                
                self.send_data('pump/telemetry', pump_data)
                
                # Esperar siguiente ciclo
                time.sleep(UPDATE_INTERVAL)
        
        except KeyboardInterrupt:
            print("\n\n⏹️  Simulador detenido por el usuario")
            print(f"📊 Total de ciclos ejecutados: {cycle}")
            print(f"⏱️  Horas de bomba simuladas: {self.running_hours:.2f}h\n")


class OneTimeBatchSimulator:
    """Simulador para generar datos históricos de prueba"""
    
    @staticmethod
    def generate_historical_data(hours=24, interval_minutes=10):
        """Generar datos históricos para las últimas N horas"""
        from datetime import timedelta
        
        print(f"\n🔄 Generando {hours} horas de datos históricos...")
        
        total_records = hours * (60 // interval_minutes)
        simulator = ExtendedSensorSimulator()
        success_count = 0
        
        for i in range(total_records):
            # Calcular timestamp histórico
            minutes_ago = total_records - i
            timestamp = datetime.now() - timedelta(minutes=minutes_ago * interval_minutes)
            
            # Generar datos
            weather_data = simulator.generate_meteorological_data()
            pump_data = simulator.generate_pump_telemetry()
            
            # Actualizar timestamps
            weather_data['timestamp'] = timestamp.isoformat()
            pump_data['timestamp'] = timestamp.isoformat()
            
            # Enviar
            if simulator.send_data('meteorology', weather_data):
                success_count += 1
            if simulator.send_data('pump/telemetry', pump_data):
                success_count += 1
            
            # Mostrar progreso
            if (i + 1) % 10 == 0:
                print(f"Progreso: {i+1}/{total_records} registros ({(i+1)/total_records*100:.1f}%)")
        
        print(f"\n✅ Generación completada: {success_count} registros enviados")


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == '--historical':
        # Modo batch: generar datos históricos
        hours = int(sys.argv[2]) if len(sys.argv) > 2 else 24
        sim = OneTimeBatchSimulator()
        sim.generate_historical_data(hours=hours)
    else:
        # Modo continuo: simulación en tiempo real
        simulator = ExtendedSensorSimulator()
        simulator.run()
