#!/usr/bin/env python3
"""
Script para inicializar base de datos con datos de prueba
Crea estaciones de bombeo, datos históricos y configuraciones
"""

import random
import sqlite3
from datetime import datetime, timedelta
from database import db, GateStatus, WaterLevel, PumpingStation, FlowSummary
from app import app
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class TestDataGenerator:
    """Generador de datos de prueba para la estación de bombeo"""
    
    def __init__(self):
        self.stations_config = [
            {
                'name': 'Estación Principal Norte',
                'location': 'Canal Norte - Km 12.5',
                'gate_diameter': 2.5,
                'gate_length': 6.0,
                'weir_type': 'rectangular',
                'weir_width': 3.2,
                'cd_coefficient': 0.62
            },
            {
                'name': 'Estación Principal Sur', 
                'location': 'Canal Sur - Km 8.3',
                'gate_diameter': 2.0,
                'gate_length': 5.5,
                'weir_type': 'rectangular',
                'weir_width': 2.8,
                'cd_coefficient': 0.58
            },
            {
                'name': 'Estación Auxiliar Este',
                'location': 'Canal Auxiliar Este',
                'gate_diameter': 1.8,
                'gate_length': 4.0,
                'weir_type': 'triangular',
                'weir_width': 2.2,
                'cd_coefficient': 0.60
            },
            {
                'name': 'Estación de Emergencia',
                'location': 'Canal de Desagüe Principal',
                'gate_diameter': 3.0,
                'gate_length': 8.0,
                'weir_type': 'rectangular',
                'weir_width': 4.0,
                'cd_coefficient': 0.65
            }
        ]
    
    def create_pumping_stations(self):
        """Crea las estaciones de bombeo de prueba"""
        logger.info("Creando estaciones de bombeo...")
        
        for config in self.stations_config:
            existing = PumpingStation.query.filter_by(name=config['name']).first()
            if not existing:
                station = PumpingStation(
                    name=config['name'],
                    location=config['location'],
                    gate_diameter=config['gate_diameter'],
                    gate_length=config['gate_length'],
                    weir_type=config['weir_type'],
                    weir_width=config['weir_width'],
                    cd_coefficient=config['cd_coefficient']
                )
                db.session.add(station)
                logger.info(f"  Creada: {config['name']}")
            else:
                logger.info(f"  Ya existe: {config['name']}")
        
        db.session.commit()
    
    def generate_realistic_pattern(self, base_value, time_offset_hours, variation_factor=0.3):
        """Genera un patrón realista basado en la hora del día"""
        hour = (datetime.now().hour + time_offset_hours) % 24
        
        # Patrón diario típico para operación de compuertas
        if 6 <= hour <= 9:  # Mañana - incremento gradual
            factor = 1.0 + (hour - 6) * 0.15
        elif 9 <= hour <= 16:  # Día - actividad alta
            factor = 1.4 + random.uniform(-0.2, 0.2)
        elif 16 <= hour <= 20:  # Tarde - descenso gradual
            factor = 1.4 - (hour - 16) * 0.1
        elif 20 <= hour <= 23:  # Noche temprana
            factor = 1.0 - random.uniform(0, 0.3)
        else:  # Madrugada - actividad mínima
            factor = 0.6 + random.uniform(0, 0.2)
        
        # Añadir variación estacional (simplificada)
        seasonal_factor = 1.0 + 0.2 * random.gauss(0, 1)
        
        # Calcular valor final
        value = base_value * factor * seasonal_factor
        
        # Añadir variación aleatoria
        variation = random.gauss(0, variation_factor * value)
        
        return max(0, value + variation)
    
    def generate_historical_data(self, days_back=30):
        """Genera datos históricos para las últimas N días"""
        logger.info(f"Generando datos históricos para {days_back} días...")
        
        # Obtener estaciones existentes
        stations = PumpingStation.query.all()
        if not stations:
            logger.error("No hay estaciones creadas. Ejecute create_pumping_stations() primero.")
            return
        
        # Generar datos para cada estación
        for station in stations:
            logger.info(f"  Generando datos para: {station.name}")
            
            # Calcular rango de tiempo
            end_time = datetime.now()
            start_time = end_time - timedelta(days=days_back)
            
            # Generar datos cada 15-60 minutos
            current_time = start_time
            gate_position = random.uniform(20, 80)  # Posición inicial
            water_level = random.uniform(1.0, 3.0)   # Nivel inicial
            
            data_points = 0
            while current_time <= end_time:
                # Calcular tiempo transcurrido en horas
                hours_offset = (current_time - start_time).total_seconds() / 3600
                
                # Generar nuevos valores con patrones realistas
                target_gate_position = self.generate_realistic_pattern(50, hours_offset, 0.25)
                target_water_level = self.generate_realistic_pattern(2.0, hours_offset, 0.15)
                
                # Movimiento gradual hacia valores objetivo
                gate_position += (target_gate_position - gate_position) * 0.1
                gate_position = max(0, min(100, gate_position))
                
                water_level += (target_water_level - water_level) * 0.05
                water_level = max(0.1, min(5.0, water_level))
                
                # Calcular flujo basado en nivel (simplificado)
                flow = max(0, water_level * station.weir_width * 0.8 + random.gauss(0, 0.1))
                
                # Determinar estado de compuerta
                if gate_position >= 95:
                    event_type = 'OPEN'
                elif gate_position <= 5:
                    event_type = 'CLOSE'
                else:
                    # Probabilidad de movimiento basada en cambios recientes
                    if abs(target_gate_position - gate_position) > 5:
                        event_type = 'MOVING'
                    else:
                        event_type = random.choice(['OPEN', 'CLOSE', 'MOVING'])
                
                # Crear registro de compuerta
                gate_status = GateStatus(
                    gate_id=station.id,
                    position_percent=round(gate_position, 2),
                    event_type=event_type,
                    timestamp=current_time,
                    source_device=f'test_sensor_{station.id}'
                )
                db.session.add(gate_status)
                
                # Crear registro de nivel de agua
                water_record = WaterLevel(
                    location_id=station.id,
                    level_m=round(water_level, 3),
                    flow_m3s=round(flow, 4),
                    timestamp=current_time,
                    source_device=f'test_level_sensor_{station.id}'
                )
                db.session.add(water_record)
                
                data_points += 1
                
                # Avanzar tiempo (entre 15 y 60 minutos)
                interval = random.randint(15, 60)
                current_time += timedelta(minutes=interval)
                
                # Commit cada 100 registros para evitar transacciones muy grandes
                if data_points % 100 == 0:
                    db.session.commit()
            
            logger.info(f"    Generados {data_points} puntos de datos")
        
        # Commit final
        db.session.commit()
        logger.info("Datos históricos generados exitosamente")
    
    def generate_daily_summaries(self, days_back=30):
        """Genera resúmenes diarios basados en los datos existentes"""
        logger.info(f"Generando resúmenes diarios para {days_back} días...")
        
        stations = PumpingStation.query.all()
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=days_back)
        
        current_date = start_date
        while current_date <= end_date:
            for station in stations:
                # Verificar si ya existe resumen para este día
                existing = FlowSummary.query.filter_by(
                    location_id=station.id,
                    date=current_date
                ).first()
                
                if existing:
                    continue
                
                # Calcular estadísticas del día
                day_start = datetime.combine(current_date, datetime.min.time())
                day_end = datetime.combine(current_date, datetime.max.time())
                
                # Obtener datos del día
                water_records = WaterLevel.query.filter(
                    WaterLevel.location_id == station.id,
                    WaterLevel.timestamp >= day_start,
                    WaterLevel.timestamp <= day_end
                ).all()
                
                gate_records = GateStatus.query.filter(
                    GateStatus.gate_id == station.id,
                    GateStatus.timestamp >= day_start,
                    GateStatus.timestamp <= day_end
                ).all()
                
                if water_records:
                    # Calcular volumen total (aproximado)
                    avg_flow = sum(r.flow_m3s for r in water_records) / len(water_records)
                    total_volume = avg_flow * 24 * 3600  # m³/día
                    
                    # Pico de flujo
                    peak_flow = max(r.flow_m3s for r in water_records)
                    
                    # Horas de compuerta abierta
                    open_records = [r for r in gate_records if r.position_percent > 10]
                    gate_open_hours = len(open_records) * 0.5  # Estimación
                    
                    # Crear resumen
                    summary = FlowSummary(
                        location_id=station.id,
                        date=current_date,
                        total_m3=round(total_volume, 1),
                        peak_flow_m3s=round(peak_flow, 4),
                        gate_open_hours=round(gate_open_hours, 2)
                    )
                    db.session.add(summary)
            
            current_date += timedelta(days=1)
        
        db.session.commit()
        logger.info("Resúmenes diarios generados exitosamente")
    
    def create_test_scenarios(self):
        """Crea escenarios de prueba específicos"""
        logger.info("Creando escenarios de prueba específicos...")
        
        now = datetime.now()
        
        # Escenario 1: Emergencia reciente
        emergency_time = now - timedelta(hours=2)
        emergency_gate = GateStatus(
            gate_id=4,  # Estación de emergencia
            position_percent=100.0,
            event_type='OPEN',
            timestamp=emergency_time,
            source_device='emergency_system'
        )
        db.session.add(emergency_gate)
        
        emergency_level = WaterLevel(
            location_id=4,
            level_m=4.2,
            flow_m3s=15.8,
            timestamp=emergency_time,
            source_device='emergency_level_sensor'
        )
        db.session.add(emergency_level)
        
        # Escenario 2: Mantenimiento programado
        maintenance_time = now - timedelta(hours=6)
        maintenance_gate = GateStatus(
            gate_id=2,
            position_percent=0.0,
            event_type='CLOSE',
            timestamp=maintenance_time,
            source_device='maintenance_system'
        )
        db.session.add(maintenance_gate)
        
        # Escenario 3: Operación normal con variaciones
        for i in range(1, 4):  # Estaciones 1, 2, 3
            for j in range(10):  # 10 lecturas recientes
                time_offset = now - timedelta(minutes=j*5)
                
                position = 45 + random.gauss(0, 15)
                position = max(0, min(100, position))
                
                level = 2.0 + random.gauss(0, 0.5)
                level = max(0.1, min(4.0, level))
                
                flow = level * 2.5 + random.gauss(0, 0.3)
                flow = max(0, flow)
                
                gate = GateStatus(
                    gate_id=i,
                    position_percent=round(position, 2),
                    event_type='MOVING' if j % 3 == 0 else 'OPEN',
                    timestamp=time_offset,
                    source_device=f'normal_sensor_{i}'
                )
                db.session.add(gate)
                
                water = WaterLevel(
                    location_id=i,
                    level_m=round(level, 3),
                    flow_m3s=round(flow, 4),
                    timestamp=time_offset,
                    source_device=f'normal_level_sensor_{i}'
                )
                db.session.add(water)
        
        db.session.commit()
        logger.info("Escenarios de prueba creados exitosamente")

