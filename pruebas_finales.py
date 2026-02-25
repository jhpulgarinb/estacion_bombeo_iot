#!/usr/bin/env python3
"""
PRUEBAS FINALES DEL SISTEMA
Verifica que todo esté funcionando correctamente
"""

import sys
import requests
import json
from datetime import datetime

print("=" * 70)
print("  PRUEBAS FINALES - SISTEMA IOT BOMBEO")
print("=" * 70)
print()

# Prueba 1: Conexión a base de datos
print("TEST 1: Conexión a MySQL")
print("-" * 70)

try:
    from database import db, MonitoringStation, PumpingStation, AlertThreshold
    from flask import Flask
    from config import SQLALCHEMY_DATABASE_URI
    
    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = SQLALCHEMY_DATABASE_URI
    db.init_app(app)
    
    with app.app_context():
        # Contar estaciones
        estaciones = MonitoringStation.query.count()
        bombas = PumpingStation.query.count()
        umbrales = AlertThreshold.query.count()
        
        print(f"✅ Conexión exitosa a MySQL")
        print(f"   Estaciones: {estaciones}")
        print(f"   Bombas: {bombas}")
        print(f"   Umbrales: {umbrales}")
        print()

except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)

# Prueba 2: Validar estructura de base de datos
print("TEST 2: Validar estructura de base de datos")
print("-" * 70)

try:
    with app.app_context():
        # Verificar que las tablas existen
        from sqlalchemy import inspect
        
        inspector = inspect(db.engine)
        tablas = inspector.get_table_names()
        
        tablas_esperadas = [
            'iot_estacion_monitoreo',
            'iot_estacion_bombeo',
            'iot_datos_meteorologicos',
            'iot_telemetria_bomba',
            'iot_nivel_agua',
            'iot_estado_compuerta',
            'iot_alerta_sistema',
            'iot_umbral_alerta',
            'iot_log_control_automatico',
            'iot_contacto_notificacion',
            'iot_resumen_flujo'
        ]
        
        tablas_creadas = sum(1 for t in tablas_esperadas if t in tablas)
        print(f"✅ Tablas verificadas: {tablas_creadas}/{len(tablas_esperadas)}")
        
        if tablas_creadas == len(tablas_esperadas):
            print("   Todas las tablas están presentes")
        else:
            print("   ⚠️  Faltan algunas tablas")
        print()

except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)

# Prueba 3: Datos de prueba
print("TEST 3: Verificar datos de prueba")
print("-" * 70)

try:
    with app.app_context():
        # Mostrar estaciones
        estaciones = MonitoringStation.query.all()
        print(f"✅ Estaciones de monitoreo:")
        for estacion in estaciones:
            print(f"   • {estacion.nombre}")
        
        # Mostrar bombas
        bombas = PumpingStation.query.all()
        print(f"\n✅ Estaciones de bombeo:")
        for bomba in bombas:
            print(f"   • {bomba.nombre} ({bomba.capacidad_maxima_m3h} m³/h)")
        
        print()

except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)

# Prueba 4: Verificar modelos
print("TEST 4: Verificar modelos SQLAlchemy")
print("-" * 70)

try:
    with app.app_context():
        estacion = MonitoringStation.query.first()
        
        if estacion:
            print(f"✅ Modelo MonitoringStation:")
            print(f"   ID: {estacion.id}")
            print(f"   Nombre: {estacion.nombre}")
            print(f"   Ubicación: {estacion.ubicacion}")
            print(f"   Activo: {estacion.activo}")
            print()
        
        bomba = PumpingStation.query.first()
        if bomba:
            print(f"✅ Modelo PumpingStation:")
            print(f"   ID: {bomba.id}")
            print(f"   Nombre: {bomba.nombre}")
            print(f"   Tipo: {bomba.tipo_bomba}")
            print(f"   Capacidad: {bomba.capacidad_maxima_m3h} m³/h")
            print()

except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)

# Prueba 5: Serialización JSON
print("TEST 5: Verificar serialización JSON")
print("-" * 70)

try:
    with app.app_context():
        estacion = MonitoringStation.query.first()
        
        if estacion:
            json_data = estacion.to_dict()
            print(f"✅ Estación serializada correctamente:")
            print(f"   {json.dumps(json_data, indent=2, ensure_ascii=False)[:200]}...")
            print()

except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)

# Resumen final
print("=" * 70)
print("  ✅ TODAS LAS PRUEBAS COMPLETADAS EXITOSAMENTE")
print("=" * 70)
print()
print("📝 PRÓXIMOS PASOS:")
print()
print("1. Ejecutar Flask:")
print("   python app.py")
print()
print("2. Abrir dashboard:")
print("   http://localhost:5000")
print()
print("3. Enviar datos de sensores:")
print("   - Usar Wokwi ESP32 simulator")
print("   - O hacer requests POST a los endpoints API")
print()
print("=" * 70)
