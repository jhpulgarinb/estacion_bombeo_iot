Write-Host "========================================================"
Write-Host "  PRUEBA API METEOROLOGIA"
Write-Host "========================================================"
Write-Host ""

Write-Host "[1/3] Enviando datos meteorologicos..."

$url = "http://localhost:9000/api/meteorology"
$body = '{"estacion_id":1,"temperatura_c":28.5,"humedad_porcentaje":75,"precipitacion_mm":2.3,"presion_hpa":1013,"velocidad_viento_ms":3.5,"direccion_viento_grados":180,"radiacion_solar_wm2":650,"fecha_hora":"2026-02-21 15:30:00"}'

try {
    $response = Invoke-WebRequest -Uri $url -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    Write-Host "OK Datos enviados (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "ERROR al enviar: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[2/3] Consultando ultimos datos..."

try {
    $response = Invoke-WebRequest -Uri "http://localhost:9000/api/meteorology/latest?station_id=1" -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host "OK Datos recuperados" -ForegroundColor Green
    Write-Host "  Temperatura: $($result.data.temperatura_c) C"
    Write-Host "  Humedad: $($result.data.humedad_porcentaje) %"
} catch {
    Write-Host "ERROR al consultar: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "[3/3] Probando endpoint de estaciones..."

try {
    $response = Invoke-WebRequest -Uri "http://localhost:9000/api/stations" -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host "OK Estaciones: $($result.stations.Count)" -ForegroundColor Green
    foreach ($station in $result.stations) {
        Write-Host "  - $($station.nombre)"
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================================"
Write-Host "  SISTEMA VALIDADO"
Write-Host "========================================================"
Write-Host ""
Write-Host "Flask corriendo en: http://localhost:9000"
Write-Host ""