def initialize_database():
    """Inicializa completamente la base de datos con datos de prueba"""
    logger.info("=== Inicializando Base de Datos con Datos de Prueba ===")
    
    with app.app_context():
        try:
            # Crear todas las tablas
            logger.info("Creando estructura de base de datos...")
            db.create_all()
            
            # Crear generador de datos
            generator = TestDataGenerator()
            
            # Crear estaciones de bombeo
            generator.create_pumping_stations()
            
            # Generar datos históricos
            generator.generate_historical_data(days_back=30)
            
            # Generar resúmenes diarios
            generator.generate_daily_summaries(days_back=30)
            
            # Crear escenarios de prueba específicos
            generator.create_test_scenarios()
            
            # Verificar datos creados
            stations_count = PumpingStation.query.count()
            gates_count = GateStatus.query.count()
            water_count = WaterLevel.query.count()
            summary_count = FlowSummary.query.count()
            
            logger.info("=== Resumen de datos creados ===")
            logger.info(f"Estaciones de bombeo: {stations_count}")
            logger.info(f"Registros de compuertas: {gates_count}")
            logger.info(f"Registros de nivel de agua: {water_count}")
            logger.info(f"Resúmenes diarios: {summary_count}")
            
            logger.info("¡Base de datos inicializada exitosamente!")
            
            return True
            
        except Exception as e:
            logger.error(f"Error al inicializar base de datos: {e}")
            db.session.rollback()
            return False

