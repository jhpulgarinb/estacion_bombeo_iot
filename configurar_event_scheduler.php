<?php
/**
 * Configuración de Event Scheduler en MySQL
 * Activa los eventos programados para limpieza y resúmenes
 */

$mysqli = new mysqli('localhost', 'root', '', 'promotorapalmera_db');

if ($mysqli->connect_error) {
    die("❌ Error de conexión: " . $mysqli->connect_error . "\n");
}

echo "========================================================\n";
echo "   CONFIGURACION EVENT SCHEDULER - MySQL\n";
echo "========================================================\n\n";

// Verificar estado actual
$result = $mysqli->query("SHOW VARIABLES LIKE 'event_scheduler'");
$row = $result->fetch_assoc();

echo "Estado actual de event_scheduler: " . $row['Value'] . "\n\n";

if ($row['Value'] == 'OFF') {
    echo "🔄 Activando Event Scheduler...\n";
    
    if ($mysqli->query("SET GLOBAL event_scheduler = ON")) {
        echo "✅ Event Scheduler activado\n\n";
    } else {
        echo "❌ Error al activar: " . $mysqli->error . "\n\n";
        echo "ALTERNATIVA: Ejecute en MySQL:\n";
        echo "   SET GLOBAL event_scheduler = ON;\n\n";
    }
} else {
    echo "✅ Event Scheduler ya está activado\n\n";
}

// Verificar eventos
echo "--- EVENTOS CONFIGURADOS ---\n";
$result = $mysqli->query("SHOW EVENTS WHERE Db = 'promotorapalmera_db'");

$eventos = 0;
while ($row = $result->fetch_assoc()) {
    echo "✓ " . $row['Name'] . "\n";
    echo "  Status: " . $row['Status'] . "\n";
    echo "  Ejecutar cada: " . $row['Interval_value'] . " " . $row['Interval_field'] . "\n";
    echo "  Próxima ejecución: " . $row['Starts'] . "\n\n";
    $eventos++;
}

if ($eventos == 0) {
    echo "⚠️  No se encontraron eventos\n";
    echo "   Verifique que init_database_mysql_es.sql se ejecutó correctamente\n\n";
} else {
    echo "✅ Total de eventos: $eventos\n\n";
}

// Información útil
echo "--- INFORMACIÓN ÚTIL ---\n";
echo "Para ver todas las variables:\n";
echo "   SHOW VARIABLES LIKE 'event%';\n\n";

echo "Para ver detalles de eventos:\n";
echo "   SHOW EVENTS WHERE Db='promotorapalmera_db' \\G\n\n";

echo "Para desactivar si es necesario:\n";
echo "   SET GLOBAL event_scheduler = OFF;\n\n";

echo "Para ver logs de eventos:\n";
echo "   SELECT * FROM mysql.event WHERE db='promotorapalmera_db';\n\n";

$mysqli->close();

echo "========================================================\n";
echo "   CONFIGURACION COMPLETADA\n";
echo "========================================================\n";

?>
