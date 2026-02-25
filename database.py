from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class GateStatus(db.Model):
    """Modelo para el estado de las compuertas"""
    __tablename__ = 'iot_estado_compuerta'
    
    id = db.Column(db.Integer, primary_key=True)
    estacion_id = db.Column('estacion_id', db.Integer, nullable=False)
    numero_compuerta = db.Column('numero_compuerta', db.Integer, nullable=False)
    estado = db.Column(db.String(20))
    apertura_porcentaje = db.Column('apertura_porcentaje', db.Numeric(5,2))
    caudal_m3s = db.Column('caudal_m3s', db.Numeric(8,4))
    valor_sensor_posicion = db.Column('valor_sensor_posicion', db.Numeric(10,3))
    fecha_hora = db.Column('fecha_hora', db.DateTime, nullable=False, default=datetime.utcnow)
    dispositivo_origen = db.Column('dispositivo_origen', db.String(50))
    
    def __repr__(self):
        return f'<GateStatus {self.numero_compuerta}: {self.apertura_porcentaje}% at {self.fecha_hora}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'estacion_id': self.estacion_id,
            'numero_compuerta': self.numero_compuerta,
            'estado': self.estado,
            'apertura_porcentaje': float(self.apertura_porcentaje) if self.apertura_porcentaje else None,
            'caudal_m3s': float(self.caudal_m3s) if self.caudal_m3s else None,
            'valor_sensor_posicion': float(self.valor_sensor_posicion) if self.valor_sensor_posicion else None,
            'fecha_hora': self.fecha_hora.isoformat() if self.fecha_hora else None,
            'dispositivo_origen': self.dispositivo_origen
        }

class WaterLevel(db.Model):
    """Modelo para las lecturas de nivel de agua"""
    __tablename__ = 'iot_nivel_agua'
    
    id = db.Column(db.Integer, primary_key=True)
    estacion_id = db.Column('estacion_id', db.Integer, nullable=False)
    nivel_m = db.Column('nivel_m', db.Numeric(6,3), nullable=False)
    volumen_m3 = db.Column('volumen_m3', db.Numeric(12,3))
    tendencia = db.Column(db.String(20))
    fecha_hora = db.Column('fecha_hora', db.DateTime, nullable=False, default=datetime.utcnow)
    dispositivo_origen = db.Column('dispositivo_origen', db.String(50))
    
    def __repr__(self):
        return f'<WaterLevel {self.estacion_id}: {self.nivel_m}m at {self.fecha_hora}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'estacion_id': self.estacion_id,
            'nivel_m': float(self.nivel_m) if self.nivel_m else None,
            'volumen_m3': float(self.volumen_m3) if self.volumen_m3 else None,
            'tendencia': self.tendencia,
            'fecha_hora': self.fecha_hora.isoformat() if self.fecha_hora else None,
            'dispositivo_origen': self.dispositivo_origen
        }

class FlowSummary(db.Model):
    """Modelo para resúmenes diarios de flujo"""
    __tablename__ = 'iot_resumen_flujo'
    
    id = db.Column(db.Integer, primary_key=True)
    estacion_id = db.Column('estacion_id', db.Integer)
    fecha = db.Column(db.Date, nullable=False)
    entrada_total_m3 = db.Column('entrada_total_m3', db.Numeric(14,3))
    salida_total_m3 = db.Column('salida_total_m3', db.Numeric(14,3))
    flujo_neto_m3 = db.Column('flujo_neto_m3', db.Numeric(14,3))
    pico_entrada_m3h = db.Column('pico_entrada_m3h', db.Numeric(12,4))
    pico_salida_m3h = db.Column('pico_salida_m3h', db.Numeric(12,4))
    nivel_agua_promedio_m = db.Column('nivel_agua_promedio_m', db.Numeric(6,3))
    nivel_agua_minimo_m = db.Column('nivel_agua_minimo_m', db.Numeric(6,3))
    nivel_agua_maximo_m = db.Column('nivel_agua_maximo_m', db.Numeric(6,3))
    precipitacion_total_mm = db.Column('precipitacion_total_mm', db.Numeric(8,2))
    horas_bombeo = db.Column('horas_bombeo', db.Numeric(8,2))
    consumo_energia_kwh = db.Column('consumo_energia_kwh', db.Numeric(10,3))
    
    def __repr__(self):
        return f'<FlowSummary {self.estacion_id}: {self.flujo_neto_m3}m³ on {self.fecha}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'estacion_id': self.estacion_id,
            'fecha': self.fecha.isoformat() if self.fecha else None,
            'entrada_total_m3': float(self.entrada_total_m3) if self.entrada_total_m3 else None,
            'salida_total_m3': float(self.salida_total_m3) if self.salida_total_m3 else None,
            'flujo_neto_m3': float(self.flujo_neto_m3) if self.flujo_neto_m3 else None,
            'pico_entrada_m3h': float(self.pico_entrada_m3h) if self.pico_entrada_m3h else None,
            'pico_salida_m3h': float(self.pico_salida_m3h) if self.pico_salida_m3h else None,
            'nivel_agua_promedio_m': float(self.nivel_agua_promedio_m) if self.nivel_agua_promedio_m else None,
            'nivel_agua_minimo_m': float(self.nivel_agua_minimo_m) if self.nivel_agua_minimo_m else None,
            'nivel_agua_maximo_m': float(self.nivel_agua_maximo_m) if self.nivel_agua_maximo_m else None,
            'precipitacion_total_mm': float(self.precipitacion_total_mm) if self.precipitacion_total_mm else None,
            'horas_bombeo': float(self.horas_bombeo) if self.horas_bombeo else None,
            'consumo_energia_kwh': float(self.consumo_energia_kwh) if self.consumo_energia_kwh else None
        }

