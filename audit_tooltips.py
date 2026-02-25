#!/usr/bin/env python3
"""
Auditor de Tooltips - Verifica que todos los data-tooltip tengan contenido válido
"""

import os
import re

def audit_tooltips(html_file):
    """Analiza un archivo HTML y reporta problemas con tooltips"""
    
    with open(html_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Encontrar todos los elementos con data-tooltip
    pattern = r'data-tooltip="([^"]*)"'
    matches = re.finditer(pattern, content)
    
    tooltips = []
    empty_tooltips = []
    
    for i, match in enumerate(matches):
        tooltip_text = match.group(1)
        line_num = content[:match.start()].count('\n') + 1
        
        tooltips.append({
            'number': i + 1,
            'text': tooltip_text,
            'line': line_num,
            'empty': not tooltip_text or tooltip_text.strip() == ''
        })
        
        if not tooltip_text or tooltip_text.strip() == '':
            empty_tooltips.append((i + 1, line_num))
    
    # Print Report
    print(f"\n{'='*70}")
    print(f"AUDITORÍA DE TOOLTIPS - {os.path.basename(html_file)}")
    print(f"{'='*70}\n")
    
    print(f"✓ Total de tooltips encontrados: {len(tooltips)}")
    
    if empty_tooltips:
        print(f"\n❌ PROBLEMAS ENCONTRADOS: {len(empty_tooltips)} tooltip(s) vacío(s)\n")
        for num, line in empty_tooltips:
            print(f"   - Tooltip #{num} en línea {line}: [VACÍO]")
    else:
        print(f"\n✓ Todos los tooltips tienen contenido válido\n")
    
    # Mostrar algunos ejemplos
    print("Ejemplos de tooltips válidos:")
    print("-" * 70)
    
    examples = [t for t in tooltips if not t['empty']][:5]
    for tooltip in examples:
        text_preview = tooltip['text'][:60] + ('...' if len(tooltip['text']) > 60 else '')
        print(f"#{tooltip['number']} (línea {tooltip['line']}): \"{text_preview}\"")
    
    print("\n" + "="*70 + "\n")
    
    return {
        'total': len(tooltips),
        'empty': len(empty_tooltips),
        'valid': len(tooltips) - len(empty_tooltips),
        'details': tooltips
    }

if __name__ == '__main__':
    # Directorio del script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    html_files = [
        os.path.join(script_dir, 'index.html'),
        os.path.join(script_dir, 'test-tooltips.html'),
    ]
    
    for html_file in html_files:
        if os.path.exists(html_file):
            audit_tooltips(html_file)
