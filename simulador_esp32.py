#!/usr/bin/env python3
"""
Simulador ESP32 - Estación de Bombeo y Meteorológica
Genera datos realistas de sensores y los inyecta en la API
"""

import requests
import time
import random
import math
from datetime import datetime

class ESP32Simulator:
    """Simula sensores de ESP32 para estación de bombeo y meteorología"""
    
    def __init__(self, api_base="http://localhost:9000"):
        self.api_base = api_base
        self.station_ids = [1, 2, 3, 4]
        self.station_states = {}
        for station_id in self.station_ids:
            self.station_states[station_id] = {
                "temperature": 24.0 + random.uniform(-2, 2),
                "humidity": 60.0 + random.uniform(-8, 8),
                "wind_speed": 4.0 + random.uniform(-1.5, 1.5),
                "precipitation": 0.0,
                "gate_position": 45.0 + random.uniform(-10, 10),
                "water_level": 2.3 + random.uniform(-0.3, 0.3),
                "pump_running": random.random() > 0.2,
                "pump_flow_m3h": 520.0 + random.uniform(-80, 80),
                "pump_pressure_in": 2.6 + random.uniform(-0.4, 0.4),
                "pump_pressure_out": 5.4 + random.uniform(-0.5, 0.5),
                "pump_power_kw": 34.0 + random.uniform(-6, 6),
                "pump_temp_c": 61.0 + random.uniform(-2, 3),
                "pump_hours": 120.0 + random.uniform(-10, 10)
            }

    def get_state(self, station_id):
        return self.station_states[station_id]
        
    def simulate_meteorology(self, station_id):
        """Simula datos meteorológicos con variaciones realistas"""
        state = self.get_state(station_id)
        # Temperatura sube/baja gradualmente
        state["temperature"] += random.uniform(-0.5, 0.5)
        state["temperature"] = max(15, min(40, state["temperature"]))
        
        # Humedad varía
        state["humidity"] += random.uniform(-2, 2)
        state["humidity"] = max(30, min(95, state["humidity"]))
        
        # Viento con rachas
        state["wind_speed"] += random.uniform(-1, 1)
        state["wind_speed"] = max(0, min(30, state["wind_speed"]))
        
        # Precipitación aleatoria (10% de probabilidad)
        if random.random() < 0.1:
            state["precipitation"] = random.uniform(0.1, 5.0)
        else:
            state["precipitation"] = max(0, state["precipitation"] - 0.1)
        
        pressure_hpa = round(1013 + random.uniform(-5, 5), 1)
        wind_kmh = round(state["wind_speed"] * 3.6, 2)

        return {
            "estacion_id": station_id,
            "temperatura_c": round(state["temperature"], 2),
            "humedad_porcentaje": round(state["humidity"], 1),
            "precipitacion_mm": round(state["precipitation"], 2),
            "presion_hpa": pressure_hpa,
            "presion_atmosferica_hpa": pressure_hpa,
            "velocidad_viento_ms": round(state["wind_speed"], 2),
            "velocidad_viento_kmh": wind_kmh,
            "direccion_viento_grados": random.randint(0, 360),
            "radiacion_solar_wm2": round(max(0, 800 + random.uniform(-200, 200))),
            "fecha_hora": datetime.now().isoformat()
        }
    
    def simulate_pumping(self, station_id):
        """Simula datos de bombeo con compuerta"""
        state = self.get_state(station_id)
        # Simular cambios en posición de compuerta
        if random.random() < 0.2:
            state["gate_position"] += random.uniform(-10, 10)
            state["gate_position"] = max(0, min(100, state["gate_position"]))
        
        # Nivel de agua afectado por compuerta
        state["water_level"] += (state["gate_position"] - 50) * 0.01 + random.uniform(-0.1, 0.1)
        state["water_level"] = max(0.5, min(5.0, state["water_level"]))
        
        # Caudal dependiente de posición
        caudal = (state["gate_position"] / 100) * 5.0 + random.uniform(-0.2, 0.2)
        
        return {
            "estacion_id": station_id,
            "numero_compuerta": 1,
            "apertura_porcentaje": round(state["gate_position"], 1),
            "nivel_m": round(state["water_level"], 3),
            "caudal_m3s": round(max(0, caudal), 4),
            "fecha_hora": datetime.now().isoformat(),
            "dispositivo_origen": "ESP32_SIMULADO"
        }

    def simulate_pump_telemetry(self, station_id):
        """Simula telemetria de bomba"""
        state = self.get_state(station_id)
        if random.random() < 0.05:
            state["pump_running"] = not state["pump_running"]

        base_flow = 600.0 if state["pump_running"] else 0.0
        state["pump_flow_m3h"] = max(0.0, base_flow + random.uniform(-50, 50))
        state["pump_pressure_in"] = max(0.5, 2.5 + random.uniform(-0.3, 0.3))
        state["pump_pressure_out"] = max(state["pump_pressure_in"] + 0.5, 5.2 + random.uniform(-0.4, 0.4))
        state["pump_power_kw"] = max(0.0, (state["pump_flow_m3h"] / 600.0) * 45.0 + random.uniform(-2, 2))
        state["pump_temp_c"] = max(30.0, min(90.0, state["pump_temp_c"] + random.uniform(-0.6, 0.8)))
        state["pump_hours"] += 0.01 if state["pump_running"] else 0.0

        return {
            "bomba_id": station_id,
            "estado": "ENCENDIDA" if state["pump_running"] else "APAGADA",
            "caudal_m3h": round(state["pump_flow_m3h"], 2),
            "presion_entrada_bar": round(state["pump_pressure_in"], 2),
            "presion_salida_bar": round(state["pump_pressure_out"], 2),
            "consumo_energia_kw": round(state["pump_power_kw"], 2),
            "temperatura_motor_c": round(state["pump_temp_c"], 1),
            "horas_operacion": round(state["pump_hours"], 2),
            "modo_operacion": "AUTO",
            "fecha_hora": datetime.now().isoformat(),
            "dispositivo_origen": "ESP32_SIMULADO"
        }
    
    def send_meteorology_data(self, station_id):
        """Envía datos meteorológicos a la API"""
        try:
            data = self.simulate_meteorology(station_id)
            url = f"{self.api_base}/api/meteorology"
            response = requests.post(url, json=data, timeout=5)
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Meteorología: {response.status_code} - "
                  f"Est={station_id} T={data['temperatura_c']}°C, H={data['humedad_porcentaje']}%, "
                  f"V={data['velocidad_viento_ms']}m/s")
            return response.status_code == 200
        except Exception as e:
            print(f"ERROR Meteorología: {e}")
            return False
    
    def send_pumping_data(self, station_id):
        """Envía datos de bombeo a la API"""
        try:
            data = self.simulate_pumping(station_id)
            url = f"{self.api_base}/api/data"
            response = requests.post(url, json=data, timeout=5)
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Bombeo: {response.status_code} - "
                  f"Est={station_id} Compuerta={data['apertura_porcentaje']}%, "
                  f"Nivel={data['nivel_m']}m, "
                  f"Caudal={data['caudal_m3s']}m³/s")
            return response.status_code == 200
        except Exception as e:
            print(f"ERROR Bombeo: {e}")
            return False

    def send_pump_telemetry(self, station_id):
        """Envía telemetria de bomba a la API"""
        try:
            data = self.simulate_pump_telemetry(station_id)
            url = f"{self.api_base}/api/pump/telemetry"
            response = requests.post(url, json=data, timeout=5)
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Telemetria Bomba: {response.status_code} - "
                  f"Est={station_id} Estado={data['estado']}, "
                  f"Caudal={data['caudal_m3h']}m³/h, "
                  f"Temp={data['temperatura_motor_c']}°C")
            return response.status_code == 200
        except Exception as e:
            print(f"ERROR Telemetria Bomba: {e}")
            return False
    
    def run(self, interval=10):
        """Ejecuta simulación continuamente"""
        print("="*60)
        print("SIMULADOR ESP32 - ESTACION DE BOMBEO Y METEOROLOGIA")
        print("="*60)
        print(f"API Base: {self.api_base}")
        print(f"Intervalo: {interval} segundos")
        print("\nIniciando simulación...")
        print("Presione Ctrl+C para detener")
        print("="*60)
        print()
        
        iteration = 0
        while True:
            try:
                iteration += 1
                print(f"\n--- Iteración {iteration} ({datetime.now().strftime('%H:%M:%S')}) ---")

                for station_id in self.station_ids:
                    self.send_meteorology_data(station_id)
                    self.send_pumping_data(station_id)
                    self.send_pump_telemetry(station_id)
                    time.sleep(0.2)
                
                print(f"Esperando {interval} segundos...")
                time.sleep(interval)
                
            except KeyboardInterrupt:
                print("\n\nSimulación detenida")
                break
            except Exception as e:
                print(f"Error en simulación: {e}")
                time.sleep(interval)

if __name__ == '__main__':
    simulador = ESP32Simulator()
    simulador.run(interval=10)

