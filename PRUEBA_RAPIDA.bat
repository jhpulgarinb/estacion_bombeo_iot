@echo off
echo ========================================================
echo   PRUEBA RAPIDA - SISTEMA IOT BOMBEO
echo ========================================================
echo.

cd /d "c:\inetpub\promotorapalmera\project_estacion_bombeo"

echo [1/2] Ejecutando pruebas de base de datos...
php pruebas_finales.php

echo.
echo.
echo ========================================================
echo   PRUEBAS COMPLETADAS
echo ========================================================
echo.
echo Para iniciar el servidor Flask, necesitas Python instalado.
echo.
echo SOLUCIONES:
echo.
echo 1. Instalar Python desde: https://www.python.org/downloads/
echo    - Descarga Python 3.12
echo    - Durante instalacion, marca "Add Python to PATH"
echo.
echo 2. Crear virtual environment:
echo    python -m venv venv_nuevo
echo.
echo 3. Activar venv e instalar dependencias:
echo    venv_nuevo\Scripts\activate
echo    pip install flask pymysql sqlalchemy flask-cors
echo.
echo 4. Iniciar Flask:
echo    python app.py
echo.

pause
