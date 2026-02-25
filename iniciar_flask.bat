@echo off
REM Script para iniciar Flask - Alternativa simple
REM No requiere venv si Python está en el PATH

echo =================================================
echo   Iniciando Flask - Sistema IoT Bombeo
echo =================================================
echo.

REM Verificar pymysql
python -m pip list | findstr pymysql > nul
if errorlevel 1 (
    echo Instalando pymysql...
    python -m pip install pymysql -q
)

echo.
echo Iniciando servidor Flask...
echo URL: http://localhost:5000
echo.
echo (Presione Ctrl+C para detener)
echo.

python app.py

pause
