@echo off
REM Script de watchdog para mantener servidor HTTPS corriendo

setlocal enabledelayedexpansion

cd /d "c:\inetpub\promotorapalmera\project_estacion_bombeo"

:start
echo.
echo ========================================
echo  WATCHDOG SERVIDOR PUERTO 8082
echo ========================================
echo  Iniciando servidor robusto...
echo.

REM Iniciar servidor python
python servidor_8082_robusto.py

REM Si llegamos aqui, el servidor se detuvo
echo.
echo [WARN] Servidor se detuvo inesperadamente
echo [INFO] Reiniciando en 5 segundos...
echo.

timeout /t 5 /nobreak

goto start
