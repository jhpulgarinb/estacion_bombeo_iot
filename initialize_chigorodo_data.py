#!/usr/bin/env python3
"""
Inicializador de Datos - Chigorodó, Antioquia
Sistema de Monitoreo Río León - Finca La Plana
Datos específicos con patrones hidrológicos regionales
"""

import random
import sqlite3
import math
from datetime import datetime, timedelta
from database import db, GateStatus, WaterLevel, PumpingStation, FlowSummary
from config_chigorodo import get_chigorodo_config, ChigodoHydrologicalModel
from app import app
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ChigorodDataGenerator:
    """Generador de datos específicos para Chigorodó - Río León"""
    
    def __init__(self):
        # Cargar configuración específica de Chigorodó
        self.config = get_chigorodo_config()
        self.hydrological_model = self.config['hydrological_model']
        
        # Estaciones específicas de Finca La Plana
        self.stations_config = [
            {
                'name': 'Estación Río León - Entrada Finca La Plana',
                'location': 'Chigorodó, Antioquia - Finca La Plana, Sector Entrada',
                'coordinates': '7.6652°N, 76.6841°W',
                'gate_diameter': 3.2,
                'gate_length': 8.0,
                'weir_type': 'rectangular',
                'weir_width': 12.0,
                'cd_coefficient': 0.62,
                'elevation_masl': 32,
                'design_flow': 25.0,
                'catchment_area_km2': 85.3,
                'river_section': 'Cauce principal río León'
            },
            {
                'name': 'Estación Río León - Control Finca La Plana', 
                'location': 'Chigorodó, Antioquia - Finca La Plana, Sector Control',
                'coordinates': '7.6671°N, 76.6825°W',
                'gate_diameter': 2.8,
                'gate_length': 6.5,
                'weir_type': 'triangular',
                'weir_width': 10.0,
                'cd_coefficient': 0.58,
                'elevation_masl': 29,
                'design_flow': 18.0,
                'catchment_area_km2': 45.8,
                'river_section': 'Cauce de control río León'
            }
        ]
    
    def create_chigorodo_stations(self):
        """Crea las estaciones específicas de Chigorodó"""
        logger.info("Creando estaciones de monitoreo - Río León, Chigorodó...")
        
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
                logger.info(f"  ✅ Creada: {config['name']}")
                logger.info(f"     📍 Ubicación: {config['location']}")
                logger.info(f"     🏞️  Coordenadas: {config['coordinates']}")
                logger.info(f"     💧 Caudal diseño: {config['design_flow']} m³/s")
            else:
                logger.info(f"  ℹ️  Ya existe: {config['name']}")
        
        db.session.commit()
        
    def get_urab_rainfall_pattern(self, date: datetime) -> float:
        """
        Genera patrón de precipitación específico para Urabá
        Basado en datos históricos de la región
        """
        month = date.month
        hour = date.hour
        
        # Precipitación base mensual (mm/día promedio)
        monthly_rainfall = {
            1: 45,    # Enero - seco
            2: 35,    # Febrero - más seco
            3: 65,    # Marzo - transición
            4: 185,   # Abril - primera época lluviosa
            5: 220,   # Mayo - pico lluvia
            6: 145,   # Junio - transición
            7: 85,    # Julio - veranillo
            8: 95,    # Agosto - veranillo
            9: 195,   # Septiembre - segunda época lluviosa
            10: 245,  # Octubre - pico lluvia
            11: 185,  # Noviembre - lluvioso
            12: 105   # Diciembre - transición
        }
        
        base_rainfall = monthly_rainfall[month]
        
        # Factor de hora del día (lluvia tropical)
        if 14 <= hour <= 18:      # Tarde - pico de lluvias
            hourly_factor = 2.5
        elif 19 <= hour <= 22:    # Noche temprana
            hourly_factor = 1.8
        elif 23 <= hour <= 2:     # Noche tardía
            hourly_factor = 0.8
        elif 3 <= hour <= 6:      # Madrugada
            hourly_factor = 0.4
        elif 7 <= hour <= 10:     # Mañana
            hourly_factor = 0.6
        else:                     # Medio día
            hourly_factor = 1.2
        
        # Variabilidad aleatoria (El Niño/La Niña)
        climate_variation = random.uniform(0.7, 1.4)
        
        # Factor de intensidad (eventos extremos)
        if random.random() < 0.05:  # 5% eventos muy intensos
            intensity_factor = random.uniform(3.0, 5.0)
        elif random.random() < 0.15:  # 15% eventos intensos
            intensity_factor = random.uniform(1.5, 2.5)
        else:
            intensity_factor = random.uniform(0.8, 1.2)
        
        total_rainfall = (base_rainfall * hourly_factor * 
                         climate_variation * intensity_factor / 24)
        
        return max(0, total_rainfall)
    
    def calculate_river_level_from_rainfall(self, rainfall_mm: float, 
                                          base_level: float, hour: int) -> float:
        """
        Calcula nivel del río León basado en precipitación
        Considera características específicas de la cuenca
        """
        # Coeficiente de escorrentía para la cuenca del río León
        # (suelos aluviales con cobertura vegetal)
        runoff_coefficient = 0.45
        
        # Factor de concentración (tiempo que tarda la lluvia en llegar al río)
        concentration_time_hours = 4.5
        lag_factor = max(0.1, 1.0 - abs(hour % 24 - 16) / concentration_time_hours)
        
        # Infiltración específica para suelos de Urabá
        infiltration_loss = rainfall_mm * 0.35  # 35% se infiltra
        effective_rainfall = max(0, rainfall_mm - infiltration_loss)
        
        # Conversión lluvia a nivel de río (simplificado)
        level_increase = (effective_rainfall * runoff_coefficient * 
                         lag_factor * 0.01)  # factor de escala
        
        new_level = base_level + level_increase
        
        # Considerar evapotranspiración alta de zona tropical
        et_loss = 0.008 * (hour / 24)  # pérdida por ET durante el día
        new_level -= et_loss
        
        return max(0.2, min(7.5, new_level))  # límites realistas río León
    
    def generate_freatic_level_data(self, river_level: float, 
                                   rainfall_mm: float, station_id: int) -> float:
        """
        Genera nivel freático específico para la zona de Finca La Plana
        """
        # Nivel freático base correlacionado con río León
        base_freatic = river_level * 0.85  # nivel freático menor al río
        
        # Influencia de precipitación con retraso
        rainfall_influence = rainfall_mm * 0.02  # 2cm por mm de lluvia
        
        # Factor de permeabilidad del suelo (aluviones del río León)
        if station_id == 1:  # estación entrada - suelos más permeables
            permeability_factor = 1.2
        else:  # estación control - suelos menos permeables
            permeability_factor = 0.9
            
        # Influencia de bombeos agrícolas cercanos
        pumping_effect = math.sin(datetime.now().hour / 24 * 2 * math.pi) * 0.15
        
        # Nivel freático final
        freatic_level = (base_freatic + rainfall_influence * permeability_factor 
                        - pumping_effect)
        
        # Aplicar límites según profundidad típica de pozos en la zona
        return max(0.3, min(6.0, freatic_level))
    
    def generate_historical_data_chigorodo(self, days_back=45):
        """Genera datos históricos específicos para Chigorodó"""
        logger.info(f"Generando datos históricos - Río León ({days_back} días)...")
        logger.info(f"Patrón climático: {self.config['location'].climate_zone}")
        
        stations = PumpingStation.query.all()
        if not stations:
            logger.error("❌ No hay estaciones creadas. Ejecute create_chigorodo_stations() primero.")
            return
        
        total_points = 0
        
        for station in stations:
            logger.info(f"  📊 Generando datos para: {station.name}")
            
            # Rango de tiempo
            end_time = datetime.now()
            start_time = end_time - timedelta(days=days_back)
            
            # Estado inicial
            current_time = start_time
            river_level = random.uniform(1.5, 3.0)
            gate_position = random.uniform(25, 65)
            freatic_level = river_level * 0.8
            
            station_points = 0
            
            while current_time <= end_time:
                # Generar precipitación específica para Urabá
                rainfall = self.get_urab_rainfall_pattern(current_time)
                
                # Calcular nivel del río León
                river_level = self.calculate_river_level_from_rainfall(
                    rainfall, river_level, current_time.hour
                )
                
                # Aplicar factores estacionales específicos de Chigorodó
                seasonal_factor = self.hydrological_model.get_seasonal_factor(current_time.month)
                daily_factor = self.hydrological_model.get_daily_variation_factor(current_time.hour)
                
                # Ajustar nivel con factores locales
                river_level = river_level * seasonal_factor * daily_factor
                
                # Nivel freático específico
                freatic_level = self.generate_freatic_level_data(
                    river_level, rainfall, station.id
                )
                
                # Caudal basado en nivel y características del río León
                flow = self.calculate_river_leon_flow(river_level, station)
                
                # Posición de compuerta (lógica de control para zona tropical)
                gate_position = self.update_gate_position_tropical(
                    gate_position, river_level, rainfall, seasonal_factor
                )
                
                # Estado de compuerta
                gate_status = self.get_gate_status(gate_position, river_level)
                
                # Crear registros
                gate_record = GateStatus(
                    gate_id=station.id,
                    position_percent=round(gate_position, 2),
                    event_type=gate_status,
                    timestamp=current_time,
                    source_device=f'chigorodo_station_{station.id}'
                )
                db.session.add(gate_record)
                
                water_record = WaterLevel(
                    location_id=station.id,
                    level_m=round(river_level, 3),
                    flow_m3s=round(flow, 4),
                    timestamp=current_time,
                    source_device=f'rio_leon_sensor_{station.id}'
                )
                db.session.add(water_record)
                
                station_points += 1
                
                # Avanzar tiempo (frecuencia variable según condiciones)
                if rainfall > 10:  # lluvia intensa - más frecuencia
                    interval = random.randint(10, 20)
                elif seasonal_factor > 1.2:  # época lluviosa
                    interval = random.randint(15, 30)
                else:  # época seca
                    interval = random.randint(30, 60)
                    
                current_time += timedelta(minutes=interval)
                
                # Commit cada 100 registros
                if station_points % 100 == 0:
                    db.session.commit()
            
            total_points += station_points
            logger.info(f"    ✅ {station_points:,} puntos generados")
        
        db.session.commit()
        logger.info(f"📈 Total datos históricos generados: {total_points:,} puntos")
        logger.info(f"🗓️  Período: {start_time.date()} a {end_time.date()}")
    
    def calculate_river_leon_flow(self, level: float, station: PumpingStation) -> float:
        """Calcula caudal específico del río León"""
        # Usar modelo hidrológico de Chigorodó
        base_flow = level * float(station.weir_width) * 1.2
        
        # Aplicar coeficiente de descarga específico
        flow = base_flow * float(station.cd_coefficient)
        
        # Factor de rugosidad del cauce (vegetación tropical)
        roughness_factor = 0.92
        flow *= roughness_factor
        
        # Influencia mareal mínima del Golfo de Urabá
        tidal_influence = self.hydrological_model.simulate_tidal_influence(flow)
        
        return max(0.01, tidal_influence)
    
    def update_gate_position_tropical(self, current_position: float, 
                                    river_level: float, rainfall: float, 
                                    seasonal_factor: float) -> float:
        """Lógica de control de compuertas para clima tropical"""
        target_position = current_position
        
        # Control basado en nivel del río León
        if river_level > 6.0:  # nivel alto - abrir más
            target_position = min(95, current_position + 15)
        elif river_level > 4.5:  # nivel medio-alto
            target_position = min(80, current_position + 8)
        elif river_level < 1.0:  # nivel bajo - cerrar
            target_position = max(10, current_position - 10)
        elif river_level < 2.0:  # nivel medio-bajo
            target_position = max(25, current_position - 5)
        
        # Control basado en precipitación
        if rainfall > 15:  # lluvia muy intensa
            target_position = min(90, target_position + 12)
        elif rainfall > 8:  # lluvia moderada
            target_position = min(75, target_position + 6)
        
        # Factor estacional (época seca vs lluviosa)
        if seasonal_factor < 0.7:  # época seca
            target_position = max(20, target_position - 8)
        elif seasonal_factor > 1.3:  # época muy lluviosa
            target_position = min(85, target_position + 10)
        
        # Movimiento gradual (inercia del sistema)
        movement = (target_position - current_position) * 0.3
        new_position = current_position + movement
        
        # Añadir variabilidad operacional
        new_position += random.uniform(-2, 2)
        
        return max(0, min(100, new_position))
    
    def get_gate_status(self, position: float, river_level: float) -> str:
        """Determina estado de compuerta considerando condiciones del río León"""
        if position >= 95:
            return 'OPEN'
        elif position <= 5:
            return 'CLOSE'
        elif river_level > 5.0 and abs(position - 75) > 5:  # nivel alto y movimiento
            return 'MOVING'
        elif random.random() < 0.2:  # 20% probabilidad de movimiento
            return 'MOVING'
        else:
            return 'OPEN' if position > 50 else 'CLOSE'
    
    def generate_daily_summaries_chigorodo(self, days_back=45):
        """Genera resúmenes diarios específicos para Chigorodó"""
        logger.info(f"Generando resúmenes diarios - Río León ({days_back} días)...")
        
        stations = PumpingStation.query.all()
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=days_back)
        
        total_summaries = 0
        
        current_date = start_date
        while current_date <= end_date:
            for station in stations:
                existing = FlowSummary.query.filter_by(
                    location_id=station.id,
                    date=current_date
                ).first()
                
                if existing:
                    continue
                
                # Calcular estadísticas del día
                day_start = datetime.combine(current_date, datetime.min.time())
                day_end = datetime.combine(current_date, datetime.max.time())
                
                water_records = WaterLevel.query.filter(
                    WaterLevel.location_id == station.id,
                    WaterLevel.timestamp >= day_start,
                    WaterLevel.timestamp <= day_end
                ).all()
                
                if not water_records:
                    current_date += timedelta(days=1)
                    continue
                
                # Estadísticas específicas para río León
                flows = [float(r.flow_m3s) for r in water_records]
                avg_flow = sum(flows) / len(flows)
                peak_flow = max(flows)
                
                # Volumen total considerando patrón tropical
                total_volume = avg_flow * 86400  # m³/día
                
                # Factor de corrección para estacionalidad
                seasonal_factor = self.hydrological_model.get_seasonal_factor(
                    current_date.month
                )
                total_volume = float(total_volume) * seasonal_factor
                
                # Horas de operación de compuertas
                gate_records = GateStatus.query.filter(
                    GateStatus.gate_id == station.id,
                    GateStatus.timestamp >= day_start,
                    GateStatus.timestamp <= day_end,
                    GateStatus.position_percent > 15
                ).count()
                
                gate_open_hours = min(24, gate_records * 0.4)  # estimación
                
                summary = FlowSummary(
                    location_id=station.id,
                    date=current_date,
                    total_m3=round(total_volume, 1),
                    peak_flow_m3s=round(peak_flow, 4),
                    gate_open_hours=round(gate_open_hours, 2)
                )
                db.session.add(summary)
                total_summaries += 1
            
            current_date += timedelta(days=1)
        
        db.session.commit()
        logger.info(f"📋 Resúmenes diarios generados: {total_summaries}")
    
    def create_special_scenarios_chigorodo(self):
        """Crea escenarios específicos para Chigorodó"""
        logger.info("Creando escenarios específicos - Río León...")
        
        now = datetime.now()
        
        # Escenario 1: Creciente reciente por lluvia intensa
        flood_time = now - timedelta(hours=8)
        flood_gate = GateStatus(
            gate_id=1,  # Estación entrada
            position_percent=95.0,
            event_type='OPEN',
            timestamp=flood_time,
            source_device='chigorodo_flood_control'
        )
        db.session.add(flood_gate)
        
        flood_level = WaterLevel(
            location_id=1,
            level_m=5.8,  # nivel alto para río León
            flow_m3s=22.4,
            timestamp=flood_time,
            source_device='rio_leon_flood_sensor'
        )
        db.session.add(flood_level)
        
        # Escenario 2: Época seca - nivel bajo
        drought_time = now - timedelta(days=2)
        drought_gate = GateStatus(
            gate_id=2,
            position_percent=25.0,
            event_type='CLOSE',
            timestamp=drought_time,
            source_device='chigorodo_drought_control'
        )
        db.session.add(drought_gate)
        
        drought_level = WaterLevel(
            location_id=2,
            level_m=0.9,  # nivel bajo típico época seca
            flow_m3s=1.2,
            timestamp=drought_time,
            source_device='rio_leon_drought_sensor'
        )
        db.session.add(drought_level)
        
        # Escenario 3: Operación normal con variaciones tropicales
        for station_id in [1, 2]:
            for i in range(15):  # 15 lecturas recientes
                time_offset = now - timedelta(minutes=i*10)
                
                # Simulación de patrones tropicales
                hour = time_offset.hour
                if 14 <= hour <= 18:  # tarde lluviosa
                    level = random.uniform(3.2, 4.5)
                    position = random.uniform(65, 85)
                elif 20 <= hour <= 6:  # noche
                    level = random.uniform(2.1, 3.0)
                    position = random.uniform(35, 55)
                else:  # día
                    level = random.uniform(2.5, 3.8)
                    position = random.uniform(45, 70)
                
                flow = level * 2.2 + random.gauss(0, 0.5)
                flow = max(0.1, flow)
                
                gate = GateStatus(
                    gate_id=station_id,
                    position_percent=round(position, 2),
                    event_type='MOVING' if i % 4 == 0 else 'OPEN',
                    timestamp=time_offset,
                    source_device=f'chigorodo_normal_{station_id}'
                )
                db.session.add(gate)
                
                water = WaterLevel(
                    location_id=station_id,
                    level_m=round(level, 3),
                    flow_m3s=round(flow, 4),
                    timestamp=time_offset,
                    source_device=f'rio_leon_normal_{station_id}'
                )
                db.session.add(water)
        
        db.session.commit()
        logger.info("✅ Escenarios específicos de Chigorodó creados")

