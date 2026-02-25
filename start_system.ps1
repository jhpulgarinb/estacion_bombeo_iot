# Script de inicio rápido - Sistema IoT Estación de Bombeo
# Promotora Palmera de Antioquia S.A.S.
# Fecha: 20 de febrero de 2026

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   SISTEMA IoT - ESTACIÓN DE BOMBEO" -ForegroundColor Yellow
Write-Host "   Promotora Palmera de Antioquia S.A.S." -ForegroundColor Gray
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Navegar al directorio del proyecto
$projectPath = "c:\inetpub\promotorapalmera\project_estacion_bombeo"
Set-Location $projectPath

Write-Host "📂 Directorio de trabajo: $projectPath" -ForegroundColor Green
Write-Host ""

# Verificar que existe Python
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✅ Python encontrado: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Python no está instalado o no está en PATH" -ForegroundColor Red
    Write-Host "   Instale Python desde https://www.python.org" -ForegroundColor Yellow
    pause
    exit
}

Write-Host ""

# Verificar si existe la base de datos
$dbFile = Join-Path $projectPath "monitoring.db"
if (-not (Test-Path $dbFile)) {
    Write-Host "⚠️  Base de datos no encontrada. Inicializando..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        python init_database.py
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ Base de datos inicializada correctamente" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "❌ ERROR al inicializar la base de datos" -ForegroundColor Red
            Write-Host "   Revise los mensajes de error arriba" -ForegroundColor Yellow
            pause
            exit
        }
    } catch {
        Write-Host "❌ ERROR: No se pudo ejecutar init_database.py" -ForegroundColor Red
        Write-Host "   $_" -ForegroundColor Yellow
        pause
        exit
    }
} else {
    Write-Host "✅ Base de datos encontrada: monitoring.db" -ForegroundColor Green
}

# Verificar dependencias Python
Write-Host ""
Write-Host "📦 Verificando dependencias Python..." -ForegroundColor Cyan

$requiredPackages = @("flask", "flask-cors", "flask-sqlalchemy", "requests")
$missingPackages = @()

foreach ($package in $requiredPackages) {
    $installed = python -c "import $($package.Replace('-', '_'))" 2>&1
    if ($LASTEXITCODE -ne 0) {
        $missingPackages += $package
    }
}

if ($missingPackages.Count -gt 0) {
    Write-Host "⚠️  Faltan paquetes: $($missingPackages -join ', ')" -ForegroundColor Yellow
    Write-Host "   Instalando automáticamente..." -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($package in $missingPackages) {
        Write-Host "   Installing $package..." -ForegroundColor Gray
        pip install $package --quiet
    }
    
    Write-Host ""
    Write-Host "✅ Dependencias instaladas" -ForegroundColor Green
} else {
    Write-Host "✅ Todas las dependencias están instaladas" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   OPCIONES DE INICIO" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Iniciar SOLO el SERVIDOR Flask (API + Dashboard)" -ForegroundColor White
Write-Host "2. Iniciar SOLO el SIMULADOR de sensores" -ForegroundColor White
Write-Host "3. Iniciar AMBOS (Servidor + Simulador)" -ForegroundColor Green
Write-Host "4. Generar DATOS HISTÓRICOS (24 horas)" -ForegroundColor Cyan
Write-Host "5. Salir" -ForegroundColor Gray
Write-Host ""

$opcion = Read-Host "Seleccione una opción (1-5)"

switch ($opcion) {
    "1" {
        Write-Host ""
        Write-Host "🚀 Iniciando servidor Flask..." -ForegroundColor Green
        Write-Host "📡 URL: http://localhost:5000" -ForegroundColor Cyan
        Write-Host "💡 Presione Ctrl+C para detener" -ForegroundColor Yellow
        Write-Host ""
        python app.py
    }
    
    "2" {
        Write-Host ""
        Write-Host "🌦️  Iniciando simulador de sensores..." -ForegroundColor Green
        Write-Host "📊 Generando datos meteorológicos y telemetría cada 10s" -ForegroundColor Cyan
        Write-Host "💡 Presione Ctrl+C para detener" -ForegroundColor Yellow
        Write-Host ""
        python simulator_extended.py
    }
    
    "3" {
        Write-Host ""
        Write-Host "🚀 Iniciando SISTEMA COMPLETO..." -ForegroundColor Green
        Write-Host ""
        Write-Host "📡 Servidor Flask: http://localhost:5000" -ForegroundColor Cyan
        Write-Host "🌦️  Simulador: Enviando datos cada 10s" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "💡 Presione Ctrl+C para detener AMBOS procesos" -ForegroundColor Yellow
        Write-Host ""
        
        # Iniciar Flask en background
        $flaskJob = Start-Job -ScriptBlock {
            Set-Location "c:\inetpub\promotorapalmera\project_estacion_bombeo"
            python app.py
        }
        
        Write-Host "✅ Servidor Flask iniciado (Job ID: $($flaskJob.Id))" -ForegroundColor Green
        Start-Sleep -Seconds 3 # Esperar que Flask inicie
        
        Write-Host "✅ Iniciando simulador..." -ForegroundColor Green
        Write-Host ""
        
        try {
            # Ejecutar simulador en foreground
            python simulator_extended.py
        } finally {
            # Cuando se detenga el simulador (Ctrl+C), detener Flask también
            Write-Host ""
            Write-Host "🛑 Deteniendo servidor Flask..." -ForegroundColor Yellow
            Stop-Job $flaskJob
            Remove-Job $flaskJob
            Write-Host "✅ Sistema detenido completamente" -ForegroundColor Green
        }
    }
    
    "4" {
        Write-Host ""
        Write-Host "📊 Generando datos históricos..." -ForegroundColor Cyan
        Write-Host ""
        
        $horas = Read-Host "¿Cuántas horas de datos desea generar? (por defecto: 24)"
        if ([string]::IsNullOrWhiteSpace($horas)) {
            $horas = 24
        }
        
        Write-Host ""
        Write-Host "⏳ Generando $horas horas de datos (puede tomar unos minutos)..." -ForegroundColor Yellow
        Write-Host "💡 Asegúrese de que el servidor Flask esté corriendo en otra ventana" -ForegroundColor Cyan
        Write-Host ""
        
        python simulator_extended.py --historical $horas
        
        Write-Host ""
        Write-Host "✅ Generación completada" -ForegroundColor Green
        pause
    }
    
    "5" {
        Write-Host "👋 Saliendo..." -ForegroundColor Gray
        exit
    }
    
    default {
        Write-Host ""
        Write-Host "❌ Opción inválida" -ForegroundColor Red
        pause
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   FIN DE EJECUCIÓN" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
