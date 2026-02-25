#!/usr/bin/env python3
"""
Servidor HTTPS robusto puerto 8082
Con manejo mejorado de errores y mantiene conexiones vivas
"""
import os
import sys
import http.server
import socketserver
import ssl
from pathlib import Path
import threading
import time
import socket

# Servir desde el directorio raíz de promotorapalmera
SERVIDOR_DIR = Path(__file__).parent.parent
os.chdir(SERVIDOR_DIR)

HOST = '0.0.0.0'
PORT_HTTPS = 8082

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Handler personalizado con timeout aumentado"""
    
    timeout = 300  # 5 minutos de timeout
    
    def do_GET(self):
        protocol = "HTTPS" if getattr(self, 'is_https', False) else "HTTP"
        print(f"[{protocol}] GET {self.path}")
        
        if self.path == '/' or self.path == '':
            if os.path.exists('index.html'):
                self.path = '/index.html'
        
        try:
            return super().do_GET()
        except Exception as e:
            print(f"[ERROR GET] {e}")
            self.send_error(500, str(e))
    
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Connection', 'keep-alive')
        self.send_header('Keep-Alive', 'timeout=5, max=100')
        super().end_headers()
    
    def log_message(self, format, *args):
        pass


def iniciar_servidor_https():
    """Inicia servidor HTTPS permanente en puerto 8082"""
    cert_dir = Path(__file__).parent
    cert_file = cert_dir / 'server.crt'
    key_file = cert_dir / 'server.key'
    
    if not cert_file.exists() or not key_file.exists():
        print("[WARN] Certificados SSL no encontrados")
        print(f"  Buscando en: {cert_dir}")
        print("  Ejecutando generador de certificados...")
        print("")
        
        try:
            os.chdir(cert_dir)
            import generar_certificado_ssl
            if not generar_certificado_ssl.generar_certificado_autofirmado():
                print("[ERROR] No se pudo generar certificados")
                return False
            os.chdir(SERVIDOR_DIR)
        except Exception as e:
            print(f"[ERROR] Error generando certificados: {e}")
            return False
    
    socketserver.TCPServer.allow_reuse_address = True
    socketserver.TCPServer.daemon_threads = True
    
    try:
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(str(cert_file), str(key_file))
        
        class HTTPSHandler(MyHTTPRequestHandler):
            is_https = True
        
        httpd = socketserver.TCPServer((HOST, PORT_HTTPS), HTTPSHandler)
        httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
        
        print("")
        print("=" * 70)
        print("[OK] Servidor HTTPS activo en puerto 8082")
        print("=" * 70)
        print("")
        print("Presione Ctrl+C para detener")
        print("")
        
        # Configurar timeout del socket para detectar desconexiones
        httpd.timeout = 30
        
        # Servir indefinidamente
        httpd.serve_forever()
        
    except KeyboardInterrupt:
        print("\n[INFO] Servidor detenido por usuario")
        return True
    except Exception as e:
        print(f"[ERROR] Error en servidor HTTPS: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == '__main__':
    print("=" * 70)
    print("  SERVIDOR HTTPS ROBUSTO - PROMOTORA PALMERA")
    print("=" * 70)
    print(f"  Directorio: {os.getcwd()}")
    print(f"  Puerto: 8082 (HTTPS)")
    print("")
    print("  URL de acceso:")
    print("    https://192.168.1.34:8082/uploads/nomina/consulta_planilla_publica.html")
    print("")
    
    iniciar_servidor_https()
