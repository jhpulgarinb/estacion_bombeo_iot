@echo off
REM =====================================================
REM   🌊 Sistema de Monitoreo de Estaciones de Bombeo
REM   ⚡ Inicio con Doble Clic
REM =====================================================

title 🌊 Sistema de Monitoreo - Estaciones de Bombeo

echo.
echo ╔══════════════════════════════════════════════════════════════════╗
echo ║                                                                  ║
echo ║        🌊 SISTEMA DE MONITOREO DE ESTACIONES DE BOMBEO 🌊       ║
echo ║                                                                  ║
echo ║                     ⚡ INICIO AUTOMÁTICO ⚡                     ║
echo ║                                                                  ║
echo ╚══════════════════════════════════════════════════════════════════╝
echo.

echo 🔄 Iniciando sistema...
echo.

REM Verificar si PowerShell está disponible
where pwsh >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ PowerShell Core encontrado
    pwsh -ExecutionPolicy Bypass -File "INICIAR.ps1"
) else (
    where powershell >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo ✅ PowerShell encontrado
        powershell -ExecutionPolicy Bypass -File "INICIAR.ps1"
    ) else (
        echo ❌ PowerShell no encontrado
        echo.
        echo 🔧 SOLUCIÓN:
        echo    PowerShell es necesario para ejecutar este sistema
        echo    Normalmente viene instalado en Windows 10/11
        echo.
        echo    Si no tienes PowerShell:
        echo    1. Ve a Microsoft Store
        echo    2. Busca "PowerShell"
        echo    3. Instala PowerShell
        echo.
        pause
        exit /b 1
    )
)

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ⚠️  El sistema se cerró con errores
    echo    Revisa los mensajes de arriba para más información
    echo.
    echo 💡 CONSEJOS:
    echo    - Ejecuta como Administrador si hay problemas de permisos
    echo    - Verifica que Python esté instalado
    echo    - Asegúrate de estar en el directorio correcto del proyecto
    echo.
)

echo.
echo ✅ Proceso completado
echo Presiona cualquier tecla para cerrar esta ventana...
pause >nul
