#!/usr/bin/env python3
"""
Sensores Virtuales Específicos - Río León, Chigorodó
Simulación de niveles freáticos y condiciones hidrológicas
Finca La Plana - Sistema de Monitoreo Avanzado
"""

import time
import math
import random
import requests
import threading
import logging
from datetime import datetime, timedelta
from dataclasses import dataclass
from typing import Dict, List, Optional
import json

# Importar configuración específica de Chigorodó
from config_chigorodo import get_chigorodo_config, ChigodoHydrologicalModel

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@dataclass
class SensorChigorodaConfig:
    """Configuración específica de sensores para Chigorodó"""
    sensor_id: int
    sensor_type: str  # 'gate', 'freatic_level', 'river_level', 'flow', 'quality'
    name: str
    location: str
    station_id: int
    coordinates: Dict[str, float]
    min_value: float
    max_value: float
    precision: float
    unit: str
    update_interval: int = 20  # segundos
    noise_factor: float = 0.02  # factor de ruido (2%)
    calibration_factor: float = 1.0
    seasonal_influence: bool = True
    tidal_influence: bool = False

class RioLeonSensor:
    """Sensor virtual base para río León"""
    
    def __init__(self, config: SensorChigorodaConfig):
        self.config = config
        self.current_value = random.uniform(config.min_value, config.max_value)
        self.target_value = self.current_value
        self.last_update = datetime.now()
        self.historical_values = []
        
        # Cargar modelo hidrológico de Chigorodó
        self.chigorodo_config = get_chigorodo_config()
        self.hydrological_model = self.chigorodo_config['hydrological_model']
        
        # Estado del sensor
        self.is_active = True
        self.quality_status = 'GOOD'  # GOOD, UNCERTAIN, BAD
        self.maintenance_mode = False
        
    def add_noise(self, value: float) -> float:
        """Añade ruido realista específico para condiciones tropicales"""
        # Ruido base gaussiano
        base_noise = random.gauss(0, self.config.noise_factor * abs(value))
        
        # Ruido ambiental específico (viento, temperatura, humedad)
        environmental_noise = random.uniform(-0.005, 0.005)
        
        # Ruido de medición del sensor
        instrument_noise = random.uniform(-self.config.precision, self.config.precision)
        
        total_noise = base_noise + environmental_noise + instrument_noise
        
        return value + total_noise
        
    def get_seasonal_influence(self) -> float:
        """Obtiene influencia estacional específica para río León"""
        if not self.config.seasonal_influence:
            return 1.0
            
        return self.hydrological_model.get_seasonal_factor()
    
    def get_daily_cycle_factor(self) -> float:
        """Factor de ciclo diario tropical"""
        return self.hydrological_model.get_daily_variation_factor(datetime.now().hour)
    
    def get_precipitation_factor(self) -> float:
        """Simula factor de precipitación basado en patrones de Urabá"""
        current_month = datetime.now().month
        climate = self.chigorodo_config['climate']
        
        # Factor base según época del año
        if current_month in climate.dry_season_months:
            base_precipitation = 0.3
        elif current_month in climate.wet_season_months:
            base_precipitation = 1.8
        else:  # meses de transición
            base_precipitation = 1.0
            
        # Variación diaria (más lluvia en tarde-noche)
        hour = datetime.now().hour
        if 14 <= hour <= 20:  # tarde-noche
            daily_factor = 1.5
        elif 21 <= hour <= 6:  # noche-madrugada
            daily_factor = 0.7
        else:  # mañana
            daily_factor = 1.0
            
        # Variabilidad aleatoria
        random_factor = random.uniform(0.5, 2.0)
        
        return base_precipitation * daily_factor * random_factor
    
    def simulate_equipment_drift(self) -> float:
        """Simula deriva del equipo por condiciones ambientales"""
        # Deriva por temperatura (alta temperatura en Urabá)
        temperature_drift = math.sin(time.time() / 86400) * 0.001  # ciclo diario
        
        # Deriva por humedad (alta humedad constante)
        humidity_drift = random.uniform(-0.0005, 0.0005)
        
        # Deriva por aging del sensor
        days_operating = (datetime.now() - datetime(2024, 1, 1)).days
        aging_drift = days_operating * 0.00001
        
        return temperature_drift + humidity_drift + aging_drift
        
    def update_quality_status(self):
        """Actualiza estado de calidad del sensor"""
        # Simular problemas ocasionales
        if random.random() < 0.02:  # 2% probabilidad de problema
            self.quality_status = 'UNCERTAIN'
        elif random.random() < 0.005:  # 0.5% probabilidad de fallo
            self.quality_status = 'BAD'
        else:
            self.quality_status = 'GOOD'
            
    def get_sensor_status(self) -> Dict:
        """Obtiene estado completo del sensor"""
        return {
            'sensor_id': self.config.sensor_id,
            'name': self.config.name,
            'location': self.config.location,
            'station_id': self.config.station_id,
            'is_active': self.is_active,
            'quality_status': self.quality_status,
            'maintenance_mode': self.maintenance_mode,
            'last_update': self.last_update.isoformat(),
            'current_value': round(self.current_value, 4),
            'unit': self.config.unit,
            'coordinates': self.config.coordinates
        }

