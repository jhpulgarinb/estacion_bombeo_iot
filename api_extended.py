"""
Endpoints API Extendidos - Sistema de Automatización
Proyecto de grado

Nuevos endpoints para:
- Telemetría meteorológica
- Telemetría de bomba completa
- Sistema de alertas
- Control automático

Fecha: 20 de febrero de 2026
"""

from flask import Blueprint, request, jsonify
from datetime import datetime, timedelta
from sqlalchemy import func, desc
from database import (
    db, MeteorologicalData, PumpTelemetry, SystemAlert,
    AlertThreshold, AutomaticControlLog, MonitoringStation,
    NotificationContact
)
from alert_system import alert_manager
from auto_control import AutomaticController, run_automatic_control_cycle

# Crear blueprint para nuevos endpoints
api_extended = Blueprint('api_extended', __name__, url_prefix='/api')


# =====================================================================
# ENDPOINTS - METEOROLOGÍA
# =====================================================================

@api_extended.route('/meteorology', methods=['POST'])
def receive_meteorological_data():
    """
    Recibir datos de estación meteorológica
    
    Body JSON:
    {
        "station_id": 1,
        "precipitation_mm": 5.2,
        "wind_speed_kmh": 12.5,
        "wind_direction_deg": 180,
        "temperature_c": 28.5,
        "humidity_percent": 75.0,
        "pressure_hpa": 1013.2,
        "solar_radiation_wm2": 850.0,
        "timestamp": "2026-02-20T14:30:00",
        "source_device": "ESP32_WEATHER_01"
    }
    """
    try:
        data = request.get_json()
        
        # Validar campos requeridos
        if 'estacion_id' not in data:
            return jsonify({'error': 'Missing estacion_id'}), 400
        
        # Crear registro
        met_data = MeteorologicalData(
            estacion_id=data['estacion_id'],
            precipitacion_mm=data.get('precipitacion_mm', 0.0),
            velocidad_viento_kmh=data.get('velocidad_viento_kmh', 0.0),
            direccion_viento_grados=data.get('direccion_viento_grados', 0),
            temperatura_c=data.get('temperatura_c'),
            humedad_porcentaje=data.get('humedad_porcentaje'),
            presion_atmosferica_hpa=data.get('presion_atmosferica_hpa'),
            radiacion_solar_wm2=data.get('radiacion_solar_wm2'),
            fecha_hora=datetime.fromisoformat(data.get('fecha_hora', datetime.now().isoformat())),
            dispositivo_origen=data.get('dispositivo_origen')
        )
        
        db.session.add(met_data)
        db.session.commit()
        
        # Verificar umbrales (ej: precipitación alta)
        if data.get('precipitacion_mm', 0) > 0:
            threshold = alert_manager.check_thresholds(
                station_id=data['estacion_id'],
                parameter_name='precipitacion_mm',
                current_value=data['precipitacion_mm']
            )
            
            if threshold and threshold['violated']:
                alert_manager.create_alert(
                    alert_type='HIGH_PRECIPITATION',
                    severity=threshold['alert_level'],
                    estacion_id=data['estacion_id'],
                    message=threshold['message'],
                    auto_notify=True
                )
        
        return jsonify({
            'message': 'Meteorological data received',
            'id': met_data.id
        }), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@api_extended.route('/meteorology/latest', methods=['GET'])
def get_latest_meteorological_data():
    """Obtener último registro meteorológico por estación"""
    station_id = request.args.get('station_id', type=int)
    
    if not station_id:
        return jsonify({'error': 'station_id required'}), 400
    
    latest = MeteorologicalData.query.filter_by(
        estacion_id=station_id
    ).order_by(desc(MeteorologicalData.fecha_hora)).first()
    
    if not latest:
        return jsonify({'error': 'No data found'}), 404
    
    return jsonify({
        'success': True,
        'data': latest.to_dict()
    }), 200


@api_extended.route('/meteorology/history', methods=['GET'])
def get_meteorological_history():
    """Obtener histórico de datos meteorológicos"""
    station_id = request.args.get('station_id', type=int)
    hours = request.args.get('hours', 24, type=int)
    
    if not station_id:
        return jsonify({'error': 'station_id required'}), 400
    
    time_threshold = datetime.now() - timedelta(hours=hours)
    
    data = MeteorologicalData.query.filter(
        MeteorologicalData.estacion_id == station_id,
        MeteorologicalData.fecha_hora >= time_threshold
    ).order_by(MeteorologicalData.fecha_hora.asc()).all()
    
    return jsonify({
        'success': True,
        'count': len(data),
        'data': [d.to_dict() for d in data]
    }), 200


# =====================================================================
# ENDPOINTS - TELEMETRÍA DE BOMBA
# =====================================================================

