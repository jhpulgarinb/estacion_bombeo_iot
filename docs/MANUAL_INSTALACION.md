# Manual de Instalación - Sistema de Monitoreo de Estaciones de Bombeo

## Tabla de Contenidos
1. [Requisitos del Sistema](#requisitos-del-sistema)
2. [Instalación Automática](#instalación-automática)
3. [Instalación Manual](#instalación-manual)
4. [Configuración de Base de Datos](#configuración-de-base-de-datos)
5. [Verificación de Instalación](#verificación-de-instalación)
6. [Solución de Problemas](#solución-de-problemas)

## Requisitos del Sistema

### Hardware Mínimo
- **Procesador:** Intel i3 o AMD equivalente
- **Memoria RAM:** 4 GB mínimo, 8 GB recomendado
- **Almacenamiento:** 2 GB de espacio libre
- **Red:** Conexión a Internet para descargas iniciales

### Software Requerido
- **Sistema Operativo:** Windows 10/11 (64-bit)
- **Python:** Versión 3.8 o superior
- **PostgreSQL:** Versión 12 o superior
- **Navegador Web:** Chrome, Firefox, Safari o Edge actualizado

## Instalación Automática

### Opción 1: Instalación Rápida (Recomendada)

1. **Descargar el Sistema**
   - Extraiga todos los archivos en una carpeta (ej: `C:\EstacionBombeo`)

2. **Ejecutar Instalador Automático**
   ```powershell
   # Abrir PowerShell como Administrador
   # Navegar a la carpeta del sistema
   cd "C:\EstacionBombeo"
   
   # Ejecutar instalador
   .\instalar_sistema.ps1
   ```

3. **Seguir las Instrucciones en Pantalla**
   - El instalador verificará Python
   - Creará un entorno virtual
   - Instalará dependencias automáticamente
   - Configurará la base de datos (opcional)

4. **Iniciar la Aplicación**
   ```powershell
   .\iniciar_aplicacion.ps1
   ```

## Instalación Manual

### Paso 1: Instalar Python

1. Descargar Python desde: https://www.python.org/downloads/
2. Ejecutar el instalador
3. **IMPORTANTE:** Marcar "Add Python to PATH"
4. Verificar instalación:
   ```powershell
   python --version
   pip --version
   ```

### Paso 2: Instalar PostgreSQL

1. Descargar desde: https://www.postgresql.org/download/windows/
2. Ejecutar instalador
3. Configurar usuario `postgres` con contraseña
4. Recordar el puerto (por defecto 5432)

### Paso 3: Preparar Entorno Python

```powershell
# Crear entorno virtual
python -m venv venv

# Activar entorno virtual
.\venv\Scripts\Activate.ps1

# Actualizar pip
python -m pip install --upgrade pip

# Instalar dependencias
pip install -r requirements.txt
```

### Paso 4: Configurar Base de Datos

```powershell
# Ejecutar script de configuración
.\setup_database.ps1
```

O manualmente:
```sql
-- Conectarse a PostgreSQL como administrador
CREATE USER usuario WITH ENCRYPTED PASSWORD 'password';
CREATE DATABASE monitoring_db OWNER usuario;
GRANT ALL PRIVILEGES ON DATABASE monitoring_db TO usuario;

-- Ejecutar esquema
\c monitoring_db
\i bd-estacion-bombeo.sql
```

## Configuración de Base de Datos

### Configuración Automática
El script `setup_database.ps1` realizará automáticamente:
- Creación del usuario de base de datos
- Creación de la base de datos `monitoring_db`
- Ejecución del esquema SQL
- Actualización del archivo `config.py`

### Configuración Manual

1. **Editar config.py**
   ```python
   import os

   BASE_DIR = os.path.abspath(os.path.dirname(__file__))
   SQLALCHEMY_DATABASE_URI = 'postgresql://usuario:password@localhost:5432/monitoring_db'
   SQLALCHEMY_TRACK_MODIFICATIONS = False
   SECRET_KEY = 'clave-secreta-única'
   ```

2. **Crear Tablas**
   ```python
   # Desde Python
   from app import app, db
   with app.app_context():
       db.create_all()
   ```

## Verificación de Instalación

### 1. Verificar Servicios
```powershell
# Verificar Python
python --version

# Verificar PostgreSQL
psql --version

# Verificar conexión a BD
psql -h localhost -U usuario -d monitoring_db
```

### 2. Ejecutar Pruebas

```powershell
# Activar entorno virtual
.\venv\Scripts\Activate.ps1

# Iniciar aplicación en modo debug
python app.py
```

### 3. Probar Interface Web
1. Abrir navegador en: http://localhost:5000
2. Verificar que el dashboard carga correctamente
3. Probar selector de estaciones
4. Verificar que los gráficos se renderizan

## Estructura de Archivos Final

```
project_estacion_bombeo/
├── venv/                    # Entorno virtual Python
├── docs/                    # Documentación
│   ├── MANUAL_INSTALACION.md
│   ├── MANUAL_USUARIO.md
│   └── MANUAL_TECNICO.md
├── app.py                   # Aplicación Flask
├── database.py              # Modelos de datos
├── config.py                # Configuración
├── calculations.py          # Cálculos hidráulicos
├── index.html               # Dashboard web
├── styles.css               # Estilos CSS
├── script.js                # JavaScript frontend
├── bd-estacion-bombeo.sql   # Esquema base de datos
├── requirements.txt         # Dependencias Python
├── instalar_sistema.ps1     # Instalador automático
├── setup_database.ps1       # Configurador de BD
└── iniciar_aplicacion.ps1   # Script de inicio
```

## Solución de Problemas

### Error: "Python no reconocido"
**Causa:** Python no está en PATH
**Solución:** 
1. Reinstalar Python marcando "Add to PATH"
2. O agregar manualmente Python al PATH del sistema

### Error: "No se puede conectar a PostgreSQL"
**Causa:** PostgreSQL no está ejecutándose o configuración incorrecta
**Solución:**
1. Verificar que PostgreSQL está ejecutándose:
   ```powershell
   net start postgresql-x64-13
   ```
2. Verificar configuración en `config.py`
3. Verificar credenciales y puerto

### Error: "Módulo no encontrado"
**Causa:** Dependencias no instaladas o entorno virtual no activado
**Solución:**
```powershell
# Activar entorno virtual
.\venv\Scripts\Activate.ps1

# Reinstalar dependencias
pip install -r requirements.txt
```

### Error: "Puerto 5000 en uso"
**Causa:** Otro servicio usa el puerto 5000
**Solución:**
1. Cambiar puerto en `app.py`:
   ```python
   app.run(host='0.0.0.0', port=5001, debug=True)
   ```
2. O detener el servicio que usa el puerto

### Dashboard no carga datos
**Causa:** Base de datos vacía o error de conexión
**Solución:**
1. Verificar conexión a base de datos
2. Inicializar datos de ejemplo:
   ```powershell
   curl -X POST http://localhost:5000/api/init-db
   ```

## Contacto y Soporte

Para problemas adicionales:
1. Verificar logs de la aplicación
2. Revisar documentación técnica completa
3. Contactar al administrador del sistema

---

**Nota:** Este manual asume una instalación estándar en Windows. Para otros sistemas operativos, adapte los comandos según corresponda.
