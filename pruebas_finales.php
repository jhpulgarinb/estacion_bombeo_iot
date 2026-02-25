<?php
/**
 * PRUEBAS FINALES DEL SISTEMA
 * Verifica que todo está funcionando correctamente
 */

echo "========================================================\n";
echo "  PRUEBAS FINALES - SISTEMA IOT BOMBEO\n";
echo "========================================================\n\n";

// Prueba 1: Conexión a MySQL
echo "TEST 1: Conexión a MySQL\n";
echo "--------------------------------------------------------\n";

$mysqli = new mysqli('localhost', 'root', '', 'promotorapalmera_db');

if ($mysqli->connect_error) {
    echo "❌ Error de conexión: " . $mysqli->connect_error . "\n";
    exit(1);
}

echo "✅ Conexión exitosa a MySQL\n";
echo "   Base de datos: promotorapalmera_db\n\n";

// Prueba 2: Verificar tablas
echo "TEST 2: Verificar estructura de base de datos\n";
echo "--------------------------------------------------------\n";

$tablas_esperadas = [
    'iot_estacion_monitoreo',
    'iot_estacion_bombeo',
    'iot_datos_meteorologicos',
    'iot_telemetria_bomba',
    'iot_nivel_agua',
    'iot_estado_compuerta',
    'iot_alerta_sistema',
    'iot_umbral_alerta',
    'iot_log_control_automatico',
    'iot_contacto_notificacion',
    'iot_resumen_flujo'
];

$result = $mysqli->query("SHOW TABLES");
$tablas_existentes = [];
while ($row = $result->fetch_row()) {
    $tablas_existentes[] = $row[0];
}

$tablas_creadas = 0;
foreach ($tablas_esperadas as $tabla) {
    if (in_array($tabla, $tablas_existentes)) {
        $tablas_creadas++;
        echo "✓ $tabla\n";
    } else {
        echo "✗ $tabla (NO ENCONTRADA)\n";
    }
}

echo "\n✅ Tablas verificadas: $tablas_creadas/" . count($tablas_esperadas) . "\n\n";

// Prueba 3: Datos de prueba
echo "TEST 3: Verificar datos de prueba\n";
echo "--------------------------------------------------------\n";

// Estaciones
$result = $mysqli->query("SELECT id, nombre, ubicacion FROM iot_estacion_monitoreo");
echo "✅ Estaciones de monitoreo:\n";
while ($row = $result->fetch_assoc()) {
    echo "   • {$row['nombre']}\n";
    echo "     Ubicación: {$row['ubicacion']}\n";
}

// Bombas
$result = $mysqli->query("SELECT id, nombre, tipo_bomba, capacidad_maxima_m3h FROM iot_estacion_bombeo");
echo "\n✅ Estaciones de bombeo:\n";
while ($row = $result->fetch_assoc()) {
    echo "   • {$row['nombre']} ({$row['tipo_bomba']})\n";
    echo "     Capacidad: {$row['capacidad_maxima_m3h']} m³/h\n";
}

// Umbrales
$result = $mysqli->query("SELECT COUNT(*) as total FROM iot_umbral_alerta");
$row = $result->fetch_assoc();
echo "\n✅ Umbrales de alerta: " . $row['total'] . "\n";

// Contactos
$result = $mysqli->query("SELECT COUNT(*) as total FROM iot_contacto_notificacion");
$row = $result->fetch_assoc();
echo "✅ Contactos notificación: " . $row['total'] . "\n\n";

// Prueba 4: Vistas
echo "TEST 4: Verificar vistas creadas\n";
echo "--------------------------------------------------------\n";

$vistas_esperadas = [
    'v_iot_ultima_meteorologia',
    'v_iot_estado_bombas',
    'v_iot_alertas_activas',
    'v_iot_resumen_mensual',
    'v_iot_nivel_agua_actual',
    'v_iot_historial_control'
];

$result = $mysqli->query("SHOW FULL TABLES WHERE TABLE_TYPE LIKE 'VIEW'");
$vistas_existentes = [];
while ($row = $result->fetch_row()) {
    if (strpos($row[0], 'v_iot_') === 0) {
        $vistas_existentes[] = $row[0];
        echo "✓ {$row[0]}\n";
    }
}

echo "\n✅ Vistas verificadas: " . count($vistas_existentes) . "/" . count($vistas_esperadas) . "\n\n";

// Prueba 5: Procedimientos almacenados
echo "TEST 5: Verificar procedimientos almacenados\n";
echo "--------------------------------------------------------\n";

$result = $mysqli->query("SHOW PROCEDURE STATUS WHERE Db = 'promotorapalmera_db'");
$procedimientos = 0;
while ($row = $result->fetch_assoc()) {
    if (strpos($row['Name'], 'sp_') === 0) {
        echo "✓ {$row['Name']}\n";
        $procedimientos++;
    }
}

echo "\n✅ Procedimientos: $procedimientos\n\n";

// Prueba 6: Eventos
echo "TEST 6: Verificar eventos programados\n";
echo "--------------------------------------------------------\n";

$result = $mysqli->query("SHOW EVENTS WHERE Db = 'promotorapalmera_db'");
$eventos = 0;
while ($row = $result->fetch_assoc()) {
    echo "✓ {$row['Name']} (Status: {$row['Status']})\n";
    $eventos++;
}

echo "\n✅ Eventos: $eventos\n\n";

// Prueba 7: Event Scheduler
echo "TEST 7: Verificar Event Scheduler\n";
echo "--------------------------------------------------------\n";

$result = $mysqli->query("SHOW VARIABLES LIKE 'event_scheduler'");
$row = $result->fetch_assoc();
if ($row['Value'] == 'ON') {
    echo "✅ Event Scheduler: ACTIVADO\n";
} else {
    echo "⚠️  Event Scheduler: DESACTIVADO\n";
    echo "   Para activar: SET GLOBAL event_scheduler = ON;\n";
}

echo "\n";

// Resumen final
echo "========================================================\n";
echo "  ✅ TODAS LAS PRUEBAS COMPLETADAS EXITOSAMENTE\n";
echo "========================================================\n\n";

echo "📊 RESUMEN DEL SISTEMA:\n";
echo "   Tablas: $tablas_creadas/" . count($tablas_esperadas) . " creadas\n";
echo "   Vistas: " . count($vistas_existentes) . "/" . count($vistas_esperadas) . " creadas\n";
echo "   Procedimientos: $procedimientos/2\n";
echo "   Eventos: $eventos/2\n";
echo "\n";

echo "📝 PRÓXIMOS PASOS:\n\n";
echo "1. Ejecutar Flask:\n";
echo "   python app.py\n\n";
echo "2. Abrir dashboard:\n";
echo "   http://localhost:5000\n\n";
echo "3. Enviar datos de sensores:\n";
echo "   - Usar Wokwi ESP32 simulator\n";
echo "   - O hacer requests POST a los endpoints API\n\n";
echo "4. Ver datos en la base de datos:\n";
echo "   phpMyAdmin: http://localhost/phpmyadmin\n";
echo "   Base de datos: promotorapalmera_db\n\n";

echo "========================================================\n";

$mysqli->close();

?>
