from flask import Flask, request, jsonify, send_from_directory, send_file
from flask_cors import CORS
import os
from database import db, GateStatus, WaterLevel, PumpingStation, FlowSummary, MeteorologicalData
from datetime import datetime, timedelta
from sqlalchemy import func, desc
import json

app = Flask(__name__)
CORS(app)
app.config.from_pyfile('config.py')
db.init_app(app)

# Registrar endpoints extendidos
try:
    from api_extended import api_extended
    app.register_blueprint(api_extended)
except Exception as e:
    print(f"Advertencia: No se pudieron registrar endpoints extendidos: {e}")

@app.route('/api/data', methods=['POST'])
def receive_data():
    try:
        data = request.get_json() or {}

        # Aceptar payloads en español (simulador) e ingles (clientes antiguos)
        station_id = data.get('estacion_id') or data.get('station_id') or data.get('gate_id')
        numero_compuerta = data.get('numero_compuerta') or data.get('gate_number') or 1
        apertura = data.get('apertura_porcentaje')
        if apertura is None:
            apertura = data.get('position_percent')

        nivel = data.get('nivel_m')
        if nivel is None:
            nivel = data.get('level_m')

        caudal = data.get('caudal_m3s')
        if caudal is None:
            caudal = data.get('flow_m3s')

        fecha_raw = data.get('fecha_hora') or data.get('timestamp')
        if fecha_raw:
            fecha_hora = datetime.fromisoformat(str(fecha_raw).replace('Z', '+00:00'))
        else:
            fecha_hora = datetime.now()

        if station_id is None or apertura is None or nivel is None:
            return jsonify({'error': 'Missing required fields'}), 400

        estado = data.get('estado')
        if not estado:
            estado = 'MOVING' if 0 < float(apertura) < 100 else 'OPEN' if float(apertura) == 100 else 'CLOSE'

        dispositivo = data.get('dispositivo_origen') or data.get('source_device') or 'unknown'

        # Guardar en base de datos
        gate_status = GateStatus(
            estacion_id=int(station_id),
            numero_compuerta=int(numero_compuerta),
            estado=estado,
            apertura_porcentaje=apertura,
            caudal_m3s=caudal,
            valor_sensor_posicion=apertura,
            fecha_hora=fecha_hora,
            dispositivo_origen=dispositivo
        )

        water_level = WaterLevel(
            estacion_id=int(station_id),
            nivel_m=nivel,
            volumen_m3=data.get('volumen_m3'),
            tendencia=data.get('tendencia'),
            fecha_hora=fecha_hora,
            dispositivo_origen=dispositivo
        )
        
        db.session.add(gate_status)
        db.session.add(water_level)
        db.session.commit()
        
        return jsonify({'message': 'Data received successfully'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/meteorology', methods=['POST'])
def receive_meteorology():
    """Recibe datos meteorológicos del simulador ESP32"""
    try:
        data = request.get_json()
        
        # Intentar guardar en BD si existe tabla de meteorología
        try:
            from database import MeteorologicalData

            velocidad_kmh = data.get('velocidad_viento_kmh')
            if velocidad_kmh is None:
                velocidad_kmh = float(data.get('velocidad_viento_ms', 0)) * 3.6

            presion_hpa = data.get('presion_atmosferica_hpa')
            if presion_hpa is None:
                presion_hpa = data.get('presion_hpa', 1013)

            fecha_raw = data.get('fecha_hora', datetime.now().isoformat())
            fecha_hora = datetime.fromisoformat(str(fecha_raw).replace('Z', '+00:00'))
            
            meteo = MeteorologicalData(
                estacion_id=data.get('estacion_id', 1),
                temperatura_c=data.get('temperatura_c', 0),
                humedad_porcentaje=data.get('humedad_porcentaje', 0),
                precipitacion_mm=data.get('precipitacion_mm', 0),
                presion_atmosferica_hpa=presion_hpa,
                velocidad_viento_kmh=velocidad_kmh,
                direccion_viento_grados=data.get('direccion_viento_grados', 0),
                radiacion_solar_wm2=data.get('radiacion_solar_wm2', 0),
                fecha_hora=fecha_hora,
                dispositivo_origen=data.get('dispositivo_origen', 'ESP32_SIMULADO')
            )
            
            db.session.add(meteo)
            db.session.commit()
        except Exception as e:
            print(f"Advertencia al guardar meteorología: {e}")
        
        return jsonify({'message': 'Meteorological data received'}), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/dashboard', methods=['GET'])
def get_dashboard_data():
    try:
        station_id = request.args.get('station_id', 1, type=int)
        hours = request.args.get('hours', 24, type=int)
        
        # Obtener datos para el dashboard
        # (Implementar consultas según necesidades)
        
        return jsonify({
            'current_status': get_current_status(station_id),
            'historical_data': get_historical_data(station_id, hours),
            'daily_summary': get_daily_summary(station_id)
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def get_current_status(station_id):
    """Obtiene el estado actual de una estación"""
    try:
        # Obtener último estado de compuerta
        latest_gate = GateStatus.query.filter_by(estacion_id=station_id).order_by(desc(GateStatus.fecha_hora)).first()
        
        # Obtener último nivel de agua
        latest_water = WaterLevel.query.filter_by(estacion_id=station_id).order_by(desc(WaterLevel.fecha_hora)).first()
        
        if not latest_gate or not latest_water:
            return {
                'position_percent': 0,
                'level_m': 0.0,
                'flow_m3s': 0.0,
                'status': 'NO_DATA',
                'last_update': None
            }
        
        return {
            'position_percent': float(latest_gate.apertura_porcentaje) if latest_gate.apertura_porcentaje else 0,
            'level_m': float(latest_water.nivel_m) if latest_water.nivel_m else 0.0,
            'flow_m3s': float(latest_gate.caudal_m3s) if latest_gate.caudal_m3s else 0.0,
            'status': latest_gate.estado,
            'last_update': latest_gate.fecha_hora.isoformat() if latest_gate.fecha_hora else None
        }
    except Exception as e:
        print(f"Error getting current status: {e}")
        return {
            'position_percent': 0,
            'level_m': 0.0,
            'flow_m3s': 0.0,
            'status': 'ERROR',
            'last_update': None
        }

def get_historical_data(station_id, hours=24):
    """Obtiene datos históricos de las últimas N horas"""
    try:
        # Calcular timestamp de inicio
        start_time = datetime.utcnow() - timedelta(hours=hours)

        water_levels = db.session.query(WaterLevel).filter(
            WaterLevel.estacion_id == station_id,
            WaterLevel.fecha_hora >= start_time
        ).order_by(WaterLevel.fecha_hora).all()

        gate_statuses = db.session.query(GateStatus).filter(
            GateStatus.estacion_id == station_id,
            GateStatus.fecha_hora >= start_time
        ).order_by(GateStatus.fecha_hora).all()

        # Combinar nivel y caudal usando el ultimo registro de compuerta disponible
        gate_index = 0
        last_gate = None
        combined = []
        for level in water_levels:
            while gate_index < len(gate_statuses) and gate_statuses[gate_index].fecha_hora <= level.fecha_hora:
                last_gate = gate_statuses[gate_index]
                gate_index += 1

            combined.append({
                'timestamp': level.fecha_hora.isoformat(),
                'level_m': float(level.nivel_m) if level.nivel_m else 0.0,
                'flow_m3s': float(last_gate.caudal_m3s) if last_gate and last_gate.caudal_m3s else 0.0,
                'position_percent': float(last_gate.apertura_porcentaje) if last_gate and last_gate.apertura_porcentaje else 0.0
            })

        return combined
        
    except Exception as e:
        print(f"Error getting historical data: {e}")
        return []

def get_daily_summary(station_id):
    """Obtiene resumen diario de la estación"""
    try:
        today = datetime.utcnow().date()
        start_of_day = datetime.combine(today, datetime.min.time())
        end_of_day = datetime.combine(today, datetime.max.time())

        def build_meteorology_summary():
            meteo_records = MeteorologicalData.query.filter(
                MeteorologicalData.estacion_id == station_id,
                MeteorologicalData.fecha_hora >= start_of_day,
                MeteorologicalData.fecha_hora <= end_of_day
            ).all()

            if not meteo_records:
                return {
                    'precipitacion_total_mm': 0.0,
                    'temperatura_promedio_c': 0.0,
                    'temperatura_min_c': 0.0,
                    'temperatura_max_c': 0.0,
                    'viento_max_kmh': 0.0,
                    'presion_promedio_hpa': 0.0
                }

            precip_total = sum(float(r.precipitacion_mm or 0) for r in meteo_records)
            temp_values = [float(r.temperatura_c) for r in meteo_records if r.temperatura_c is not None]
            pressure_values = [float(r.presion_atmosferica_hpa) for r in meteo_records if r.presion_atmosferica_hpa is not None]
            wind_max = max(float(r.velocidad_viento_kmh or 0) for r in meteo_records)

            temp_avg = sum(temp_values) / len(temp_values) if temp_values else 0.0
            temp_min = min(temp_values) if temp_values else 0.0
            temp_max = max(temp_values) if temp_values else 0.0
            pressure_avg = sum(pressure_values) / len(pressure_values) if pressure_values else 0.0

            return {
                'precipitacion_total_mm': round(precip_total, 2),
                'temperatura_promedio_c': round(temp_avg, 2),
                'temperatura_min_c': round(temp_min, 2),
                'temperatura_max_c': round(temp_max, 2),
                'viento_max_kmh': round(wind_max, 2),
                'presion_promedio_hpa': round(pressure_avg, 2)
            }
        
        # Buscar resumen existente
        summary = FlowSummary.query.filter_by(
            estacion_id=station_id,
            fecha=today
        ).first()

        meteo_summary = build_meteorology_summary()
        
        if summary:
            return {
                'date': summary.fecha.isoformat(),
                'total_m3': float(summary.entrada_total_m3) if summary.entrada_total_m3 else 0.0,
                'peak_flow_m3s': float(summary.pico_entrada_m3h) if summary.pico_entrada_m3h else 0.0,
                'gate_open_hours': float(summary.horas_bombeo) if summary.horas_bombeo else 0.0,
                'precipitacion_total_mm': float(summary.precipitacion_total_mm) if summary.precipitacion_total_mm else meteo_summary['precipitacion_total_mm'],
                'temperatura_promedio_c': meteo_summary['temperatura_promedio_c'],
                'temperatura_min_c': meteo_summary['temperatura_min_c'],
                'temperatura_max_c': meteo_summary['temperatura_max_c'],
                'viento_max_kmh': meteo_summary['viento_max_kmh'],
                'presion_promedio_hpa': meteo_summary['presion_promedio_hpa']
            }
        
        # Si no existe, calcular en tiempo real
        # Calcular estadísticas del día
        daily_records = GateStatus.query.filter(
            GateStatus.estacion_id == station_id,
            GateStatus.fecha_hora >= start_of_day,
            GateStatus.fecha_hora <= end_of_day
        ).all()
        
        if not daily_records:
            return {
                'date': today.isoformat(),
                'total_m3': 0.0,
                'peak_flow_m3s': 0.0,
                'gate_open_hours': 0.0,
                **meteo_summary
            }
        
        # Calcular volumen total (aproximado)
        total_volume = sum(float(r.caudal_m3s or 0) for r in daily_records) * 3600 / len(daily_records)
        
        # Encontrar pico de caudal
        peak_flow = max(float(r.caudal_m3s or 0) for r in daily_records)
        
        # Calcular horas de compuerta abierta (aproximado)
        gate_records = GateStatus.query.filter(
            GateStatus.estacion_id == station_id,
            GateStatus.fecha_hora >= start_of_day,
            GateStatus.fecha_hora <= end_of_day,
            GateStatus.apertura_porcentaje > 0
        ).count()
        
        open_hours = gate_records * 0.1  # Estimación basada en frecuencia de registros
        
        return {
            'date': today.isoformat(),
            'total_m3': round(total_volume, 1),
            'peak_flow_m3s': round(peak_flow, 4),
            'gate_open_hours': round(open_hours, 2),
            **meteo_summary
        }
        
    except Exception as e:
        print(f"Error getting daily summary: {e}")
        return {
            'date': datetime.utcnow().date().isoformat(),
            'total_m3': 0.0,
            'peak_flow_m3s': 0.0,
            'gate_open_hours': 0.0,
            'precipitacion_total_mm': 0.0,
            'temperatura_promedio_c': 0.0,
            'temperatura_min_c': 0.0,
            'temperatura_max_c': 0.0,
            'viento_max_kmh': 0.0,
            'presion_promedio_hpa': 0.0
        }

@app.route('/api/stations', methods=['GET'])
def get_stations():
    """Obtiene lista de estaciones disponibles"""
    try:
        stations = PumpingStation.query.all()
        return jsonify({
            'stations': [station.to_dict() for station in stations]
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/meteorology/latest', methods=['GET'])
def get_latest_meteorology():
    """Obtiene últimos datos meteorológicos"""
    try:
        station_id = request.args.get('station_id', 1, type=int)
        
        # Buscar en la tabla de meteorología extendida si existe
        try:
            from database import MeteorologicalData
            latest = MeteorologicalData.query.filter_by(
                estacion_id=station_id
            ).order_by(MeteorologicalData.fecha_hora.desc()).first()
            
            if latest:
                velocidad_ms = float(latest.velocidad_viento_kmh or 0) / 3.6
                return jsonify({
                    'data': {
                        'temperatura_c': float(latest.temperatura_c or 0),
                        'humedad_porcentaje': float(latest.humedad_porcentaje or 0),
                        'precipitacion_mm': float(latest.precipitacion_mm or 0),
                        'presion_hpa': float(latest.presion_atmosferica_hpa or 1013),
                        'velocidad_viento_ms': round(velocidad_ms, 2),
                        'direccion_viento_grados': int(latest.direccion_viento_grados or 0),
                        'radiacion_solar_wm2': float(latest.radiacion_solar_wm2 or 0),
                        'fecha_hora': latest.fecha_hora.isoformat() if latest.fecha_hora else None
                    }
                }), 200
        except:
            pass
        
        # Fallback: retornar datos simulados
        return jsonify({
            'data': {
                'temperatura_c': 25.0,
                'humedad_porcentaje': 60.0,
                'precipitacion_mm': 0.0,
                'presion_hpa': 1013.0,
                'velocidad_viento_ms': 5.0,
                'direccion_viento_grados': 180,
                'radiacion_solar_wm2': 800,
                'fecha_hora': datetime.now().isoformat()
            }
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/init-db', methods=['POST'])
def init_database():
    """Inicializa la base de datos y crea las tablas"""
    try:
        db.create_all()
        
        # Crear estaciones de ejemplo si no existen
        if PumpingStation.query.count() == 0:
            station1 = PumpingStation(
                estacion_id=1,
                nombre='Estacion 1 - Bombeo Principal',
                tipo_bomba='centrifuga',
                capacidad_maxima_m3h=1200,
                potencia_nominal_kw=75,
                nivel_minimo_agua_m=0.5,
                nivel_maximo_agua_m=5.0,
                activo=True
            )

            station2 = PumpingStation(
                estacion_id=2,
                nombre='Estacion 2 - Bombeo Auxiliar',
                tipo_bomba='centrifuga',
                capacidad_maxima_m3h=800,
                potencia_nominal_kw=45,
                nivel_minimo_agua_m=0.5,
                nivel_maximo_agua_m=5.0,
                activo=True
            )

            db.session.add(station1)
            db.session.add(station2)
            db.session.commit()
        
        return jsonify({'message': 'Database initialized successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Rutas para servir documentación estática
@app.route('/docs/')
@app.route('/docs/index.html')
def serve_docs_index():
    """Servir página principal de documentación"""
    return send_file('docs/index.html')

@app.route('/docs/<path:filename>')
def serve_docs_static(filename):
    """Servir archivos estáticos de documentación"""
    return send_from_directory('docs', filename)

@app.route('/')
def serve_root():
    """Redirigir root a página de inicio"""
    return send_file('inicio.html')

@app.route('/index.html')
def serve_bombeo():
    """Servir dashboard de bombeo"""
    return send_file('index.html')

@app.route('/meteorologia')
@app.route('/meteorologia.html')
def serve_meteorology():
    """Servir dashboard meteorológico"""
    return send_file('meteorologia.html')

@app.route('/styles.css')
def serve_styles():
    """Servir archivo CSS"""
    return send_file('styles.css')

@app.route('/script.js')
def serve_script():
    """Servir archivo JavaScript"""
    return send_file('script.js')

@app.route('/dashboard_extended.js')
def serve_dashboard_extended():
    """Servir archivo JavaScript del dashboard extendido"""
    return send_file('dashboard_extended.js')

@app.route('/tooltip-system.js')
def serve_tooltip_system():
    """Servir archivo JavaScript del sistema de tooltips"""
    return send_file('tooltip-system.js')

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    
    # Permitir reutilizar el socket
    from werkzeug.serving import WSGIRequestHandler
    WSGIRequestHandler.protocol_version = "HTTP/1.1"
    
    app.run(host='0.0.0.0', port=9000, debug=False, use_reloader=False)
