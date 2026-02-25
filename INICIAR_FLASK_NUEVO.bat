@echo off
echo ========================================================
echo   INICIANDO SERVIDOR FLASK - SISTEMA IOT BOMBEO
echo ========================================================
echo.

cd /d "%~dp0"

echo Activando virtual environment...
call venv_nuevo\Scripts\activate.bat

echo Iniciando Flask...
echo Dashboard disponible en: http://localhost:5000
echo Presiona Ctrl+C para detener el servidor
echo.

python app.py

pause
