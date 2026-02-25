"""
Sistema de Control Automático de Bombeo
Promotora Palmera de Antioquia S.A.S.

Lógica de decisión basada en:
- Nivel de agua
- Precipitación reciente
- Tarifas energéticas
- Umbrales configurables

Fecha: 20 de febrero de 2026
"""

import os
from datetime import datetime, timedelta
from sqlalchemy import func, desc
from database import (
    db, PumpTelemetry, WaterLevel, MeteorologicalData,
    MonitoringStation, AutomaticControlLog, AlertThreshold
)
from alert_system import alert_manager


class AutomaticController:
    """Controlador automático de bombas"""
    
    def __init__(self, pump_id):
        self.pump_id = pump_id
        self.station = MonitoringStation.query.get(pump_id)
        
        if not self.station:
            raise ValueError(f"Estación {pump_id} no encontrada")
        
        if not self.station.auto_control_enabled:
            raise ValueError(f"Control automático desactivado para estación {pump_id}")
    
    def evaluate_and_act(self):
        """
        Función principal: evaluar condiciones y ejecutar acción
        
        Returns:
            dict: Resultado de la evaluación y acción tomada
        """
        print(f"\n🤖 Evaluando control automático para bomba {self.pump_id}...")
        
        # 1. Obtener datos actuales
        water_level = self.get_current_water_level()
        rainfall_2h = self.get_recent_rainfall(hours=2)
        rainfall_24h = self.get_recent_rainfall(hours=24)
        current_tariff = self.get_current_energy_tariff()
        pump_status = self.get_current_pump_status()
        inlet_pressure = self.get_current_pressure()
        
        # 2. Obtener umbrales configurados
        thresholds = self.get_thresholds()
        
        # 3. Aplicar lógica de decisión
        decision = self.decision_logic(
            water_level=water_level,
            rainfall_2h=rainfall_2h,
            rainfall_24h=rainfall_24h,
            tariff=current_tariff,
            pump_running=pump_status['is_running'],
            inlet_pressure=inlet_pressure,
            thresholds=thresholds
        )
        
        # 4. Ejecutar acción si es necesaria
        if decision['should_run'] and not pump_status['is_running']:
            self.start_pump(
                reason=decision['reason'],
                water_level=water_level,
                rainfall=rainfall_2h,
                tariff=current_tariff
            )
            result = {
                'action': 'START',
                'reason': decision['reason'],
                'success': True
            }
        
        elif not decision['should_run'] and pump_status['is_running']:
            self.stop_pump(
                reason=decision['reason'],
                water_level=water_level,
                rainfall=rainfall_2h,
                tariff=current_tariff
            )
            result = {
                'action': 'STOP',
                'reason': decision['reason'],
                'success': True
            }
        
        else:
            result = {
                'action': 'NO_CHANGE',
                'reason': decision['reason'],
                'success': True
            }
        
        return result
    
    def decision_logic(self, water_level, rainfall_2h, rainfall_24h, tariff, 
                      pump_running, inlet_pressure, thresholds):
        """
        Lógica de decisión para activar/desactivar bomba
        
        Reglas:
        1. ENCENDER si:
           - Nivel agua < 50% del umbral mínimo
           - Lluvia últimas 2h < 5mm
           - Presión entrada > mínimo requerido
           - Tarifa NO es PEAK
        
        2. APAGAR si:
           - Nivel agua > umbral máximo
           - Lluvia últimas 2h > 30mm
           - Presión entrada < mínimo
           - Es tarifa PEAK y nivel > 70%
        
        Args:
            water_level (float): Nivel actual de agua en metros
            rainfall_2h (float): Precipitación últimas 2 horas
            rainfall_24h (float): Precipitación últimas 24 horas
            tariff (str): Tarifa energética actual (PEAK/VALLEY/STANDARD)
            pump_running (bool): Estado actual de la bomba
            inlet_pressure (float): Presión de entrada en bar
            thresholds (dict): Umbrales configurados
        
        Returns:
            dict: Decisión y razón
        """
        # Umbrales por defecto
        min_water_level = thresholds.get('min_water_level', 0.5)
        max_water_level = thresholds.get('max_water_level', 3.0)
        min_pressure = thresholds.get('min_inlet_pressure', 2.0)
        max_rain_2h = thresholds.get('max_rain_2h_for_pumping', 30.0)
        
        # REGLA 1: Nivel crítico bajo
        if water_level is not None and water_level < (min_water_level * 0.5):
            # Nivel crítico, encender bomba incluso con lluvia moderada
            if rainfall_2h < 15.0:  # Menos de 15mm
                if inlet_pressure >= min_pressure:
                    return {
                        'should_run': True,
                        'reason': f'Nivel crítico ({water_level:.2f}m < {min_water_level*0.5:.2f}m)'
                    }
                else:
                    return {
                        'should_run': False,
                        'reason': f'Presión insuficiente ({inlet_pressure:.2f} bar < {min_pressure} bar)'
                    }
        
        # REGLA 2: Lluvia fuerte reciente
        if rainfall_2h > max_rain_2h:
            return {
                'should_run': False,
                'reason': f'Lluvia fuerte reciente ({rainfall_2h:.1f}mm en 2h)'
            }
        
        # REGLA 3: Nivel máximo alcanzado
        if water_level is not None and water_level > max_water_level:
            return {
                'should_run': False,
                'reason': f'Nivel máximo alcanzado ({water_level:.2f}m > {max_water_level:.2f}m)'
            }
        
        # REGLA 4: Optimización por tarifa energética
        if tariff == 'PEAK':
            # Solo bombear en tarifa pico si es urgente
            if water_level is not None and water_level < (min_water_level * 0.7):
                return {
                    'should_run': True,
                    'reason': f'Nivel bajo en tarifa pico ({water_level:.2f}m < {min_water_level*0.7:.2f}m)'
                }
            else:
                return {
                    'should_run': False,
                    'reason': f'Tarifa PICO - esperar tarifa valle (nivel actual: {water_level:.2f}m)'
                }
        
        # REGLA 5: Condiciones normales de operación
        if water_level is not None and water_level < min_water_level:
            if rainfall_2h < 5.0:  # Lluvia mínima
                if inlet_pressure >= min_pressure:
                    return {
                        'should_run': True,
                        'reason': f'Nivel bajo ({water_level:.2f}m < {min_water_level:.2f}m), condiciones óptimas'
                    }
        
        # REGLA 6: Mantener estado actual si condiciones aceptables
        if water_level is not None:
            if min_water_level <= water_level <= max_water_level:
                return {
                    'should_run': pump_running,
                    'reason': f'Nivel aceptable ({water_level:.2f}m), mantener estado'
                }
        
        # Por defecto: apagar
        return {
            'should_run': False,
            'reason': 'Condiciones no requieren bombeo'
        }
    
    def get_current_water_level(self):
        """Obtener nivel de agua más reciente"""
        latest = WaterLevel.query.filter_by(
            location_id=self.pump_id
        ).order_by(desc(WaterLevel.timestamp)).first()
        
        if latest:
            return float(latest.level_m)
        return None
    
    def get_recent_rainfall(self, hours=2):
        """
        Obtener precipitación acumulada en las últimas X horas
        
        Args:
            hours (int): Horas hacia atrás
        
        Returns:
            float: Precipitación acumulada en mm
        """
        time_threshold = datetime.now() - timedelta(hours=hours)
        
        result = db.session.query(
            func.sum(MeteorologicalData.precipitation_mm)
        ).filter(
            MeteorologicalData.station_id == self.pump_id,
            MeteorologicalData.timestamp >= time_threshold
        ).scalar()
        
        return float(result) if result else 0.0
    
    def get_current_energy_tariff(self):
        """
        Obtener tarifa energética actual basada en hora del día
        
        Returns:
            str: PEAK, VALLEY, o STANDARD
        """
        current_hour = datetime.now().hour
        
        # Definición de tarifas (Colombia ejemplo)
        if 0 <= current_hour < 6:
            return 'VALLEY'
        elif 6 <= current_hour < 10:
            return 'PEAK'
        elif 10 <= current_hour < 18:
            return 'STANDARD'
        elif 18 <= current_hour < 22:
            return 'PEAK'
        else:  # 22-24
            return 'VALLEY'
    
    def get_current_pump_status(self):
        """Obtener estado actual de la bomba"""
        latest = PumpTelemetry.query.filter_by(
            pump_id=self.pump_id
        ).order_by(desc(PumpTelemetry.timestamp)).first()
        
        if latest:
            return {
                'is_running': latest.is_running,
                'flow_rate_m3h': float(latest.flow_rate_m3h) if latest.flow_rate_m3h else 0.0,
                'power_consumption': float(latest.power_consumption_kwh) if latest.power_consumption_kwh else 0.0
            }
        
        return {
            'is_running': False,
            'flow_rate_m3h': 0.0,
            'power_consumption': 0.0
        }
    
    def get_current_pressure(self):
        """Obtener presión de entrada actual"""
        latest = PumpTelemetry.query.filter_by(
            pump_id=self.pump_id
        ).order_by(desc(PumpTelemetry.timestamp)).first()
        
        if latest and latest.inlet_pressure_bar:
            return float(latest.inlet_pressure_bar)
        return 0.0
    
    def get_thresholds(self):
        """Obtener umbrales configurados para esta estación"""
        thresholds_list = AlertThreshold.query.filter_by(
            station_id=self.pump_id,
            is_active=True
        ).all()
        
        thresholds = {}
        for th in thresholds_list:
            param = th.parameter_name
            
            if 'water_level' in param.lower():
                if th.min_value:
                    thresholds['min_water_level'] = float(th.min_value)
                if th.max_value:
                    thresholds['max_water_level'] = float(th.max_value)
            
            elif 'pressure' in param.lower():
                if th.min_value:
                    thresholds['min_inlet_pressure'] = float(th.min_value)
            
            elif 'precipitation' in param.lower() or 'rain' in param.lower():
                if th.max_value:
                    thresholds['max_rain_2h_for_pumping'] = float(th.max_value)
        
        return thresholds
    
    def start_pump(self, reason, water_level, rainfall, tariff):
        """
        Activar bomba y registrar acción
        
        Args:
            reason (str): Razón de la activación
            water_level (float): Nivel de agua actual
            rainfall (float): Precipitación reciente
            tariff (str): Tarifa energética
        """
        # Registrar en log de control automático
        log_entry = AutomaticControlLog(
            pump_id=self.pump_id,
            action='START',
            reason=reason,
            water_level_m=water_level,
            precipitation_mm=rainfall,
            energy_tariff=tariff,
            timestamp=datetime.now()
        )
        db.session.add(log_entry)
        db.session.commit()
        
        # Generar alerta informativa
        alert_manager.create_alert(
            alert_type='AUTO_CONTROL_START',
            severity='LOW',
            station_id=self.pump_id,
            message=f"Bomba iniciada automáticamente. Razón: {reason}",
            auto_notify=True
        )
        
        # TODO: Enviar comando real al hardware (MQTT/HTTP)
        print(f"✅ BOMBA {self.pump_id} INICIADA - {reason}")
    
    def stop_pump(self, reason, water_level, rainfall, tariff):
        """
        Apagar bomba y registrar acción
        
        Args:
            reason (str): Razón de la detención
            water_level (float): Nivel de agua actual
            rainfall (float): Precipitación reciente
            tariff (str): Tarifa energética
        """
        # Registrar en log
        log_entry = AutomaticControlLog(
            pump_id=self.pump_id,
            action='STOP',
            reason=reason,
            water_level_m=water_level,
            precipitation_mm=rainfall,
            energy_tariff=tariff,
            timestamp=datetime.now()
        )
        db.session.add(log_entry)
        db.session.commit()
        
        # Generar alerta informativa
        alert_manager.create_alert(
            alert_type='AUTO_CONTROL_STOP',
            severity='LOW',
            station_id=self.pump_id,
            message=f"Bomba detenida automáticamente. Razón: {reason}",
            auto_notify=True
        )
        
        # TODO: Enviar comando real al hardware (MQTT/HTTP)
        print(f"⏸️  BOMBA {self.pump_id} DETENIDA - {reason}")


