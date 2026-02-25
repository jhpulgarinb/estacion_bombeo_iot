"""
Script de prueba - Verifica conexión Flask con MySQL
Instala pymysql y prueba la conexión
"""

import subprocess
import sys

print("=" * 70)
print("  PRUEBA DE CONEXIÓN FLASK - MYSQL")
print("=" * 70)
print()

# Instalar pymysql
print("📦 Instalando pymysql...")
try:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pymysql", "-q"])
    print("✅ pymysql instalado\n")
except Exception as e:
    print(f"⚠️  Error instalando pymysql: {e}\n")
    print("Continuando de todas formas...\n")

# Importar Flask y SQLAlchemy
try:
    from flask import Flask
    from flask_sqlalchemy import SQLAlchemy
    from database import db, MonitoringStation, PumpingStation
    from config import SQLALCHEMY_DATABASE_URI
    
    print("✅ Importaciones exitosas")
    print(f"📂 Base de datos: {SQLALCHEMY_DATABASE_URI}\n")
    
    # Crear aplicación Flask
    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = SQLALCHEMY_DATABASE_URI
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    db.init_app(app)
    
    print("🔌 Realizando conexión a MySQL...\n")
    
    with app.app_context():
        # Intentar ejecutar una consulta simple
        print("📊 DATOS DE LA BASE DE DATOS:\n")
        
        # Estaciones de monitoreo
        print("--- ESTACIONES DE MONITOREO ---")
        estaciones = MonitoringStation.query.all()
        if estaciones:
            print(f"✅ Total: {len(estaciones)} estaciones\n")
            for estacion in estaciones:
                print(f"   • {estacion.nombre}")
                print(f"     Ubicación: {estacion.ubicacion}")
                print(f"     Coordenadas: ({estacion.latitud}, {estacion.longitud})")
                print(f"     Estado: {'Activa' if estacion.activo else 'Inactiva'}\n")
        else:
            print("   (sin datos)\n")
        
        # Estaciones de bombeo
        print("--- ESTACIONES DE BOMBEO ---")
        bombas = PumpingStation.query.all()
        if bombas:
            print(f"✅ Total: {len(bombas)} bombas\n")
            for bomba in bombas:
                print(f"   • {bomba.nombre}")
                print(f"     Tipo: {bomba.tipo_bomba}")
                print(f"     Capacidad: {bomba.capacidad_maxima_m3h} m³/h")
                print(f"     Estado: {'Activa' if bomba.activo else 'Inactiva'}\n")
        else:
            print("   (sin datos)\n")
    
    print("=" * 70)
    print("  ✅ CONEXIÓN EXITOSA")
    print("=" * 70)
    print()
    print("📝 PRÓXIMOS PASOS:")
    print()
    print("1. Ejecutar Flask:")
    print("   python app.py")
    print()
    print("2. Abrir en el navegador:")
    print("   http://localhost:5000")
    print()
    print("=" * 70)
    
except ImportError as e:
    print(f"❌ Error de importación: {e}\n")
    print("Asegúrese de que todas las dependencias estén instaladas:")
    print("   pip install flask flask-sqlalchemy pymysql\n")
    
except Exception as e:
    print(f"❌ Error de conexión: {e}\n")
    print("Verifique que:")
    print("   1. MySQL esté ejecutándose")
    print("   2. La base de datos 'promotorapalmera_db' exista")
    print("   3. Las tablas 'iot_*' estén creadas\n")
    import traceback
    traceback.print_exc()
