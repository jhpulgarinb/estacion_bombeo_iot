#!/usr/bin/env python3
"""
Servidor HTTP para puerto 8081
Estación de Bombeo
"""
import os
import sys
import http.server
import socketserver
from pathlib import Path

os.chdir(Path(__file__).parent)

HOST = '0.0.0.0'
PORT = 8000

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/' or self.path == '':
            self.path = '/index.html'
        return super().do_GET()
    
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        return super().end_headers()

if __name__ == '__main__':
    handler = MyHTTPRequestHandler
    
    # Permitir reutilizar el socket
    socketserver.TCPServer.allow_reuse_address = True
    
    try:
        with socketserver.TCPServer((HOST, PORT), handler) as httpd:
            print("=" * 60)
            print("SERVIDOR HTTP - ESTACION DE BOMBEO")
            print("=" * 60)
            print(f"Puerto: {PORT}")
            print(f"Host: {HOST}")
            print(f"Directorio: {os.getcwd()}")
            print("")
            print("URLs accesibles:")
            print(f"  ✓ http://localhost:8000")
            print(f"  ✓ http://127.0.0.1:8000")
            print(f"  ✓ http://www.ppasas.com:8000")
            print("")
            print("Presione Ctrl+C para detener")
            print("=" * 60)
            print("")
            
            httpd.serve_forever()
    except OSError as e:
        print(f"ERROR: No se pudo iniciar el servidor en puerto {PORT}")
        print(f"Detalles: {e}")
        print("")
        print("Posibles soluciones:")
        print("1. El puerto está en uso por otro proceso")
        print("2. Ejecutar como Administrador")
        print("3. Usar netsh para liberar el puerto")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\nServidor detenido")
        sys.exit(0)

