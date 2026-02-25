#!/usr/bin/env python3
"""
Simulador de sensores virtuales para estación de bombeo
Genera datos realistas de apertura de compuertas, niveles de agua y flujos
"""

import time
import json
import random
import requests
import threading
from datetime import datetime, timedelta
from dataclasses import dataclass
from typing import Dict, List
import math
import logging

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@dataclass
class SensorConfig:
    """Configuración de un sensor virtual"""
    sensor_id: int
    sensor_type: str  # 'gate', 'water_level', 'flow'
    name: str
    location: str
    min_value: float
    max_value: float
    noise_factor: float = 0.05  # Factor de ruido (5% por defecto)
    update_interval: int = 30  # Segundos entre actualizaciones

class VirtualSensor:
    """Sensor virtual base"""
    
    def __init__(self, config: SensorConfig):
        self.config = config
        self.current_value = random.uniform(config.min_value, config.max_value)
        self.target_value = self.current_value
        self.last_update = datetime.now()
        
    def add_noise(self, value: float) -> float:
        """Añade ruido realista al valor"""
        noise = random.gauss(0, self.config.noise_factor * abs(value))
        return value + noise
        
    def get_trend_factor(self) -> float:
        """Genera factor de tendencia basado en hora del día"""
        hour = datetime.now().hour
        
        if self.config.sensor_type == 'water_level':
            # Simula patrones de lluvia y drenaje
            if 6 <= hour <= 10 or 18 <= hour <= 22:  # Horas pico
                return 1.2
            elif 2 <= hour <= 5:  # Madrugada - menos actividad
                return 0.7
        elif self.config.sensor_type == 'gate':
            # Simula operación de compuertas
            if 8 <= hour <= 17:  # Horario laboral - más actividad
                return 1.5
            
        return 1.0

class GateSensor(VirtualSensor):
    """Sensor virtual de compuerta"""
    
    def __init__(self, config: SensorConfig):
        super().__init__(config)
        self.is_moving = False
        self.operation_mode = 'AUTO'  # 'AUTO', 'MANUAL', 'EMERGENCY'
        
    def update_value(self):
        """Actualiza el valor del sensor de compuerta"""
        trend = self.get_trend_factor()
        
        # Simular diferentes modos de operación
        if random.random() < 0.1:  # 10% probabilidad de cambio de modo
            self.operation_mode = random.choice(['AUTO', 'MANUAL', 'EMERGENCY'])
            
        if self.operation_mode == 'EMERGENCY':
            # En emergencia, abrir completamente
            self.target_value = self.config.max_value
        elif self.operation_mode == 'AUTO':
            # Operación automática basada en tendencias
            if trend > 1.2:
                self.target_value = min(self.config.max_value, 
                                      self.current_value + random.uniform(5, 15))
            elif trend < 0.8:
                self.target_value = max(self.config.min_value, 
                                      self.current_value - random.uniform(2, 8))
        
        # Movimiento gradual hacia el valor objetivo
        if abs(self.target_value - self.current_value) > 1:
            self.is_moving = True
            step = random.uniform(1, 3)
            if self.target_value > self.current_value:
                self.current_value = min(self.target_value, 
                                       self.current_value + step)
            else:
                self.current_value = max(self.target_value, 
                                       self.current_value - step)
        else:
            self.is_moving = False
            
        # Aplicar límites y ruido
        self.current_value = max(self.config.min_value, 
                               min(self.config.max_value, self.current_value))
        self.current_value = self.add_noise(self.current_value)
        
    def get_status(self) -> str:
        """Obtiene el estado de la compuerta"""
        if self.is_moving:
            return 'MOVING'
        elif self.current_value >= 95:
            return 'OPEN'
        elif self.current_value <= 5:
            return 'CLOSE'
        else:
            return 'PARTIAL'

