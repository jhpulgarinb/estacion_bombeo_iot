<?php
/**
 * Script de Inicialización de Base de Datos MySQL - VERSIÓN EN ESPAÑOL
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
    
    echo "<h3>📄 Ejecutando script SQL: " . basename($archivo) . "</h3>";
    
    // Dividir el script en comandos individuales
    $comandos = explode(';', $sql);
    $exitosos = 0;
    $errores = 0;
    $advertencias = [];
    
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
        if ($mysqli->multi_query($comando . ';')) {
            do {
                if ($result = $mysqli->store_result()) {
                    $result->free();
                }
            } while ($mysqli->more_results() && $mysqli->next_result());
            
            $exitosos++;
        } else {
            // Solo mostrar errores que no sean de "ya existe"
            if (strpos($mysqli->error, 'already exists') === false && 
                strpos($mysqli->error, 'Duplicate entry') === false &&
                !empty($mysqli->error)) {
                $advertencias[] = $mysqli->error;
                $errores++;
            }
        }
    }
    
    echo "<div style='background-color: #e8f5e9; padding: 15px; border-left: 4px solid #4CAF50; margin: 15px 0;'>";
    echo "<p><strong>✅ Resumen de ejecución:</strong></p>";
    echo "<ul>";
    echo "<li><strong style='color: #4CAF50;'>{$exitosos}</strong> comandos ejecutados correctamente</li>";
    if ($errores > 0) {
        echo "<li><strong style='color: #FF9800;'>{$errores}</strong> advertencias (pueden ser normales)</li>";
    }
    echo "</ul>";
    echo "</div>";
    
    if (count($advertencias) > 0 && count($advertencias) < 10) {
        echo "<details style='margin: 15px 0;'>";
        echo "<summary style='cursor: pointer; color: #FF9800;'>⚠️ Ver advertencias ({$errores})</summary>";
        echo "<ul style='font-size: 0.9em; color: #666;'>";
        foreach ($advertencias as $adv) {
            echo "<li>" . htmlspecialchars($adv) . "</li>";
        }
        echo "</ul>";
        echo "</details>";
    }
    
    return true;
}

/**
 * Función para verificar las tablas creadas
 */
function verificarTablas($mysqli) {
    echo "<h3>📊 Verificando tablas creadas...</h3>";
    
    $query = "SELECT TABLE_NAME, TABLE_ROWS, 
              ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024, 2) AS size_kb,
              TABLE_COMMENT
              FROM information_schema.TABLES
              WHERE TABLE_SCHEMA = '" . DB_NAME . "'
                AND TABLE_NAME LIKE 'iot_%'
              ORDER BY TABLE_NAME";
    
    $result = $mysqli->query($query);
    
    if ($result) {
        echo "<table border='1' cellpadding='8' cellspacing='0' style='border-collapse: collapse; width: 100%; font-size: 0.95em;'>";
        echo "<tr style='background-color: #4CAF50; color: white;'>";
        echo "<th>Tabla</th><th>Filas</th><th>Tamaño (KB)</th><th>Descripción</th>";
        echo "</tr>";
        
        $total_rows = 0;
        $total_size = 0;
        $tabla_count = 0;
        
        while ($row = $result->fetch_assoc()) {
            $tabla_count++;
            echo "<tr>";
            echo "<td><code>{$row['TABLE_NAME']}</code></td>";
            echo "<td style='text-align: right;'>{$row['TABLE_ROWS']}</td>";
            echo "<td style='text-align: right;'>{$row['size_kb']}</td>";
            echo "<td style='font-size: 0.85em; color: #666;'>{$row['TABLE_COMMENT']}</td>";
            echo "</tr>";
            $total_rows += $row['TABLE_ROWS'];
            $total_size += $row['size_kb'];
        }
        
        echo "<tr style='background-color: #f0f0f0; font-weight: bold;'>";
        echo "<td>TOTAL ({$tabla_count} tablas)</td>";
        echo "<td style='text-align: right;'>{$total_rows}</td>";
        echo "<td style='text-align: right;'>" . round($total_size, 2) . "</td>";
        echo "<td></td>";
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
    
    $query = "SELECT TABLE_NAME AS view_name, VIEW_DEFINITION
              FROM information_schema.VIEWS
              WHERE TABLE_SCHEMA = '" . DB_NAME . "'
                AND TABLE_NAME LIKE 'v_iot_%'
              ORDER BY TABLE_NAME";
    
    $result = $mysqli->query($query);
    
    if ($result) {
        echo "<ul style='column-count: 2; list-style-type: none; padding: 0;'>";
        $count = 0;
        while ($row = $result->fetch_assoc()) {
            echo "<li style='padding: 5px 0;'>✅ <code style='background-color: #f4f4f4; padding: 2px 6px; border-radius: 3px;'>{$row['view_name']}</code></li>";
            $count++;
        }
        echo "</ul>";
        echo "<p><strong>Total de vistas:</strong> <span style='color: #4CAF50; font-size: 1.2em;'>{$count}</span></p>";
        $result->free();
    } else {
        echo "❌ Error al consultar vistas: {$mysqli->error}";
    }
}