def verify_database():
    """Verifica que los datos se hayan creado correctamente"""
    logger.info("=== Verificando Base de Datos ===")
    
    with app.app_context():
        try:
            # Verificar estaciones
            stations = PumpingStation.query.all()
            logger.info(f"Estaciones encontradas: {len(stations)}")
            for station in stations:
                logger.info(f"  - {station.name} (ID: {station.id})")
            
            # Verificar datos recientes
            recent_gates = GateStatus.query.filter(
                GateStatus.timestamp >= datetime.now() - timedelta(hours=24)
            ).count()
            
            recent_water = WaterLevel.query.filter(
                WaterLevel.timestamp >= datetime.now() - timedelta(hours=24)
            ).count()
            
            logger.info(f"Registros recientes (últimas 24h):")
            logger.info(f"  - Compuertas: {recent_gates}")
            logger.info(f"  - Nivel de agua: {recent_water}")
            
            # Verificar rango de datos
            oldest_record = GateStatus.query.order_by(GateStatus.timestamp).first()
            newest_record = GateStatus.query.order_by(GateStatus.timestamp.desc()).first()
            
            if oldest_record and newest_record:
                logger.info(f"Rango de datos:")
                logger.info(f"  - Desde: {oldest_record.timestamp}")
                logger.info(f"  - Hasta: {newest_record.timestamp}")
            
            logger.info("Verificación completada.")
            return True
            
        except Exception as e:
            logger.error(f"Error en verificación: {e}")
            return False

if __name__ == "__main__":
    print("Inicializando sistema con datos de prueba...")
    
    if initialize_database():
        print("\n" + "="*50)
        verify_database()
        print("="*50)
        print("\nSistema listo para usar!")
        print("Puede iniciar la aplicación con: python app.py")
        print("Y los sensores virtuales con: python virtual_sensors.py")
    else:
        print("Error al inicializar la base de datos.")
        exit(1)
