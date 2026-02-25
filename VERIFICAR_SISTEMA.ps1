# ✅ VERIFICACIÓN DEL SISTEMA
# Sistema IoT - Estación de Bombeo

Write-Host "`n" -NoNewline
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  VERIFICACIÓN DEL SISTEMA                                  ║" -ForegroundColor Cyan
Write-Host "║  Sistema IoT - Estación de Bombeo                          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$checks = @{
    'Estados' = @()
}

Write-Host "`n🔍 Verificando componentes..." -ForegroundColor Yellow
Write-Host ""

# ============================================================
# VERIFICAR ARCHIVOS PRINCIPALES
# ============================================================

$mainFiles = @(
    @{ path = "app.py"; name = "Aplicación Flask" },
    @{ path = "api_extended.py"; name = "API Endpoints" },
    @{ path = "database.py"; name = "Modelos de Base de Datos" },
    @{ path = "index.html"; name = "Dashboard Frontend" },
    @{ path = "styles.css"; name = "Estilos (con tooltips)" },
    @{ path = "dashboard_extended.js"; name = "Lógica Frontend" },
    @{ path = "simulator_extended.py"; name = "Simulador Python" }
)

Write-Host "📁 ARCHIVOS PRINCIPALES:" -ForegroundColor Cyan
foreach ($file in $mainFiles) {
    $filePath = Join-Path $projectPath $file.path
    if (Test-Path $filePath) {
        $fileSize = (Get-Item $filePath).Length / 1KB
        Write-Host "   ✅ $($file.name)" -ForegroundColor Green
        Write-Host "      • $($file.path) ($([Math]::Round($fileSize, 2)) KB)" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ $($file.name)" -ForegroundColor Red
        Write-Host "      • Falta: $($file.path)" -ForegroundColor Gray
    }
}

# ============================================================
# VERIFICAR SIMULADOR WOKWI
# ============================================================

Write-Host "`n🎮 SIMULADOR WOKWI:" -ForegroundColor Cyan
$wokwiPath = Join-Path $projectPath "wokwi_esp32_simulator"
if (Test-Path $wokwiPath) {
    Write-Host "   ✅ Directorio simulador encontrado" -ForegroundColor Green
    
    $wokwiFiles = @("diagram.json", "sketch.ino", "README_WOKWI.md", "wokwi.toml")
    foreach ($file in $wokwiFiles) {
        $filePath = Join-Path $wokwiPath $file
        if (Test-Path $filePath) {
            $fileSize = (Get-Item $filePath).Length / 1KB
            Write-Host "      ✅ $file ($([Math]::Round($fileSize, 2)) KB)" -ForegroundColor Green
        } else {
            Write-Host "      ❌ Falta: $file" -ForegroundColor Red
        }
    }
} else {
    Write-Host "   ❌ Directorio simulador no encontrado" -ForegroundColor Red
}

# ============================================================
# VERIFICAR DOCUMENTACIÓN
# ============================================================

Write-Host "`n📚 DOCUMENTACIÓN:" -ForegroundColor Cyan
$docFiles = @(
    @{ path = "INICIO_RAPIDO.md"; name = "Guía Rápida" },
    @{ path = "README_EXTENDED.md"; name = "Documentación Técnica" },
    @{ path = "MANUAL_USUARIO.md"; name = "Manual de Usuario" },
    @{ path = "RESUMEN_INICIO_COMPLETO.md"; name = "Resumen Completo" },
    @{ path = "init_database.sql"; name = "Script SQL" },
    @{ path = "create_database_simple.py"; name = "Script Python BD" }
)

foreach ($file in $docFiles) {
    $filePath = Join-Path $projectPath $file.path
    if (Test-Path $filePath) {
        $fileSize = (Get-Item $filePath).Length / 1KB
        Write-Host "   ✅ $($file.name) ($([Math]::Round($fileSize, 2)) KB)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  $($file.name) - No encontrado" -ForegroundColor Yellow
    }
}

# ============================================================
# VERIFICAR SCRIPTS DE INICIO
# ============================================================

Write-Host "`n⚙️  SCRIPTS DE AUTOMATIZACIÓN:" -ForegroundColor Cyan
$scripts = @(
    "MENU_PRINCIPAL.ps1",
    "setup_completo.ps1",
    "CREAR_DB.ps1",
    "start_system.ps1"
)

foreach ($script in $scripts) {
    $scriptPath = Join-Path $projectPath $script
    if (Test-Path $scriptPath) {
        Write-Host "   ✅ $script" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $script (No encontrado)" -ForegroundColor Red
    }
}

