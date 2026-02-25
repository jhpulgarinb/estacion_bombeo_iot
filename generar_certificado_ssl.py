#!/usr/bin/env python3
"""
Generador de certificados SSL autofirmados
Para habilitar HTTPS en el servidor
"""
from datetime import datetime, timedelta
import os

def generar_certificado_autofirmado():
    """Genera certificado SSL autofirmado usando OpenSSL"""
    
    cert_file = 'server.crt'
    key_file = 'server.key'
    
    # Si ya existen, no regenerar
    if os.path.exists(cert_file) and os.path.exists(key_file):
        print(f"✓ Certificados ya existen:")
        print(f"  - {cert_file}")
        print(f"  - {key_file}")
        return True
    
    print("=" * 60)
    print("GENERANDO CERTIFICADO SSL AUTOFIRMADO")
    print("=" * 60)
    print("")
    
    # Intentar con pyOpenSSL
    try:
        from OpenSSL import crypto
        
        # Crear par de claves
        k = crypto.PKey()
        k.generate_key(crypto.TYPE_RSA, 2048)
        
        # Crear certificado
        cert = crypto.X509()
        cert.get_subject().C = "CO"
        cert.get_subject().ST = "Antioquia"
        cert.get_subject().L = "Medellin"
        cert.get_subject().O = "Promotora Palmera de Antioquia"
        cert.get_subject().OU = "IT"
        cert.get_subject().CN = "www.ppasas.com"
        
        # Añadir nombres alternativos
        cert.add_extensions([
            crypto.X509Extension(b"subjectAltName", False,
                b"DNS:ppasas.com,DNS:www.ppasas.com,DNS:localhost,IP:127.0.0.1")
        ])
        
        cert.set_serial_number(1000)
        cert.gmtime_adj_notBefore(0)
        cert.gmtime_adj_notAfter(365*24*60*60)  # 1 año
        cert.set_issuer(cert.get_subject())
        cert.set_pubkey(k)
        cert.sign(k, 'sha256')
        
        # Guardar certificado
        with open(cert_file, "wb") as f:
            f.write(crypto.dump_certificate(crypto.FILETYPE_PEM, cert))
        
        # Guardar clave privada
        with open(key_file, "wb") as f:
            f.write(crypto.dump_privatekey(crypto.FILETYPE_PEM, k))
        
        print("✓ Certificado generado exitosamente con pyOpenSSL")
        print(f"  - Certificado: {cert_file}")
        print(f"  - Clave privada: {key_file}")
        print("")
        return True
        
    except ImportError:
        print("⚠ pyOpenSSL no está instalado, usando método alternativo...")
        print("")
        
        # Método alternativo con certificado OpenSSL vía comando
        import subprocess
        
        try:
            # Verificar si OpenSSL está disponible
            subprocess.run(['openssl', 'version'], 
                         capture_output=True, check=True)
            
            # Generar certificado con OpenSSL
            cmd = [
                'openssl', 'req', '-x509', '-newkey', 'rsa:2048',
                '-keyout', key_file, '-out', cert_file,
                '-days', '365', '-nodes',
                '-subj', '/C=CO/ST=Antioquia/L=Medellin/O=Promotora Palmera/CN=www.ppasas.com'
            ]
            
            subprocess.run(cmd, check=True, capture_output=True)
            
            print("✓ Certificado generado exitosamente con OpenSSL")
            print(f"  - Certificado: {cert_file}")
            print(f"  - Clave privada: {key_file}")
            print("")
            return True
            
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("✗ ERROR: No se pudo generar el certificado")
            print("")
            print("SOLUCIÓN:")
            print("  Instale pyOpenSSL con: pip install pyopenssl")
            print("  O instale OpenSSL en el sistema")
            print("")
            return False

if __name__ == '__main__':
    exito = generar_certificado_autofirmado()
    
    if exito:
        print("=" * 60)
        print("CERTIFICADOS LISTOS PARA USAR")
        print("=" * 60)
        print("")
        print("IMPORTANTE:")
        print("  • Los navegadores mostrarán advertencia de 'No seguro'")
        print("  • Esto es NORMAL con certificados autofirmados")
        print("  • Los usuarios deben hacer clic en 'Avanzado' y 'Continuar'")
        print("")
        print("El servidor ahora puede usar HTTPS en el puerto 8081")
        print("")
    else:
        print("No se pudieron generar los certificados")
        exit(1)