class FreaticsLevelSensor(RioLeonSensor):
    """Sensor de nivel freático específico para río León"""
    
    def __init__(self, config: SensorChigorodaConfig):
        super().__init__(config)
        self.base_level = (config.min_value + config.max_value) / 2
        self.infiltration_lag = 0  # retraso de infiltración
        
    def update_value(self):
        """Actualiza el nivel freático considerando factores específicos del río León"""
        # Factores de influencia
        seasonal_factor = self.get_seasonal_influence()
        daily_factor = self.get_daily_cycle_factor()
        precipitation_factor = self.get_precipitation_factor()
        
        # Nivel base del río (influye directamente en nivel freático)
        river_base_level = 2.5 + math.sin(time.time() / 43200) * 1.0  # ciclo de 12 horas
        
        # Calcular nivel freático usando modelo hidrológico
        freatic_level = self.hydrological_model.calculate_freatic_level(
            river_base_level, 
            precipitation_factor
        )
        
        # Aplicar retraso de infiltración (el agua tarda en infiltrarse)
        lag_factor = 0.95  # el nivel freático responde más lento
        self.current_value = self.current_value * lag_factor + freatic_level * (1 - lag_factor)
        
        # Aplicar factores específicos
        self.current_value *= seasonal_factor * daily_factor
        
        # Simular influencia de bombeo de pozos cercanos
        pumping_influence = math.sin(time.time() / 3600) * 0.1  # ciclos de bombeo
        self.current_value += pumping_influence
        
        # Aplicar deriva del equipo
        drift = self.simulate_equipment_drift()
        self.current_value += drift
        
        # Aplicar ruido y límites
        self.current_value = self.add_noise(self.current_value)
        self.current_value = max(self.config.min_value, 
                               min(self.config.max_value, self.current_value))
        
        # Actualizar calidad
        self.update_quality_status()
        self.last_update = datetime.now()

class RiverLevelSensor(RioLeonSensor):
    """Sensor de nivel del río León"""
    
    def update_value(self):
        """Actualiza nivel del río considerando caudales y precipitación"""
        seasonal_factor = self.get_seasonal_influence()
        daily_factor = self.get_daily_cycle_factor()
        precipitation_factor = self.get_precipitation_factor()
        
        # Nivel base con variaciones naturales
        hour_factor = math.sin((datetime.now().hour / 24) * 2 * math.pi) * 0.3
        base_variation = math.sin(time.time() / 7200) * 0.5  # ciclo de 2 horas
        
        # Calcular nivel objetivo
        target_level = (self.base_level + 
                       hour_factor + 
                       base_variation) * seasonal_factor * daily_factor
        
        # Aplicar efecto de precipitación con retraso
        if precipitation_factor > 1.5:  # lluvia intensa
            target_level += (precipitation_factor - 1.0) * 0.8
            
        # Influencia mareal mínima desde el Golfo de Urabá
        if self.config.tidal_influence:
            target_level = self.hydrological_model.simulate_tidal_influence(target_level)
        
        # Movimiento gradual hacia nivel objetivo
        self.current_value += (target_level - self.current_value) * 0.1
        
        # Aplicar deriva y ruido
        drift = self.simulate_equipment_drift()
        self.current_value += drift
        self.current_value = self.add_noise(self.current_value)
        
        # Aplicar límites
        self.current_value = max(self.config.min_value, 
                               min(self.config.max_value, self.current_value))
        
        self.update_quality_status()
        self.last_update = datetime.now()

