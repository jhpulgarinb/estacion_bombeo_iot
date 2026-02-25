@echo off
REM =====================================================================
REM   SCRIPT MAESTRO - INICIAR SISTEMA COMPLETO IOT BOMBEO
REM   Promotora Palmera de Antioquia S.A.S.
REM   Fecha: 21 de febrero de 2026
REM =====================================================================

setlocal enabledelayedexpansion

title Sistema IoT Bombeo - Iniciador Maestro

:MENU
cls
echo.
echo  =====================================================================
echo    SISTEMA IOT BOMBEO - PROYECTO DE GRADO
echo  =====================================================================
echo.
echo  Estado del Sistema:
echo.

REM Verificar MySQL
mysql -u root -e "SELECT 1" > nul 2>&1
if errorlevel 1 (
    echo  [X] MySQL - NO CONECTADO
) else (
    echo  [OK] MySQL - CONECTADO
)

REM Verificar Python
python --version > nul 2>&1
if errorlevel 1 (
    echo  [X] Python - NO ENCONTRADO
) else (
    echo  [OK] Python - DISPONIBLE
)

REM Verificar PyMySQL
python -m pip list 2>nul | find "pymysql" > nul
if errorlevel 1 (
    echo  [X] PyMySQL - NO INSTALADO
) else (
    echo  [OK] PyMySQL - INSTALADO
)

echo.
echo  =====================================================================
echo.
echo  OPCIONES:
echo.
echo   [1] Verificar instalaci\u00f3n MySQL
echo   [2] Configurar Event Scheduler
echo   [3] Instalar dependencias Python
echo   [4] Ejecutar pruebas
echo   [5] Iniciar servidor Flask
echo   [6] Ver estado de eventos
echo   [7] Abrir phpMyAdmin
echo   [8] Salir
echo.
echo  =====================================================================
echo.

set /p choice="  Seleccione una opci\u00f3n (1-8): "

if "%choice%"=="1" goto VERIFY_MYSQL
if "%choice%"=="2" goto CONFIG_EVENTS
if "%choice%"=="3" goto INSTALL_PY
if "%choice%"=="4" goto RUN_TESTS
if "%choice%"=="5" goto START_FLASK
if "%choice%"=="6" goto VIEW_EVENTS
if "%choice%"=="7" goto OPEN_PHPMYADMIN
if "%choice%"=="8" exit /b 0

goto MENU

REM =====================================================================

:VERIFY_MYSQL
cls
echo.
echo  Verificando instalaci\u00f3n MySQL...
echo.
php verificar_mysql.php
echo.
pause
goto MENU

:CONFIG_EVENTS
cls
echo.
echo  Configurando Event Scheduler...
echo.
php configurar_event_scheduler.php
echo.
pause
goto MENU

:INSTALL_PY
cls
echo.
echo  Instalando dependencias Python...
echo.
pip install pymysql flask flask-sqlalchemy flask-cors -q
echo.
echo  Dependencias instaladas correctamente
echo.
pause
goto MENU

:RUN_TESTS
cls
echo.
echo  Ejecutando pruebas...
echo.
python prueba_conexion.py
echo.
pause
goto MENU

:START_FLASK
cls
echo.
echo  =====================================================================
echo    Iniciando servidor Flask
echo  =====================================================================
echo.
echo  Instalando dependencias...
pip install pymysql flask flask-sqlalchemy flask-cors -q

echo.
echo  Probando conexi\u00f3n a MySQL...
python -c "from database import db, MonitoringStation; from flask import Flask; from config import SQLALCHEMY_DATABASE_URI; app = Flask(__name__); app.config['SQLALCHEMY_DATABASE_URI'] = SQLALCHEMY_DATABASE_URI; db.init_app(app); print('✓ Conexi\u00f3n exitosa')" 2>nul

if errorlevel 1 (
    echo.
    echo  ERROR: No se puede conectar a MySQL
    echo.
    pause
    goto MENU
)

echo.
echo  =====================================================================
echo  Servidor Flask iniciado
echo  =====================================================================
echo.
echo  URL: http://localhost:5000
echo  Dashboard: http://localhost:5000/dashboard
echo.
echo  (Presione Ctrl+C para detener)
echo.

python app.py
goto MENU

:VIEW_EVENTS
cls
echo.
echo  Estado de eventos programados en MySQL...
echo.
mysql -u root promotorapalmera_db -e "SHOW EVENTS WHERE Db='promotorapalmera_db'" 2>&1
echo.
pause
goto MENU

:OPEN_PHPMYADMIN
start http://localhost/phpmyadmin
echo  Abriendo phpMyAdmin en navegador...
timeout /t 2 > nul
goto MENU

REM =====================================================================
REM FIN DEL SCRIPT
REM =====================================================================
