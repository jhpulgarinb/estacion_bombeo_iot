@echo off
REM Script para iniciar el servidor HTTPS/HTTP
REM Promotora Palmera - Sistema de Nómina

cls
echo ========================================
echo   INICIANDO SERVIDOR HTTPS/HTTP
echo ========================================
echo.
echo Puerto 8082 = HTTPS (para móviles)
echo Puerto 8081 = HTTP  (alternativo)
echo.
echo Matando procesos Python anteriores...
taskkill /F /IM python.exe 2>nul

echo Esperando 2 segundos...
timeout /t 2 /nobreak

echo.
echo Iniciando servidor...
cd /d "c:\inetpub\promotorapalmera\project_estacion_bombeo"
python servidor_dual_http_https.py

pause
