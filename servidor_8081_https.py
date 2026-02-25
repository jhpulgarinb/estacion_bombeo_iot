#!/usr/bin/env python3
"""
Servidor HTTPS para puerto 8081
Soporte para HTTP y HTTPS simultáneo
Estación de Bombeo - Promotora Palmera
"""
import os
import sys
import http.server
import socketserver
import ssl
from pathlib import Path
import threading

# Cambiar al directorio raíz de promotorapalmera para servir todos los archivos
SERVIDOR_DIR = Path(__file__).parent.parent
os.chdir(SERVIDOR_DIR)

HOST = '0.0.0.0'
PORT_HTTP = 8081
PORT_HTTPS = 8444  # Puerto alternativo para HTTPS

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Handler personalizado con soporte CORS"""
    
    def do_GET(self):
        # Redirigir raíz a index.html
        if self.path == '/' or self.path == '':
            self.path = '/index.html'
        return super().do_GET()
    
    def end_headers(self):
        # Agregar headers CORS
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()
    
    def log_message(self, format, *args):
        """Log personalizado"""
        protocol = "HTTPS" if hasattr(self.connection, 'getpeercert') else "HTTP"
        sys.stdout.write(f"[{protocol}] {self.address_string()} - {format % args}\n")


def iniciar_servidor_http():
    """Inicia servidor HTTP en puerto 8081"""
    socketserver.TCPServer.allow_reuse_address = True
    
    try:
        with socketserver.TCPServer((HOST, PORT_HTTP), MyHTTPRequestHandler) as httpd:
            print(f"✓ Servidor HTTP activo en puerto {PORT_HTTP}")
            httpd.serve_forever()
    except Exception as e:
        print(f"✗ Error en servidor HTTP: {e}")


def iniciar_servidor_https():
    """Inicia servidor HTTPS en puerto 8444"""
    # Los certificados están en el subdirectorio project_estacion_bombeo
    cert_dir = Path(__file__).parent
    cert_file = cert_dir / 'server.crt'
    key_file = cert_dir / 'server.key'
    
    # Verificar certificados
    if not cert_file.exists() or not key_file.exists():
        print("⚠ Certificados SSL no encontrados")
        print("  Ejecutando generador de certificados...")
        print("")
        
        try:
            import generar_certificado_ssl
            if not generar_certificado_ssl.generar_certificado_autofirmado():
                print("✗ No se pudo iniciar servidor HTTPS")
                return
        except Exception as e:
            print(f"✗ Error generando certificados: {e}")
            return
    
    socketserver.TCPServer.allow_reuse_address = True
    
    try:
        # Crear contexto SSLstr(cert_file), str(key_file)
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(cert_file, key_file)
        
        # Crear servidor HTTPS
        with socketserver.TCPServer((HOST, PORT_HTTPS), MyHTTPRequestHandler) as httpd:
            httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
            print(f"✓ Servidor HTTPS activo en puerto {PORT_HTTPS}")
            httpd.serve_forever()
            
    except Exception as e:
        print(f"✗ Error en servidor HTTPS: {e}")


if __name__ == '__main__':
    print("=" * 70)
    print("  SERVIDOR HTTP/HTTPS - ESTACION DE BOMBEO")
    print("=" * 70)
    print(f"  Directorio: {os.getcwd()}")
    print("")
    print("  URLs accesibles:")
    print(f"    HTTP:  http://www.ppasas.com:8081")
    print(f"    HTTP:  http://localhost:8081")
    print(f"    HTTPS: https://www.ppasas.com:8444")
    print(f"    HTTPS: https://localhost:8444")
    print("")
    print("  IMPORTANTE PARA CELULARES:")
    print("    • Si el navegador fuerza HTTPS, use el puerto 8444")
    print("    • Acepte la advertencia del certificado autofirmado")
    print("    • Haga clic en 'Avanzado' → 'Continuar de todos modos'")
    print("")
    print("  Presione Ctrl+C para detener ambos servidores")
    print("=" * 70)
    print("")
    
    # Iniciar servidor HTTP en thread separado
    thread_http = threading.Thread(target=iniciar_servidor_http, daemon=True)
    thread_http.start()
    
    # Iniciar servidor HTTPS en thread principal
    try:
        iniciar_servidor_https()
    except KeyboardInterrupt:
        print("\n")
        print("=" * 70)
        print("  SERVIDORES DETENIDOS")
        print("=" * 70)
        sys.exit(0)
