#!/usr/bin/env python3
"""
Configuración específica para el sistema de monitoreo
Río León - Chigorodó, Antioquia, Colombia
Finca La Plana - Estaciones de Bombeo
"""

import math
from datetime import datetime
from dataclasses import dataclass
from typing import Dict, List, Tuple

@dataclass
class GeographicLocation:
    """Información geográfica de la ubicación"""
    municipality: str
    department: str
    country: str
    latitude: float
    longitude: float
    elevation_masl: float  # metros sobre el nivel del mar
    climate_zone: str
    hydrographic_basin: str

@dataclass
class RiverCharacteristics:
    """Características específicas del río León"""
    name: str
    length_km: float
    average_width_m: float
    max_depth_m: float
    flow_regime: str
    seasonal_variation: Dict[str, float]  # variación por época
    flood_level_m: float
    drought_level_m: float
    critical_level_m: float

@dataclass
class ClimateData:
    """Datos climáticos específicos de Chigorodó"""
    annual_rainfall_mm: float
    dry_season_months: List[int]  # meses secos
    wet_season_months: List[int]  # meses lluviosos
    temperature_range: Tuple[float, float]  # min, max °C
    humidity_avg: float  # porcentaje
    evaporation_rate: float  # mm/día

# ============================================================================
# CONFIGURACIÓN GEOGRÁFICA ESPECÍFICA
# ============================================================================

CHIGORODO_LOCATION = GeographicLocation(
    municipality="Chigorodó",
    department="Antioquia",
    country="Colombia",
    latitude=7.6667,  # 7°40'N
    longitude=-76.6833,  # 76°41'W
    elevation_masl=28,  # metros sobre el nivel del mar
    climate_zone="Tropical húmedo de bosque muy húmedo (bmh-T)",
    hydrographic_basin="Cuenca del río Atrato - Subcuenca río León"
)

FINCA_LA_PLANA_COORDS = {
    'estacion_1': {
        'lat': 7.6652,
        'lon': -76.6841,
        'elevation': 32,
        'description': 'Estación Principal - Entrada Finca La Plana'
    },
    'estacion_2': {
        'lat': 7.6671,
        'lon': -76.6825,
        'elevation': 29,
        'description': 'Estación Secundaria - Sector Río León'
    }
}

# ============================================================================
# CARACTERÍSTICAS DEL RÍO LEÓN
# ============================================================================

RIO_LEON = RiverCharacteristics(
    name="Río León",
    length_km=85.2,
    average_width_m=45.0,
    max_depth_m=8.5,
    flow_regime="Tropical pluvial con dos picos",
    seasonal_variation={
        'enero': 0.7,      # época seca
        'febrero': 0.6,    # época seca
        'marzo': 0.8,      # transición
        'abril': 1.2,      # primera temporada lluviosa
        'mayo': 1.4,       # primera temporada lluviosa
        'junio': 1.1,      # transición
        'julio': 0.9,      # veranillo
        'agosto': 0.8,     # veranillo
        'septiembre': 1.3, # segunda temporada lluviosa
        'octubre': 1.5,    # segunda temporada lluviosa
        'noviembre': 1.3,  # segunda temporada lluviosa
        'diciembre': 0.9   # transición a seca
    },
    flood_level_m=6.5,
    drought_level_m=0.8,
    critical_level_m=7.2
)

# ============================================================================
# DATOS CLIMÁTICOS ESPECÍFICOS
# ============================================================================

CHIGORODO_CLIMATE = ClimateData(
    annual_rainfall_mm=2800,  # mm/año (alto por ser zona de Urabá)
    dry_season_months=[1, 2, 7, 8],  # enero, febrero, julio, agosto
    wet_season_months=[4, 5, 9, 10, 11],  # abril-mayo, sept-nov
    temperature_range=(24, 32),  # °C - tropical cálido
    humidity_avg=82,  # % - alta humedad por cercanía al mar
    evaporation_rate=4.2  # mm/día
)

# ============================================================================
# PARÁMETROS HIDROLÓGICOS ESPECÍFICOS
# ============================================================================

