import sys
import pymysql
from sqlalchemy import create_engine, text

print("=" * 60)
print("  PRUEBA DE SISTEMA IOT BOMBEO")
print("=" * 60)
print()

# Prueba 1: Conexión MySQL
print("[1/4] Probando conexión MySQL...")
try:
    conn = pymysql.connect(
        host='localhost',
        user='root',
        password='',
        database='promotorapalmera_db',
        charset='utf8mb4'
    )
    print("✓ Conexión MySQL: EXITOSA")
    
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM iot_estacion_monitoreo")
    count = cursor.fetchone()[0]
    print(f"  - Estaciones de monitoreo: {count}")
    
    cursor.execute("SELECT COUNT(*) FROM iot_estacion_bombeo")
    count = cursor.fetchone()[0]
    print(f"  - Estaciones de bombeo: {count}")
    
    conn.close()
except Exception as e:
    print(f"✗ Error MySQL: {e}")
    sys.exit(1)

print()

# Prueba 2: SQLAlchemy
print("[2/4] Probando SQLAlchemy...")
try:
    engine = create_engine('mysql+pymysql://root:@localhost:3306/promotorapalmera_db?charset=utf8mb4')
    with engine.connect() as conn:
        result = conn.execute(text("SELECT nombre FROM iot_estacion_monitoreo ORDER BY id"))
        stations = result.fetchall()
        print("✓ SQLAlchemy: EXITOSA")
        for station in stations:
            print(f"  - {station[0]}")
except Exception as e:
    print(f"✗ Error SQLAlchemy: {e}")
    sys.exit(1)

print()

# Prueba 3: Importar modelos
print("[3/4] Probando importación de modelos...")
try:
    from database import db, MonitoringStation, PumpingStation
    print("✓ Importación de modelos: EXITOSA")
except Exception as e:
    print(f"✗ Error importando modelos: {e}")
    sys.exit(1)

print()

# Prueba 4: Verificar Flask
print("[4/4] Probando Flask...")
try:
    from flask import Flask
    from config import SQLALCHEMY_DATABASE_URI
    
    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = SQLALCHEMY_DATABASE_URI
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    db.init_app(app)
    
    with app.app_context():
        # Consultar estaciones
        stations = MonitoringStation.query.all()
        print(f"✓ Flask + SQLAlchemy: EXITOSA")
        print(f"  - {len(stations)} estaciones encontradas")
        
        for station in stations:
            print(f"    * {station.nombre} ({station.tipo_estacion})")
            
except Exception as e:
    print(f"✗ Error Flask: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print()
print("=" * 60)
print("  ✓ TODAS LAS PRUEBAS PASARON EXITOSAMENTE")
print("=" * 60)
print()
print("El sistema está listo para iniciar Flask.")
print("Ejecuta: python app.py")
print()
