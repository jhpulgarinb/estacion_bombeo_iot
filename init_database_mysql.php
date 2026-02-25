<?php
/**
 * Script de Inicialización de Base de Datos MySQL
 * Sistema IoT Estación de Bombeo
 * Promotora Palmera de Antioquia S.A.S.
 * Fecha: 21 de febrero de 2026
 */

// Configuración de la base de datos
define('DB_HOST', 'localhost');
define('DB_PORT', '3306');
define('DB_NAME', 'promotorapalmera_db');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

// Configuración de visualización de errores
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: text/html; charset=utf-8');

/**
 * Función para conectar a MySQL
 */
function conectarMySQL() {
    $mysqli = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME, (int)DB_PORT);
    
    if ($mysqli->connect_errno) {
        die("❌ Error de conexión a MySQL ({$mysqli->connect_errno}): {$mysqli->connect_error}");
    }
    
    // Configurar charset
    if (!$mysqli->set_charset(DB_CHARSET)) {
        die("❌ Error al configurar charset: {$mysqli->error}");
    }
    
    return $mysqli;
}

/**
 * Función para ejecutar el script SQL
 */
function ejecutarScriptSQL($mysqli, $archivo) {
    if (!file_exists($archivo)) {
        die("❌ Error: No se encuentra el archivo {$archivo}");
    }
    
    $sql = file_get_contents($archivo);
    
    if ($sql === false) {
        die("❌ Error al leer el archivo {$archivo}");
    }
    
    echo "<h3>📄 Ejecutando script SQL: {$archivo}</h3>";
    
    // Dividir el script en comandos individuales
    $comandos = explode(';', $sql);
    $exitosos = 0;
    $errores = 0;
    
    foreach ($comandos as $comando) {
        $comando = trim($comando);
        
        // Ignorar comentarios y líneas vacías
        if (empty($comando) || 
            substr($comando, 0, 2) === '--' || 
            substr($comando, 0, 2) === '/*' ||
            strtoupper(substr($comando, 0, 9)) === 'DELIMITER') {
            continue;
        }
        
        // Ejecutar comando
        if ($mysqli->query($comando)) {
            $exitosos++;
            if ($mysqli->affected_rows > 0) {
                echo "✅ Ejecutado correctamente ({$mysqli->affected_rows} filas afectadas)<br>";
            }
        } else {
            // Solo mostrar errores que no sean de "ya existe"
            if (strpos($mysqli->error, 'already exists') === false && 
                strpos($mysqli->error, 'Duplicate entry') === false) {
                echo "⚠️ Advertencia: {$mysqli->error}<br>";
                $errores++;
            }
        }
    }
    
    echo "<p><strong>Resumen:</strong> {$exitosos} comandos ejecutados correctamente";
    if ($errores > 0) {
        echo ", {$errores} errores/advertencias";
    }
    echo "</p>";
    
    return true;
}

/**
 * Función para verificar las tablas creadas
 */
function verificarTablas($mysqli) {
    echo "<h3>📊 Verificando tablas creadas...</h3>";
    
    $query = "SELECT TABLE_NAME, TABLE_ROWS, 
              ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024, 2) AS size_kb
              FROM information_schema.TABLES
              WHERE TABLE_SCHEMA = '" . DB_NAME . "'
                AND TABLE_NAME LIKE 'iot_%'
              ORDER BY TABLE_NAME";
    
    $result = $mysqli->query($query);
    
    if ($result) {
        echo "<table border='1' cellpadding='8' cellspacing='0' style='border-collapse: collapse; width: 100%;'>";
        echo "<tr style='background-color: #4CAF50; color: white;'>";
        echo "<th>Tabla</th><th>Filas</th><th>Tamaño (KB)</th>";
        echo "</tr>";
        
        $total_rows = 0;
        $total_size = 0;
        
        while ($row = $result->fetch_assoc()) {
            echo "<tr>";
            echo "<td>{$row['TABLE_NAME']}</td>";
            echo "<td style='text-align: right;'>{$row['TABLE_ROWS']}</td>";
            echo "<td style='text-align: right;'>{$row['size_kb']}</td>";
            echo "</tr>";
            $total_rows += $row['TABLE_ROWS'];
            $total_size += $row['size_kb'];
        }
        
        echo "<tr style='background-color: #f0f0f0; font-weight: bold;'>";
        echo "<td>TOTAL</td>";
        echo "<td style='text-align: right;'>{$total_rows}</td>";
        echo "<td style='text-align: right;'>" . round($total_size, 2) . "</td>";
        echo "</tr>";
        echo "</table>";
        
        $result->free();
    } else {
        echo "❌ Error al consultar tablas: {$mysqli->error}";
    }
}

