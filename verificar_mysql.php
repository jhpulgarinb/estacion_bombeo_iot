<?php
/**
 * Script de verificación de instalación MySQL
 * Verifica que todas las tablas fueron creadas correctamente
 */

define('DB_HOST', 'localhost');
define('DB_PORT', '3306');
define('DB_NAME', 'promotorapalmera_db');
define('DB_USER', 'root');
define('DB_PASS', '');

function conectarMySQL() {
    $mysqli = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME, DB_PORT);
    
    if ($mysqli->connect_error) {
        die("❌ Error de conexión: " . $mysqli->connect_error);
    }
    
    $mysqli->set_charset("utf8mb4");
    return $mysqli;
}

echo "=================================================================\n";
echo "   VERIFICACIÓN DE INSTALACIÓN MYSQL - SISTEMA IOT BOMBEO\n";
echo "=================================================================\n\n";

$mysqli = conectarMySQL();
echo "✅ Conexión exitosa a MySQL\n";
echo "   Base de datos: " . DB_NAME . "\n\n";

// Verificar tablas
echo "--- TABLAS INSTALADAS ---\n";
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

$tablas_encontradas = 0;
foreach ($tablas_esperadas as $tabla) {
    $result = $mysqli->query("SHOW TABLES LIKE '$tabla'");
    if ($result->num_rows > 0) {
        // Contar registros
        $count_result = $mysqli->query("SELECT COUNT(*) as total FROM $tabla");
        $count = $count_result->fetch_assoc()['total'];
        echo "✅ $tabla ($count registros)\n";
        $tablas_encontradas++;
    } else {
        echo "❌ $tabla - NO ENCONTRADA\n";
    }
}

echo "\n📊 Total: $tablas_encontradas/" . count($tablas_esperadas) . " tablas encontradas\n\n";

// Verificar vistas
echo "--- VISTAS CREADAS ---\n";
$vistas_esperadas = [
    'v_iot_ultima_meteorologia',
    'v_iot_estado_bombas',
    'v_iot_alertas_activas',
    'v_iot_resumen_mensual',
    'v_iot_nivel_agua_actual',
    'v_iot_historial_control'
];

$vistas_encontradas = 0;
foreach ($vistas_esperadas as $vista) {
    $result = $mysqli->query("SHOW FULL TABLES WHERE TABLE_TYPE LIKE 'VIEW' AND Tables_in_" . DB_NAME . " = '$vista'");
    if ($result->num_rows > 0) {
        echo "✅ $vista\n";
        $vistas_encontradas++;
    } else {
        echo "❌ $vista - NO ENCONTRADA\n";
    }
}

echo "\n📊 Total: $vistas_encontradas/" . count($vistas_esperadas) . " vistas encontradas\n\n";

// Verificar procedimientos almacenados
echo "--- PROCEDIMIENTOS ALMACENADOS ---\n";
$result = $mysqli->query("SHOW PROCEDURE STATUS WHERE Db = '" . DB_NAME . "'");
$procedimientos = 0;
while ($row = $result->fetch_assoc()) {
    if (strpos($row['Name'], 'sp_') === 0) {
        echo "✅ " . $row['Name'] . "\n";
        $procedimientos++;
    }
}
echo "\n📊 Total: $procedimientos procedimientos almacenados\n\n";

// Verificar eventos programados
echo "--- EVENTOS PROGRAMADOS ---\n";
$result = $mysqli->query("SHOW EVENTS WHERE Db = '" . DB_NAME . "'");
$eventos = 0;
while ($row = $result->fetch_assoc()) {
    echo "✅ " . $row['Name'] . " (" . $row['Status'] . ")\n";
    $eventos++;
}
echo "\n📊 Total: $eventos eventos programados\n\n";

// Verificar event scheduler
echo "--- EVENT SCHEDULER STATUS ---\n";
$result = $mysqli->query("SHOW VARIABLES LIKE 'event_scheduler'");
$row = $result->fetch_assoc();
if ($row['Value'] == 'ON') {
    echo "✅ Event Scheduler: ACTIVADO\n";
} else {
    echo "⚠️  Event Scheduler: DESACTIVADO\n";
    echo "   Para activar: SET GLOBAL event_scheduler = ON;\n";
}

echo "\n--- DATOS DE PRUEBA ---\n";
$result = $mysqli->query("SELECT COUNT(*) as total FROM iot_estacion_monitoreo");
$estaciones = $result->fetch_assoc()['total'];

$result = $mysqli->query("SELECT COUNT(*) as total FROM iot_estacion_bombeo");
$bombas = $result->fetch_assoc()['total'];

$result = $mysqli->query("SELECT COUNT(*) as total FROM iot_umbral_alerta");
$umbrales = $result->fetch_assoc()['total'];

$result = $mysqli->query("SELECT COUNT(*) as total FROM iot_contacto_notificacion");
$contactos = $result->fetch_assoc()['total'];

echo "📍 Estaciones de monitoreo: $estaciones\n";
echo "⚙️  Estaciones de bombeo: $bombas\n";
echo "🎯 Umbrales de alerta: $umbrales\n";
echo "👤 Contactos de notificación: $contactos\n";

// Mostrar estaciones
if ($estaciones > 0) {
    echo "\n--- ESTACIONES CONFIGURADAS ---\n";
    $result = $mysqli->query("SELECT id, nombre, ubicacion, activo FROM iot_estacion_monitoreo ORDER BY id");
    while ($row = $result->fetch_assoc()) {
        $status = $row['activo'] ? '🟢' : '🔴';
        echo "$status ID: {$row['id']} - {$row['nombre']}\n";
        echo "   Ubicación: {$row['ubicacion']}\n";
    }
}

// Mostrar bombas
if ($bombas > 0) {
    echo "\n--- BOMBAS CONFIGURADAS ---\n";
    $result = $mysqli->query("SELECT id, nombre, tipo_bomba, capacidad_maxima_m3h, activo FROM iot_estacion_bombeo ORDER BY id");
    while ($row = $result->fetch_assoc()) {
        $status = $row['activo'] ? '🟢' : '🔴';
        echo "$status ID: {$row['id']} - {$row['nombre']}\n";
        echo "   Tipo: {$row['tipo_bomba']} | Capacidad: {$row['capacidad_maxima_m3h']} m³/h\n";
    }
}

$mysqli->close();

echo "\n=================================================================\n";
echo "   VERIFICACIÓN COMPLETADA\n";
echo "=================================================================\n";

if ($tablas_encontradas == count($tablas_esperadas) && 
    $vistas_encontradas == count($vistas_esperadas)) {
    echo "✅ INSTALACIÓN EXITOSA - Todas las tablas y vistas están creadas\n";
    echo "\n📝 PRÓXIMOS PASOS:\n";
    echo "1. Instalar pymysql: pip install pymysql\n";
    echo "2. Ejecutar Flask: python app.py\n";
    echo "3. Verificar dashboard: http://localhost:5000\n";
} else {
    echo "⚠️  INSTALACIÓN INCOMPLETA - Faltan algunas tablas o vistas\n";
    echo "   Ejecutar: http://localhost/project_estacion_bombeo/instalar_mysql_es.php\n";
}

echo "=================================================================\n";
?>