class ChigodoHydrologicalModel:
    """Modelo hidrológico específico para la zona de Chigorodó"""
    
    def __init__(self):
        self.location = CHIGORODO_LOCATION
        self.river = RIO_LEON
        self.climate = CHIGORODO_CLIMATE
        
    def get_seasonal_factor(self, month: int = None) -> float:
        """Obtiene factor estacional basado en el mes actual o especificado"""
        if month is None:
            month = datetime.now().month
            
        month_names = {
            1: 'enero', 2: 'febrero', 3: 'marzo', 4: 'abril',
            5: 'mayo', 6: 'junio', 7: 'julio', 8: 'agosto',
            9: 'septiembre', 10: 'octubre', 11: 'noviembre', 12: 'diciembre'
        }
        
        return self.river.seasonal_variation.get(month_names[month], 1.0)
    
    def get_daily_variation_factor(self, hour: int) -> float:
        """Factor de variación diaria basado en patrones tropicales"""
        # En zona tropical, las lluvias suelen ser más intensas en las tardes
        if 14 <= hour <= 18:  # 2PM - 6PM: pico de lluvias tarde
            return 1.3
        elif 19 <= hour <= 22:  # 7PM - 10PM: lluvias nocturnas
            return 1.1
        elif 3 <= hour <= 6:   # 3AM - 6AM: mínimo nocturno
            return 0.7
        elif 7 <= hour <= 11:  # 7AM - 11AM: incremento matutino
            return 0.9
        else:
            return 1.0
    
    def calculate_freatic_level(self, base_level: float, 
                               rainfall_factor: float = 1.0) -> float:
        """
        Calcula nivel freático considerando:
        - Nivel base del río León
        - Factor de precipitación
        - Características del suelo de la región
        """
        seasonal_factor = self.get_seasonal_factor()
        daily_factor = self.get_daily_variation_factor(datetime.now().hour)
        
        # Factor de infiltración específico para suelos de Urabá
        # (suelos aluviales con alta capacidad de infiltración)
        infiltration_factor = 0.85
        
        # Factor de evapotranspiración tropical
        evapotranspiration_factor = 0.92  # alta evapotranspiración
        
        adjusted_level = (base_level * 
                         seasonal_factor * 
                         daily_factor * 
                         rainfall_factor * 
                         infiltration_factor * 
                         evapotranspiration_factor)
        
        # Aplicar límites realistas para la zona
        return max(0.2, min(adjusted_level, self.river.critical_level_m))
    
    def get_flood_risk_level(self, current_level: float) -> str:
        """Determina nivel de riesgo de inundación"""
        if current_level >= self.river.critical_level_m:
            return "CRÍTICO"
        elif current_level >= self.river.flood_level_m:
            return "ALTO"
        elif current_level >= (self.river.flood_level_m * 0.8):
            return "MEDIO"
        elif current_level <= self.river.drought_level_m:
            return "SEQUÍA"
        else:
            return "NORMAL"
    
    def simulate_tidal_influence(self, base_flow: float) -> float:
        """
        Simula influencia mareal mínima del Golfo de Urabá
        (efecto indirecto a través del río Atrato)
        """
        import time
        # Ciclo mareal de ~12.5 horas con influencia muy reducida
        tidal_cycle = math.sin(time.time() / (12.5 * 3600)) * 0.05
        return base_flow + tidal_cycle

# ============================================================================
# CONFIGURACIÓN DE ESTACIONES ESPECÍFICAS
# ============================================================================

ESTACIONES_FINCA_LA_PLANA = [
    {
        'id': 1,
        'name': 'Estación Río León - Entrada',
        'location': 'Finca La Plana - Sector Entrada',
        'coordinates': FINCA_LA_PLANA_COORDS['estacion_1'],
        'type': 'Principal',
        'river_section': 'Cauce principal río León',
        'monitoring_purpose': 'Control de caudal de entrada y nivel freático',
        'infrastructure': {
            'gate_type': 'Compuerta radial',
            'gate_diameter': 3.2,  # metros - mayor para zona de alta pluviosidad
            'gate_material': 'Acero inoxidable marino',
            'foundation_depth': 4.5,  # profundidad cimentación
            'design_flow': 25.0,  # m³/s - diseño para crecientes
            'spillway_width': 12.0,  # ancho aliviadero
            'spillway_type': 'Vertedero rectangular con compuertas'
        },
        'sensors': {
            'water_level': {
                'range_m': (0.2, 7.5),
                'precision': 0.001,  # mm
                'sensor_type': 'Ultrasonido + Presión'
            },
            'flow_velocity': {
                'range_ms': (0.1, 4.5),
                'precision': 0.01,
                'sensor_type': 'Doppler'
            },
            'gate_position': {
                'range_percent': (0, 100),
                'precision': 0.1,
                'sensor_type': 'Encoder absoluto'
            },
            'freatic_level': {
                'range_m': (0.5, 6.0),
                'precision': 0.002,
                'sensor_type': 'Piezómetro'
            }
        }
    },
    {
        'id': 2,
        'name': 'Estación Río León - Control',
        'location': 'Finca La Plana - Sector Control',
        'coordinates': FINCA_LA_PLANA_COORDS['estacion_2'],
        'type': 'Secundaria',
        'river_section': 'Cauce de control río León',
        'monitoring_purpose': 'Regulación de caudal y monitoreo ambiental',
        'infrastructure': {
            'gate_type': 'Compuerta plana deslizante',
            'gate_diameter': 2.8,
            'gate_material': 'Acero galvanizado',
            'foundation_depth': 3.8,
            'design_flow': 18.0,
            'spillway_width': 10.0,
            'spillway_type': 'Vertedero triangular'
        },
        'sensors': {
            'water_level': {
                'range_m': (0.1, 6.5),
                'precision': 0.001,
                'sensor_type': 'Ultrasonido + Radar'
            },
            'flow_velocity': {
                'range_ms': (0.05, 3.8),
                'precision': 0.01,
                'sensor_type': 'Electromagnético'
            },
            'gate_position': {
                'range_percent': (0, 100),
                'precision': 0.1,
                'sensor_type': 'Potenciómetro lineal'
            },
            'freatic_level': {
                'range_m': (0.3, 5.5),
                'precision': 0.002,
                'sensor_type': 'Transductor de presión'
            },
            'water_quality': {
                'parameters': ['pH', 'conductividad', 'turbidez', 'oxígeno_disuelto'],
                'sensor_type': 'Multiparámetro sumergible'
            }
        }
    }
]