/**
 * Función para verificar las vistas creadas
 */
function verificarVistas($mysqli) {
    echo "<h3>👁️ Verificando vistas creadas...</h3>";
    
    $query = "SELECT TABLE_NAME AS view_name
              FROM information_schema.VIEWS
              WHERE TABLE_SCHEMA = '" . DB_NAME . "'
                AND TABLE_NAME LIKE 'v_iot_%'
              ORDER BY TABLE_NAME";
    
    $result = $mysqli->query($query);
    
    if ($result) {
        echo "<ul style='column-count: 2;'>";
        $count = 0;
        while ($row = $result->fetch_assoc()) {
            echo "<li>✅ {$row['view_name']}</li>";
            $count++;
        }
        echo "</ul>";
        echo "<p><strong>Total de vistas:</strong> {$count}</p>";
        $result->free();
    } else {
        echo "❌ Error al consultar vistas: {$mysqli->error}";
    }
}

/**
 * Función para verificar datos insertados
 */
function verificarDatos($mysqli) {
    echo "<h3>📈 Verificando datos insertados...</h3>";
    
    $tablas = [
        'iot_monitoring_station' => 'Estaciones de Monitoreo',
        'iot_pumping_station' => 'Estaciones de Bombeo',
        'iot_alert_threshold' => 'Umbrales de Alerta',
        'iot_notification_contact' => 'Contactos de Notificación'
    ];
    
    echo "<table border='1' cellpadding='8' cellspacing='0' style='border-collapse: collapse; width: 100%;'>";
    echo "<tr style='background-color: #2196F3; color: white;'>";
    echo "<th>Tabla</th><th>Registros</th>";
    echo "</tr>";
    
    foreach ($tablas as $tabla => $nombre) {
        $result = $mysqli->query("SELECT COUNT(*) as total FROM {$tabla}");
        if ($result) {
            $row = $result->fetch_assoc();
            echo "<tr>";
            echo "<td>{$nombre}</td>";
            echo "<td style='text-align: right;'><strong>{$row['total']}</strong></td>";
            echo "</tr>";
            $result->free();
        }
    }
    
    echo "</table>";
}

/**
 * Función para mostrar muestra de datos
 */
