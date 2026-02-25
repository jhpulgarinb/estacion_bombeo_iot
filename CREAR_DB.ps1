# Inicialización Rápida de Base de Datos
# Sistema IoT - Estación de Bombeo

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🗄️  Inicialización de Base de Datos" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Buscar Python
$pythonExe = $null
$pythonPaths = @(
    "C:\Python312\python.exe",
    "C:\Python311\python.exe",
    "C:\Python310\python.exe",
    "C:\Python39\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
    ".\venv\Scripts\python.exe"
)

foreach ($path in $pythonPaths) {
    if (Test-Path $path) {
        $pythonExe = $path
        Write-Host "✅ Python encontrado: $path" -ForegroundColor Green
        break
    }
}

if (-not $pythonExe) {
    Write-Host "X Python no encontrado" -ForegroundColor Red
    Write-Host "`nPor favor instale Python desde: https://www.python.org/downloads/" -ForegroundColor Yellow
    Read-Host "`nPresione Enter para salir"
    exit 1
}

# Ejecutar script de inicialización
Write-Host ""
& $pythonExe .\create_database_simple.py

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nTodo listo!" -ForegroundColor Green
} else {
    Write-Host "`nHubo un error" -ForegroundColor Red
}

Write-Host ""
Read-Host "Presione Enter para salir"