class WaterLevelSensor(VirtualSensor):
    """Sensor virtual de nivel de agua"""
    
    def __init__(self, config: SensorConfig):
        super().__init__(config)
        self.base_level = (config.min_value + config.max_value) / 2
        
    def update_value(self):
        """Actualiza el nivel de agua"""
        trend = self.get_trend_factor()
        
        # Simular variaciones de nivel basadas en ciclos naturales
        time_factor = math.sin(time.time() / 3600) * 0.3  # Ciclo de 1 hora
        daily_factor = math.sin(time.time() / 86400) * 0.5  # Ciclo diario
        
        # Calcular nuevo valor
        variation = random.uniform(-0.1, 0.1) * trend
        self.current_value = (self.base_level + 
                            time_factor + 
                            daily_factor + 
                            variation)
        
        # Aplicar límites y ruido
        self.current_value = max(self.config.min_value, 
                               min(self.config.max_value, self.current_value))
        self.current_value = self.add_noise(self.current_value)

class VirtualSensorManager:
    """Gestor de sensores virtuales"""
    
    def __init__(self, api_url: str = "http://localhost:5000"):
        self.api_url = api_url
        self.sensors: Dict[int, VirtualSensor] = {}
        self.running = False
        self.threads = []
        
    def add_sensor(self, config: SensorConfig):
        """Añade un sensor virtual"""
        if config.sensor_type == 'gate':
            sensor = GateSensor(config)
        elif config.sensor_type == 'water_level':
            sensor = WaterLevelSensor(config)
        else:
            sensor = VirtualSensor(config)
            
        self.sensors[config.sensor_id] = sensor
        logger.info(f"Sensor añadido: {config.name} (ID: {config.sensor_id})")
        
    def start_simulation(self):
        """Inicia la simulación de todos los sensores"""
        self.running = True
        logger.info("Iniciando simulación de sensores virtuales...")
        
        for sensor_id, sensor in self.sensors.items():
            thread = threading.Thread(
                target=self._sensor_loop, 
                args=(sensor,),
                daemon=True
            )
            thread.start()
            self.threads.append(thread)
            
    def stop_simulation(self):
        """Detiene la simulación"""
        self.running = False
        logger.info("Deteniendo simulación de sensores virtuales...")
        
    def _sensor_loop(self, sensor: VirtualSensor):
        """Bucle principal de un sensor"""
        while self.running:
            try:
                # Actualizar valor del sensor
                sensor.update_value()
                
                # Preparar datos para enviar
                data = self._prepare_sensor_data(sensor)
                
                # Enviar datos a la API
                self._send_data(data)
                
                # Esperar hasta la siguiente actualización
                time.sleep(sensor.config.update_interval)
                
            except Exception as e:
                logger.error(f"Error en sensor {sensor.config.sensor_id}: {e}")
                time.sleep(10)  # Esperar antes de reintentar
                
    def _prepare_sensor_data(self, sensor: VirtualSensor) -> dict:
        """Prepara los datos del sensor para envío"""
        timestamp = datetime.now().isoformat() + 'Z'
        
        if isinstance(sensor, GateSensor):
            return {
                'gate_id': sensor.config.sensor_id,
                'position_percent': round(sensor.current_value, 2),
                'level_m': random.uniform(0.5, 3.0),  # Nivel asociado
                'timestamp': timestamp,
                'source_device': f'virtual_gate_{sensor.config.sensor_id}',
                'operation_mode': sensor.operation_mode,
                'status': sensor.get_status()
            }
        elif isinstance(sensor, WaterLevelSensor):
            return {
                'gate_id': sensor.config.sensor_id,
                'position_percent': random.uniform(0, 100),  # Posición asociada
                'level_m': round(sensor.current_value, 3),
                'timestamp': timestamp,
                'source_device': f'virtual_level_{sensor.config.sensor_id}'
            }
        else:
            return {
                'gate_id': sensor.config.sensor_id,
                'position_percent': random.uniform(0, 100),
                'level_m': round(sensor.current_value, 3),
                'timestamp': timestamp,
                'source_device': f'virtual_sensor_{sensor.config.sensor_id}'
            }
            
    def _send_data(self, data: dict):
        """Envía datos a la API"""
        try:
            response = requests.post(
                f"{self.api_url}/api/data",
                json=data,
                timeout=10
            )
            
            if response.status_code == 200:
                logger.debug(f"Datos enviados exitosamente: {data['gate_id']}")
            else:
                logger.warning(f"Error al enviar datos: {response.status_code}")
                
        except requests.exceptions.RequestException as e:
            logger.error(f"Error de conexión: {e}")
            
    def get_status(self) -> dict:
        """Obtiene el estado de todos los sensores"""
        status = {}
        for sensor_id, sensor in self.sensors.items():
            status[sensor_id] = {
                'name': sensor.config.name,
                'type': sensor.config.sensor_type,
                'current_value': round(sensor.current_value, 3),
                'last_update': sensor.last_update.isoformat(),
                'status': sensor.get_status() if hasattr(sensor, 'get_status') else 'ACTIVE'
            }
        return status

