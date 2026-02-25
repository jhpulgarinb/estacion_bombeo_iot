# Script de instalación MySQL - Sistema IoT Bombeo
# Ejecuta el archivo SQL directamente en MySQL

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  INSTALACIÓN MYSQL - SISTEMA IOT BOMBEO" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

$sqlFile = "init_database_mysql_es.sql"
$dbName = "promotorapalmera_db"
$dbUser = "root"
$dbPass = ""
$dbHost = "localhost"

# Verificar que existe el archivo SQL
if (!(Test-Path $sqlFile)) {
    Write-Host "❌ ERROR: No se encuentra el archivo $sqlFile" -ForegroundColor Red
    exit 1
}

Write-Host "📄 Archivo SQL: $sqlFile" -ForegroundColor Green
Write-Host "🗄️  Base de datos: $dbName" -ForegroundColor Green
Write-Host "👤 Usuario: $dbUser" -ForegroundColor Green
Write-Host ""

# Buscar MySQL
$mysqlPaths = @(
    "C:\xampp\mysql\bin\mysql.exe",
    "C:\wamp64\bin\mysql\mysql*\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server *\bin\mysql.exe",
    "C:\mysql\bin\mysql.exe"
)

$mysqlExe = $null
foreach ($path in $mysqlPaths) {
    $found = Get-Item $path -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $mysqlExe = $found.FullName
        break
    }
}

if ($null -eq $mysqlExe) {
    Write-Host "⚠️  No se encontró MySQL en rutas comunes" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "ALTERNATIVA: Usar PHP para ejecutar el SQL" -ForegroundColor Cyan
    Write-Host ""
    
    # Crear script PHP temporal
    $phpScript = @"
<?php
`$mysqli = new mysqli('$dbHost', '$dbUser', '$dbPass', '$dbName');

if (`$mysqli->connect_error) {
    die('Error de conexión: ' . `$mysqli->connect_error);
}

`$mysqli->set_charset('utf8mb4');

echo "✅ Conectado a MySQL\n";
echo "📂 Leyendo archivo SQL...\n";

`$sql = file_get_contents('$sqlFile');
if (!`$sql) {
    die("❌ Error leyendo archivo SQL\n");
}

// Dividir y ejecutar
`$statements = array_filter(array_map('trim', explode(';', `$sql)));
`$success = 0;
`$errors = 0;

foreach (`$statements as `$statement) {
    if (empty(`$statement) || strpos(`$statement, '--') === 0 || strpos(`$statement, 'DELIMITER') !== false) {
        continue;
    }
    
    if (`$mysqli->multi_query(`$statement . ';')) {
        do {
            if (`$result = `$mysqli->store_result()) {
                `$result->free();
            }
        } while (`$mysqli->next_result());
        `$success++;
    } else {
        `$error = `$mysqli->error;
        if (strpos(`$error, 'already exists') === false && strpos(`$error, 'duplicate') === false) {
            echo "⚠️  " . substr(`$statement, 0, 50) . "... - " . `$error . "\n";
            `$errors++;
        }
    }
}

echo "\n";
echo "✅ Comandos ejecutados: `$success\n";
echo "⚠️  Errores: `$errors\n";
echo "\n";

// Verificar tablas creadas
`$result = `$mysqli->query("SHOW TABLES LIKE 'iot_%'");
echo "📊 Tablas creadas: " . `$result->num_rows . "\n";

while (`$row = `$result->fetch_array()) {
    echo "  ✓ " . `$row[0] . "\n";
}

`$mysqli->close();
echo "\n✅ INSTALACIÓN COMPLETADA\n";
?>
"@

    $phpScript | Out-File -FilePath "temp_install.php" -Encoding UTF8
    
    Write-Host "🚀 Ejecutando instalación con PHP..." -ForegroundColor Green
    Write-Host ""
    
    php temp_install.php
    
    Remove-Item "temp_install.php" -ErrorAction SilentlyContinue
    
} else {
    Write-Host "✅ MySQL encontrado: $mysqlExe" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Ejecutando instalación..." -ForegroundColor Green
    Write-Host ""
    
    if ($dbPass -eq "") {
        & $mysqlExe -u $dbUser $dbName -e "source $sqlFile"
    } else {
        & $mysqlExe -u $dbUser -p$dbPass $dbName -e "source $sqlFile"
    }
    
    Write-Host ""
    Write-Host "✅ Instalación completada" -ForegroundColor Green
}

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  Ejecutando verificación..." -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

php verificar_mysql.php

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  PRÓXIMOS PASOS" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Instalar pymysql:" -ForegroundColor Yellow
Write-Host "   pip install pymysql" -ForegroundColor White
Write-Host ""
Write-Host "2. Ejecutar Flask:" -ForegroundColor Yellow
Write-Host "   python app.py" -ForegroundColor White
Write-Host ""
Write-Host "3. Abrir dashboard:" -ForegroundColor Yellow
Write-Host "   http://localhost:5000" -ForegroundColor White
Write-Host ""