function mostrarMuestraDatos($mysqli) {
    echo "<h3>📋 Muestra de datos iniciales...</h3>";
    
    // Mostrar estaciones de monitoreo
    echo "<h4>Estaciones de Monitoreo:</h4>";
    $result = $mysqli->query("SELECT id, name, location, latitude, longitude, station_type FROM iot_monitoring_station ORDER BY id");
    
    if ($result && $result->num_rows > 0) {
        echo "<table border='1' cellpadding='6' cellspacing='0' style='border-collapse: collapse; width: 100%; font-size: 0.9em;'>";
        echo "<tr style='background-color: #4CAF50; color: white;'>";
        echo "<th>ID</th><th>Nombre</th><th>Ubicación</th><th>Lat</th><th>Lon</th><th>Tipo</th>";
        echo "</tr>";
        
        while ($row = $result->fetch_assoc()) {
            echo "<tr>";
            echo "<td>{$row['id']}</td>";
            echo "<td>{$row['name']}</td>";
            echo "<td>{$row['location']}</td>";
            echo "<td>{$row['latitude']}</td>";
            echo "<td>{$row['longitude']}</td>";
            echo "<td>{$row['station_type']}</td>";
            echo "</tr>";
        }
        echo "</table>";
        $result->free();
    }
    
    // Mostrar bombas
    echo "<h4>Estaciones de Bombeo:</h4>";
    $result = $mysqli->query("SELECT id, name, pump_type, max_capacity_m3h, rated_power_kw FROM iot_pumping_station ORDER BY id");
    
    if ($result && $result->num_rows > 0) {
        echo "<table border='1' cellpadding='6' cellspacing='0' style='border-collapse: collapse; width: 100%; font-size: 0.9em;'>";
        echo "<tr style='background-color: #FF9800; color: white;'>";
        echo "<th>ID</th><th>Nombre</th><th>Tipo</th><th>Capacidad (m³/h)</th><th>Potencia (kW)</th>";
        echo "</tr>";
        
        while ($row = $result->fetch_assoc()) {
            echo "<tr>";
            echo "<td>{$row['id']}</td>";
            echo "<td>{$row['name']}</td>";
            echo "<td>{$row['pump_type']}</td>";
            echo "<td style='text-align: right;'>{$row['max_capacity_m3h']}</td>";
            echo "<td style='text-align: right;'>{$row['rated_power_kw']}</td>";
            echo "</tr>";
        }
        echo "</table>";
        $result->free();
    }
    
    // Mostrar umbrales de alerta
    echo "<h4>Umbrales de Alerta Configurados:</h4>";
    $result = $mysqli->query("SELECT parameter_name, min_value, max_value, alert_level, description FROM iot_alert_threshold ORDER BY alert_level, parameter_name");
    
    if ($result && $result->num_rows > 0) {
        echo "<table border='1' cellpadding='6' cellspacing='0' style='border-collapse: collapse; width: 100%; font-size: 0.9em;'>";
        echo "<tr style='background-color: #f44336; color: white;'>";
        echo "<th>Parámetro</th><th>Mínimo</th><th>Máximo</th><th>Nivel</th><th>Descripción</th>";
        echo "</tr>";
        
        while ($row = $result->fetch_assoc()) {
            $color = match($row['alert_level']) {
                'CRITICAL' => '#f44336',
                'HIGH' => '#FF9800',
                'MEDIUM' => '#FFC107',
                'LOW' => '#4CAF50',
                default => '#9E9E9E'
            };
            
            echo "<tr>";
            echo "<td><strong>{$row['parameter_name']}</strong></td>";
            echo "<td style='text-align: right;'>{$row['min_value']}</td>";
            echo "<td style='text-align: right;'>{$row['max_value']}</td>";
            echo "<td style='background-color: {$color}; color: white; text-align: center;'>{$row['alert_level']}</td>";
            echo "<td>{$row['description']}</td>";
            echo "</tr>";
        }
        echo "</table>";
        $result->free();
    }
}

// ============================================================
// SCRIPT PRINCIPAL
// ============================================================