# ============================================================================
# CONFIGURACIÓN DE ALERTAS ESPECÍFICAS
# ============================================================================

ALERTAS_CHIGORODO = {
    'nivel_critico': {
        'threshold': RIO_LEON.critical_level_m,
        'message': 'ALERTA ROJA: Nivel crítico en río León - Riesgo de inundación',
        'actions': ['Apertura automática compuertas', 'Notificación autoridades', 'Evacuación preventiva']
    },
    'nivel_inundacion': {
        'threshold': RIO_LEON.flood_level_m,
        'message': 'ALERTA NARANJA: Nivel de inundación en río León',
        'actions': ['Incrementar descarga', 'Monitoreo continuo', 'Preparar evacuación']
    },
    'sequia': {
        'threshold': RIO_LEON.drought_level_m,
        'message': 'ALERTA AMARILLA: Nivel de sequía en río León',
        'actions': ['Reducir descargas', 'Conservar agua', 'Monitoreo ecosistema']
    },
    'falla_comunicacion': {
        'threshold': 300,  # segundos sin datos
        'message': 'ALERTA TÉCNICA: Falla de comunicación con estación',
        'actions': ['Verificar conectividad', 'Protocolo manual', 'Equipo técnico']
    }
}

# ============================================================================
# PARÁMETROS DE CALIBRACIÓN ESPECÍFICOS
# ============================================================================

CALIBRATION_PARAMETERS = {
    'manning_coefficient': {
        'canal_principal': 0.025,  # concreto rugoso
        'cauce_natural': 0.035,    # lecho natural con vegetación
        'zona_inundacion': 0.045   # área con obstáculos
    },
    'discharge_coefficient': {
        'vertedero_rectangular': 0.62,
        'vertedero_triangular': 0.58,
        'compuerta_libre': 0.60,
        'compuerta_sumergida': 0.58
    },
    'infiltration_rates': {
        'suelo_arenoso': 25.0,      # mm/h - suelos aluviales
        'suelo_arcilloso': 8.0,     # mm/h - arcillas expandibles
        'suelo_organico': 15.0,     # mm/h - materia orgánica
        'roca_fracturada': 2.0      # mm/h - basamento rocoso
    }
}

# ============================================================================
# EXPORTAR CONFIGURACIÓN
# ============================================================================

def get_chigorodo_config():
    """Retorna la configuración completa para Chigorodó"""
    return {
        'location': CHIGORODO_LOCATION,
        'river': RIO_LEON,
        'climate': CHIGORODO_CLIMATE,
        'stations': ESTACIONES_FINCA_LA_PLANA,
        'alerts': ALERTAS_CHIGORODO,
        'calibration': CALIBRATION_PARAMETERS,
        'hydrological_model': ChigodoHydrologicalModel()
    }

if __name__ == "__main__":
    # Prueba de configuración
    config = get_chigorodo_config()
    model = config['hydrological_model']
    
    print("=== CONFIGURACIÓN CHIGORODÓ - RÍO LEÓN ===")
    print(f"Ubicación: {config['location'].municipality}, {config['location'].department}")
    print(f"Cuenca: {config['location'].hydrographic_basin}")
    print(f"Río: {config['river'].name} ({config['river'].length_km} km)")
    print(f"Factor estacional actual: {model.get_seasonal_factor():.2f}")
    print(f"Factor diario actual: {model.get_daily_variation_factor(datetime.now().hour):.2f}")
    print(f"Nivel freático simulado: {model.calculate_freatic_level(2.5):.3f} m")
    
    print("\n=== ESTACIONES CONFIGURADAS ===")
    for station in config['stations']:
        print(f"- {station['name']}: {station['location']}")
        print(f"  Coordenadas: {station['coordinates']['lat']:.4f}, {station['coordinates']['lon']:.4f}")
        print(f"  Propósito: {station['monitoring_purpose']}")
