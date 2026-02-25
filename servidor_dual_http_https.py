#!/usr/bin/env python3
"""
Servidor HTTPS en puerto 8082 (para móviles)
Servidor HTTP en puerto 8081 (IIS - no controlado por este script)
"""
import os
import sys
import http.server
import socketserver
import ssl
from pathlib import Path
import threading

# Servir desde el directorio raíz de promotorapalmera
SERVIDOR_DIR = Path(__file__).parent.parent
os.chdir(SERVIDOR_DIR)

HOST = '0.0.0.0'
PORT_HTTPS = 8082  # Puerto HTTPS (para móviles que fuerzan SSL)

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Handler personalizado con soporte CORS"""
    
    def do_GET(self):
        # Log de la petición
        protocol = "HTTPS" if getattr(self, 'is_https', False) else "HTTP"
        print(f"[{protocol}] GET {self.path}")
        
        # Redirigir raíz a index.html si existe
        if self.path == '/' or self.path == '':
            if os.path.exists('index.html'):
                self.path = '/index.html'
        
        return super().do_GET()
    
    def end_headers(self):
        # Agregar headers CORS
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()
    
    def log_message(self, format, *args):
        """Suprimir log automático, usamos nuestro propio log"""
        pass


def iniciar_servidor_https():
    """Inicia servidor HTTPS en puerto 8082 (principal)"""
    # Los certificados estan en el subdirectorio project_estacion_bombeo
    cert_dir = Path(__file__).parent
    cert_file = cert_dir / 'server.crt'
    key_file = cert_dir / 'server.key'
    
    # Verificar certificados
    if not cert_file.exists() or not key_file.exists():
        print("[WARN] Certificados SSL no encontrados")
        print(f"  Buscando en: {cert_dir}")
        print("  Ejecutando generador de certificados...")
        print("")
        
        try:
            # Cambiar al directorio de certificados
            os.chdir(cert_dir)
            import generar_certificado_ssl
            if not generar_certificado_ssl.generar_certificado_autofirmado():
                print("[ERROR] No se pudo iniciar servidor HTTPS")
                return
            # Volver al directorio de servidor
            os.chdir(SERVIDOR_DIR)
        except Exception as e:
            print(f"[ERROR] Error generando certificados: {e}")
            return
    
    socketserver.TCPServer.allow_reuse_address = True
    
    try:
        # Crear contexto SSL
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(str(cert_file), str(key_file))
        
        # Crear handler con marca de HTTPS
        class HTTPSHandler(MyHTTPRequestHandler):
            is_https = True
        
        # Crear servidor HTTPS
        with socketserver.TCPServer((HOST, PORT_HTTPS), HTTPSHandler) as httpd:
            httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
            print(f"[OK] Servidor HTTPS activo en puerto {PORT_HTTPS}")
            httpd.serve_forever()
            
    except Exception as e:
        print(f"[ERROR] Error en servidor HTTPS: {e}")


if __name__ == '__main__':
    print("=" * 70)
    print("  SERVIDOR HTTP/HTTPS - PROMOTORA PALMERA")
    print("=" * 70)
    print(f"  Directorio: {os.getcwd()}")
    print("")
    print("  URLs PRINCIPALES:")
    print(f"    [HTTPS] (moviles): https://www.ppasas.com:8082/uploads/nomina/consulta_planilla_publica.html")
    print(f"    [HTTP]  (IIS):     http://www.ppasas.com:8081/uploads/nomina/consulta_planilla_publica.html")
    print("")
    print("  INSTRUCCIONES PARA CELULARES:")
    print("    1. Acceda a: https://www.ppasas.com:8082/uploads/nomina/consulta_planilla_publica.html")
    print("    2. Aparecera: 'Tu conexion no es privada' o 'No es seguro'")
    print("    3. Toque 'Avanzado' o 'Detalles'")
    print("    4. Toque 'Ir al sitio web (no es seguro)' o 'Continuar'")
    print("    5. Listo! La pagina cargara normalmente")
    print("")
    print("  ALTERNATIVA SIN SSL:")
    print("    http://www.ppasas.com:8081/uploads/nomina/consulta_planilla_publica.html")
    print("")
    print("  El navegador recordara su decision para futuras visitas")
    print("")
    print("  Presione Ctrl+C para detener")
    print("=" * 70)
    print("")
    
    # Iniciar servidor HTTPS en thread principal
    try:
        iniciar_servidor_https()
    except KeyboardInterrupt:
        print("\n")
        print("=" * 70)
        print("  SERVIDORES DETENIDOS")
        print("=" * 70)
        sys.exit(0)