class PumpingStation(db.Model):
    """Modelo para las estaciones de bombeo"""
    __tablename__ = 'iot_estacion_bombeo'
    
    id = db.Column(db.Integer, primary_key=True)
    estacion_id = db.Column('estacion_id', db.Integer)
    nombre = db.Column(db.String(100), nullable=False)
    tipo_bomba = db.Column('tipo_bomba', db.String(50))
    capacidad_maxima_m3h = db.Column('capacidad_maxima_m3h', db.Numeric(8,2))
    potencia_nominal_kw = db.Column('potencia_nominal_kw', db.Numeric(7,2))
    nivel_minimo_agua_m = db.Column('nivel_minimo_agua_m', db.Numeric(6,3))
    nivel_maximo_agua_m = db.Column('nivel_maximo_agua_m', db.Numeric(6,3))
    activo = db.Column(db.Boolean, default=True)
    fecha_instalacion = db.Column('fecha_instalacion', db.DateTime)
    fecha_creacion = db.Column('fecha_creacion', db.DateTime, default=datetime.utcnow)
    fecha_actualizacion = db.Column('fecha_actualizacion', db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f'<PumpingStation {self.nombre}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'estacion_id': self.estacion_id,
            'nombre': self.nombre,
            'tipo_bomba': self.tipo_bomba,
            'capacidad_maxima_m3h': float(self.capacidad_maxima_m3h) if self.capacidad_maxima_m3h else None,
            'potencia_nominal_kw': float(self.potencia_nominal_kw) if self.potencia_nominal_kw else None,
            'nivel_minimo_agua_m': float(self.nivel_minimo_agua_m) if self.nivel_minimo_agua_m else None,
            'nivel_maximo_agua_m': float(self.nivel_maximo_agua_m) if self.nivel_maximo_agua_m else None,
            'activo': self.activo,
            'fecha_instalacion': self.fecha_instalacion.isoformat() if self.fecha_instalacion else None,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
            'fecha_actualizacion': self.fecha_actualizacion.isoformat() if self.fecha_actualizacion else None
        }


# =====================================================================
# NUEVOS MODELOS - SISTEMA EXTENDIDO
# =====================================================================

