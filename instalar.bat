@echo off
echo =================================================================
echo    INSTALACION MYSQL - SISTEMA IOT BOMBEO
echo =================================================================
echo.

REM Buscar MySQL
set MYSQL_EXE=
if exist "C:\xampp\mysql\bin\mysql.exe" set MYSQL_EXE=C:\xampp\mysql\bin\mysql.exe
if exist "C:\wamp64\bin\mysql\mysql8.0.31\bin\mysql.exe" set MYSQL_EXE=C:\wamp64\bin\mysql\mysql8.0.31\bin\mysql.exe

if "%MYSQL_EXE%"=="" (
    echo ERROR: No se encontro MySQL
    echo.
    echo Busque mysql.exe manualmente y ejecute:
    echo mysql -u root promotorapalmera_db ^< init_database_mysql_es.sql
    echo.
    pause
    exit /b 1
)

echo MySQL encontrado: %MYSQL_EXE%
echo.
echo Ejecutando SQL...
echo.

"%MYSQL_EXE%" -u root promotorapalmera_db < init_database_mysql_es.sql

if errorlevel 1 (
    echo.
    echo ERROR durante la instalacion
    pause
    exit /b 1
)

echo.
echo =================================================================
echo    INSTALACION COMPLETADA
echo =================================================================
echo.
echo Verificando instalacion...
echo.

php verificar_mysql.php

echo.
pause
