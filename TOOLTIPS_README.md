# 🎯 Sistema de Tooltips Flotantes - Documentación

## ✅ Estado Actual

El sistema de tooltips flotantes está completamente configurado y operativo con:

- ✓ **33 tooltips** en index.html, todos con contenido válido
- ✓ **Sistema JavaScript** avanzado en `tooltip-system.js`
- ✓ **CSS optimizado** sin conflictos con los tooltips antiguos
- ✓ **Pruebas incluidas** en `test-tooltips.html`

---

## 📋 ¿Qué se cambió?

### 1. Nuevo Archivo: `tooltip-system.js`

Sistema completo de gestión de tooltips con:

- **Auto-descubrimiento**: Encuentra automáticamente todos los elementos con `data-tooltip`
- **Posicionamiento inteligente**: Calcula la mejor posición (top, bottom, left, right)
- **Validación**: Detecta tooltips vacíos y reporta en consola
- **Estilos por tipo**: Colores diferentes para info, warning, critical, success
- **Manejo de eventos**: Mouse, keyboard (Escape), scroll, focus/blur
- **Animaciones suave**: Fade-in con easing cubic-bezier

### 2. index.html - Cambios

Se agregó la línea:
```html
<script src="tooltip-system.js"></script>
```

En la sección `<head>` ANTES de otros scripts para que se cargue primero.

### 3. styles.css - Cambios

Se deshabilitaron los estilos CSS antiguos de tooltips (que usaban `::before` y `::after`) 
para evitar conflictos con el sistema JavaScript:

```css
[data-tooltip]::before,
[data-tooltip]::after {
    display: none !important;
}
```

---

## 🎨 Tipos de Tooltips

Cada tooltip puede tener un tipo que determina su color:

