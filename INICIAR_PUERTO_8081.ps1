Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LIBERANDO PUERTO 8081" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si se ejecuta como administrador
$admin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $admin) {
    Write-Host "Este script requiere permisos de administrador" -ForegroundColor Red
    Write-Host "Por favor, ejecute como administrador" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/3] Liberando puerto 8081..." -ForegroundColor Yellow

# Intentar liberar el puerto
try {
    $output = netsh int ipv4 set dynamicport tcp start=49152 num=16384 2>&1
    Write-Host "OK: Puertos dinámicos reconfigurados" -ForegroundColor Green
} catch {
    Write-Host "Advertencia: No se pudo reconfigurar puertos dinámicos" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[2/3] Deteniendo procesos Python anteriores..." -ForegroundColor Yellow

taskkill /F /IM python.exe 2>$null
Start-Sleep -Seconds 2
Write-Host "OK: Procesos detenidos" -ForegroundColor Green

Write-Host ""
Write-Host "[3/3] Iniciando servidor en puerto 8081..." -ForegroundColor Yellow
Write-Host ""

Set-Location "c:\inetpub\promotorapalmera\project_estacion_bombeo"

# Crear archivo de configuración temporal con solo puerto 8081
$config = @"
#!/usr/bin/env python3
import os
import sys
import http.server
import socketserver
from pathlib import Path

os.chdir(Path(__file__).parent)

HOST = '0.0.0.0'
PORT = 8081

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
    
    with socketserver.TCPServer((HOST, PORT), handler) as httpd:
        print("=" * 50)
        print("SERVIDOR HTTP - ESTACION DE BOMBEO")
        print("=" * 50)
        print(f"Puerto: {PORT}")
        print(f"Directorio: {os.getcwd()}")
        print("")
        print("URLs accesibles:")
        print(f"  http://localhost:8081")
        print(f"  http://127.0.0.1:8081")
        print("")
        print("Presione Ctrl+C para detener")
        print("=" * 50)
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServidor detenido")
            sys.exit(0)
"@

$config | Out-File -FilePath "servidor_8081.py" -Encoding UTF8

python servidor_8081.py

