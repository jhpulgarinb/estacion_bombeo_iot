"""
Script de Inicialización de Base de Datos
Promotora Palmera de Antioquia S.A.S.
Sistema IoT Estación de Bombeo
Fecha: 20 de febrero de 2026

Este script crea automáticamente todas las tablas necesarias
para el sistema IoT de monitoreo y control.
"""

import os
import sys
from flask import Flask
from database import db
from database import (
    GateStatus, WaterLevel, PumpingStation, FlowSummary,
    MeteorologicalData, PumpTelemetry, SystemAlert, AlertThreshold,
    AutomaticControlLog, MonitoringStation, NotificationContact
)
from datetime import datetime

def init_database():
    """Inicializar base de datos y crear todas las tablas"""
    
    print("\n" + "="*70)
    print("🗄️  INICIALIZACIÓN DE BASE DE DATOS")
    print("="*70 + "\n")
    
    # Crear aplicación Flask temporal
    app = Flask(__name__)
    app.config.from_pyfile('config.py')
    db.init_app(app)
    
    with app.app_context():
        print("📋 Verificando tablas existentes...")
        
        # Eliminar todas las tablas si existen (CUIDADO: borra datos)
        # db.drop_all()
        # print("⚠️  Tablas anteriores eliminadas")
        
        # Crear todas las tablas
        db.create_all()
        print("✅ Tablas creadas exitosamente\n")
        
        # Verificar si hay datos de prueba
        station_count = MonitoringStation.query.count()
        
        if station_count == 0:
            print("📊 Insertando datos iniciales de prueba...\n")
            insert_seed_data()
        else:
            print(f"ℹ️  Base de datos ya contiene {station_count} estaciones\n")
        
        print("="*70)
        print("✅ INICIALIZACIÓN COMPLETADA")
        print("="*70 + "\n")
        
        # Mostrar resumen
        show_database_summary()

def insert_seed_data():
    """Insertar datos iniciales de prueba"""
    
    # 1. Estaciones de monitoreo
    stations = [
        MonitoringStation(
            station_name='Estación Administración',
            station_type='COMBINED',
            location='Sector Administrativo',
            latitude=6.2442,
            longitude=-75.5812,
            auto_control_enabled=True
        ),
        MonitoringStation(
            station_name='Estación Playa',
            station_type='COMBINED',
            location='Sector Playa',
            latitude=6.2450,
            longitude=-75.5820,
            auto_control_enabled=True
        ),
        MonitoringStation(
            station_name='Estación Bendición',
            station_type='PUMPING',
            location='Sector Bendición',
            latitude=6.2435,
            longitude=-75.5805,
            auto_control_enabled=False
        ),
        MonitoringStation(
            station_name='Estación Plana',
            station_type='METEOROLOGICAL',
            location='Sector Plana',
            latitude=6.2460,
            longitude=-75.5795,
            auto_control_enabled=False
        )
    ]
    
    for station in stations:
        db.session.add(station)
    
    db.session.commit()
    print(f"  ✅ {len(stations)} estaciones de monitoreo creadas")
    
    # 2. Bombas (vinculadas a estaciones)
    pumps = [
        PumpingStation(
            station_id=1,
            name='Bomba Principal Norte',
            max_capacity_m3s=1.2,
            min_level_m=0.5,
            max_level_m=3.0,
            status='active'
        ),
        PumpingStation(
            station_id=2,
            name='Bomba Principal Sur',
            max_capacity_m3s=1.0,
            min_level_m=0.6,
            max_level_m=2.8,
            status='active'
        ),
        PumpingStation(
            station_id=3,
            name='Bomba Auxiliar Este',
            max_capacity_m3s=0.8,
            min_level_m=0.4,
            max_level_m=2.5,
            status='maintenance'
        )
    ]
    
    for pump in pumps:
        db.session.add(pump)
    
    db.session.commit()
    print(f"  ✅ {len(pumps)} estaciones de bombeo creadas")
    
    # 3. Umbrales de alerta
    thresholds = [
        # Nivel de agua
        AlertThreshold(
            station_id=1,
            parameter_name='water_level',
            min_value=0.5,
            max_value=3.0,
            alert_level='HIGH',
            notification_method='Email,WhatsApp',
            is_active=True
        ),
        # Precipitación
        AlertThreshold(
            station_id=1,
            parameter_name='precipitation',
            min_value=0.0,
            max_value=50.0,
            alert_level='MEDIUM',
            notification_method='Email',
            is_active=True
        ),
        # Temperatura motor
        AlertThreshold(
            station_id=1,
            parameter_name='motor_temperature_c',
            min_value=0.0,
            max_value=85.0,
            alert_level='CRITICAL',
            notification_method='Email,WhatsApp,SMS',
            is_active=True
        ),
        # Presión de entrada
        AlertThreshold(
            station_id=1,
            parameter_name='inlet_pressure_bar',
            min_value=2.0,
            max_value=5.0,
            alert_level='HIGH',
            notification_method='Email,WhatsApp',
            is_active=True
        ),
        # Velocidad del viento
        AlertThreshold(
            station_id=1,
            parameter_name='wind_speed_kmh',
            min_value=0.0,
            max_value=60.0,
            alert_level='MEDIUM',
            notification_method='Email',
            is_active=True
        )
    ]
    
    for threshold in thresholds:
        db.session.add(threshold)
    
    db.session.commit()
    print(f"  ✅ {len(thresholds)} umbrales de alerta configurados")
    
    # 4. Contactos de notificación
    contacts = [
        NotificationContact(
            name='Supervisor Operaciones',
            email='supervisor@promotorapalmera.com',
            phone='+573001234567',
            whatsapp_number='+573001234567',
            role='Supervisor',
            receive_critical=True,
            receive_high=True,
            receive_medium=True,
            receive_low=False
        ),
        NotificationContact(
            name='Técnico de Campo',
            email='tecnico@promotorapalmera.com',
            phone='+573007654321',
            whatsapp_number='+573007654321',
            role='Técnico',
            receive_critical=True,
            receive_high=True,
            receive_medium=False,
            receive_low=False
        )
    ]
    
    for contact in contacts:
        db.session.add(contact)
    
    db.session.commit()
    print(f"  ✅ {len(contacts)} contactos de notificación creados")
    
    print()