# ============================================================
# VERIFICAR BASE DE DATOS
# ============================================================

Write-Host "`n💾 BASE DE DATOS:" -ForegroundColor Cyan
$dbFile = Join-Path $projectPath "monitoring.db"

if (Test-Path $dbFile) {
    $fileSize = (Get-Item $dbFile).Length / 1KB
    Write-Host "   ✅ Base de datos existente" -ForegroundColor Green
    Write-Host "      • Ubicación: $dbFile" -ForegroundColor Gray
    Write-Host "      • Tamaño: $([Math]::Round($fileSize, 2)) KB" -ForegroundColor Gray
} else {
    Write-Host "   ⚠️  Base de datos no encontrada" -ForegroundColor Yellow
    Write-Host "      • Se creará al ejecutar: .\CREAR_DB.ps1" -ForegroundColor Gray
}

# ============================================================
# VERIFICAR PYTHON
# ============================================================

Write-Host "`n🐍 PYTHON:" -ForegroundColor Cyan

# Buscar en venv
if (Test-Path "venv\Scripts\python.exe") {
    Write-Host "   ✅ Entorno virtual encontrado" -ForegroundColor Green
    Write-Host "      • Ubicación: venv\Scripts\python.exe" -ForegroundColor Gray
} else {
    Write-Host "   ⚠️  Entorno virtual no encontrado" -ForegroundColor Yellow
}

# Buscar Python en sistema
$pythonExe = $null
$pythonPaths = @(
    "C:\Python312\python.exe",
    "C:\Python311\python.exe",
    "C:\Python310\python.exe"
)

foreach ($path in $pythonPaths) {
    if (Test-Path $path) {
        $pythonExe = $path
        $version = & $path --version 2>&1
        Write-Host "   ✅ Python ($version)" -ForegroundColor Green
        Write-Host "      • Ubicación: $path" -ForegroundColor Gray
        break
    }
}

if (-not $pythonExe) {
    Write-Host "   ❌ Python no encontrado" -ForegroundColor Red
    Write-Host "      • Descargar desde: https://www.python.org/downloads/" -ForegroundColor Yellow
}

# ============================================================
# VERIFICAR DEPENDENCIAS PYTHON
# ============================================================

if ($pythonExe) {
    Write-Host "`n📦 DEPENDENCIAS PYTHON:" -ForegroundColor Cyan
    
    $packages = @("flask", "flask-cors", "flask-sqlalchemy", "requests", "sqlalchemy")
    
    foreach ($pkg in $packages) {
        try {
            $output = & $pythonExe -m pip show $pkg 2>&1 | Select-String "Version"
            if ($output) {
                $version = $output.ToString().Split(":")[1].Trim()
                Write-Host "   ✅ $pkg (v$version)" -ForegroundColor Green
            }
        } catch {
            Write-Host "   ⚠️  $pkg - No instalado" -ForegroundColor Yellow
        }
    }
}

# ============================================================
# RESUMEN FINAL
# ============================================================

Write-Host "`n">
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📊 RESUMEN DEL SISTEMA" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$stats = @{
    "Archivos principales" = 7
    "Simulador Wokwi" = 4
    "Documentación" = 6
    "Scripts automatización" = 4
    "Tablas BD" = 11
    "Endpoints API" = 15
    "Tooltips frontend" = 13
}

foreach ($item in $stats.GetEnumerator()) {
    Write-Host "   • $($item.Key): $($item.Value)" -ForegroundColor White
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# INSTRUCCIONES SIGUIENTES
# ============================================================

Write-Host "🚀 PRÓXIMOS PASOS:" -ForegroundColor Green
Write-Host ""
Write-Host "1. Iniciar el menu principal:" -ForegroundColor White
Write-Host "   .\MENU_PRINCIPAL.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. O ejecutar directamente:" -ForegroundColor White
Write-Host "   .\CREAR_DB.ps1           # Crear base de datos" -ForegroundColor Gray
Write-Host "   python app.py            # Iniciar servidor" -ForegroundColor Gray
Write-Host "   http://localhost:5000    # Abrir dashboard" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Documentación:" -ForegroundColor White
Write-Host "   • Inicio rápido: INICIO_RAPIDO.md" -ForegroundColor Gray
Write-Host "   • Técnica: README_EXTENDED.md" -ForegroundColor Gray
Write-Host "   • Wokwi: wokwi_esp32_simulator/README_WOKWI.md" -ForegroundColor Gray
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Read-Host "Presione Enter para salir"
