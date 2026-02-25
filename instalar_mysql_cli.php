<?php
/**
 * Script de instalación MySQL - Ejecución directa
 * Ejecuta el archivo SQL en la base de datos
 */

$mysqli = new mysqli('localhost', 'root', '', 'promotorapalmera_db');

if ($mysqli->connect_error) {
    die("❌ Error de conexión: " . $mysqli->connect_error . "\n");
}

$mysqli->set_charset('utf8mb4');

echo "=================================================================\n";
echo "   INSTALACIÓN MYSQL - SISTEMA IOT BOMBEO\n";
echo "=================================================================\n\n";

echo "✅ Conectado a MySQL\n";
echo "📂 Leyendo archivo SQL: init_database_mysql_es.sql\n\n";

$sql = file_get_contents('init_database_mysql_es.sql');
if (!$sql) {
    die("❌ Error leyendo archivo SQL\n");
}

// Dividir el SQL en declaraciones
$statements = explode(';', $sql);
$success = 0;
$errors = 0;
$warnings = 0;

echo "🚀 Ejecutando instalación...\n\n";

// Dividir el SQL manejando DELIMITER correctamente
$delimiter = ';';
$tempLine = '';
$statements = [];

$lines = explode("\n", $sql);
foreach ($lines as $line) {
    $line = trim($line);
    
    // Cambiar delimiter
    if (stripos($line, 'DELIMITER') === 0) {
        preg_match('/DELIMITER\s+(.+)/', $line, $matches);
        if (isset($matches[1])) {
            $delimiter = trim($matches[1]);
        }
        continue;
    }
    
    // Ignorar comentarios y líneas vacías
    if (empty($line) || strpos($line, '--') === 0 || strpos($line, '/*') === 0) {
        continue;
    }
    
    // Acumular líneas
    $tempLine .= ' ' . $line;
    
    // Si encontramos el delimiter, es el final de la declaración
    if (strpos($line, $delimiter) !== false) {
        $statement = trim(str_replace($delimiter, '', $tempLine));
        if (!empty($statement)) {
            $statements[] = $statement;
        }
        $tempLine = '';
    }
}

// Ejecutar cada statement
foreach ($statements as $statement) {
    if ($mysqli->multi_query($statement . ';')) {
        do {
            if ($result = $mysqli->store_result()) {
                $result->free();
            }
            if ($mysqli->more_results()) {
                $mysqli->next_result();
            }
        } while ($mysqli->more_results());
        
        $success++;
        
        // Mostrar progreso cada 10 comandos
        if ($success % 10 == 0) {
            echo "  ✓ $success comandos ejecutados...\n";
        }
    } else {
        $error = $mysqli->error;
        
        // Ignorar errores de "already exists"
        if (stripos($error, 'already exists') !== false || 
            stripos($error, 'duplicate') !== false) {
            $warnings++;
        } else if (!empty($error)) {
            echo "⚠️  Error: " . substr($statement, 0, 60) . "...\n";
            echo "   " . $error . "\n";
            $errors++;
        }
    }
}

echo "\n";
echo "📊 RESUMEN DE INSTALACIÓN:\n";
echo "  ✅ Comandos ejecutados: $success\n";
echo "  ⚠️  Advertencias: $warnings\n";
echo "  ❌ Errores: $errors\n";
echo "\n";

// Verificar tablas creadas
echo "--- TABLAS CREADAS ---\n";
$result = $mysqli->query("SHOW TABLES LIKE 'iot_%'");
$tablas = [];
while ($row = $result->fetch_array()) {
    $tablas[] = $row[0];
    echo "  ✓ " . $row[0] . "\n";
}
echo "  Total: " . count($tablas) . " tablas\n\n";

// Verificar vistas
echo "--- VISTAS CREADAS ---\n";
$result = $mysqli->query("SHOW FULL TABLES WHERE TABLE_TYPE LIKE 'VIEW' AND Tables_in_promotorapalmera_db LIKE 'v_iot_%'");
$vistas = 0;
while ($row = $result->fetch_array()) {
    echo "  ✓ " . $row[0] . "\n";
    $vistas++;
}
echo "  Total: $vistas vistas\n\n";

// Verificar procedimientos
echo "--- PROCEDIMIENTOS ALMACENADOS ---\n";
$result = $mysqli->query("SHOW PROCEDURE STATUS WHERE Db = 'promotorapalmera_db'");
$procedimientos = 0;
while ($row = $result->fetch_assoc()) {
    if (strpos($row['Name'], 'sp_') === 0) {
        echo "  ✓ " . $row['Name'] . "\n";
        $procedimientos++;
    }
}
echo "  Total: $procedimientos procedimientos\n\n";

// Verificar eventos
echo "--- EVENTOS PROGRAMADOS ---\n";
$result = $mysqli->query("SHOW EVENTS WHERE Db = 'promotorapalmera_db'");
$eventos = 0;
while ($row = $result->fetch_assoc()) {
    echo "  ✓ " . $row['Name'] . " (" . $row['Status'] . ")\n";
    $eventos++;
}
echo "  Total: $eventos eventos\n\n";

// Activar event scheduler si está desactivado
$result = $mysqli->query("SHOW VARIABLES LIKE 'event_scheduler'");
$row = $result->fetch_assoc();
if ($row['Value'] != 'ON') {
    echo "⚙️  Activando Event Scheduler...\n";
    $mysqli->query("SET GLOBAL event_scheduler = ON");
    echo "  ✓ Event Scheduler activado\n\n";
}

// Verificar datos de prueba
echo "--- DATOS DE PRUEBA ---\n";
$result = $mysqli->query("SELECT COUNT(*) as total FROM iot_estacion_monitoreo");
$estaciones = $result->fetch_assoc()['total'];
echo "  📍 Estaciones de monitoreo: $estaciones\n";

$result = $mysqli->query("SELECT COUNT(*) as total FROM iot_estacion_bombeo");
$bombas = $result->fetch_assoc()['total'];
echo "  ⚙️  Estaciones de bombeo: $bombas\n";

$result = $mysqli->query("SELECT COUNT(*) as total FROM iot_umbral_alerta");
$umbrales = $result->fetch_assoc()['total'];
echo "  🎯 Umbrales de alerta: $umbrales\n";

$result = $mysqli->query("SELECT COUNT(*) as total FROM iot_contacto_notificacion");
$contactos = $result->fetch_assoc()['total'];
echo "  👤 Contactos: $contactos\n";

$mysqli->close();

echo "\n";
echo "=================================================================\n";
if ($errors == 0 && count($tablas) == 11) {
    echo "  ✅ INSTALACIÓN EXITOSA\n";
    echo "=================================================================\n\n";
    echo "📝 PRÓXIMOS PASOS:\n\n";
    echo "1. Instalar pymysql:\n";
    echo "   pip install pymysql\n\n";
    echo "2. Ejecutar Flask:\n";
    echo "   python app.py\n\n";
    echo "3. Abrir dashboard:\n";
    echo "   http://localhost:5000\n\n";
} else {
    echo "  ⚠️  INSTALACIÓN CON ADVERTENCIAS\n";
    echo "=================================================================\n";
}

?>
