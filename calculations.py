import math

def calculate_flow(level_m, weir_type, weir_width, cd_coefficient):
    """
    Calcula el caudal basado en el nivel de agua y tipo de vertedero
    """
    g = 9.81  # Gravedad
    
    if weir_type == 'rectangular':
        # Fórmula para vertedero rectangular: Q = Cd * b * √(2g) * h^(3/2)
        return cd_coefficient * weir_width * math.sqrt(2 * g) * (level_m ** 1.5)
    
    elif weir_type == 'v_notch':
        # Fórmula para vertedero triangular (V-notch)
        angle_rad = math.radians(90)  # Asumiendo ángulo de 90°
        return (8/15) * cd_coefficient * math.sqrt(2 * g) * math.tan(angle_rad/2) * (level_m ** 2.5)
    
    else:
        # Flume Parshall u otros tipos
        # Implementar otras fórmulas según necesidad
        return 0

def calculate_volume(flow_rate_m3s, time_seconds):
    """
    Calcula volumen total basado en caudal y tiempo
    """
    return flow_rate_m3s * time_seconds

def encoder_to_percentage(raw_value, min_raw, max_raw):
    """
    Convierte valor crudo del encoder a porcentaje de apertura
    """
    if max_raw == min_raw:
        return 0
    return ((raw_value - min_raw) / (max_raw - min_raw)) * 100