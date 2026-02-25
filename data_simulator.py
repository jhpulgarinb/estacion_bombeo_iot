#!/usr/bin/env python3
"""
Simulador de Datos Virtuales para Estación de Bombeo
Genera datos realistas para el sistema de monitoreo
"""

import random
import time
import json
import math
from datetime import datetime, timedelta
from flask import Flask, jsonify, request
from threading import Thread
import requests

class VirtualSensorSimulator:
    def __init__(self):
        self.stations = {
            1: {
                'name': 'Estación Principal Norte',
                'location': 'Sector Norte',
                'gate_diameter': 2.0,
                'weir_type': 'rectangular',
                'weir_width': 2.0,
                'cd_coefficient': 0.62
            },
            2: {
                'name': 'Estación Principal Sur', 
                'location': 'Sector Sur',
                'gate_diameter': 2.0,
                'weir_type': 'rectangular',
                'weir_width': 2.0,
                'cd_coefficient': 0.62
            },
            3: {
                'name': 'Estación Auxiliar Este',
                'location': 'Sector Este',
                'gate_diameter': 1.5,
                'weir_type': 'rectangular',
                'weir_width': 1.5,
                'cd_coefficient': 0.65
            },
            4: {
                'name': 'Estación de Emergencia',
                'location': 'Sector Central',
                'gate_diameter': 1.0,
                'weir_type': 'rectangular',
                'weir_width': 1.0,
                'cd_coefficient': 0.68
            }
        }
        
        self.virtual_sensors = {
            'temperature': {'value': 22.5, 'min': 15, 'max': 30, 'unit': '°C'},
            'ph': {'value': 7.2, 'min': 6.5, 'max': 8.5, 'unit': 'pH'},
            'turbidity': {'value': 2.1, 'min': 0, 'max': 10, 'unit': 'NTU'},
            'pressure': {'value': 45.3, 'min': 20, 'max': 80, 'unit': 'PSI'},
            'conductivity': {'value': 450, 'min': 200, 'max': 800, 'unit': 'μS/cm'},
            'oxygen': {'value': 8.5, 'min': 4, 'max': 12, 'unit': 'mg/L'},
            'flow_velocity': {'value': 1.2, 'min': 0, 'max': 5, 'unit': 'm/s'},
            'gate_vibration': {'value': 0.02, 'min': 0, 'max': 0.1, 'unit': 'mm'},
            'motor_current': {'value': 12.5, 'min': 0, 'max': 50, 'unit': 'A'},
            'power_consumption': {'value': 850, 'min': 0, 'max': 2000, 'unit': 'W'}
        }
        
        self.current_data = {}
        self.historical_data = []
        self.running = False
        
    def calculate_flow(self, level, station_id=1):
        """Calcula caudal basado en ecuación de vertedero"""
        station = self.stations.get(station_id, self.stations[1])
        if level <= 0:
            return 0
        
        # Q = Cd * b * √(2g) * h^(3/2)
        g = 9.81
        cd = station['cd_coefficient']
        b = station['weir_width']
        
        flow = cd * b * math.sqrt(2 * g) * (level ** 1.5)
        return round(flow, 4)
    
    def simulate_daily_pattern(self, base_value, amplitude, hour):
        """Simula patrones diarios realistas"""
        # Patrón sinusoidal con ruido
        daily_factor = 1 + amplitude * math.sin((hour - 6) * math.pi / 12)
        noise = random.uniform(-0.1, 0.1)
        return base_value * daily_factor * (1 + noise)
    
    def simulate_weather_influence(self, base_value, weather_factor=1.0):
        """Simula influencia del clima"""
        # weather_factor: 0.5 (sequía) a 2.0 (lluvia intensa)
        seasonal_variation = random.uniform(0.9, 1.1)
        return base_value * weather_factor * seasonal_variation
    
    def generate_station_data(self, station_id):
        """Genera datos para una estación específica"""
        now = datetime.now()
        hour = now.hour
        
        # Nivel base con patrón diario (más alto en la mañana)
        base_level = 1.8
        if 6 <= hour <= 12:  # Mañana - nivel alto
            level_base = base_level * 1.2
        elif 13 <= hour <= 18:  # Tarde - nivel medio-alto
            level_base = base_level * 1.0
        elif 19 <= hour <= 22:  # Noche - nivel medio
            level_base = base_level * 0.8
        else:  # Madrugada - nivel bajo
            level_base = base_level * 0.6
            
        # Agregar variación aleatoria
        level = level_base + random.uniform(-0.2, 0.3)
        level = max(0.1, min(4.0, level))  # Limitar entre 0.1 y 4.0 metros
        
        # Calcular caudal basado en nivel
        flow = self.calculate_flow(level, station_id)
        
        # Estado de compuerta basado en caudal
        if flow < 0.1:
            gate_position = random.uniform(0, 15)  # Cerrada o casi cerrada
            gate_status = 'CERRADA'
        elif flow < 0.5:
            gate_position = random.uniform(15, 45)  # Parcialmente abierta
            gate_status = 'PARCIAL'
        else:
            gate_position = random.uniform(45, 90)  # Abierta
            gate_status = 'ABIERTA'
            
        # Volumen acumulado (simulado)
        daily_volume = 1000 + (hour * 150) + random.uniform(-200, 300)
        
        return {
            'station_id': station_id,
            'timestamp': now.isoformat(),
            'level_m': round(level, 3),
            'flow_m3s': flow,
            'gate_position_percent': round(gate_position, 1),
            'gate_status': gate_status,
            'daily_volume_m3': round(daily_volume, 1),
            'sensors': self.update_virtual_sensors()
        }
    
    def update_virtual_sensors(self):
        """Actualiza sensores virtuales con valores realistas"""
        updated_sensors = {}
        
        for sensor_name, config in self.virtual_sensors.items():
            current = config['value']
            min_val = config['min']
            max_val = config['max']
            
            # Generar variación basada en el tipo de sensor
            if sensor_name == 'temperature':
                # Temperatura varía lentamente
                variation = random.uniform(-0.3, 0.3)
                new_value = current + variation
            elif sensor_name == 'ph':
                # pH varía muy lentamente
                variation = random.uniform(-0.05, 0.05)
                new_value = current + variation
            elif sensor_name == 'turbidity':
                # Turbidez puede cambiar más rápidamente
                variation = random.uniform(-0.3, 0.3)
                new_value = current + variation
            elif sensor_name == 'pressure':
                # Presión varía con el flujo
                variation = random.uniform(-2, 2)
                new_value = current + variation
            elif sensor_name == 'conductivity':
                # Conductividad varía moderadamente
                variation = random.uniform(-10, 10)
                new_value = current + variation
            elif sensor_name == 'oxygen':
                # Oxígeno varía con temperatura y flujo
                variation = random.uniform(-0.2, 0.2)
                new_value = current + variation
            elif sensor_name == 'flow_velocity':
                # Velocidad correlacionada con caudal
                variation = random.uniform(-0.1, 0.1)
                new_value = current + variation
            elif sensor_name == 'gate_vibration':
                # Vibración aumenta con movimiento
                variation = random.uniform(-0.005, 0.01)
                new_value = current + variation
            elif sensor_name == 'motor_current':
                # Corriente varía con carga
                variation = random.uniform(-1, 2)
                new_value = current + variation
            else:  # power_consumption
                # Consumo correlacionado con corriente
                variation = random.uniform(-50, 100)
                new_value = current + variation
            
            # Mantener dentro de límites
            new_value = max(min_val, min(max_val, new_value))
            config['value'] = new_value
            
            # Determinar estado del sensor
            percentage = ((new_value - min_val) / (max_val - min_val)) * 100
            if percentage < 10 or percentage > 90:
                status = 'alert'
            elif percentage < 20 or percentage > 80:
                status = 'warning'
            else:
                status = 'normal'
            
            updated_sensors[sensor_name] = {
                'name': sensor_name.replace('_', ' ').title(),
                'value': round(new_value, 2),
                'unit': config['unit'],
                'status': status,
                'percentage': round(percentage, 1),
                'timestamp': datetime.now().isoformat()
            }
        
        return updated_sensors
    
    def generate_historical_data(self, station_id, hours=24):
        """Genera datos históricos para gráficos"""
        historical = []
        now = datetime.now()
        
        for i in range(hours):
            timestamp = now - timedelta(hours=hours-i-1)
            hour = timestamp.hour
            
            # Generar datos para esta hora
            level = self.simulate_daily_pattern(1.5, 0.3, hour)
            level = max(0.1, min(4.0, level))
            
            flow = self.calculate_flow(level, station_id)
            
            historical.append({
                'timestamp': timestamp.isoformat(),
                'level_m': round(level, 3),
                'flow_m3s': flow,
                'gate_position': round(30 + flow * 40 + random.uniform(-10, 10), 1)
            })
        
        return historical
    
    def start_simulation(self):
        """Inicia la simulación de datos en tiempo real"""
        self.running = True
        
        def simulation_loop():
            while self.running:
                try:
                    # Generar datos para todas las estaciones
                    for station_id in self.stations.keys():
                        data = self.generate_station_data(station_id)
                        self.current_data[station_id] = data
                        
                        # Enviar datos al sistema principal si está disponible
                        try:
                            response = requests.post('http://localhost:5000/api/data', 
                                                   json=data, timeout=2)
                        except:
                            pass  # Sistema principal no disponible
                    
                    # Guardar en histórico
                    self.historical_data.append({
                        'timestamp': datetime.now(),
                        'data': dict(self.current_data)
                    })
                    
                    # Mantener solo las últimas 1000 entradas
                    if len(self.historical_data) > 1000:
                        self.historical_data.pop(0)
                    
                    time.sleep(5)  # Actualizar cada 5 segundos
                    
                except Exception as e:
                    print(f"Error en simulación: {e}")
                    time.sleep(10)
        
        thread = Thread(target=simulation_loop, daemon=True)
        thread.start()
        print("Simulador de datos iniciado")
    
    def stop_simulation(self):
        """Detiene la simulación"""
        self.running = False
        print("Simulador de datos detenido")
    
    def get_dashboard_data(self, station_id=1, hours=24):
        """Obtiene datos para el dashboard"""
        current = self.current_data.get(station_id, {})
        historical = self.generate_historical_data(station_id, hours)
        
        return {
            'current_status': {
                'position_percent': current.get('gate_position_percent', 0),
                'level_m': current.get('level_m', 0),
                'flow_m3s': current.get('flow_m3s', 0),
                'status': current.get('gate_status', 'UNKNOWN'),
                'last_update': current.get('timestamp', datetime.now().isoformat())
            },
            'historical_data': historical,
            'daily_summary': {
                'date': datetime.now().date().isoformat(),
                'total_m3': current.get('daily_volume_m3', 0),
                'peak_flow_m3s': max([h['flow_m3s'] for h in historical], default=0),
                'gate_open_hours': random.uniform(8, 16)
            },
            'virtual_sensors': current.get('sensors', {}),
            'station_info': self.stations.get(station_id, {})
        }

