# ============================================================
# INSTALADOR DE BASE DE DATOS MySQL - VERSIÓN EN ESPAÑOL
# Sistema IoT Estación de Bombeo
# Promotora Palmera de Antioquia S.A.S.
# ============================================================

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  INSTALACIÓN BASE DE DATOS MySQL - VERSIÓN ESPAÑOL" -ForegroundColor Green
Write-Host "  Sistema IoT Estación de Bombeo" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar archivos necesarios
$archivoSQL = ".\init_database_mysql_es.sql"
$archivoPHP = ".\instalar_mysql_es.php"

if (-not (Test-Path $archivoSQL)) {
    Write-Host "❌ ERROR: No se encuentra el archivo $archivoSQL" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Archivo SQL encontrado: $archivoSQL" -ForegroundColor Green
Write-Host ""

# Mostrar opciones de instalación
Write-Host "OPCIONES DE INSTALACIÓN:" -ForegroundColor Yellow
Write-Host ""
Write-Host "[1] 🌐 Instalación WEB (Recomendado)" -ForegroundColor Cyan
Write-Host "    Abre el instalador en el navegador"
Write-Host "    URL: http://localhost/project_estacion_bombeo/instalar_mysql_es.php"
Write-Host ""
Write-Host "[2] 💻 Instalación por MySQL CLI" -ForegroundColor Cyan
Write-Host "    Ejecuta el script SQL directamente usando MySQL command line"
Write-Host ""
Write-Host "[3] 📋 Ver instrucciones manuales" -ForegroundColor Cyan
Write-Host "    Muestra las instrucciones para phpMyAdmin u otras herramientas"
Write-Host ""
Write-Host "[4] ❌ Cancelar" -ForegroundColor Red
Write-Host ""

$opcion = Read-Host "Selecciona una opción (1-4)"

switch ($opcion) {
    "1" {
        Write-Host ""
        Write-Host "🌐 Abriendo instalador web..." -ForegroundColor Green
        Write-Host ""
        
        # Intentar abrir en el navegador
        try {
            Start-Process "http://localhost/project_estacion_bombeo/instalar_mysql_es.php"
            Write-Host "✅ Navegador abierto correctamente" -ForegroundColor Green
            Write-Host ""
            Write-Host "📌 Si el navegador no se abre automáticamente, copia esta URL:" -ForegroundColor Yellow
            Write-Host "   http://localhost/project_estacion_bombeo/instalar_mysql_es.php" -ForegroundColor Cyan
        }
        catch {
            Write-Host "⚠️ No se pudo abrir el navegador automáticamente" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Por favor, abre manualmente esta URL en tu navegador:" -ForegroundColor Yellow
            Write-Host "http://localhost/project_estacion_bombeo/instalar_mysql_es.php" -ForegroundColor Cyan
        }
        
        Write-Host ""
        Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    
    "2" {
        Write-Host ""
        Write-Host "💻 Instalación por MySQL CLI..." -ForegroundColor Green
        Write-Host ""
        
        # Buscar MySQL
        $mysqlPaths = @(
            "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
            "C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql.exe",
            "C:\xampp\mysql\bin\mysql.exe",
            "C:\wamp64\bin\mysql\mysql8.0.27\bin\mysql.exe",
            "C:\wamp\bin\mysql\mysql5.7.24\bin\mysql.exe"
        )
        
        $mysqlPath = $null
        foreach ($path in $mysqlPaths) {
            if (Test-Path $path) {
                $mysqlPath = $path
                break
            }
        }
        
        if ($mysqlPath) {
            Write-Host "✅ MySQL encontrado en: $mysqlPath" -ForegroundColor Green
            Write-Host ""
            Write-Host "Ejecutando script SQL..." -ForegroundColor Yellow
            Write-Host ""
            
            # Solicitar credenciales
            $usuario = Read-Host "Usuario MySQL (por defecto: root)"
            if ([string]::IsNullOrWhiteSpace($usuario)) {
                $usuario = "root"
            }
            
            $password = Read-Host "Contraseña MySQL (Enter si no tiene)" -AsSecureString
            $passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
            )
            
            # Construir comando
            if ([string]::IsNullOrWhiteSpace($passwordPlain)) {
                & $mysqlPath -u $usuario promotorapalmera_db < $archivoSQL
            } else {
                & $mysqlPath -u $usuario -p$passwordPlain promotorapalmera_db < $archivoSQL
            }
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "✅ ¡Instalación completada exitosamente!" -ForegroundColor Green
            } else {
                Write-Host ""
                Write-Host "❌ Error durante la instalación. Código de salida: $LASTEXITCODE" -ForegroundColor Red
            }
        }
        else {
            Write-Host "❌ No se encontró MySQL en las rutas comunes" -ForegroundColor Red
            Write-Host ""
            Write-Host "Por favor, ejecuta manualmente:" -ForegroundColor Yellow
            Write-Host 'mysql -u root -p promotorapalmera_db < init_database_mysql_es.sql' -ForegroundColor Cyan
        }
        
        Write-Host ""
        Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    
    "3" {
        Write-Host ""
        Write-Host "========================================================" -ForegroundColor Cyan
        Write-Host "  INSTRUCCIONES MANUALES DE INSTALACIÓN" -ForegroundColor Yellow
        Write-Host "========================================================" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "📋 OPCIÓN A - phpMyAdmin:" -ForegroundColor Green
        Write-Host ""
        Write-Host "1. Accede a phpMyAdmin (http://localhost/phpmyadmin)" -ForegroundColor Gray
        Write-Host "2. Selecciona la base de datos 'promotorapalmera_db'" -ForegroundColor Gray
        Write-Host "3. Ve a la pestaña 'SQL'" -ForegroundColor Gray
        Write-Host "4. Copia el contenido del archivo:" -ForegroundColor Gray
        Write-Host "   $archivoSQL" -ForegroundColor Cyan
        Write-Host "5. Pégalo en el área de texto" -ForegroundColor Gray
        Write-Host "6. Haz clic en 'Continuar'" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "📋 OPCIÓN B - MySQL Workbench:" -ForegroundColor Green
        Write-Host ""
        Write-Host "1. Abre MySQL Workbench" -ForegroundColor Gray
        Write-Host "2. Conecta a tu servidor MySQL" -ForegroundColor Gray
        Write-Host "3. Abre el archivo:" -ForegroundColor Gray
        Write-Host "   $archivoSQL" -ForegroundColor Cyan
        Write-Host "4. Ejecuta el script (icono de rayo o Ctrl+Shift+Enter)" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "📋 OPCIÓN C - Línea de comandos MySQL:" -ForegroundColor Green
        Write-Host ""
        Write-Host 'mysql -u root -p promotorapalmera_db < init_database_mysql_es.sql' -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "📋 OPCIÓN D - Navegador web (PHP):" -ForegroundColor Green
        Write-Host ""
        Write-Host "http://localhost/project_estacion_bombeo/instalar_mysql_es.php" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "========================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    
    "4" {
        Write-Host ""
        Write-Host "❌ Instalación cancelada" -ForegroundColor Yellow
        Write-Host ""
        exit 0
    }
    
    default {
        Write-Host ""
        Write-Host "❌ Opción no válida" -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  RESUMEN DE TABLAS CREADAS" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ 11 TABLAS (prefijo: iot_):" -ForegroundColor Yellow
Write-Host "   1. iot_estacion_monitoreo" -ForegroundColor Gray
Write-Host "   2. iot_estacion_bombeo" -ForegroundColor Gray
Write-Host "   3. iot_datos_meteorologicos" -ForegroundColor Gray
Write-Host "   4. iot_telemetria_bomba" -ForegroundColor Gray
Write-Host "   5. iot_nivel_agua" -ForegroundColor Gray
Write-Host "   6. iot_estado_compuerta" -ForegroundColor Gray
Write-Host "   7. iot_alerta_sistema" -ForegroundColor Gray
Write-Host "   8. iot_umbral_alerta" -ForegroundColor Gray
Write-Host "   9. iot_log_control_automatico" -ForegroundColor Gray
Write-Host "  10. iot_contacto_notificacion" -ForegroundColor Gray
Write-Host "  11. iot_resumen_flujo" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ 6 VISTAS:" -ForegroundColor Yellow
Write-Host "   - v_iot_ultima_meteorologia" -ForegroundColor Gray
Write-Host "   - v_iot_estado_bombas" -ForegroundColor Gray
Write-Host "   - v_iot_alertas_activas" -ForegroundColor Gray
Write-Host "   - v_iot_resumen_mensual" -ForegroundColor Gray
Write-Host "   - v_iot_nivel_agua_actual" -ForegroundColor Gray
Write-Host "   - v_iot_historial_control" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ 2 PROCEDIMIENTOS ALMACENADOS:" -ForegroundColor Yellow
Write-Host "   - sp_verificar_crear_alerta" -ForegroundColor Gray
Write-Host "   - sp_insertar_telemetria_bomba" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ 2 EVENTOS PROGRAMADOS:" -ForegroundColor Yellow
Write-Host "   - evt_limpiar_telemetria_antigua" -ForegroundColor Gray
Write-Host "   - evt_generar_resumen_diario" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ DATOS INICIALES:" -ForegroundColor Yellow
Write-Host "   - 4 Estaciones de Monitoreo" -ForegroundColor Gray
Write-Host "   - 3 Estaciones de Bombeo" -ForegroundColor Gray
Write-Host "   - 5 Umbrales de Alerta" -ForegroundColor Gray
Write-Host "   - 2 Contactos de Notificación" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 PRÓXIMOS PASOS:" -ForegroundColor Green
Write-Host ""
Write-Host "1. Verificar que las tablas se crearon correctamente" -ForegroundColor Gray
Write-Host "2. Actualizar config.py para usar MySQL" -ForegroundColor Gray
Write-Host "3. Actualizar database.py con nombres en español" -ForegroundColor Gray
Write-Host "4. Configurar simulador Wokwi" -ForegroundColor Gray
Write-Host "5. Iniciar servidor Flask: python app.py" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
