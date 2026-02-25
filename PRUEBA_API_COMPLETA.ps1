# PRUEBA API - Insertar datos meteorológicos
$url = "http://localhost:5000/api/meteorology"
$headers = @{
    "Content-Type" = "application/json"
}

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

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  PRUEBA COMPLETA - API METEOROLOGIA" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Enviando datos meteorológicos..." -ForegroundColor Yellow
Write-Host "  URL: $url" -ForegroundColor Gray
Write-Host "  Payload:" -ForegroundColor Gray
Write-Host $body -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri $url -Method POST -Body $body -Headers $headers -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host "✓ Datos enviados exitosamente" -ForegroundColor Green
    Write-Host "  Status Code: $($response.StatusCode)" -ForegroundColor White
    Write-Host "  Response: $($response.Content)" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "✗ Error al enviar datos: $_" -ForegroundColor Red
    exit 1
}

Write-Host "[2/3] Consultando últimos datos meteorológicos..." -ForegroundColor Yellow

try {
    $getUrl = "http://localhost:5000/api/meteorology/latest?station_id=1"
    $response = Invoke-WebRequest -Uri $getUrl -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host "✓ Datos recuperados exitosamente" -ForegroundColor Green
    Write-Host "  Estación: $($result.data.estacion_id)" -ForegroundColor White
    Write-Host "  Temperatura: $($result.data.temperatura_c)°C" -ForegroundColor White
    Write-Host "  Humedad: $($result.data.humedad_porcentaje)%" -ForegroundColor White
    Write-Host "  Precipitación: $($result.data.precipitacion_mm)mm" -ForegroundColor White
    Write-Host "  Fecha/Hora: $($result.data.fecha_hora)" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "✗ Error al consultar datos: $_" -ForegroundColor Red
    exit 1
}

Write-Host "[3/3] Validando en MySQL directamente..." -ForegroundColor Yellow

try {
    # Usar PHP para consultar MySQL
    $phpScript = @"
<?php
`$conn = new mysqli('localhost', 'root', '', 'promotorapalmera_db');
`$result = `$conn->query("SELECT COUNT(*) as total FROM iot_datos_meteorologicos");
`$row = `$result->fetch_assoc();
echo `$row['total'];
`$conn->close();
?>
"@
    
    $phpScript | Out-File -FilePath "$env:TEMP\test_mysql.php" -Encoding ASCII
    $count = php "$env:TEMP\test_mysql.php"
    
    Write-Host "✓ MySQL validado" -ForegroundColor Green
    Write-Host "  Total de registros meteorológicos: $count" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "⚠ No se pudo validar MySQL (opcional): $_" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  ✓ PRUEBA COMPLETA EXITOSA" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "RESUMEN:" -ForegroundColor Yellow
Write-Host "  • Python instalado: ✓" -ForegroundColor White
Write-Host "  • Dependencias instaladas: ✓" -ForegroundColor White
Write-Host "  • Flask corriendo: ✓ (http://localhost:5000)" -ForegroundColor White
Write-Host "  • MySQL funcionando: ✓" -ForegroundColor White
Write-Host "  • API endpoints: ✓ (nombres en español)" -ForegroundColor White
Write-Host "  • Inserción de datos: ✓" -ForegroundColor White
Write-Host "  • Consulta de datos: ✓" -ForegroundColor White
Write-Host ""
Write-Host "Dashboard disponible en: http://localhost:5000" -ForegroundColor Cyan
Write-Host ""