class MeteorologicalData(db.Model):
    """Modelo para datos de estación meteorológica"""
    __tablename__ = 'iot_datos_meteorologicos'
    
    id = db.Column(db.Integer, primary_key=True)
    estacion_id = db.Column('estacion_id', db.Integer, nullable=False)
    temperatura_c = db.Column('temperatura_c', db.Numeric(5,2))
    humedad_porcentaje = db.Column('humedad_porcentaje', db.Numeric(5,2))
    precipitacion_mm = db.Column('precipitacion_mm', db.Numeric(6,2), default=0.0)
    velocidad_viento_kmh = db.Column('velocidad_viento_kmh', db.Numeric(5,2), default=0.0)
    direccion_viento_grados = db.Column('direccion_viento_grados', db.Integer, default=0)
    presion_atmosferica_hpa = db.Column('presion_atmosferica_hpa', db.Numeric(6,2))
    radiacion_solar_wm2 = db.Column('radiacion_solar_wm2', db.Numeric(7,2))
    indice_uv = db.Column('indice_uv', db.Numeric(4,2))
    evapotranspiracion_mm = db.Column('evapotranspiracion_mm', db.Numeric(6,3))
    humedad_suelo_porcentaje = db.Column('humedad_suelo_porcentaje', db.Numeric(5,2))
    temperatura_suelo_c = db.Column('temperatura_suelo_c', db.Numeric(5,2))
    humedad_hoja_porcentaje = db.Column('humedad_hoja_porcentaje', db.Numeric(5,2))
    fecha_hora = db.Column('fecha_hora', db.DateTime, nullable=False, default=datetime.utcnow)
    dispositivo_origen = db.Column('dispositivo_origen', db.String(50))
    
    def __repr__(self):
        return f'<MeteorologicalData Station {self.estacion_id} at {self.fecha_hora}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'estacion_id': self.estacion_id,
            'temperatura_c': float(self.temperatura_c) if self.temperatura_c else None,
            'humedad_porcentaje': float(self.humedad_porcentaje) if self.humedad_porcentaje else None,
            'precipitacion_mm': float(self.precipitacion_mm) if self.precipitacion_mm else 0.0,
            'velocidad_viento_kmh': float(self.velocidad_viento_kmh) if self.velocidad_viento_kmh else 0.0,
            'direccion_viento_grados': self.direccion_viento_grados,
            'presion_atmosferica_hpa': float(self.presion_atmosferica_hpa) if self.presion_atmosferica_hpa else None,
            'radiacion_solar_wm2': float(self.radiacion_solar_wm2) if self.radiacion_solar_wm2 else None,
            'indice_uv': float(self.indice_uv) if self.indice_uv else None,
            'evapotranspiracion_mm': float(self.evapotranspiracion_mm) if self.evapotranspiracion_mm else None,
            'humedad_suelo_porcentaje': float(self.humedad_suelo_porcentaje) if self.humedad_suelo_porcentaje else None,
            'temperatura_suelo_c': float(self.temperatura_suelo_c) if self.temperatura_suelo_c else None,
            'humedad_hoja_porcentaje': float(self.humedad_hoja_porcentaje) if self.humedad_hoja_porcentaje else None,
            'fecha_hora': self.fecha_hora.isoformat() if self.fecha_hora else None,
            'dispositivo_origen': self.dispositivo_origen
        }


class PumpTelemetry(db.Model):
    """Modelo para telemetría completa de bombas"""
    __tablename__ = 'iot_telemetria_bomba'
    
    id = db.Column(db.Integer, primary_key=True)
    bomba_id = db.Column('bomba_id', db.Integer, nullable=False)
    estado = db.Column(db.String(20), nullable=False, default='APAGADO')
    caudal_m3h = db.Column('caudal_m3h', db.Numeric(8,3), default=0.0)
    presion_entrada_bar = db.Column('presion_entrada_bar', db.Numeric(6,3), default=0.0)
    presion_salida_bar = db.Column('presion_salida_bar', db.Numeric(6,3), default=0.0)
    consumo_energia_kw = db.Column('consumo_energia_kw', db.Numeric(10,3), default=0.0)
    temperatura_motor_c = db.Column('temperatura_motor_c', db.Numeric(5,2))
    nivel_vibracion = db.Column('nivel_vibracion', db.Numeric(6,3))
    horas_operacion = db.Column('horas_operacion', db.Numeric(12,2), default=0.0)
    modo_operacion = db.Column('modo_operacion', db.String(20))
    fecha_hora = db.Column('fecha_hora', db.DateTime, nullable=False, default=datetime.utcnow)
    dispositivo_origen = db.Column('dispositivo_origen', db.String(50))
    
    def __repr__(self):
        return f'<PumpTelemetry Pump {self.bomba_id}: {self.estado}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'bomba_id': self.bomba_id,
            'estado': self.estado,
            'caudal_m3h': float(self.caudal_m3h) if self.caudal_m3h else 0.0,
            'presion_entrada_bar': float(self.presion_entrada_bar) if self.presion_entrada_bar else 0.0,
            'presion_salida_bar': float(self.presion_salida_bar) if self.presion_salida_bar else 0.0,
            'consumo_energia_kw': float(self.consumo_energia_kw) if self.consumo_energia_kw else 0.0,
            'temperatura_motor_c': float(self.temperatura_motor_c) if self.temperatura_motor_c else None,
            'nivel_vibracion': float(self.nivel_vibracion) if self.nivel_vibracion else None,
            'horas_operacion': float(self.horas_operacion) if self.horas_operacion else 0.0,
            'modo_operacion': self.modo_operacion,
            'fecha_hora': self.fecha_hora.isoformat() if self.fecha_hora else None,
            'dispositivo_origen': self.dispositivo_origen
        }