class FlowVelocitySensor(RioLeonSensor):
    """Sensor de velocidad de flujo del río"""
    
    def update_value(self):
        """Actualiza velocidad de flujo basada en nivel y condiciones"""
        seasonal_factor = self.get_seasonal_influence()
        precipitation_factor = self.get_precipitation_factor()
        
        # Velocidad base proporcional al caudal estacional
        base_velocity = 1.2 * seasonal_factor
        
        # Efecto de precipitación sobre velocidad
        if precipitation_factor > 1.3:
            velocity_increase = (precipitation_factor - 1.0) * 0.6
            base_velocity += velocity_increase
            
        # Variación por hora (menos velocidad en la noche)
        hour = datetime.now().hour
        if 22 <= hour or hour <= 6:
            base_velocity *= 0.85
        elif 10 <= hour <= 16:
            base_velocity *= 1.1
            
        # Turbulencia y variaciones naturales
        turbulence = random.uniform(-0.1, 0.1)
        base_velocity += turbulence
        
        # Aplicar cambio gradual
        self.current_value += (base_velocity - self.current_value) * 0.15
        
        # Ruido y límites
        drift = self.simulate_equipment_drift()
        self.current_value += drift
        self.current_value = self.add_noise(self.current_value)
        self.current_value = max(self.config.min_value, 
                               min(self.config.max_value, self.current_value))
        
        self.update_quality_status()
        self.last_update = datetime.now()

class GatePositionSensor(RioLeonSensor):
    """Sensor de posición de compuerta con lógica específica"""
    
    def __init__(self, config: SensorChigorodaConfig):
        super().__init__(config)
        self.operation_mode = 'AUTO'  # AUTO, MANUAL, EMERGENCY
        self.target_position = self.current_value
        self.movement_speed = random.uniform(0.5, 2.0)  # %/segundo
        
    def update_value(self):
        """Actualiza posición de compuerta basada en condiciones del río"""
        seasonal_factor = self.get_seasonal_influence()
        precipitation_factor = self.get_precipitation_factor()
        
        # Cambiar modo de operación ocasionalmente
        if random.random() < 0.05:  # 5% probabilidad
            self.operation_mode = random.choice(['AUTO', 'MANUAL', 'EMERGENCY'])
            
        # Lógica de control automático
        if self.operation_mode == 'AUTO':
            # Apertura basada en precipitación y nivel estacional
            if precipitation_factor > 1.8:  # lluvia muy intensa
                self.target_position = min(95, self.current_value + 20)
            elif precipitation_factor > 1.3:  # lluvia moderada
                self.target_position = min(80, self.current_value + 10)
            elif seasonal_factor < 0.7:  # época seca
                self.target_position = max(20, self.current_value - 5)
            else:  # condiciones normales
                self.target_position = 45 + seasonal_factor * 30
                
        elif self.operation_mode == 'EMERGENCY':
            # En emergencia, abrir completamente
            self.target_position = 100
            self.movement_speed = 3.0  # movimiento más rápido
            
        elif self.operation_mode == 'MANUAL':
            # Mantener posición o cambios aleatorios pequeños
            if random.random() < 0.1:
                self.target_position += random.uniform(-5, 5)
        
        # Movimiento gradual hacia posición objetivo
        difference = self.target_position - self.current_value
        if abs(difference) > 0.5:
            move_amount = min(abs(difference), self.movement_speed)
            if difference > 0:
                self.current_value += move_amount
            else:
                self.current_value -= move_amount
        
        # Aplicar límites y ruido mínimo
        self.current_value = max(0, min(100, self.current_value))
        self.current_value = self.add_noise(self.current_value)
        
        self.update_quality_status()
        self.last_update = datetime.now()
        
    def get_operation_status(self) -> str:
        """Obtiene estado de operación de la compuerta"""
        if abs(self.target_position - self.current_value) > 2:
            return 'MOVING'
        elif self.current_value >= 95:
            return 'OPEN'
        elif self.current_value <= 5:
            return 'CLOSED'
        else:
            return 'PARTIAL'