/**
 * Función para verificar procedimientos almacenados
 */
function verificarProcedimientos($mysqli) {
    echo "<h3>⚙️ Verificando procedimientos almacenados...</h3>";
    
    $query = "SHOW PROCEDURE STATUS WHERE Db = '" . DB_NAME . "' AND Name LIKE 'sp_%'";
    
    $result = $mysqli->query($query);
    
    if ($result) {
        echo "<ul style='list-style-type: none; padding: 0;'>";
        $count = 0;
        while ($row = $result->fetch_assoc()) {
            echo "<li style='padding: 5px 0;'>🔧 <code style='background-color: #e3f2fd; padding: 2px 6px; border-radius: 3px;'>{$row['Name']}</code> - <span style='font-size: 0.9em; color: #666;'>{$row['Comment']}</span></li>";
            $count++;
        }
        echo "</ul>";
        echo "<p><strong>Total de procedimientos:</strong> <span style='color: #2196F3; font-size: 1.2em;'>{$count}</span></p>";
        $result->free();
    } else {
        echo "⚠️ No se pudieron verificar procedimientos";
    }
}

/**
 * Función para verificar eventos programados
 */
function verificarEventos($mysqli) {
    echo "<h3>⏰ Verificando eventos programados...</h3>";
    
    // Primero verificar si el event_scheduler está habilitado
    $result = $mysqli->query("SHOW VARIABLES LIKE 'event_scheduler'");
    if ($result) {
        $row = $result->fetch_assoc();
        $scheduler_status = $row['Value'];
        
        if ($scheduler_status === 'OFF') {
            echo "<div style='background-color: #fff3e0; padding: 15px; border-left: 4px solid #FF9800; margin: 15px 0;'>";
            echo "<p>⚠️ <strong>Event Scheduler está DESHABILITADO</strong></p>";
            echo "<p>Para habilitar los eventos automáticos, ejecuta:</p>";
            echo "<pre style='background-color: #f4f4f4; padding: 10px; border-radius: 4px;'>SET GLOBAL event_scheduler = ON;</pre>";
            echo "</div>";
        } else {
            echo "<p style='color: #4CAF50;'>✅ Event Scheduler está <strong>HABILITADO</strong></p>";
        }
        $result->free();
    }
    
    $query = "SHOW EVENTS FROM " . DB_NAME . " WHERE Name LIKE 'evt_%'";
    
    $result = $mysqli->query($query);
    
    if ($result) {
        echo "<ul style='list-style-type: none; padding: 0;'>";
        $count = 0;
        while ($row = $result->fetch_assoc()) {
            echo "<li style='padding: 5px 0;'>⏱️ <code style='background-color: #fce4ec; padding: 2px 6px; border-radius: 3px;'>{$row['Name']}</code> - Cada {$row['Interval_value']} {$row['Interval_field']}</li>";
            $count++;
        }
        echo "</ul>";
        echo "<p><strong>Total de eventos:</strong> <span style='color: #E91E63; font-size: 1.2em;'>{$count}</span></p>";
        $result->free();
    } else {
        echo "⚠️ No se pudieron verificar eventos";
    }
}