@api_extended.route('/pump/telemetry', methods=['POST'])
def receive_pump_telemetry():
    """
    Recibir telemetría completa de bomba
    
    Body JSON:
    {
        "pump_id": 1,
        "is_running": true,
        "flow_rate_m3h": 85.5,
        "inlet_pressure_bar": 3.2,
        "outlet_pressure_bar": 6.5,
        "power_consumption_kwh": 25.3,
        "motor_temperature_c": 68.5,
        "running_hours": 1523.5,
        "timestamp": "2026-02-20T14:30:00",
        "source_device": "ESP32_PUMP_01"
    }
    """
    try:
        data = request.get_json()
        
        if 'bomba_id' not in data:
            return jsonify({'error': 'Missing bomba_id'}), 400
        
        telemetry = PumpTelemetry(
            bomba_id=data['bomba_id'],
            estado=data.get('estado', 'APAGADO'),
            caudal_m3h=data.get('caudal_m3h', 0.0),
            presion_entrada_bar=data.get('presion_entrada_bar', 0.0),
            presion_salida_bar=data.get('presion_salida_bar', 0.0),
            consumo_energia_kw=data.get('consumo_energia_kw', 0.0),
            temperatura_motor_c=data.get('temperatura_motor_c'),
            nivel_vibracion=data.get('nivel_vibracion'),
            horas_operacion=data.get('horas_operacion', 0.0),
            modo_operacion=data.get('modo_operacion', 'AUTO'),
            fecha_hora=datetime.fromisoformat(data.get('fecha_hora', datetime.now().isoformat())),
            dispositivo_origen=data.get('dispositivo_origen')
        )
        
        db.session.add(telemetry)
        db.session.commit()
        
        # Verificar umbrales críticos
        checks = [
            ('temperatura_motor_c', data.get('temperatura_motor_c')),
            ('presion_entrada_bar', data.get('presion_entrada_bar')),
            ('presion_salida_bar', data.get('presion_salida_bar'))
        ]
        
        for param_name, value in checks:
            if value is not None:
                threshold = alert_manager.check_thresholds(
                    station_id=data['bomba_id'],
                    parameter_name=param_name,
                    current_value=value
                )
                
                if threshold and threshold['violated']:
                    alert_manager.create_alert(
                        alert_type=f'BOMBA_{param_name.upper()}',
                        severity=threshold['alert_level'],
                        estacion_id=data['bomba_id'],
                        message=threshold['message'],
                        auto_notify=True
                    )
        
        return jsonify({
            'message': 'Pump telemetry received',
            'id': telemetry.id
        }), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@api_extended.route('/pump/status', methods=['GET'])
def get_pump_status():
    """Obtener estado actual de bomba"""
    pump_id = request.args.get('pump_id', type=int)
    
    if not pump_id:
        return jsonify({'error': 'pump_id required'}), 400
    
    latest = PumpTelemetry.query.filter_by(
        bomba_id=pump_id
    ).order_by(desc(PumpTelemetry.fecha_hora)).first()
    
    if not latest:
        return jsonify({'error': 'No data found'}), 404
    
    return jsonify({
        'success': True,
        'data': latest.to_dict()
    }), 200


# =====================================================================
# ENDPOINTS - ALERTAS
# =====================================================================

@api_extended.route('/alerts', methods=['POST'])
def create_manual_alert():
    """Crear alerta manual"""
    try:
        data = request.get_json()
        
        required = ['alert_type', 'severity', 'station_id', 'message']
        for field in required:
            if field not in data:
                return jsonify({'error': f'Missing field: {field}'}), 400
        
        alert = alert_manager.create_alert(
            alert_type=data['alert_type'],
            severity=data['severity'],
            station_id=data['station_id'],
            message=data['message'],
            auto_notify=data.get('auto_notify', True)
        )
        
        return jsonify({
            'success': True,
            'alert_id': alert.id,
            'message': 'Alert created successfully'
        }), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@api_extended.route('/alerts/active', methods=['GET'])
def get_active_alerts():
    """Obtener alertas activas (no resueltas)"""
    station_id = request.args.get('station_id', type=int)
    
    query = SystemAlert.query.filter_by(esta_resuelto=False)
    
    if station_id:
        query = query.filter_by(estacion_id=station_id)
    
    alerts = query.order_by(
        SystemAlert.fecha_hora.desc()
    ).all()
    
    return jsonify({
        'success': True,
        'count': len(alerts),
        'alerts': [a.to_dict() for a in alerts]
    }), 200


@api_extended.route('/alerts/<int:alert_id>/resolve', methods=['PUT'])
def resolve_alert(alert_id):
    """Marcar alerta como resuelta"""
    try:
        data = request.get_json()
        resolved_by = data.get('resolved_by', 'Sistema')
        
        success = alert_manager.resolve_alert(alert_id, resolved_by)
        
        if success:
            return jsonify({
                'success': True,
                'message': 'Alert resolved'
            }), 200
        else:
            return jsonify({
                'success': False,
                'error': 'Alert not found or already resolved'
            }), 404
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# =====================================================================
# ENDPOINTS - CONTROL AUTOMÁTICO
# =====================================================================

