# Script para instalar pymysql y ejecutar Flask
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  Iniciando Flask con MySQL" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que estamos en el venv
if (!(Test-Path "venv\Lib\site-packages")) {
    Write-Host "ERROR: Entorno virtual no encontrado" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Entorno virtual detectado" -ForegroundColor Green
Write-Host ""

# Verificar si pymysql está instalado
Write-Host "🔍 Verificando pymysql..." -ForegroundColor Yellow
$pymysqlPath = "venv\Lib\site-packages\pymysql"

if (Test-Path $pymysqlPath) {
    Write-Host "✅ pymysql ya está instalado" -ForegroundColor Green
} else {
    Write-Host "📦 Instalando pymysql..." -ForegroundColor Yellow
    & "venv\Scripts\python.exe" -m pip install pymysql -q
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ pymysql instalado exitosamente" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Error instalando pymysql" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🧪 Probando conexión a MySQL..." -ForegroundColor Cyan
Write-Host ""

$testScript = @"
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
        print('')
        print('🚀 Iniciando Flask...')
        print('   URL: http://localhost:5000')
        
except Exception as e:
    print(f'❌ Error de conexión: {e}')
    import traceback
    traceback.print_exc()
"@

$testScript | & "venv\Scripts\python.exe"

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  Iniciando servidor Flask..." -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

& "venv\Scripts\python.exe" app.py