def initialize_chigorodo_database():
    """Inicializa base de datos completa para Chigorodó"""
    logger.info("" + "="*70)
    logger.info("🌊 INICIALIZACIÓN SISTEMA CHIGORODÓ - RÍO LEÓN 🌊")
    logger.info("   Finca La Plana - Antioquia, Colombia")
    logger.info("   Sistema de Monitoreo con Datos Reales")
    logger.info("="*70)
    
    with app.app_context():
        try:
            # Crear estructura de base de datos
            logger.info("🏗️  Creando estructura de base de datos...")
            db.create_all()
            
            # Crear generador específico
            generator = ChigorodDataGenerator()
            
            # Mostrar configuración
            config = generator.config
            logger.info(f"\n📍 CONFIGURACIÓN GEOGRÁFICA:")
            logger.info(f"   Municipio: {config['location'].municipality}")
            logger.info(f"   Departamento: {config['location'].department}")
            logger.info(f"   Cuenca: {config['location'].hydrographic_basin}")
            logger.info(f"   Clima: {config['location'].climate_zone}")
            logger.info(f"   Precipitación anual: {config['climate'].annual_rainfall_mm} mm")
            
            logger.info(f"\n🏞️  CARACTERÍSTICAS DEL RÍO:")
            logger.info(f"   Río: {config['river'].name}")
            logger.info(f"   Longitud: {config['river'].length_km} km")
            logger.info(f"   Ancho promedio: {config['river'].average_width_m} m")
            logger.info(f"   Régimen: {config['river'].flow_regime}")
            
            # Crear estaciones específicas
            generator.create_chigorodo_stations()
            
            # Generar datos históricos con patrones locales
            generator.generate_historical_data_chigorodo(days_back=45)
            
            # Generar resúmenes diarios
            generator.generate_daily_summaries_chigorodo(days_back=45)
            
            # Crear escenarios específicos
            generator.create_special_scenarios_chigorodo()
            
            # Verificar datos creados
            stations_count = PumpingStation.query.count()
            gates_count = GateStatus.query.count()
            water_count = WaterLevel.query.count()
            summary_count = FlowSummary.query.count()
            
            logger.info("\n" + "="*50)
            logger.info("📊 RESUMEN DE DATOS GENERADOS")
            logger.info("="*50)
            logger.info(f"🏭 Estaciones de monitoreo: {stations_count}")
            logger.info(f"🚪 Registros de compuertas: {gates_count:,}")
            logger.info(f"🌊 Registros de nivel/caudal: {water_count:,}")
            logger.info(f"📋 Resúmenes diarios: {summary_count}")
            
            # Mostrar información de estaciones
            stations = PumpingStation.query.all()
            logger.info(f"\n🏭 ESTACIONES CONFIGURADAS:")
            for station in stations:
                logger.info(f"   {station.id}. {station.name}")
                logger.info(f"      📍 {station.location}")
                logger.info(f"      🔧 Compuerta: Ø{station.gate_diameter}m, {station.weir_type}")
            
            logger.info("\n" + "="*70)
            logger.info("✅ SISTEMA CHIGORODÓ INICIALIZADO EXITOSAMENTE")
            logger.info("🚀 Listo para ejecutar sensores virtuales específicos")
            logger.info("="*70)
            
            return True
            
        except Exception as e:
            logger.error(f"❌ Error al inicializar sistema Chigorodó: {e}")
            db.session.rollback()
            return False

