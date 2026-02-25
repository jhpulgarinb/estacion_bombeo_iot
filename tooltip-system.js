/**
 * Sistema de Tooltips Flotantes Avanzado
 * Gestiona tooltips con soporte para múltiples tipos y posiciones
 */

class TooltipSystem {
    constructor() {
        this.tooltips = new Map();
        this.activeTooltip = null;
        this.showDelay = 200; // ms
        this.hideDelay = 100; // ms
        this.showTimeout = null;
        this.hideTimeout = null;
        
        // Configuración de colores por tipo
        this.typeColors = {
            'info': { bg: '#3498db', border: '#2980b9' },
            'warning': { bg: '#f39c12', border: '#e67e22' },
            'critical': { bg: '#e74c3c', border: '#c0392b' },
            'success': { bg: '#27ae60', border: '#229954' }
        };
        
        this.init();
    }

    init() {
        // Buscar todos los elementos con data-tooltip
        this.discoverTooltips();
        
        // Agregar listeners globales
        this.attachGlobalListeners();
        
        // Inicializar tooltips
        this.initializeTooltips();
        
        console.log(`[TooltipSystem] Inicializado: ${this.tooltips.size} tooltips encontrados`);
    }

    discoverTooltips() {
        const elements = document.querySelectorAll('[data-tooltip]');
        
        elements.forEach((element, index) => {
            const tooltipText = element.getAttribute('data-tooltip');
            const position = element.getAttribute('data-tooltip-position') || 'top';
            const type = element.getAttribute('data-tooltip-type') || 'info';
            
            // Validar que el tooltip tenga contenido
            if (!tooltipText || tooltipText.trim() === '') {
                console.warn(`[TooltipSystem] ADVERTENCIA: Tooltip vacío en elemento`, element);
                return;
            }
            
            const id = `tooltip-${index}`;
            element.setAttribute('data-tooltip-id', id);
            
            this.tooltips.set(id, {
                element: element,
                text: tooltipText,
                position: position,
                type: type,
                visible: false,
                dom: null
            });
        });
    }

    initializeTooltips() {
        this.tooltips.forEach((tooltip, id) => {
            // Crear el DOM del tooltip
            tooltip.dom = this.createTooltipDOM(tooltip);
            
            // Agregar event listeners al elemento
            tooltip.element.addEventListener('mouseenter', () => this.showTooltip(id));
            tooltip.element.addEventListener('mouseleave', () => this.hideTooltip(id));
            tooltip.element.addEventListener('focus', () => this.showTooltip(id));
            tooltip.element.addEventListener('blur', () => this.hideTooltip(id));
        });
    }

    createTooltipDOM(tooltip) {
        const container = document.createElement('div');
        container.className = `tooltip-floating tooltip-${tooltip.type}`;
        container.setAttribute('data-tooltip-id', tooltip.element.getAttribute('data-tooltip-id'));
        container.style.cssText = `
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            z-index: 10001;
            background: ${this.typeColors[tooltip.type]?.bg || '#3498db'};
            color: white;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 0.85rem;
            line-height: 1.4;
            max-width: 320px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
            pointer-events: none;
            white-space: normal;
            word-wrap: break-word;
            border: 2px solid ${this.typeColors[tooltip.type]?.border || '#2980b9'};
            animation: tooltipFadeIn 0.3s ease-out;
        `;
        
        container.textContent = tooltip.text;
        document.body.appendChild(container);
        
        return container;
    }

    showTooltip(id) {
        clearTimeout(this.hideTimeout);
        
        this.showTimeout = setTimeout(() => {
            const tooltip = this.tooltips.get(id);
            if (!tooltip) return;
            
            // Ocultar tooltip anterior si existe
            if (this.activeTooltip && this.activeTooltip !== id) {
                this.hideTooltip(this.activeTooltip);
            }
            
            const dom = tooltip.dom;
            const element = tooltip.element;
            
            // Mostrar con display
            dom.style.display = 'block';
            tooltip.visible = true;
            this.activeTooltip = id;
            
            // Posicionar después de que se renderice
            requestAnimationFrame(() => {
                this.positionTooltip(tooltip);
            });
        }, this.showDelay);
    }

    hideTooltip(id) {
        clearTimeout(this.showTimeout);
        
        this.hideTimeout = setTimeout(() => {
            const tooltip = this.tooltips.get(id);
            if (!tooltip) return;
            
            tooltip.dom.style.display = 'none';
            tooltip.visible = false;
            
            if (this.activeTooltip === id) {
                this.activeTooltip = null;
            }
        }, this.hideDelay);
    }