class ChigorodSensorManager:
    """Gestor de sensores virtuales para Chigorodó"""
    
    def __init__(self, api_url: str = "http://localhost:5000"):
        self.api_url = api_url
        self.sensors: Dict[int, RioLeonSensor] = {}
        self.running = False
        self.threads = []
        self.chigorodo_config = get_chigorodo_config()
        
    def create_default_sensors(self):
        """Crea sensores por defecto para las estaciones de Finca La Plana"""
        sensors_config = [
            # ESTACIÓN 1: Río León - Entrada
            SensorChigorodaConfig(
                sensor_id=101, sensor_type='freatic_level',
                name='Nivel Freático - Entrada', 
                location='Finca La Plana - Sector Entrada',
                station_id=1, coordinates={'lat': 7.6652, 'lon': -76.6841},
                min_value=0.5, max_value=6.0, precision=0.002,
                unit='metros', update_interval=30, noise_factor=0.015
            ),
            SensorChigorodaConfig(
                sensor_id=102, sensor_type='river_level',
                name='Nivel Río León - Entrada',
                location='Cauce Principal - Río León',
                station_id=1, coordinates={'lat': 7.6652, 'lon': -76.6841},
                min_value=0.2, max_value=7.5, precision=0.001,
                unit='metros', update_interval=15, tidal_influence=True
            ),
            SensorChigorodaConfig(
                sensor_id=103, sensor_type='flow',
                name='Velocidad Flujo - Entrada',
                location='Cauce Principal - Río León',
                station_id=1, coordinates={'lat': 7.6652, 'lon': -76.6841},
                min_value=0.1, max_value=4.5, precision=0.01,
                unit='m/s', update_interval=20
            ),
            SensorChigorodaConfig(
                sensor_id=104, sensor_type='gate',
                name='Compuerta Radial Principal',
                location='Estructura de Control - Entrada',
                station_id=1, coordinates={'lat': 7.6652, 'lon': -76.6841},
                min_value=0, max_value=100, precision=0.1,
                unit='%', update_interval=10
            ),
            
            # ESTACIÓN 2: Río León - Control
            SensorChigorodaConfig(
                sensor_id=201, sensor_type='freatic_level',
                name='Nivel Freático - Control',
                location='Finca La Plana - Sector Control',
                station_id=2, coordinates={'lat': 7.6671, 'lon': -76.6825},
                min_value=0.3, max_value=5.5, precision=0.002,
                unit='metros', update_interval=25, noise_factor=0.018
            ),
            SensorChigorodaConfig(
                sensor_id=202, sensor_type='river_level',
                name='Nivel Río León - Control',
                location='Cauce de Control - Río León',
                station_id=2, coordinates={'lat': 7.6671, 'lon': -76.6825},
                min_value=0.1, max_value=6.5, precision=0.001,
                unit='metros', update_interval=18, tidal_influence=True
            ),
            SensorChigorodaConfig(
                sensor_id=203, sensor_type='flow',
                name='Velocidad Flujo - Control',
                location='Cauce de Control - Río León',
                station_id=2, coordinates={'lat': 7.6671, 'lon': -76.6825},
                min_value=0.05, max_value=3.8, precision=0.01,
                unit='m/s', update_interval=22
            ),
            SensorChigorodaConfig(
                sensor_id=204, sensor_type='gate',
                name='Compuerta Deslizante Control',
                location='Estructura de Control Secundario',
                station_id=2, coordinates={'lat': 7.6671, 'lon': -76.6825},
                min_value=0, max_value=100, precision=0.1,
                unit='%', update_interval=12
            )
        ]
        
        for config in sensors_config:
            self.add_sensor(config)
            
    def add_sensor(self, config: SensorChigorodaConfig):
        """Añade un sensor específico"""
        if config.sensor_type == 'freatic_level':
            sensor = FreaticsLevelSensor(config)
        elif config.sensor_type == 'river_level':
            sensor = RiverLevelSensor(config)
        elif config.sensor_type == 'flow':
            sensor = FlowVelocitySensor(config)
        elif config.sensor_type == 'gate':
            sensor = GatePositionSensor(config)
        else:
            sensor = RioLeonSensor(config)
            
        self.sensors[config.sensor_id] = sensor
        logger.info(f"Sensor Rio León añadido: {config.name} (ID: {config.sensor_id})")
        
    def start_simulation(self):
        """Inicia simulación de todos los sensores"""
        self.running = True
        logger.info(f"Iniciando simulación - Río León, Chigorodó...")
        logger.info(f"Estaciones: Finca La Plana ({len(self.sensors)} sensores)")
        
        for sensor_id, sensor in self.sensors.items():
            thread = threading.Thread(
                target=self._sensor_loop,
                args=(sensor,),
                daemon=True
            )
            thread.start()
            self.threads.append(thread)
            
    def _sensor_loop(self, sensor: RioLeonSensor):
        """Bucle principal de sensor"""
        while self.running:
            try:
                # Actualizar valor
                sensor.update_value()
                
                # Preparar y enviar datos
                data = self._prepare_sensor_data(sensor)
                self._send_data(data)
                
                # Esperar siguiente actualización
                time.sleep(sensor.config.update_interval)
                
            except Exception as e:
                logger.error(f"Error en sensor {sensor.config.sensor_id}: {e}")
                time.sleep(10)
                
    def _prepare_sensor_data(self, sensor: RioLeonSensor) -> dict:
        """Prepara datos específicos del río León"""
        timestamp = datetime.now().isoformat() + 'Z'
        
        base_data = {
            'gate_id': sensor.config.station_id,
            'sensor_id': sensor.config.sensor_id,
            'timestamp': timestamp,
            'source_device': f'rio_leon_{sensor.config.sensor_type}_{sensor.config.sensor_id}',
            'location': sensor.config.location,
            'coordinates': sensor.config.coordinates,
            'quality_status': sensor.quality_status
        }
        
        # Datos específicos por tipo de sensor
        if sensor.config.sensor_type == 'freatic_level':
            base_data.update({
                'level_m': round(sensor.current_value, 3),
                'sensor_type': 'freatic_level',
                'position_percent': random.uniform(30, 70)  # posición asociada
            })
        elif sensor.config.sensor_type == 'river_level':
            base_data.update({
                'level_m': round(sensor.current_value, 3),
                'sensor_type': 'river_level', 
                'position_percent': random.uniform(20, 80)
            })
        elif sensor.config.sensor_type == 'gate':
            gate_sensor = sensor
            base_data.update({
                'position_percent': round(sensor.current_value, 2),
                'level_m': random.uniform(1.0, 4.0),
                'operation_mode': getattr(gate_sensor, 'operation_mode', 'AUTO'),
                'gate_status': getattr(gate_sensor, 'get_operation_status', lambda: 'PARTIAL')()
            })
        else:
            base_data.update({
                'level_m': random.uniform(1.0, 3.0),
                'position_percent': random.uniform(20, 80),
                'flow_velocity': round(sensor.current_value, 3) if sensor.config.sensor_type == 'flow' else None
            })
            
        return base_data
        
    def _send_data(self, data: dict):
        """Envía datos a la API"""
        try:
            response = requests.post(
                f"{self.api_url}/api/data",
                json=data,
                timeout=10
            )
            
            if response.status_code == 200:
                logger.debug(f"Datos enviados - Sensor {data['sensor_id']}")
            else:
                logger.warning(f"Error al enviar datos: {response.status_code}")
                
        except requests.exceptions.RequestException as e:
            logger.error(f"Error de conexión: {e}")
            
    def get_system_status(self) -> dict:
        """Estado completo del sistema de Chigorodó"""
        return {
            'location': 'Chigorodó, Antioquia - Río León',
            'project': 'Finca La Plana - Sistema de Monitoreo',
            'sensors_active': len([s for s in self.sensors.values() if s.is_active]),
            'sensors_total': len(self.sensors),
            'stations': 2,
            'last_update': datetime.now().isoformat(),
            'sensors_detail': [sensor.get_sensor_status() for sensor in self.sensors.values()]
        }
        
    def stop_simulation(self):
        """Detiene la simulación"""
        self.running = False
        logger.info("Deteniendo simulación Río León...")