class SystemAlert(db.Model):
    """Modelo para alertas del sistema"""
    __tablename__ = 'iot_alerta_sistema'
    
    id = db.Column(db.Integer, primary_key=True)
    estacion_id = db.Column('estacion_id', db.Integer)
    bomba_id = db.Column('bomba_id', db.Integer)
    tipo_alerta = db.Column('tipo_alerta', db.String(50), nullable=False)
    severidad = db.Column(db.String(20), nullable=False)
    titulo = db.Column(db.String(200))
    descripcion = db.Column(db.Text, nullable=False)
    nombre_parametro = db.Column('nombre_parametro', db.String(100))
    valor_parametro = db.Column('valor_parametro', db.Numeric(12,4))
    valor_umbral = db.Column('valor_umbral', db.Numeric(12,4))
    esta_resuelto = db.Column('esta_resuelto', db.Boolean, default=False)
    notificacion_enviada = db.Column('notificacion_enviada', db.Boolean, default=False)
    canales_notificacion = db.Column('canales_notificacion', db.String(200))
    fecha_hora = db.Column('fecha_hora', db.DateTime, nullable=False, default=datetime.utcnow)
    fecha_resolucion = db.Column('fecha_resolucion', db.DateTime)
    resuelto_por = db.Column('resuelto_por', db.String(100))
    notas_resolucion = db.Column('notas_resolucion', db.Text)
    
    def __repr__(self):
        return f'<SystemAlert {self.severidad}: {self.tipo_alerta}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'estacion_id': self.estacion_id,
            'bomba_id': self.bomba_id,
            'tipo_alerta': self.tipo_alerta,
            'severidad': self.severidad,
            'titulo': self.titulo,
            'descripcion': self.descripcion,
            'nombre_parametro': self.nombre_parametro,
            'valor_parametro': float(self.valor_parametro) if self.valor_parametro else None,
            'valor_umbral': float(self.valor_umbral) if self.valor_umbral else None,
            'esta_resuelto': self.esta_resuelto,
            'notificacion_enviada': self.notificacion_enviada,
            'canales_notificacion': self.canales_notificacion,
            'fecha_hora': self.fecha_hora.isoformat() if self.fecha_hora else None,
            'fecha_resolucion': self.fecha_resolucion.isoformat() if self.fecha_resolucion else None,
            'resuelto_por': self.resuelto_por,
            'notas_resolucion': self.notas_resolucion
        }


class AlertThreshold(db.Model):
    """Modelo para umbrales de alertas configurables"""
    __tablename__ = 'iot_umbral_alerta'
    
    id = db.Column(db.Integer, primary_key=True)
    nombre_parametro = db.Column('nombre_parametro', db.String(100), nullable=False)
    valor_minimo = db.Column('valor_minimo', db.Numeric(12,4))
    valor_maximo = db.Column('valor_maximo', db.Numeric(12,4))
    nivel_alerta = db.Column('nivel_alerta', db.String(20))
    descripcion = db.Column(db.Text)
    activo = db.Column(db.Boolean, default=True)
    fecha_creacion = db.Column('fecha_creacion', db.DateTime, default=datetime.utcnow)
    fecha_actualizacion = db.Column('fecha_actualizacion', db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f'<AlertThreshold {self.nombre_parametro}: {self.valor_minimo}-{self.valor_maximo}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'nombre_parametro': self.nombre_parametro,
            'valor_minimo': float(self.valor_minimo) if self.valor_minimo else None,
            'valor_maximo': float(self.valor_maximo) if self.valor_maximo else None,
            'nivel_alerta': self.nivel_alerta,
            'descripcion': self.descripcion,
            'activo': self.activo,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
            'fecha_actualizacion': self.fecha_actualizacion.isoformat() if self.fecha_actualizacion else None
        }