def show_database_summary():
    """Mostrar resumen del estado de la base de datos"""
    
    from flask import Flask
    app = Flask(__name__)
    app.config.from_pyfile('config.py')
    db.init_app(app)
    
    with app.app_context():
        print("📊 RESUMEN DE BASE DE DATOS:")
        print("-" * 70)
        
        try:
            stations = MonitoringStation.query.count()
            print(f"  • Estaciones de monitoreo: {stations}")
        except:
            print(f"  • Estaciones de monitoreo: 0 (tabla no existe)")
        
        try:
            pumps = PumpingStation.query.count()
            print(f"  • Estaciones de bombeo: {pumps}")
        except:
            print(f"  • Estaciones de bombeo: 0 (tabla no existe)")
        
        try:
            thresholds = AlertThreshold.query.count()
            print(f"  • Umbrales de alerta: {thresholds}")
        except:
            print(f"  • Umbrales de alerta: 0 (tabla no existe)")
        
        try:
            contacts = NotificationContact.query.count()
            print(f"  • Contactos de notificación: {contacts}")
        except:
            print(f"  • Contactos de notificación: 0 (tabla no existe)")
        
        try:
            weather_data = MeteorologicalData.query.count()
            print(f"  • Datos meteorológicos: {weather_data}")
        except:
            print(f"  • Datos meteorológicos: 0 (tabla no existe)")
        
        try:
            pump_data = PumpTelemetry.query.count()
            print(f"  • Datos de telemetría: {pump_data}")
        except:
            print(f"  • Datos de telemetría: 0 (tabla no existe)")
        
        try:
            alerts = SystemAlert.query.count()
            print(f"  • Alertas del sistema: {alerts}")
        except:
            print(f"  • Alertas del sistema: 0 (tabla no existe)")
        
        try:
            control_logs = AutomaticControlLog.query.count()
            print(f"  • Logs de control: {control_logs}")
        except:
            print(f"  • Logs de control: 0 (tabla no existe)")
        
        print("-" * 70)
        print()

if __name__ == '__main__':
    # Verificar que estamos en el directorio correcto
    if not os.path.exists('config.py'):
        print("❌ ERROR: No se encuentra config.py")
        print("   Ejecute este script desde el directorio del proyecto")
        sys.exit(1)
    
    init_database()
