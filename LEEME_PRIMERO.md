# 🌊 SISTEMA DE MONITOREO DE ESTACIONES DE BOMBEO

## 🚀 INICIO RÁPIDO - UN SOLO CLIC

### 💥 **FORMA MÁS FÁCIL** - Sistema Completo Automatizado

```powershell
.\INICIAR.ps1
```

**¡Eso es todo!** El script hará todo automáticamente:
- ✅ Verifica Python y dependencias
- ✅ Instala lo que falta
- ✅ Inicia simulador de datos
- ✅ Inicia aplicación web
- ✅ Abre el navegador automáticamente
- ✅ Muestra estado en tiempo real

---

## 🎛️ OPCIONES AVANZADAS

### Solo Simulador de Datos
```powershell
.\INICIAR.ps1 -SoloSimulador
```

### Solo Aplicación Web
```powershell
.\INICIAR.ps1 -SoloApp
```

### Sin abrir navegador automáticamente
```powershell
.\INICIAR.ps1 -NoAbrir
```

---

## 🌐 URLs DEL SISTEMA

Una vez iniciado, accede a:

- **📊 Dashboard Principal:** http://localhost:5000
- **📈 Simulador de Datos:** http://localhost:5001/api/simulator/status  
- **📚 Documentación:** http://localhost:5000/docs

---

## 🎯 CARACTERÍSTICAS DEL SISTEMA

### 🏭 **Monitoreo en Tiempo Real**
- **4 estaciones de bombeo** con datos independientes
- **10 tipos de sensores** (temperatura, pH, turbidez, presión, etc.)
- **Gráficos dinámicos** con Chart.js
- **Alertas automáticas** para condiciones anómalas

### 📊 **Simulador Inteligente**
- **Patrones diarios realistas** (más actividad de día)
- **Cálculos hidráulicos precisos** (ecuaciones de vertedero)
- **Variaciones climáticas** simuladas
- **Estados de compuertas** lógicos y coherentes
- **Actualización automática** cada 5 segundos

### 🎨 **Dashboard Avanzado**
- **Interfaz moderna** y responsiva
- **Indicadores visuales** (medidores, barras de progreso)
- **Cambio automático** entre datos reales y simulados
- **Sensores virtuales** con iconos específicos
- **Estadísticas en tiempo real**

---

## 🔧 SOLUCIÓN DE PROBLEMAS

### ❌ **Error: Python no encontrado**
1. Instala Python desde https://python.org
2. Durante la instalación, marca "Add Python to PATH"
3. Reinicia PowerShell
4. Ejecuta `.\INICIAR.ps1` otra vez

### ❌ **Error: Puerto en uso**
1. El script detectará automáticamente
2. Te preguntará si quieres terminar los procesos
3. Responde "y" para aceptar
4. O cierra manualmente las aplicaciones que usan los puertos 5000/5001

### ❌ **Error: Permisos**
1. Haz clic derecho en PowerShell
2. Selecciona "Ejecutar como administrador"
3. Navega al directorio del proyecto
4. Ejecuta `.\INICIAR.ps1`

### ❌ **Error: Scripts deshabilitados**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📁 ESTRUCTURA DEL PROYECTO

```
📁 project_estacion_bombeo/
├── 🚀 INICIAR.ps1                    # ← EJECUTA ESTE ARCHIVO
├── 📖 LEEME_PRIMERO.md               # ← Este archivo
├── 🏭 app.py                         # Aplicación Flask principal
├── 🔬 data_simulator.py              # Simulador de datos virtuales  
├── 💾 database.py                    # Modelos de base de datos
├── 🌐 index.html                     # Dashboard web
├── ⚡ script.js                      # Lógica del dashboard
├── 🎨 styles.css                     # Estilos del dashboard
├── 📊 calculations.py                # Cálculos hidráulicos
├── 📚 docs/                          # Documentación técnica
├── 🔧 requirements.txt               # Dependencias Python
└── 📋 README_*.md                    # Documentación adicional
```

---

## 🎮 GUÍA DE USO

### 1. **Inicio del Sistema**
```powershell
.\INICIAR.ps1
```

### 2. **Verificar que Todo Funciona**
El script mostrará:
```
🟢 Simulador: EJECUTÁNDOSE
🟢 Aplicación: EJECUTÁNDOSE
```

### 3. **Acceder al Dashboard**
- Se abre automáticamente en el navegador
- O ve a: http://localhost:5000

### 4. **Explorar Funciones**
- **Gráficos interactivos** - Muestra datos históricos
- **Sensores virtuales** - Panel lateral con 10 sensores
- **Cambio de estación** - Selector en la parte superior
- **Rango de tiempo** - Últimas 6, 12, 24 horas
- **Alertas en tiempo real** - Panel de notificaciones

### 5. **Detener el Sistema**
- Presiona `Ctrl+C` en la consola
- O cierra la ventana de PowerShell

---

## 💡 CONSEJOS Y TRUCOS

### 🔍 **Ver Solo el Simulador**
```powershell
.\INICIAR.ps1 -SoloSimulador
```
Útil para verificar que los datos se generan correctamente.

### 🌐 **Verificar APIs**
- Status del simulador: http://localhost:5001/api/simulator/status
- Datos de estación: http://localhost:5001/api/simulator/dashboard?station_id=1

### 📱 **Dashboard Responsivo**
El dashboard funciona en móviles y tablets. Abre la URL desde cualquier dispositivo en tu red local.

### 🔄 **Datos en Tiempo Real**
Los gráficos se actualizan automáticamente cada 30 segundos. Usa el botón "🔄 Actualizar" para refrescar manualmente.

### 🎯 **Personalizar Simulador**
Edita `data_simulator.py` para:
- Cambiar rangos de sensores
- Agregar nuevas estaciones  
- Modificar patrones de datos
- Ajustar frecuencia de actualización

---

## 🆘 SOPORTE

Si tienes problemas:

1. **🔧 Ejecuta el diagnosticador automático:**
   ```powershell
   .\INICIAR.ps1
   ```
   El script detectará y reportará la mayoría de problemas

2. **📋 Revisa los logs:**
   Los errores aparecen en la consola con colores y emojis

3. **🔄 Reinicia limpio:**
   - Cierra todas las ventanas de PowerShell
   - Abre una nueva como administrador
   - Ejecuta `.\INICIAR.ps1` otra vez

4. **📚 Consulta documentación:**
   - `README_SIMULADOR.md` - Info del simulador
   - `README_COMPLETO.md` - Documentación técnica
   - `docs/` - Manuales detallados

---

## 🎉 ¡DISFRUTA EL SISTEMA!

El sistema está diseñado para **funcionar inmediatamente** sin configuración compleja. 

**¡Solo ejecuta `.\INICIAR.ps1` y tendrás un sistema completo de monitoreo de estaciones de bombeo con datos realistas!**

---

> 💡 **Tip:** Para producción real, reemplaza el simulador con tus sensores IoT reales. El sistema está preparado para ambos casos.
