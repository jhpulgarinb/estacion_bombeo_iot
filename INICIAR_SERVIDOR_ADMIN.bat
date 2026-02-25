@echo off
REM Script para ejecutar servidor en puerto 8081 con privilegios de administrador
REM Elevate Command Prompt to Administrator level
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Pidiendo permisos de administrador...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %*", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /b

:gotAdmin
    cd /d "c:\inetpub\promotorapalmera\project_estacion_bombeo"
    python servidor_simple.py
    pause