    positionTooltip(tooltip) {
        const element = tooltip.element;
        const dom = tooltip.dom;
        const position = tooltip.position;
        
        const rect = element.getBoundingClientRect();
        
        // Obtener dimensions después del reflow
        const domWidth = dom.offsetWidth;
        const domHeight = dom.offsetHeight;
        
        // Offset respecto al viewport
        const offset = 10;
        let top, left;
        
        switch (position) {
            case 'top':
                top = rect.top - domHeight - offset;
                left = rect.left + rect.width / 2 - domWidth / 2;
                break;
            
            case 'bottom':
                top = rect.bottom + offset;
                left = rect.left + rect.width / 2 - domWidth / 2;
                break;
            
            case 'left':
                top = rect.top + rect.height / 2 - domHeight / 2;
                left = rect.left - domWidth - offset;
                break;
            
            case 'right':
                top = rect.top + rect.height / 2 - domHeight / 2;
                left = rect.right + offset;
                break;
            
            default:
                return;
        }
        
        // Ajustar para que no salga de pantalla
        const padding = 10;
        
        // Ajuste horizontal
        if (left < padding) {
            left = padding;
        } else if (left + domWidth > window.innerWidth - padding) {
            left = window.innerWidth - domWidth - padding;
        }
        
        // Ajuste vertical
        if (top < padding) {
            top = padding;
        } else if (top + domHeight > window.innerHeight - padding) {
            top = window.innerHeight - domHeight - padding;
        }
        
        dom.style.top = `${Math.round(top)}px`;
        dom.style.left = `${Math.round(left)}px`;
    }

    attachGlobalListeners() {
        // Ocultar tooltips al hacer scroll
        document.addEventListener('scroll', () => {
            if (this.activeTooltip) {
                this.hideTooltip(this.activeTooltip);
            }
        }, { passive: true });
        
        // Ocultar tooltips cuando se presiona Escape
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.activeTooltip) {
                this.hideTooltip(this.activeTooltip);
            }
        });
    }

    // Método para actualizar un tooltip después de que cambie
    updateTooltip(elementSelector, newText) {
        const element = document.querySelector(elementSelector);
        if (!element) return;
        
        element.setAttribute('data-tooltip', newText);
        const id = element.getAttribute('data-tooltip-id');
        
        if (id && this.tooltips.has(id)) {
            const tooltip = this.tooltips.get(id);
            tooltip.text = newText;
            if (tooltip.dom) {
                tooltip.dom.textContent = newText;
            }
        }
    }

    // Método para validar todos los tooltips
    validateAll() {
        const issues = [];
        
        this.tooltips.forEach((tooltip, id) => {
            if (!tooltip.text || tooltip.text.trim() === '') {
                issues.push({
                    id: id,
                    element: tooltip.element,
                    issue: 'Tooltip con texto vacío'
                });
            }
        });
        
        if (issues.length > 0) {
            console.warn(`[TooltipSystem] ${issues.length} tooltip(s) con problemas:`, issues);
        } else {
            console.log(`[TooltipSystem] ✓ Todos los ${this.tooltips.size} tooltips tienen contenido válido`);
        }
        
        return issues;
    }
}

// Agregar animación al CSS si no existe
function addTooltipStyles() {
    const styleId = 'tooltip-animation-styles';
    if (document.getElementById(styleId)) return;
    
    const style = document.createElement('style');
    style.id = styleId;
    style.textContent = `
        @keyframes tooltipFadeIn {
            from {
                opacity: 0;
                transform: translateY(-5px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .tooltip-floating {
            font-family: 'Arial', sans-serif;
            cursor: default;
        }
        
        .tooltip-floating.tooltip-info {
            background: linear-gradient(135deg, #3498db, #2980b9);
        }
        
        .tooltip-floating.tooltip-warning {
            background: linear-gradient(135deg, #f39c12, #e67e22);
        }
        
        .tooltip-floating.tooltip-critical {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            animation: tooltipPulse 0.5s ease-out;
        }
        
        .tooltip-floating.tooltip-success {
            background: linear-gradient(135deg, #27ae60, #229954);
        }
        
        @keyframes tooltipPulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }
    `;
    
    document.head.appendChild(style);
}

// Inicializar cuando el DOM esté listo
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        addTooltipStyles();
        window.tooltipSystem = new TooltipSystem();
        window.tooltipSystem.validateAll();
    });
} else {
    // DOM ya está cargado
    addTooltipStyles();
    window.tooltipSystem = new TooltipSystem();
    window.tooltipSystem.validateAll();
}