@api_extended.route('/control/auto', methods=['POST'])
def toggle_automatic_control():
    """Activar/desactivar modo automático"""
    try:
        data = request.get_json()
        
        if 'estacion_id' not in data or 'enabled' not in data:
            return jsonify({'error': 'Missing estacion_id or enabled'}), 400
        
        station_id = data['estacion_id']
        station = MonitoringStation.query.get(station_id)
        
        if not station:
            station = MonitoringStation(
                id=station_id,
                nombre=f'Estacion {station_id}',
                tipo_estacion='BOMBEO'
            )
            db.session.add(station)
            db.session.commit()
        
        station.control_automatico_habilitado = data['enabled']
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': f'Automatic control {"enabled" if data["enabled"] else "disabled"}',
            'estacion_id': station.id,
            'control_automatico_habilitado': station.control_automatico_habilitado
        }), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@api_extended.route('/control/manual', methods=['POST'])
def manual_pump_control():
    """Control manual ON/OFF de bomba"""
    try:
        data = request.get_json()
        
        if 'bomba_id' not in data or 'action' not in data:
            return jsonify({'error': 'Missing bomba_id or action'}), 400
        
        if data['action'] not in ['INICIAR', 'DETENER']:
            return jsonify({'error': 'Action must be INICIAR or DETENER'}), 400
        
        # Registrar override manual
        log_entry = AutomaticControlLog(
            bomba_id=data['bomba_id'],
            accion='MANUAL_OVERRIDE',
            razon=f"Manual {data['action']} by {data.get('user', 'Unknown')}",
            fecha_hora=datetime.now()
        )
        db.session.add(log_entry)
        db.session.commit()
        
        # TODO: Enviar comando real al hardware
        
        return jsonify({
            'success': True,
            'message': f'Manual {data["action"]} command sent',
            'bomba_id': data['bomba_id'],
            'action': data['action']
        }), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@api_extended.route('/control/status', methods=['GET'])
def get_control_status():
    """Obtener estado del sistema de control"""
    station_id = request.args.get('station_id', type=int)
    
    if not station_id:
        return jsonify({'error': 'station_id required'}), 400
    
    station = MonitoringStation.query.get(station_id)
    
    if not station:
        station = MonitoringStation(
            id=station_id,
            nombre=f'Estacion {station_id}',
            tipo_estacion='BOMBEO'
        )
        db.session.add(station)
        db.session.commit()
    
    # Último log de control
    latest_log = AutomaticControlLog.query.filter_by(
        bomba_id=station_id
    ).order_by(desc(AutomaticControlLog.fecha_hora)).first()
    
    return jsonify({
        'success': True,
        'estacion_id': station.id,
        'nombre': station.nombre,
        'control_automatico_habilitado': station.control_automatico_habilitado,
        'ultimo_log': latest_log.to_dict() if latest_log else None
    })


@api_extended.route('/control/run-cycle', methods=['POST'])
def run_control_cycle():
    """Ejecutar ciclo de control automático manualmente"""
    try:
        results = run_automatic_control_cycle()
        
        return jsonify({
            'success': True,
            'message': 'Control cycle completed',
            'results': results
        }), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@api_extended.route('/control/thresholds', methods=['GET', 'PUT'])
def manage_thresholds():
    """Obtener o actualizar umbrales de control"""
    station_id = request.args.get('station_id', type=int)
    
    if not station_id:
        return jsonify({'error': 'station_id required'}), 400
    
    if request.method == 'GET':
        thresholds = AlertThreshold.query.all()
        
        return jsonify({
            'success': True,
            'count': len(thresholds),
            'thresholds': [t.to_dict() for t in thresholds]
        }), 200
    
    else:  # PUT
        try:
            data = request.get_json()
            
            threshold = AlertThreshold.query.get(data.get('id'))
            
            if threshold:
                # Actualizar existente
                threshold.min_value = data.get('min_value', threshold.min_value)
                threshold.max_value = data.get('max_value', threshold.max_value)
                threshold.alert_level = data.get('alert_level', threshold.alert_level)
                threshold.is_active = data.get('is_active', threshold.is_active)
                threshold.updated_at = datetime.now()
            else:
                # Crear nuevo
                threshold = AlertThreshold(
                    nombre_parametro=data['nombre_parametro'],
                    valor_minimo=data.get('valor_minimo'),
                    valor_maximo=data.get('valor_maximo'),
                    nivel_alerta=data.get('nivel_alerta', 'MEDIO'),
                    activo=data.get('activo', True)
                )
                db.session.add(threshold)
            
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': 'Threshold updated',
                'threshold': threshold.to_dict()
            }), 200
        
        except Exception as e:
            return jsonify({'error': str(e)}), 500


# =====================================================================
# ENDPOINTS - ESTACIONES
# =====================================================================

@api_extended.route('/stations', methods=['GET'])
def get_stations():
    """Listar todas las estaciones"""
    active_only = request.args.get('active_only', 'true').lower() == 'true'
    
    query = MonitoringStation.query
    
    if active_only:
        query = query.filter_by(activo=True)
    
    stations = query.all()
    
    return jsonify({
        'success': True,
        'count': len(stations),
        'stations': [s.to_dict() for s in stations]
    }), 200


# Exportar blueprint
__all__ = ['api_extended']
