#!/usr/bin/env python3
"""
Verificador de Integridad del Sistema de Tooltips
Genera un reporte completo sobre el estado de los tooltips
"""

import os
import re
import json
from datetime import datetime

def analyze_system():
    """Analiza la integridad del sistema de tooltips"""
    
    base_dir = r'c:\inetpub\promotorapalmera\project_estacion_bombeo'
    
    report = {
        'timestamp': datetime.now().isoformat(),
        'status': 'OK',
        'files': {},
        'issues': []
    }
    
    # 1. Verificar archivos existentes
    files_to_check = {
        'index.html': 'HTML principal del dashboard',
        'tooltip-system.js': 'Sistema de tooltips JavaScript',
        'styles.css': 'Estilos CSS',
        'script.js': 'Script principal',
        'test-tooltips.html': 'Archivo de prueba'
    }
    
    for filename, description in files_to_check.items():
        filepath = os.path.join(base_dir, filename)
        exists = os.path.exists(filepath)
        size = os.path.getsize(filepath) if exists else 0
        
        report['files'][filename] = {
            'exists': exists,
            'size_bytes': size,
            'description': description
        }
        
        if not exists:
            report['issues'].append(f"Falta el archivo: {filename}")
            report['status'] = 'ERROR'
    
    # 2. Verificar que index.html incluya el script
    index_path = os.path.join(base_dir, 'index.html')
    if os.path.exists(index_path):
        with open(index_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        has_script_tag = 'tooltip-system.js' in content
        report['files']['index.html']['has_script_tag'] = has_script_tag
        
        if not has_script_tag:
            report['issues'].append("index.html NO incluye tooltip-system.js")
            report['status'] = 'ERROR'
        
        # Contar tooltips
        tooltip_count = len(re.findall(r'data-tooltip="([^"]*)"', content))
        report['files']['index.html']['tooltip_count'] = tooltip_count
        
        # Buscar tooltips vacíos
        empty_tooltips = re.findall(r'data-tooltip=""', content)
        if empty_tooltips:
            report['issues'].append(f"Se encontraron {len(empty_tooltips)} tooltips vacíos")
            report['status'] = 'WARNING'
        else:
            report['files']['index.html']['all_tooltips_filled'] = True
    
    # 3. Verificar CSS
    css_path = os.path.join(base_dir, 'styles.css')
    if os.path.exists(css_path):
        with open(css_path, 'r', encoding='utf-8') as f:
            css_content = f.read()
        
        # Buscar que los antiguos tooltips estén deshabilitados
        has_disabled = '[data-tooltip]::before' in css_content and 'display: none !important;' in css_content
        report['files']['styles.css']['old_tooltips_disabled'] = has_disabled
        
        if not has_disabled:
            report['issues'].append("CSS: Los tooltips antiguos no están deshabilitados")
    
    # 4. Verificar tooltip-system.js
    js_path = os.path.join(base_dir, 'tooltip-system.js')
    if os.path.exists(js_path):
        with open(js_path, 'r', encoding='utf-8') as f:
            js_content = f.read()
        
        has_class = 'class TooltipSystem' in js_content
        has_init = 'this.init()' in js_content
        has_discover = 'discoverTooltips()' in js_content
        
        report['files']['tooltip-system.js']['has_class'] = has_class
        report['files']['tooltip-system.js']['has_init'] = has_init
        report['files']['tooltip-system.js']['has_discover'] = has_discover
        
        if not (has_class and has_init and has_discover):
            report['issues'].append("tooltip-system.js parece incompleto")
    
    return report

def print_report(report):
    """Imprime un reporte formateado"""
    
    print("\n" + "="*80)
    print("REPORTE DE INTEGRIDAD - SISTEMA DE TOOLTIPS")
    print("="*80)
    
    print(f"\n📅 Fecha: {report['timestamp']}")
    print(f"🔍 Estado General: {report['status']}")
    
    print("\n📁 Archivos:")
    print("-"*80)
    for filename, info in report['files'].items():
        exists_icon = "✓" if info['exists'] else "✗"
        size_str = f"{info['size_bytes']:,} bytes" if info['exists'] else "NO EXISTE"
        print(f"  {exists_icon} {filename:30} ({size_str})")
        
        if info.get('has_script_tag') is not None:
            script_icon = "✓" if info.get('has_script_tag') else "✗"
            print(f"     {script_icon} Incluye script en index.html")
        
        if info.get('tooltip_count'):
            print(f"     📊 {info['tooltip_count']} tooltips detectados")
        
        if info.get('all_tooltips_filled'):
            print(f"     ✓ Todos los tooltips tienen contenido")
        
        if info.get('old_tooltips_disabled'):
            print(f"     ✓ Tooltips antiguos deshabilitados")
    
    if report['issues']:
        print("\n⚠️  PROBLEMAS ENCONTRADOS:")
        print("-"*80)
        for issue in report['issues']:
            print(f"  ⚠️  {issue}")
    else:
        print("\n✓ No hay problemas detectados")
    
    print("\n" + "="*80)
    print("RECOMENDACIONES:")
    print("-"*80)
    
    if report['status'] == 'OK':
        print("""
✓ El sistema está completamente configurado.

PRUEBA EN EL NAVEGADOR:
1. Abre http://localhost:9000 en tu navegador
2. Pasa el cursor sobre cualquier tarjeta (Estado de Compuerta, Nivel de Agua, etc.)
3. Deberías ver un tooltip flotante con explicaciones azules
4. Prueba también con botones (rojo para crítico), gráficos, etc.

CARACTERÍSTICAS:
• Los tooltips se muestran después de 200ms de pasar el cursor
• Se posicionan automáticamente en la pantalla
• Tienen colores diferentes según el tipo (info, warning, critical, success)
• Se ocultan al hacer scroll o presionar Escape
""")
    else:
        print("Por favor, revisa los problemas detectados arriba.")
    
    print("="*80 + "\n")

if __name__ == '__main__':
    report = analyze_system()
    print_report(report)
    
    # Guardar JSON para referencia
    json_path = r'c:\inetpub\promotorapalmera\project_estacion_bombeo\tooltip-report.json'
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    print(f"💾 Reporte guardado en: {json_path}")
