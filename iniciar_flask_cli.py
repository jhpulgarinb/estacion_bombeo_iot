#!/usr/bin/env python
"""
Script para instalar pymysql e iniciar Flask con MySQL
"""

import subprocess
import sys
import os

print("=" * 60)
print("  Iniciando Flask con MySQL")
print("=" * 60)
print()

# Detectar si estamos en venv
venv_python = os.path.join("venv", "Scripts", "python.exe")
if not os.path.exists(venv_python):
    print("ERROR: Entorno virtual no encontrado")
    sys.exit(1)

print("✅ Entorno virtual detectado")
print()

# Instalar pymysql
print("📦 Instalando pymysql...")
try:
    result = subprocess.run(
        [venv_python, "-m", "pip", "install", "pymysql", "-q"],
        check=False
    )
    if result.returncode == 0:
        print("✅ pymysql instalado\n")
    else:
        print("⚠️  Error en instalación (continuando...)\n")
except Exception as e:
    print(f"⚠️  Error: {e}\n")

# Probar conexión
print("🧪 Probando conexión a MySQL...")
print()

test_code = """
import sys
try:
    from flask import Flask
    from flask_sqlalchemy import SQLAlchemy
    from database import db, MonitoringStation, PumpingStation
    from config import SQLALCHEMY_DATABASE_URI
    
    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = SQLALCHEMY_DATABASE_URI
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    db.init_app(app)
    
    with app.app_context():
        estaciones = db.session.execute(db.text('SELECT COUNT(*) FROM iot_estacion_monitoreo')).scalar()
        bombas = db.session.execute(db.text('SELECT COUNT(*) FROM iot_estacion_bombeo')).scalar()
        
        print('✅ Conexión a MySQL exitosa')
        print(f'   Estaciones de monitoreo: {estaciones}')
        print(f'   Estaciones de bombeo: {bombas}')
        
except Exception as e:
    print(f'❌ Error de conexión: {e}')
    import traceback
    traceback.print_exc()
    sys.exit(1)
"""

subprocess.run([venv_python, "-c", test_code])

print()
print("=" * 60)
print("  Iniciando servidor Flask...")
print("=" * 60)
print()
print("URL: http://localhost:5000")
print()

# Ejecutar Flask
subprocess.run([venv_python, "app.py"])