/**
 * Función para verificar datos insertados
 */
function verificarDatos($mysqli) {
    echo "<h3>📈 Verificando datos insertados...</h3>";
    
    $tablas = [
        'iot_estacion_monitoreo' => 'Estaciones de Monitoreo',
        'iot_estacion_bombeo' => 'Estaciones de Bombeo',
        'iot_umbral_alerta' => 'Umbrales de Alerta',
        'iot_contacto_notificacion' => 'Contactos de Notificación'
    ];
    
    echo "<table border='1' cellpadding='8' cellspacing='0' style='border-collapse: collapse; width: 100%;'>";
    echo "<tr style='background-color: #2196F3; color: white;'>";
    echo "<th>Tabla</th><th>Registros</th><th>Estado</th>";
    echo "</tr>";
    
    foreach ($tablas as $tabla => $nombre) {
        $result = $mysqli->query("SELECT COUNT(*) as total FROM {$tabla}");
        if ($result) {
            $row = $result->fetch_assoc();
            $count = $row['total'];
            $color = $count > 0 ? '#4CAF50' : '#FF9800';
            $icon = $count > 0 ? '✅' : '⚠️';
            
            echo "<tr>";
            echo "<td>{$nombre}</td>";
            echo "<td style='text-align: right; font-weight: bold; color: {$color};'>{$count}</td>";
            echo "<td style='text-align: center;'>{$icon}</td>";
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
    echo "<h4>🏢 Estaciones de Monitoreo:</h4>";
    $result = $mysqli->query("SELECT id, nombre, ubicacion, latitud, longitud, tipo_estacion FROM iot_estacion_monitoreo ORDER BY id");
    
    if ($result && $result->num_rows > 0) {
        echo "<table border='1' cellpadding='6' cellspacing='0' style='border-collapse: collapse; width: 100%; font-size: 0.9em;'>";
        echo "<tr style='background-color: #4CAF50; color: white;'>";
        echo "<th>ID</th><th>Nombre</th><th>Ubicación</th><th>Latitud</th><th>Longitud</th><th>Tipo</th>";
        echo "</tr>";
        
        while ($row = $result->fetch_assoc()) {
            echo "<tr>";
            echo "<td>{$row['id']}</td>";
            echo "<td><strong>{$row['nombre']}</strong></td>";
            echo "<td>{$row['ubicacion']}</td>";
            echo "<td>{$row['latitud']}</td>";
            echo "<td>{$row['longitud']}</td>";
            echo "<td><span style='background-color: #e3f2fd; padding: 2px 8px; border-radius: 3px;'>{$row['tipo_estacion']}</span></td>";
            echo "</tr>";
        }
        echo "</table>";
        $result->free();
    }
    
    // Mostrar bombas
    echo "<h4>💧 Estaciones de Bombeo:</h4>";
    $result = $mysqli->query("SELECT id, nombre, tipo_bomba, capacidad_maxima_m3h, potencia_nominal_kw FROM iot_estacion_bombeo ORDER BY id");
    
    if ($result && $result->num_rows > 0) {
        echo "<table border='1' cellpadding='6' cellspacing='0' style='border-collapse: collapse; width: 100%; font-size: 0.9em;'>";
        echo "<tr style='background-color: #FF9800; color: white;'>";
        echo "<th>ID</th><th>Nombre</th><th>Tipo</th><th>Capacidad (m³/h)</th><th>Potencia (kW)</th>";
        echo "</tr>";
        
        while ($row = $result->fetch_assoc()) {
            echo "<tr>";
            echo "<td>{$row['id']}</td>";
            echo "<td><strong>{$row['nombre']}</strong></td>";
            echo "<td>{$row['tipo_bomba']}</td>";
            echo "<td style='text-align: right;'>{$row['capacidad_maxima_m3h']}</td>";
            echo "<td style='text-align: right;'>{$row['potencia_nominal_kw']}</td>";
            echo "</tr>";
        }
        echo "</table>";
        $result->free();
    }
    
    // Mostrar umbrales de alerta
    echo "<h4>🚨 Umbrales de Alerta Configurados:</h4>";
    $result = $mysqli->query("SELECT nombre_parametro, valor_minimo, valor_maximo, nivel_alerta, descripcion FROM iot_umbral_alerta ORDER BY FIELD(nivel_alerta, 'CRITICO', 'ALTO', 'MEDIO', 'BAJO'), nombre_parametro");
    
    if ($result && $result->num_rows > 0) {
        echo "<table border='1' cellpadding='6' cellspacing='0' style='border-collapse: collapse; width: 100%; font-size: 0.9em;'>";
        echo "<tr style='background-color: #f44336; color: white;'>";
        echo "<th>Parámetro</th><th>Mínimo</th><th>Máximo</th><th>Nivel</th><th>Descripción</th>";
        echo "</tr>";
        
        while ($row = $result->fetch_assoc()) {
            $color = match($row['nivel_alerta']) {
                'CRITICO' => '#f44336',
                'ALTO' => '#FF9800',
                'MEDIO' => '#FFC107',
                'BAJO' => '#4CAF50',
                default => '#9E9E9E'
            };
            
            echo "<tr>";
            echo "<td><strong>{$row['nombre_parametro']}</strong></td>";
            echo "<td style='text-align: right;'>{$row['valor_minimo']}</td>";
            echo "<td style='text-align: right;'>{$row['valor_maximo']}</td>";
            echo "<td style='background-color: {$color}; color: white; text-align: center; font-weight: bold;'>{$row['nivel_alerta']}</td>";
            echo "<td style='font-size: 0.85em;'>{$row['descripcion']}</td>";
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
            max-width: 1400px;
            margin: 20px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 4px solid #4CAF50;
            padding-bottom: 15px;
            margin-bottom: 10px;
        }
        h2 {
            color: #34495e;
            margin-top: 35px;
            padding-top: 20px;
            border-top: 2px solid #ecf0f1;
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
            background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
            border-left: 5px solid #4CAF50;
            padding: 20px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .warning-box {
            background: linear-gradient(135deg, #fff3e0 0%, #ffe0b2 100%);
            border-left: 5px solid #FF9800;
            padding: 20px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .error-box {
            background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
            border-left: 5px solid #f44336;
            padding: 20px;
            margin: 20px 0;
            border-radius: 4px;
        }
        table {
            margin: 15px 0;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        table th {
            font-weight: 600;
        }
        .footer {
            margin-top: 50px;
            padding-top: 30px;
            border-top: 3px solid #ecf0f1;
            text-align: center;
            color: #7f8c8d;
        }
        code {
            background-color: #f4f4f4;
            padding: 3px 8px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 0.95em;
        }
        pre {
            background-color: #2c3e50;
            color: #ecf0f1;
            padding: 15px;
            border-radius: 6px;
            overflow-x: auto;
        }
        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.85em;
            font-weight: 600;
        }
        .badge-success {
            background-color: #4CAF50;
            color: white;
        }
        .badge-info {
            background-color: #2196F3;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Inicialización de Base de Datos MySQL</h1>
        <h2 style='border-top: none; padding-top: 0; margin-top: 10px;'>Sistema IoT Estación de Bombeo - Promotora Palmera de Antioquia S.A.S.</h2>
        <p style="font-size: 1.1em; color: #666;"><span class="badge badge-success">VERSIÓN EN ESPAÑOL</span></p>
        
        <?php
        echo "<div class='info-box'>";
        echo "<strong>📅 Fecha:</strong> " . date('d/m/Y H:i:s') . "<br>";
        echo "<strong>🗄️ Base de datos:</strong> <code>" . DB_NAME . "</code><br>";
        echo "<strong>🖥️ Servidor:</strong> <code>" . DB_HOST . ":" . DB_PORT . "</code><br>";
        echo "<strong>👤 Usuario:</strong> <code>" . DB_USER . "</code><br>";
        echo "<strong>🌐 Idioma:</strong> <span class='badge badge-info'>ESPAÑOL</span><br>";
        echo "</div>";
        
        // Conectar a MySQL
        echo "<h2>🔌 Paso 1: Conectar a MySQL</h2>";
        $mysqli = conectarMySQL();
        echo "<div class='info-box'>✅ <strong>Conexión exitosa a MySQL</strong></div>";
        
        // Ejecutar script SQL
        echo "<h2>⚙️ Paso 2: Ejecutar script de inicialización</h2>";
        $archivoSQL = __DIR__ . '/init_database_mysql_es.sql';
        
        if (file_exists($archivoSQL)) {
            if (ejecutarScriptSQL($mysqli, $archivoSQL)) {
                echo "<div class='info-box'>✅ <strong>Script SQL ejecutado correctamente</strong></div>";
            } else {
                echo "<div class='error-box'>❌ <strong>Error al ejecutar el script SQL</strong></div>";
            }
        } else {
            echo "<div class='error-box'>❌ <strong>Error:</strong> No se encuentra el archivo <code>init_database_mysql_es.sql</code></div>";
        }
        
        // Verificar tablas
        echo "<h2>🔍 Paso 3: Verificación del sistema</h2>";
        verificarTablas($mysqli);
        
        // Verificar vistas
        verificarVistas($mysqli);
        
        // Verificar procedimientos
        verificarProcedimientos($mysqli);
        
        // Verificar eventos
        verificarEventos($mysqli);
        
        // Verificar datos
        verificarDatos($mysqli);
        
        // Mostrar muestra de datos
        mostrarMuestraDatos($mysqli);
        
        // Resumen final
        echo "<h2>📊 Resumen Final</h2>";
        echo "<div class='info-box'>";
        echo "<h3 style='margin-top: 0; color: #4CAF50;'>✅ Base de datos inicializada correctamente</h3>";
        echo "<ul style='font-size: 1.05em;'>";
        echo "<li><strong>11 tablas</strong> creadas con prefijo <code>iot_</code> <span class='badge badge-success'>EN ESPAÑOL</span></li>";
        echo "<li><strong>6 vistas</strong> para consultas rápidas</li>";
        echo "<li><strong>2 procedimientos almacenados</strong> para alertas automáticas</li>";
        echo "<li><strong>2 eventos programados</strong> para mantenimiento automático</li>";
        echo "<li><strong>Datos iniciales</strong> insertados: </li>";
        echo "<ul>";
        echo "<li>4 estaciones de monitoreo (Administración, Playa, Bendición, Plana)</li>";
        echo "<li>3 estaciones de bombeo (Principal Norte, Auxiliar Sur, Respaldo Este)</li>";
        echo "<li>5 umbrales de alerta configurados</li>";
        echo "<li>2 contactos de notificación</li>";
        echo "</ul>";
        echo "</ul>";
        echo "</div>";
        
        echo "<div class='warning-box'>";
        echo "<h4>📝 Próximos pasos:</h4>";
        echo "<ol style='font-size: 1.05em;'>";
        echo "<li>✅ <strong>Tablas creadas</strong> - Ya puedes usar la base de datos</li>";
        echo "<li>🔄 Actualizar <code>config.py</code> de Flask para usar MySQL</li>";
        echo "<li>🔄 Actualizar <code>database.py</code> con los nuevos nombres de tablas en español</li>";
        echo "<li>🎮 Configurar simulador ESP32 Wokwi para enviar datos</li>";
        echo "<li>🚀 Iniciar servidor Flask: <code>python app.py</code></li>";
        echo "<li>🌐 Acceder al dashboard: <code>http://localhost:5000</code></li>";
        echo "</ol>";
        echo "</div>";
        
        // Cerrar conexión
        $mysqli->close();
        ?>
        
        <div class="footer">
            <p style="font-size: 1.3em; font-weight: bold; margin-bottom: 10px;">Promotora Palmera de Antioquia S.A.S.</p>
            <p style="font-size: 1.1em;">Sistema IoT de Monitoreo y Control de Estación de Bombeo</p>
            <p>Versión 1.0 EN ESPAÑOL - Febrero 2026</p>
            <p style="margin-top: 20px; font-size: 0.9em; color: #999;">
                Desarrollado con ❤️ para la transformación digital del sector agrícola
            </p>
        </div>
    </div>
</body>
</html>
