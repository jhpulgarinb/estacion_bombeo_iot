# INSTALADOR DE PYTHON PARA EL SISTEMA IOT BOMBEO
# Este script descarga e instala Python 3.12 si no está disponible

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  INSTALADOR DE PYTHON - SISTEMA IOT BOMBEO" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar si Python ya está instalado
Write-Host "TEST 1: Verificando Python existente..." -ForegroundColor Yellow

$pythonPaths = @(
    "C:\Python312\python.exe",
    "C:\Python311\python.exe",
    "C:\Python310\python.exe",
    "C:\Program Files\Python312\python.exe",
    "C:\Program Files\Python311\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe"
)

$pythonFound = $null
foreach ($path in $pythonPaths) {
    if (Test-Path $path) {
        $pythonFound = $path
        Write-Host "✅ Python encontrado: $path" -ForegroundColor Green
        break
    }
}

if (-not $pythonFound) {
    Write-Host "❌ No se encontró Python instalado" -ForegroundColor Red
    Write-Host ""
    Write-Host "Descargando Python 3.12.0..." -ForegroundColor Yellow
    
    $pythonUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe"
    $installerPath = "$env:TEMP\python-3.12.0-installer.exe"
    
    try {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $installerPath -UseBasicParsing
        Write-Host "✅ Descarga completada" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "Instalando Python 3.12.0..." -ForegroundColor Yellow
        Write-Host "IMPORTANTE: Marca 'Add Python to PATH' durante la instalación" -ForegroundColor Cyan
        
        Start-Process -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait
        
        Write-Host "✅ Python instalado exitosamente" -ForegroundColor Green
        
        # Actualizar la ruta de Python
        $pythonFound = "C:\Python312\python.exe"
        
        # Refrescar PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
    } catch {
        Write-Host "❌ Error al descargar/instalar Python: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "SOLUCION MANUAL:" -ForegroundColor Yellow
        Write-Host "1. Ve a: https://www.python.org/downloads/" -ForegroundColor White
        Write-Host "2. Descarga Python 3.12" -ForegroundColor White
        Write-Host "3. Durante instalacion, marca Add Python to PATH" -ForegroundColor White
        Write-Host "4. Ejecuta este script nuevamente" -ForegroundColor White
        exit 1
    }
}

# 2. Verificar versión de Python
Write-Host ""
Write-Host "TEST 2: Verificando versión de Python..." -ForegroundColor Yellow
& $pythonFound --version

# 3. Crear virtual environment
Write-Host ""
Write-Host "TEST 3: Creando virtual environment..." -ForegroundColor Yellow

$venvPath = "c:\inetpub\promotorapalmera\project_estacion_bombeo\venv_nuevo"

if (Test-Path $venvPath) {
    Write-Host "⚠️  Virtual environment ya existe, eliminándolo..." -ForegroundColor Yellow
    Remove-Item -Path $venvPath -Recurse -Force
}

& $pythonFound -m venv $venvPath

if (Test-Path "$venvPath\Scripts\python.exe") {
    Write-Host "✅ Virtual environment creado exitosamente" -ForegroundColor Green
} else {
    Write-Host "❌ Error al crear virtual environment" -ForegroundColor Red
    exit 1
}

# 4. Instalar dependencias
Write-Host ""
Write-Host "TEST 4: Instalando dependencias..." -ForegroundColor Yellow

$requirementsPath = "c:\inetpub\promotorapalmera\project_estacion_bombeo\requirements.txt"

if (Test-Path $requirementsPath) {
    & "$venvPath\Scripts\python.exe" -m pip install --upgrade pip
    & "$venvPath\Scripts\pip.exe" install -r $requirementsPath
    Write-Host "✅ Dependencias instaladas" -ForegroundColor Green
} else {
    Write-Host "⚠️  No se encontró requirements.txt" -ForegroundColor Yellow
    Write-Host "Instalando dependencias básicas..." -ForegroundColor Yellow
    
    & "$venvPath\Scripts\python.exe" -m pip install --upgrade pip
    & "$venvPath\Scripts\pip.exe" install flask
    & "$venvPath\Scripts\pip.exe" install pymysql
    & "$venvPath\Scripts\pip.exe" install sqlalchemy
    & "$venvPath\Scripts\pip.exe" install flask-cors
    
    Write-Host "✅ Dependencias básicas instaladas" -ForegroundColor Green
}

# 5. Crear script de inicio
Write-Host ""
Write-Host "TEST 5: Creando script de inicio..." -ForegroundColor Yellow

$iniciarScriptContent = @'
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
'@

$iniciarScriptContent | Out-File -FilePath "c:\inetpub\promotorapalmera\project_estacion_bombeo\INICIAR_FLASK_NUEVO.bat" -Encoding ASCII

Write-Host "✅ Script de inicio creado: INICIAR_FLASK_NUEVO.bat" -ForegroundColor Green

# 6. Resumen
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  ✅ INSTALACIÓN COMPLETADA EXITOSAMENTE" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 CONFIGURACIÓN:" -ForegroundColor Yellow
Write-Host "   Python: $pythonFound" -ForegroundColor White
Write-Host "   Virtual Env: $venvPath" -ForegroundColor White
Write-Host ""

Write-Host "🚀 PARA INICIAR EL SISTEMA:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Opción 1 (Doble clic):" -ForegroundColor Cyan
Write-Host "   INICIAR_FLASK_NUEVO.bat" -ForegroundColor White
Write-Host ""
Write-Host "   Opción 2 (PowerShell):" -ForegroundColor Cyan
Write-Host "   cd c:\inetpub\promotorapalmera\project_estacion_bombeo" -ForegroundColor White
Write-Host "   .\venv_nuevo\Scripts\Activate.ps1" -ForegroundColor White
Write-Host "   python app.py" -ForegroundColor White
Write-Host ""

Write-Host "🌐 URLS DEL SISTEMA:" -ForegroundColor Yellow
Write-Host "   Dashboard: http://localhost:5000" -ForegroundColor White
Write-Host "   API: http://localhost:5000/api/" -ForegroundColor White
Write-Host ""

Write-Host "========================================================" -ForegroundColor Cyan