def run_automatic_control_cycle():
    """
    Ejecutar ciclo de control automático para todas las estaciones activas
    
    Esta función debe ejecutarse periódicamente (cada 10-15 minutos)
    """
    print("\n" + "="*60)
    print("🤖 CICLO DE CONTROL AUTOMÁTICO")
    print(f"⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*60)
    
    # Obtener estaciones con control automático activado
    stations = MonitoringStation.query.filter_by(
        auto_control_enabled=True,
        is_active=True
    ).all()
    
    if not stations:
        print("⚠️  No hay estaciones con control automático habilitado")
        return
    
    results = []
    
    for station in stations:
        try:
            controller = AutomaticController(station.id)
            result = controller.evaluate_and_act()
            results.append({
                'station_id': station.id,
                'station_name': station.station_name,
                'result': result
            })
            
            print(f"\n📍 {station.station_name}:")
            print(f"   Acción: {result['action']}")
            print(f"   Razón: {result['reason']}")
        
        except Exception as e:
            print(f"\n❌ Error en estación {station.id}: {str(e)}")
            results.append({
                'station_id': station.id,
                'station_name': station.station_name,
                'result': {'action': 'ERROR', 'reason': str(e), 'success': False}
            })
    
    print("\n" + "="*60)
    print(f"✅ Ciclo completado - {len(results)} estaciones procesadas")
    print("="*60 + "\n")
    
    return results


if __name__ == '__main__':
    # Prueba del sistema de control automático
    run_automatic_control_cycle()