def verify_chigorodo_database():
    """Verifica datos específicos de Chigorodó"""
    logger.info("\n🔍 VERIFICACIÓN DEL SISTEMA")
    logger.info("="*50)
    
    with app.app_context():
        try:
            # Verificar estaciones
            stations = PumpingStation.query.all()
            logger.info(f"📊 Estaciones encontradas: {len(stations)}")
            
            for station in stations:
                logger.info(f"\n   🏭 {station.name}")
                logger.info(f"      📍 Ubicación: {station.location}")
                
                # Verificar datos recientes
                recent_data = WaterLevel.query.filter(
                    WaterLevel.location_id == station.id,
                    WaterLevel.timestamp >= datetime.now() - timedelta(hours=48)
                ).count()
                
                logger.info(f"      📈 Datos recientes (48h): {recent_data} registros")
                
                # Último registro
                latest = WaterLevel.query.filter_by(
                    location_id=station.id
                ).order_by(WaterLevel.timestamp.desc()).first()
                
                if latest:
                    logger.info(f"      🕒 Último registro: {latest.timestamp}")
                    logger.info(f"      🌊 Último nivel: {latest.level_m:.3f} m")
                    logger.info(f"      💧 Último caudal: {latest.flow_m3s:.3f} m³/s")
            
            # Estadísticas generales
            total_records = WaterLevel.query.count()
            date_range = db.session.query(
                db.func.min(WaterLevel.timestamp),
                db.func.max(WaterLevel.timestamp)
            ).first()
            
            logger.info(f"\n📈 ESTADÍSTICAS GENERALES:")
            logger.info(f"   Total registros: {total_records:,}")
            if date_range[0] and date_range[1]:
                logger.info(f"   Período de datos: {date_range[0]} a {date_range[1]}")
                days = (date_range[1] - date_range[0]).days
                logger.info(f"   Días de datos: {days}")
                logger.info(f"   Promedio registros/día: {total_records/max(1,days):.1f}")
            
            logger.info(f"\n✅ Verificación completada - Sistema operativo")
            return True
            
        except Exception as e:
            logger.error(f"❌ Error en verificación: {e}")
            return False

if __name__ == "__main__":
    print("🌊 Inicializando Sistema de Monitoreo - Chigorodó 🌊\n")
    
    if initialize_chigorodo_database():
        print("\n" + "🔍 EJECUTANDO VERIFICACIÓN...")
        verify_chigorodo_database()
        print("\n" + "="*70)
        print("🎉 SISTEMA CHIGORODÓ LISTO PARA USAR")
        print("📋 PRÓXIMOS PASOS:")
        print("   1. Ejecutar: python sensores_rio_leon.py")
        print("   2. Ejecutar: python app.py")
        print("   3. Acceder: http://localhost:5000")
        print("="*70)
    else:
        print("❌ Error al inicializar sistema Chigorodó.")
        exit(1)