# API Flask para servir datos simulados
app = Flask(__name__)
simulator = VirtualSensorSimulator()

@app.route('/api/simulator/dashboard')
def get_dashboard():
    station_id = request.args.get('station_id', 1, type=int)
    hours = request.args.get('hours', 24, type=int)
    return jsonify(simulator.get_dashboard_data(station_id, hours))

@app.route('/api/simulator/sensors')
def get_sensors():
    station_id = request.args.get('station_id', 1, type=int)
    current = simulator.current_data.get(station_id, {})
    return jsonify(current.get('sensors', {}))

@app.route('/api/simulator/start', methods=['POST'])
def start_simulator():
    simulator.start_simulation()
    return jsonify({'message': 'Simulador iniciado', 'status': 'running'})

@app.route('/api/simulator/stop', methods=['POST'])  
def stop_simulator():
    simulator.stop_simulation()
    return jsonify({'message': 'Simulador detenido', 'status': 'stopped'})

@app.route('/api/simulator/status')
def simulator_status():
    return jsonify({
        'running': simulator.running,
        'stations': list(simulator.stations.keys()),
        'sensors_count': len(simulator.virtual_sensors),
        'last_update': max([data.get('timestamp', '') 
                           for data in simulator.current_data.values()], default='')
    })

if __name__ == '__main__':
    # Iniciar simulador automáticamente
    simulator.start_simulation()
    
    print("Simulador de Datos Virtuales iniciado")
    print("Acceso: http://localhost:5001")
    print("Dashboard simulado: http://localhost:5001/api/simulator/dashboard")
    
    try:
        app.run(host='0.0.0.0', port=5001, debug=False)
    except KeyboardInterrupt:
        simulator.stop_simulation()
        print("\nSimulador detenido")