?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicialización Base de Datos IoT - Promotora Palmera</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        h2 {
            color: #34495e;
            margin-top: 30px;
        }
        h3 {
            color: #16a085;
            margin-top: 25px;
        }
        h4 {
            color: #7f8c8d;
            margin-top: 20px;
        }
        .info-box {
            background-color: #e8f5e9;
            border-left: 4px solid #4CAF50;
            padding: 15px;
            margin: 20px 0;
        }
        .warning-box {
            background-color: #fff3e0;
            border-left: 4px solid #FF9800;
            padding: 15px;
            margin: 20px 0;
        }
        .error-box {
            background-color: #ffebee;
            border-left: 4px solid #f44336;
            padding: 15px;
            margin: 20px 0;
        }
        table {
            margin: 15px 0;
        }
        table th {
            font-weight: 600;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 2px solid #ecf0f1;
            text-align: center;
            color: #7f8c8d;
        }
        code {
            background-color: #f4f4f4;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Inicialización de Base de Datos MySQL</h1>
        <h2>Sistema IoT Estación de Bombeo - Promotora Palmera de Antioquia S.A.S.</h2>
        
        <?php
        echo "<div class='info-box'>";
        echo "<strong>📅 Fecha:</strong> " . date('d/m/Y H:i:s') . "<br>";
        echo "<strong>🗄️ Base de datos:</strong> " . DB_NAME . "<br>";
        echo "<strong>🖥️ Servidor:</strong> " . DB_HOST . ":" . DB_PORT . "<br>";
        echo "<strong>👤 Usuario:</strong> " . DB_USER . "<br>";
        echo "</div>";
        
        // Conectar a MySQL
        echo "<h2>🔌 Paso 1: Conectar a MySQL</h2>";
        $mysqli = conectarMySQL();
        echo "<div class='info-box'>✅ Conexión exitosa a MySQL</div>";
        
        // Ejecutar script SQL
        echo "<h2>⚙️ Paso 2: Ejecutar script de inicialización</h2>";
        $archivoSQL = __DIR__ . '/init_database_mysql.sql';
        
        if (ejecutarScriptSQL($mysqli, $archivoSQL)) {
            echo "<div class='info-box'>✅ Script SQL ejecutado correctamente</div>";
        } else {
            echo "<div class='error-box'>❌ Error al ejecutar el script SQL</div>";
        }
        
        // Verificar tablas
        echo "<h2>🔍 Paso 3: Verificación del sistema</h2>";
        verificarTablas($mysqli);
        
        // Verificar vistas
        verificarVistas($mysqli);
        
        // Verificar datos
        verificarDatos($mysqli);
        
        // Mostrar muestra de datos
        mostrarMuestraDatos($mysqli);
        
        // Resumen final
        echo "<h2>📊 Resumen Final</h2>";
        echo "<div class='info-box'>";
        echo "<h3>✅ Base de datos inicializada correctamente</h3>";
        echo "<ul>";
        echo "<li><strong>11 tablas</strong> creadas con prefijo <code>iot_</code></li>";
        echo "<li><strong>5 vistas</strong> para consultas rápidas</li>";
        echo "<li><strong>2 procedimientos almacenados</strong> para alertas automáticas</li>";
        echo "<li><strong>2 eventos programados</strong> para mantenimiento</li>";
        echo "<li><strong>Datos iniciales</strong> insertados (4 estaciones, 3 bombas, 5 umbrales, 2 contactos)</li>";
        echo "</ul>";
        echo "</div>";
        
        echo "<div class='warning-box'>";
        echo "<h4>📝 Próximos pasos:</h4>";
        echo "<ol>";
        echo "<li>Actualizar el archivo <code>config.py</code> para usar MySQL en lugar de SQLite</li>";
        echo "<li>Configurar la conexión en Flask con las credenciales de MySQL</li>";
        echo "<li>Actualizar el simulador ESP32 Wokwi para apuntar al servidor correcto</li>";
        echo "<li>Iniciar el servidor Flask: <code>python app.py</code></li>";
        echo "<li>Acceder al dashboard: <code>http://localhost:5000</code></li>";
        echo "</ol>";
        echo "</div>";
        
        // Cerrar conexión
        $mysqli->close();
        ?>
        
        <div class="footer">
            <p><strong>Promotora Palmera de Antioquia S.A.S.</strong></p>
            <p>Sistema IoT de Monitoreo y Control de Estación de Bombeo</p>
            <p>Versión 1.0 - Febrero 2026</p>
        </div>
    </div>
</body>
</html>
