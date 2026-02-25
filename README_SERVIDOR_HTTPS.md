# Guía Rápida - Servidor HTTPS para Consulta de Planillas

## 📋 Resumen

Se ha configurado un servidor HTTPS para solucionar el problema de acceso desde celulares que fuerzan conexiones seguras.

## 🔧 Configuración Actual

### Puertos Activos:
- **Puerto 8082**: HTTPS (Python) - **PRINCIPAL PARA MÓVILES**
- **Puerto 8081**: HTTP (IIS) - Alternativo desde PC
- **Puerto 8080**: HTTP (Python) - Alternativo

### URLs de Acceso:
```
HTTPS (Recomendado para móviles):
https://www.ppasas.com:8082/uploads/nomina/consulta_planilla_publica.html

HTTP tradicional (PC):
http://www.ppasas.com:8081/uploads/nomina/consulta_planilla_publica.html
```

## 🚀 Iniciar Servidor

### Opción 1: Inicio Manual
```powershell
cd "c:\inetpub\promotorapalmera\project_estacion_bombeo"
.\INICIAR_HTTPS_8081.ps1
```

### Opción 2: Monitor Automático (Recomendado)
```powershell
cd "c:\inetpub\promotorapalmera\project_estacion_bombeo"
.\MONITOR_SERVIDOR_HTTPS.ps1
```

El monitor mantiene el servidor activo y lo reinicia automáticamente si se cae.

## 📱 Instrucciones para Usuarios Móviles

### Paso 1: Acceder por HTTPS
Abrir en el navegador:
```
https://www.ppasas.com:8082/uploads/nomina/consulta_planilla_publica.html
```

### Paso 2: Aceptar Certificado
El navegador mostrará una advertencia:
- **Chrome/Edge**: "Tu conexión no es privada"
- **Safari**: "Esta conexión no es privada"
- **Firefox**: "Advertencia: Riesgo potencial de seguridad"

**Acciones a realizar:**
1. Hacer clic en "Avanzado" o "Detalles"
2. Seleccionar "Ir al sitio web (no es seguro)" o "Continuar"
3. La página cargará normalmente

**NOTA:** Esta advertencia es NORMAL porque usamos un certificado autofirmado. 
El navegador recordará la decisión y no volverá a preguntar.

### Paso 3: Usar Página Normalmente
Una vez aceptado el certificado, la consulta de planillas funciona igual que siempre.

## 📁 Archivos Creados

### Servidor:
- `generar_certificado_ssl.py` - Genera certificados SSL autofirmados
- `servidor_dual_http_https.py` - Servidor con soporte HTTP y HTTPS
- `servidor_8081_https.py` - Versión anterior (deprecated)
- `server.crt` - Certificado SSL (válido 1 año)
- `server.key` - Clave privada SSL

### Scripts de Inicio:
- `INICIAR_HTTPS_8081.ps1` - Inicio manual del servidor
- `MONITOR_SERVIDOR_HTTPS.ps1` - Monitor automático con reinicio

### Documentación:
- `ayuda_iphone.html` - Guía de ayuda para usuarios móviles
- `README_SERVIDOR_HTTPS.md` - Este archivo

## 🔍 Verificación

### Comprobar que el servidor está activo:
```powershell
netstat -ano | findstr ":8082"
```

Debería mostrar:
```
TCP    0.0.0.0:8082           0.0.0.0:0              LISTENING       [PID]
```

### Probar desde navegador (PC):
```
https://localhost:8082/uploads/nomina/consulta_planilla_publica.html
```

### Probar desde celular:
```
https://www.ppasas.com:8082/uploads/nomina/consulta_planilla_publica.html
```

## ⚙️ Mantenimiento

### Regenerar Certificados (si expiran):
```powershell
cd "c:\inetpub\promotorapalmera\project_estacion_bombeo"
Remove-Item server.crt, server.key
python generar_certificado_ssl.py
```

### Ver Logs del Servidor:
```powershell
Get-Content "c:\inetpub\promotorapalmera\project_estacion_bombeo\servidor_https.log" -Tail 50
```

### Detener Servidor:
```powershell
taskkill /F /IM python.exe
```

## 🐛 Solución de Problemas

### Problema: "Puerto ya en uso"
**Solución:**
```powershell
netstat -ano | findstr ":8082"
taskkill /F /PID [número del PID]
```

### Problema: "pyOpenSSL no instalado"
**Solución:**
```powershell
pip install pyopenssl
```

### Problema: "Certificado expirado"
**Solución:**
Ver sección "Regenerar Certificados" arriba.

### Problema: "Página no carga en móvil"
**Soluciones:**
1. Verificar que el servidor está corriendo
2. Asegurarse de usar puerto 8082 (no 8081)
3. Aceptar la advertencia del certificado
4. Ver guía completa en: `http://www.ppasas.com:8081/uploads/nomina/ayuda_iphone.html`

## 📊 Logs y Monitoreo

Los logs se guardan en:
- `servidor_https.log` - Log del monitor automático
- `stdout.log` - Salida estándar del servidor
- `stderr.log` - Errores del servidor

## 🔐 Seguridad

**Certificado Autofirmado:**
- Válido por 1 año desde la generación
- No verificado por autoridad certificadora (CA)
- Seguro para uso interno/corporativo
- Los navegadores mostrarán advertencia (es normal)

**Para Producción (Opcional):**
Considerar obtener certificado SSL válido de:
- Let's Encrypt (gratuito)
- DigiCert, Comodo, etc. (pagos)

## 📞 Soporte

Para problemas técnicos, contactar al administrador del sistema.

---
**Última actualización:** 24 de febrero de 2026  
**Versión:** 1.0  
**Autor:** Sistema Promotora Palmera de Antioquia