| Tipo | Color | Casos de Uso | Ejemplo |
|------|-------|------------|---------|
| `info` | Azul (#3498db) | Información general | Explicar qué es una métrica |
| `warning` | Naranja (#f39c12) | Advertencias | "Temperatura >75°C" |
| `critical` | Rojo (#e74c3c) | Errores graves | "Fallo del sistema" |
| `success` | Verde (#27ae60) | Estado positivo | "Sistema normal" |

### Ejemplo de HTML:

```html
<!-- Info (azul) -->
<div class="card" data-tooltip="Esto es información" data-tooltip-type="info">
    Tarjeta
</div>

<!-- Warning (naranja) -->
<button data-tooltip="¡Cuidado!" data-tooltip-type="warning">
    Acción
</button>

<!-- Critical (rojo) -->
<span data-tooltip="Error grave" data-tooltip-type="critical">
    ⚠️
</span>
```

---

## 📍 Posiciones de Tooltips

Se pueden posicionar en 4 direcciones:

```html
<!-- Arriba (default) -->
<div data-tooltip="..." data-tooltip-position="top">

<!-- Abajo -->
<div data-tooltip="..." data-tooltip-position="bottom">

<!-- Izquierda -->
<div data-tooltip="..." data-tooltip-position="left">

<!-- Derecha -->
<div data-tooltip="..." data-tooltip-position="right">
```

---

## 🔧 API JavaScript

Si necesitas interactuar con los tooltips desde JavaScript:

```javascript
// El sistema se inicializa automáticamente en window.tooltipSystem

// Validar todos los tooltips
window.tooltipSystem.validateAll();

// Actualizar el texto de un tooltip
window.tooltipSystem.updateTooltip('.selector', 'Nuevo texto');

// Acceder a todos los tooltips
window.tooltipSystem.tooltips  // Map de todos los tooltips

// Ver el tooltip más reciente
window.tooltipSystem.activeTooltip  // ID del tooltip activo
```

---

## 📊 Tooltips en index.html

Actualmente hay 33 tooltips distribuidos en:

### Tarjetas de Estado (4)
- Estado de Compuerta
- Nivel de Agua
- Caudal Actual
- Volumen Diario

### Meteorología (5)
- Título de sección
- Precipitación
- Viento
- Temperatura/Humedad
- Presión Atmosférica/Radiación Solar

### Control Automático (8)
- Título de sección
- Control Mode Toggle
- Stop System Button
- Pump Control Card
- Métricas de bomba (6: caudal, presión entrada, presión salida, temperatura, consumo, horas)

### Botones de Control (2)
- Start Pump
- Stop Pump

### Logs y Alertas (5)
- Decision Log
- Alert Title
- Critical Count
- High Count
- Medium Count

### Gráficos (7)
- Caudal (flow)
- Nivel de Agua
- Apertura de Compuertas
- Precipitación
- Velocidad de Viento
- Temperatura
- Presión Atmosférica

---

## 🧪 Pruebas

### Test Visual (Recomendado)

1. Abre http://localhost:9000 en tu navegador
2. Pasa el cursor sobre cualquier elemento
3. Deberías ver un tooltip flotante azul
4. Verifica diferentes posiciones (arriba, abajo, izquierda, derecha)
5. Prueba elementos con diferentes tipos (info, warning, critical)

### Test Automatizado

```bash
python verify_tooltips.py
```

Esto genera un reporte completo con:
- Verificación de archivos
- Conteo de tooltips
- Detección de tooltips vacíos
- Validación del CSS
- Estado general del sistema

### Test de Consola Interactivo

Abre http://localhost:9000/test-tooltips.html para una página de prueba con:
- 4 elementos de prueba (info, warning, critical, success)
- Botones para validar y contar tooltips
- Log en tiempo real de eventos

---

## 🐛 Solución de Problemas

### Los tooltips no aparecen

1. **Verificar consola del navegador** (F12) para errores de JS
2. **Confirmar que tooltip-system.js está siendo cargado** (Tab Network)
3. **Actualizar caché** (Ctrl+Shift+Delete)
4. **Verificar que el elemento tenga `data-tooltip="..."`** (no vacío)

### Los tooltips muestran texto vacío

```bash
python audit_tooltips.py
```

Esto identificará qué tooltips están vacíos.

### Los tooltips aparecen pero desaparecen rápidamente

Es normal después de 100ms cuando sacas el cursor. Si querés mantenerlos más tiempo,
edita en `tooltip-system.js`:

```javascript
this.hideDelay = 100; // Aumenta este valor
```

### Los tooltips se superponen con otros elementos

El sistema usa `z-index: 10001` para asegurar que estén siempre adelante.
Si hay conflictos, verifica otros elementos con z-index muy alto.

---

## 📈 Próximas Mejoras Sugeridas

1. **Tooltips persistentes** - Opción para que se queden visibles con un click
2. **Animaciones personalizadas** - Diferentes estilos de entrada/salida
3. **Tooltips con contenido HTML** - Permitir HTML dentro de tooltips
4. **Temas personalizables** - Sistema de temas light/dark
5. **Gestión de teclado mejorada** - Tab para navegar y mostrar tooltips
6. **Analytics** - Rastrear qué tooltips se usan más

---

## 📝 Resumen Técnico

| Componente | Archivo | Tamaño | Descripción |
|-----------|---------|--------|------------|
| Sistema | `tooltip-system.js` | 11 KB | Motor JavaScript |
| Markup | `index.html` | 24 KB | 33 tooltips integrados |
| Estilos | `styles.css` | 17 KB | CSS adaptado (deshabilitó antiguos) |
| Test | `test-tooltips.html` | 5 KB | Página de prueba interactiva |
| Auditoría | `audit_tooltips.py` | 2 KB | Script de validación |
| Verificación | `verify_tooltips.py` | 4 KB | Reporte de integridad |

**Total de código nuevo: ~23 KB**

---

## ✨ Características Implementadas

✓ Auto-inicialización al cargar la página
✓ Descubrimiento automático de elementos
✓ Posicionamiento inteligente (4 direcciones)
✓ Validación de contenido
✓ Colores por tipo
✓ Animaciones suaves
✓ Gestión de eventos (mouse, keyboard, scroll)
✓ Responsivo (adapta al tamaño de ventana)
✓ Sin dependencias externas
✓ Console logging para debug

---

## 🎉 ¡Listo!

El sistema está completamente operativo. Para cualquier ajuste, puedes:

1. Modificar texto de tooltips directamente en HTML
2. Cambiar tipos (info/warning/critical/success)
3. Cambiar posiciones (top/bottom/left/right)
4. Editar colores en `tooltip-system.js` (objeto `typeColors`)
5. Ajustar tiempos de show/hide delay

¡Que lo disfrutes! 🚀