def create_default_sensors() -> List[SensorConfig]:
    """Crea configuración de sensores por defecto"""
    sensors = [
        # Compuertas principales
        SensorConfig(
            sensor_id=1,
            sensor_type='gate',
            name='Compuerta Principal A',
            location='Canal Principal - Entrada',
            min_value=0,
            max_value=100,
            noise_factor=0.03,
            update_interval=15
        ),
        SensorConfig(
            sensor_id=2,
            sensor_type='gate',
            name='Compuerta Principal B',
            location='Canal Principal - Salida',
            min_value=0,
            max_value=100,
            noise_factor=0.03,
            update_interval=20
        ),
        
        # Compuertas secundarias
        SensorConfig(
            sensor_id=3,
            sensor_type='gate',
            name='Compuerta Auxiliar 1',
            location='Canal Auxiliar Norte',
            min_value=0,
            max_value=100,
            noise_factor=0.05,
            update_interval=30
        ),
        
        # Sensores de nivel
        SensorConfig(
            sensor_id=11,
            sensor_type='water_level',
            name='Nivel Embalse Principal',
            location='Embalse - Zona Central',
            min_value=0.2,
            max_value=4.5,
            noise_factor=0.02,
            update_interval=10
        ),
        SensorConfig(
            sensor_id=12,
            sensor_type='water_level',
            name='Nivel Canal Entrada',
            location='Canal de Entrada',
            min_value=0.1,
            max_value=2.8,
            noise_factor=0.03,
            update_interval=15
        ),
        SensorConfig(
            sensor_id=13,
            sensor_type='water_level',
            name='Nivel Canal Salida',
            location='Canal de Salida',
            min_value=0.05,
            max_value=3.2,
            noise_factor=0.04,
            update_interval=12
        )
    ]
    
    return sensors

def main():
    """Función principal"""
    print("=== Simulador de Sensores Virtuales - Estación de Bombeo ===")
    
    # Crear gestor de sensores
    manager = VirtualSensorManager()
    
    # Añadir sensores por defecto
    for config in create_default_sensors():
        manager.add_sensor(config)
    
    # Iniciar simulación
    manager.start_simulation()
    
    try:
        print(f"\nSimulación iniciada con {len(manager.sensors)} sensores.")
        print("Presiona Ctrl+C para detener...")
        
        # Mostrar estado cada 60 segundos
        while True:
            time.sleep(60)
            status = manager.get_status()
            print(f"\n--- Estado de sensores ({datetime.now().strftime('%H:%M:%S')}) ---")
            for sensor_id, info in status.items():
                print(f"  {info['name']}: {info['current_value']} ({info['status']})")
                
    except KeyboardInterrupt:
        print("\n\nDeteniendo simulación...")
        manager.stop_simulation()
        print("Simulación detenida.")

if __name__ == "__main__":
    main()