def main():
    """Función principal para Chigorodó"""
    print("=" * 70)
    print("🌊 SISTEMA DE MONITOREO RÍO LEÓN - CHIGORODÓ 🌊")
    print("   Finca La Plana - Sensores Virtuales Avanzados")
    print("   Simulación de Niveles Freáticos - Urabá Antioquia")
    print("=" * 70)
    
    # Crear gestor específico
    manager = ChigorodSensorManager()
    
    # Crear sensores específicos
    manager.create_default_sensors()
    
    # Mostrar configuración
    config = get_chigorodo_config()
    print(f"\n📍 UBICACIÓN: {config['location'].municipality}, {config['location'].department}")
    print(f"🏞️  RÍO: {config['river'].name} ({config['river'].length_km} km)")
    print(f"🌡️  CLIMA: {config['location'].climate_zone}")
    print(f"💧 PRECIPITACIÓN ANUAL: {config['climate'].annual_rainfall_mm} mm")
    print(f"🏭 ESTACIONES: {len(config['stations'])} estaciones de monitoreo")
    print(f"🔧 SENSORES: {len(manager.sensors)} sensores virtuales activos")
    
    # Iniciar simulación
    manager.start_simulation()
    
    try:
        print(f"\n✅ Simulación iniciada exitosamente")
        print(f"🔗 Enviando datos a: {manager.api_url}")
        print("⏹️  Presiona Ctrl+C para detener...")
        
        while True:
            time.sleep(60)
            status = manager.get_system_status()
            print(f"\n--- Estado Sistema ({datetime.now().strftime('%H:%M:%S')}) ---")
            print(f"Sensores activos: {status['sensors_active']}/{status['sensors_total']}")
            
            # Mostrar algunos valores actuales
            for sensor in list(manager.sensors.values())[:4]:  # primeros 4 sensores
                print(f"  {sensor.config.name}: {sensor.current_value:.3f} {sensor.config.unit}")
                
    except KeyboardInterrupt:
        print("\n\n🛑 Deteniendo simulación Río León...")
        manager.stop_simulation()
        print("✅ Sistema detenido correctamente.")

if __name__ == "__main__":
    main()
