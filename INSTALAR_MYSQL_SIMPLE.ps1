# INSTALADOR MYSQL - SISTEMA IOT ESTACION DE BOMBEO
# Version en Español

Clear-Host
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  INSTALACION BASE DE DATOS MySQL - VERSION ESPANOL" -ForegroundColor Green
Write-Host "  Sistema IoT Estacion de Bombeo" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar archivos necesarios
$archivoSQL = ".\init_database_mysql_es.sql"

if (-not (Test-Path $archivoSQL)) {
    Write-Host "ERROR: No se encuentra el archivo $archivoSQL" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "Archivo SQL encontrado: $archivoSQL" -ForegroundColor Green
Write-Host ""

# Mostrar opciones de instalacion
Write-Host "OPCIONES DE INSTALACION:" -ForegroundColor Yellow
Write-Host ""
Write-Host "[1] Instalacion WEB (Recomendado)" -ForegroundColor Cyan
Write-Host ""
Write-Host "[2] Ver instrucciones manuales" -ForegroundColor Cyan
Write-Host ""
Write-Host "[3] Cancelar" -ForegroundColor Red
Write-Host ""

$opcion = Read-Host "Selecciona una opcion (1-3)"

if ($opcion -eq "1") {
    Write-Host ""
    Write-Host "Abriendo instalador web..." -ForegroundColor Green
    Write-Host ""
    
    Start-Process "http://localhost/project_estacion_bombeo/instalar_mysql_es.php"
    
    Write-Host "Navegador abierto en:" -ForegroundColor Green
    Write-Host "http://localhost/project_estacion_bombeo/instalar_mysql_es.php" -ForegroundColor Cyan
    Write-Host ""
}
elseif ($opcion -eq "2") {
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "  INSTRUCCIONES MANUALES DE INSTALACION" -ForegroundColor Yellow
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "OPCION A - phpMyAdmin:" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Accede a phpMyAdmin (http://localhost/phpmyadmin)"
    Write-Host "2. Selecciona la base de datos 'promotorapalmera_db'"
    Write-Host "3. Ve a la pestana 'SQL'"
    Write-Host "4. Copia el contenido del archivo: $archivoSQL"
    Write-Host "5. Pegalo en el area de texto"
    Write-Host "6. Haz clic en 'Continuar'"
    Write-Host ""
    
    Write-Host "OPCION B - MySQL Workbench:" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Abre MySQL Workbench"
    Write-Host "2. Conecta a tu servidor MySQL"
    Write-Host "3. Abre el archivo: $archivoSQL"
    Write-Host "4. Ejecuta el script (icono de rayo o Ctrl+Shift+Enter)"
    Write-Host ""
    
    Write-Host "OPCION C - Linea de comandos MySQL:" -ForegroundColor Green
    Write-Host ""
    Write-Host "  mysql -u root -p promotorapalmera_db" -ForegroundColor Cyan
    Write-Host "  (luego copiar y pegar el contenido del archivo SQL)"
    Write-Host ""
    
    Write-Host "OPCION D - Navegador web (PHP):" -ForegroundColor Green
    Write-Host ""
    Write-Host "  http://localhost/project_estacion_bombeo/instalar_mysql_es.php" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "Instalacion cancelada" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 0
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  RESUMEN DE TABLAS A CREAR" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "11 TABLAS (prefijo: iot_):" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. iot_estacion_monitoreo"
Write-Host "  2. iot_estacion_bombeo"
Write-Host "  3. iot_datos_meteorologicos"
Write-Host "  4. iot_telemetria_bomba"
Write-Host "  5. iot_nivel_agua"
Write-Host "  6. iot_estado_compuerta"
Write-Host "  7. iot_alerta_sistema"
Write-Host "  8. iot_umbral_alerta"
Write-Host "  9. iot_log_control_automatico"
Write-Host " 10. iot_contacto_notificacion"
Write-Host " 11. iot_resumen_flujo"
Write-Host ""
Write-Host "6 VISTAS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  - v_iot_ultima_meteorologia"
Write-Host "  - v_iot_estado_bombas"
Write-Host "  - v_iot_alertas_activas"
Write-Host "  - v_iot_resumen_mensual"
Write-Host "  - v_iot_nivel_agua_actual"
Write-Host "  - v_iot_historial_control"
Write-Host ""
Write-Host "2 PROCEDIMIENTOS ALMACENADOS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  - sp_verificar_crear_alerta"
Write-Host "  - sp_insertar_telemetria_bomba"
Write-Host ""
Write-Host "2 EVENTOS PROGRAMADOS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  - evt_limpiar_telemetria_antigua"
Write-Host "  - evt_generar_resumen_diario"
Write-Host ""
Write-Host "DATOS INICIALES:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  - 4 Estaciones de Monitoreo"
Write-Host "  - 3 Estaciones de Bombeo"
Write-Host "  - 5 Umbrales de Alerta"
Write-Host "  - 2 Contactos de Notificacion"
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "PROXIMOS PASOS:" -ForegroundColor Green
Write-Host ""
Write-Host "1. Verificar que las tablas se crearon correctamente"
Write-Host "2. Actualizar config.py para usar MySQL"
Write-Host "3. Actualizar database.py con nombres en espanol"
Write-Host "4. Configurar simulador Wokwi"
Write-Host "5. Iniciar servidor Flask: python app.py"
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

pause
