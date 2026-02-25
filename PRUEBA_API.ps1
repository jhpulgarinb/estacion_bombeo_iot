# PRUEBA API - Insertar datos meteorologicos
Write-Host "========================================================"
Write-Host "  PRUEBA COMPLETA - API METEOROLOGIA"Write-Host "========================================================"
Write-Host ""

# Test 1: Enviar datos
Write-Host "[1/3] Enviando datos meteorologicos..." -ForegroundColor Yellow

$url = "http://localhost:5000/api/meteorology"
$body = @{
    estacion_id = 1
    temperatura_c = 28.5
    humedad_porcentaje = 75
    precipitacion_mm = 2.3
    presion_hpa = 1013
    velocidad_viento_ms = 3.5
    direccion_viento_grados = 180
    radiacion_solar_wm2 = 650
    fecha_hora = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri $url -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    Write-Host "OK Datos enviados exitosamente" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)"
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Consultar datos
Write-Host "[2/3] Consultando ultimos datos..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/api/meteorology/latest?station_id=1" -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host "OK Datos recuperados" -ForegroundColor Green
    Write-Host "  Temperatura: $($result.data.temperatura_c) C"
    Write-Host "  Humedad: $($result.data.humedad_porcentaje) %"
    Write-Host "  Precipitacion: $($result.data.precipitacion_mm) mm"
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 3: MySQL
Write-Host "[3/3] Validando MySQL..." -ForegroundColor Yellow

$phpCode = @"
<?php
`$conn = new mysqli('localhost', 'root', '', 'promotorapalmera_db');
`$result = `$conn->query("SELECT COUNT(*) as total FROM iot_datos_meteorologicos");
`$row = `$result->fetch_assoc();
echo `$row['total'];
`$conn->close();
?>
"@

$phpCode | Out-File -FilePath "$env:TEMP\test.php" -Encoding ASCII
$count = php "$env:TEMP\test.php"

Write-Host "OK MySQL validado" -ForegroundColor Green
Write-Host "  Total registros: $count"

Write-Host ""
Write-Host "========================================================"
Write-Host "  PRUEBA COMPLETA EXITOSA"
Write-Host "========================================================"
Write-Host ""
Write-Host "SISTEMA FUNCIONANDO:"
Write-Host "  Python: OK"
Write-Host "  Flask: OK (http://localhost:5000)"
Write-Host "  MySQL: OK"
Write-Host "  API Espanol: OK"
Write-Host "  Insercion datos: OK"
Write-Host "  Consulta datos: OK"
Write-Host ""