class AutomaticControlLog(db.Model):
    """Modelo para log de control automático"""
    __tablename__ = 'iot_log_control_automatico'
    
    id = db.Column(db.Integer, primary_key=True)
    estacion_id = db.Column('estacion_id', db.Integer)
    bomba_id = db.Column('bomba_id', db.Integer, nullable=False)
    accion = db.Column(db.String(20), nullable=False)
    razon = db.Column(db.Text)
    nivel_agua_m = db.Column('nivel_agua_m', db.Numeric(6,3))
    precipitacion_mm = db.Column('precipitacion_mm', db.Numeric(6,2))
    periodo_tarifa = db.Column('periodo_tarifa', db.String(20))
    temperatura_motor_c = db.Column('temperatura_motor_c', db.Numeric(5,2))
    tiempo_decision_ms = db.Column('tiempo_decision_ms', db.Integer)
    estado_ejecucion = db.Column('estado_ejecucion', db.String(20))
    mensaje_error = db.Column('mensaje_error', db.Text)
    fecha_hora = db.Column('fecha_hora', db.DateTime, nullable=False, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<AutoControl {self.accion} at {self.fecha_hora}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'estacion_id': self.estacion_id,
            'bomba_id': self.bomba_id,
            'accion': self.accion,
            'razon': self.razon,
            'nivel_agua_m': float(self.nivel_agua_m) if self.nivel_agua_m else None,
            'precipitacion_mm': float(self.precipitacion_mm) if self.precipitacion_mm else None,
            'periodo_tarifa': self.periodo_tarifa,
            'temperatura_motor_c': float(self.temperatura_motor_c) if self.temperatura_motor_c else None,
            'tiempo_decision_ms': self.tiempo_decision_ms,
            'estado_ejecucion': self.estado_ejecucion,
            'mensaje_error': self.mensaje_error,
            'fecha_hora': self.fecha_hora.isoformat() if self.fecha_hora else None
        }


class MonitoringStation(db.Model):
    """Modelo extendido para estaciones de monitoreo"""
    __tablename__ = 'iot_estacion_monitoreo'
    
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False, unique=True)
    ubicacion = db.Column(db.String(200))
    latitud = db.Column(db.Numeric(10,7))
    longitud = db.Column(db.Numeric(10,7))
    elevacion_m = db.Column('elevacion_m', db.Numeric(7,2))
    tipo_estacion = db.Column('tipo_estacion', db.String(50))
    activo = db.Column(db.Boolean, default=True)
    control_automatico_habilitado = db.Column('control_automatico_habilitado', db.Boolean, default=True)
    fecha_instalacion = db.Column('fecha_instalacion', db.DateTime)
    fecha_ultimo_mantenimiento = db.Column('fecha_ultimo_mantenimiento', db.DateTime)
    fecha_creacion = db.Column('fecha_creacion', db.DateTime, default=datetime.utcnow)
    fecha_actualizacion = db.Column('fecha_actualizacion', db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f'<MonitoringStation {self.nombre}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'nombre': self.nombre,
            'ubicacion': self.ubicacion,
            'latitud': float(self.latitud) if self.latitud else None,
            'longitud': float(self.longitud) if self.longitud else None,
            'elevacion_m': float(self.elevacion_m) if self.elevacion_m else None,
            'tipo_estacion': self.tipo_estacion,
            'activo': self.activo,
            'control_automatico_habilitado': self.control_automatico_habilitado,
            'fecha_instalacion': self.fecha_instalacion.isoformat() if self.fecha_instalacion else None,
            'fecha_ultimo_mantenimiento': self.fecha_ultimo_mantenimiento.isoformat() if self.fecha_ultimo_mantenimiento else None,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
            'fecha_actualizacion': self.fecha_actualizacion.isoformat() if self.fecha_actualizacion else None
        }


class NotificationContact(db.Model):
    """Modelo para contactos de notificaciones"""
    __tablename__ = 'iot_contacto_notificacion'
    
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)
    cargo = db.Column(db.String(100))
    correo = db.Column(db.String(150))
    telefono = db.Column(db.String(20))
    numero_whatsapp = db.Column('numero_whatsapp', db.String(20))
    recibir_critico = db.Column('recibir_critico', db.Boolean, default=True)
    recibir_alto = db.Column('recibir_alto', db.Boolean, default=True)
    recibir_medio = db.Column('recibir_medio', db.Boolean, default=False)
    recibir_bajo = db.Column('recibir_bajo', db.Boolean, default=False)
    activo = db.Column(db.Boolean, default=True)
    fecha_creacion = db.Column('fecha_creacion', db.DateTime, default=datetime.utcnow)
    fecha_actualizacion = db.Column('fecha_actualizacion', db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f'<NotificationContact {self.nombre}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'nombre': self.nombre,
            'cargo': self.cargo,
            'correo': self.correo,
            'telefono': self.telefono,
            'numero_whatsapp': self.numero_whatsapp,
            'recibir_critico': self.recibir_critico,
            'recibir_alto': self.recibir_alto,
            'recibir_medio': self.recibir_medio,
            'recibir_bajo': self.recibir_bajo,
            'activo': self.activo,
            'fecha_creacion': self.fecha_creacion.isoformat() if self.fecha_creacion else None,
            'fecha_actualizacion': self.fecha_actualizacion.isoformat() if self.fecha_actualizacion else None
        }
