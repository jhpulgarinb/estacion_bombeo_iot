#!/usr/bin/env python3
"""
Servidor Simple HTTP para la estación de bombeo
Sirve archivos estáticos en http://localhost:9000 y http://localhost:8081
"""
import os
import sys
import http.server
import socketserver
import threading
from pathlib import Path

# Cambiar al directorio del proyecto
os.chdir(Path(__file__).parent)

PUERTOS = [9000, 8081]
HOST = '0.0.0.0'

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Servir index.html por defecto
        if self.path == '/' or self.path == '':
            self.path = '/index.html'
        return super().do_GET()

    def end_headers(self):
        # Permitir CORS
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        return super().end_headers()

def iniciar_servidor(puerto):
    handler = MyHTTPRequestHandler
    
    try:
        with socketserver.TCPServer((HOST, puerto), handler) as httpd:
            print(f"✓ Servidor activo en puerto {puerto}")
            httpd.serve_forever()
    except OSError as e:
        print(f"✗ No se pudo iniciar en puerto {puerto}: {e}")

if __name__ == '__main__':
    print("=" * 50)
    print("SERVIDOR HTTP - ESTACION DE BOMBEO")
    print("=" * 50)
    print(f"Directorio: {os.getcwd()}")
    print("")
    
    # Iniciar servidores en ambos puertos en threads separados
    threads = []
    for puerto in PUERTOS:
        t = threading.Thread(target=iniciar_servidor, args=(puerto,), daemon=True)
        t.start()
        threads.append(t)
    
    print("")
    print("URLs accesibles:")
    print(f"  http://localhost:9000")
    print(f"  http://localhost:8081")
    print("")
    print("Presione Ctrl+C para detener")
    print("=" * 50)
    
    try:
        # Mantener el programa corriendo
        for t in threads:
            t.join()
    except KeyboardInterrupt:
        print("\nServidor detenido")
        sys.exit(0)

