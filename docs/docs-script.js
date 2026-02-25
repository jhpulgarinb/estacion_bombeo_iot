// docs-script.js - Funcionalidad para la página de documentación

class DocumentationApp {
    constructor() {
        this.currentSection = 'inicio';
        this.markdownFiles = {
            'inicio': null,
            'instalacion': 'MANUAL_INSTALACION.md',
            'usuario': 'MANUAL_USUARIO.md',
            'tecnico': 'MANUAL_TECNICO.md',
            'requisitos': 'MANUAL_INSTALACION.md',
            'instalacion-rapida': 'MANUAL_INSTALACION.md',
            'api': 'MANUAL_TECNICO.md',
            'troubleshooting': 'MANUAL_TECNICO.md'
        };
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.setupRouter();
        this.loadInitialContent();
    }

    setupEventListeners() {
        // Enlaces de navegación
        document.addEventListener('click', (e) => {
            if (e.target.matches('.nav-item')) {
                e.preventDefault();
                const href = e.target.getAttribute('href');
                if (href.startsWith('#')) {
                    this.navigateTo(href.substring(1));
                }
            }
        });

        // Scroll listener para botón "volver arriba"
        window.addEventListener('scroll', () => {
            const scrollBtn = document.getElementById('scroll-top');
            if (window.pageYOffset > 300) {
                scrollBtn.style.display = 'block';
            } else {
                scrollBtn.style.display = 'none';
            }
        });

        // Hash change listener
        window.addEventListener('hashchange', () => {
            const hash = window.location.hash.substring(1);
            if (hash) {
                this.navigateTo(hash);
            }
        });
    }

    setupRouter() {
        // Configurar marked.js
        if (typeof marked !== 'undefined') {
            marked.setOptions({
                highlight: function(code, lang) {
                    if (typeof hljs !== 'undefined' && lang && hljs.getLanguage(lang)) {
                        return hljs.highlight(code, { language: lang }).value;
                    }
                    return code;
                },
                breaks: true,
                gfm: true
            });
        }
    }

    loadInitialContent() {
        const hash = window.location.hash.substring(1);
        if (hash) {
            this.navigateTo(hash);
        } else {
            this.navigateTo('inicio');
        }
    }

    async navigateTo(section) {
        this.showLoading();
        this.updateActiveNavItem(section);
        this.currentSection = section;

        try {
            let content;
            if (section === 'inicio') {
                content = this.getHomeContent();
            } else {
                content = await this.loadMarkdownContent(section);
            }
            
            this.renderContent(content);
            this.generateTOC();
            window.location.hash = section;
            
        } catch (error) {
            console.error('Error loading content:', error);
            this.renderErrorContent();
        }
    }

    showLoading() {
        document.getElementById('content-loading').style.display = 'flex';
        document.getElementById('content-container').style.display = 'none';
    }

    hideLoading() {
        document.getElementById('content-loading').style.display = 'none';
        document.getElementById('content-container').style.display = 'block';
    }

    updateActiveNavItem(section) {
        // Remover clase active de todos los elementos
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
        });
        
        // Agregar clase active al elemento seleccionado
        const activeItem = document.querySelector(`[href="#${section}"]`);
        if (activeItem) {
            activeItem.classList.add('active');
        }
    }

    async loadMarkdownContent(section) {
        const filename = this.markdownFiles[section];
        if (!filename) {
            throw new Error(`No se encontró archivo para la sección: ${section}`);
        }

        try {
            const response = await fetch(filename);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const markdownText = await response.text();
            
            // Procesar contenido específico por sección
            let processedContent = markdownText;
            if (section !== 'instalacion' && section !== 'usuario' && section !== 'tecnico') {
                processedContent = this.extractSectionContent(markdownText, section);
            }
            
            return marked.parse(processedContent);
        } catch (error) {
            throw new Error(`Error cargando ${filename}: ${error.message}`);
        }
    }

    extractSectionContent(markdownText, section) {
        // Extraer secciones específicas de documentos largos
        const sectionMappings = {
            'requisitos': 'Requisitos del Sistema',
            'instalacion-rapida': 'Instalación Automática',
            'api': 'API REST',
            'troubleshooting': 'Solución de Problemas'
        };
        
        const sectionTitle = sectionMappings[section];
        if (!sectionTitle) return markdownText;
        
        const lines = markdownText.split('\n');
        const startIndex = lines.findIndex(line => line.includes(sectionTitle));
        
        if (startIndex === -1) return markdownText;
        
        // Encontrar el final de la sección (siguiente ## o final del documento)
        let endIndex = lines.length;
        for (let i = startIndex + 1; i < lines.length; i++) {
            if (lines[i].startsWith('## ') && !lines[i].includes('###')) {
                endIndex = i;
                break;
            }
        }
        
        const sectionContent = lines.slice(startIndex, endIndex).join('\n');
        return sectionContent;
    }

    getHomeContent() {
        return `
# Documentación del Sistema de Monitoreo de Estaciones de Bombeo

## 🏠 Bienvenido

Esta documentación completa te guiará a través de la instalación, configuración y uso del Sistema de Monitoreo de Estaciones de Bombeo.

## 📚 ¿Qué encontrarás aquí?

### 🔧 Manual de Instalación
Guía paso a paso para instalar el sistema en tu entorno Windows, incluyendo:
- Requisitos del sistema
- Instalación automática y manual  
- Configuración de base de datos PostgreSQL
- Verificación de instalación
- Solución de problemas comunes

### 👤 Manual de Usuario
Aprende a usar el dashboard web para monitorear tus estaciones:
- Interface del dashboard explicada
- Interpretación de datos y gráficos
- Monitoreo en tiempo real
- Alertas y notificaciones
- Uso en dispositivos móviles

### ⚙️ Manual Técnico
Documentación completa para desarrolladores y administradores:
- Arquitectura del sistema
- API REST endpoints
- Estructura de base de datos
- Configuración avanzada
- Mantenimiento y troubleshooting
- Extensiones y desarrollo

## 🚀 Inicio Rápido

### 1. Instalación Rápida
\`\`\`powershell
# Ejecutar instalador automático
.\\instalar_sistema.ps1

# Iniciar aplicación
.\\iniciar_aplicacion.ps1
\`\`\`

### 2. Acceder al Sistema
- **Dashboard:** [http://localhost:5000/index.html](http://localhost:5000/index.html)
- **Documentación:** [http://localhost:5000/docs/](http://localhost:5000/docs/)
- **API:** [http://localhost:5000/api/dashboard](http://localhost:5000/api/dashboard)

## 🔗 Enlaces Útiles

| Recurso | Descripción | Link |
|---------|-------------|------|
| 📊 Dashboard | Interface principal de monitoreo | [Ir al Dashboard](../index.html) |
| 🔧 Instalación | Guía completa de instalación | [Ver Manual](#instalacion) |
| 👤 Usuario | Manual para operadores | [Ver Manual](#usuario) |
| ⚙️ Técnico | Documentación para desarrolladores | [Ver Manual](#tecnico) |

## 📋 Características Principales

### ✅ Monitoreo en Tiempo Real
- Estado de compuertas circulares 2m
- Niveles de agua con precisión milimétrica
- Cálculo automático de caudales
- Gráficos históricos interactivos

### ✅ Dashboard Responsivo
- Compatible con PC, tablet y móvil
- Actualización automática cada 60 segundos
- Interface intuitiva y moderna
- Métricas visuales claras

### ✅ Base de Datos Robusta
- PostgreSQL para almacenamiento confiable
- Respaldo automático de datos
- Consultas optimizadas
- Integridad referencial

### ✅ API REST Completa
- Endpoints documentados
- Formato JSON estándar
- Validación de datos
- Manejo de errores

## 🛠️ Componentes del Sistema

\`\`\`
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Frontend     │    │     Backend     │    │   Base de Datos │
│   (HTML/CSS/JS) │◄───┤   (Flask/Python)│◄───┤   (PostgreSQL)  │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
\`\`\`

## 📞 Soporte

¿Necesitas ayuda? Revisa estas secciones:

1. **[Solución de Problemas](#troubleshooting)** - Problemas comunes y soluciones
2. **[Manual Técnico](#tecnico)** - Información detallada del sistema
3. **[Manual de Instalación](#instalacion)** - Guías paso a paso

---

*Selecciona una sección del menú lateral para comenzar* 👈
        `;
    }

    renderContent(html) {
        const container = document.getElementById('content-container');
        container.innerHTML = html;
        
        // Aplicar highlight.js si está disponible
        if (typeof hljs !== 'undefined') {
            container.querySelectorAll('pre code').forEach(block => {
                hljs.highlightBlock(block);
            });
        }
        
        this.hideLoading();
        this.scrollToTop();
    }

    renderErrorContent() {
        const errorHtml = `
            <div style="text-align: center; padding: 4rem;">
                <h2 style="color: #e53e3e;">⚠️ Error al cargar contenido</h2>
                <p>No se pudo cargar la documentación solicitada.</p>
                <button onclick="location.reload()" style="
                    background: linear-gradient(135deg, #667eea, #764ba2);
                    color: white;
                    border: none;
                    padding: 1rem 2rem;
                    border-radius: 8px;
                    cursor: pointer;
                    font-size: 1rem;
                    margin-top: 1rem;
                ">🔄 Recargar Página</button>
            </div>
        `;
        
        document.getElementById('content-container').innerHTML = errorHtml;
        this.hideLoading();
    }

    generateTOC() {
        const content = document.getElementById('content-container');
        const headings = content.querySelectorAll('h1, h2, h3, h4');
        const tocList = document.getElementById('toc-list');
        
        if (headings.length === 0) {
            tocList.innerHTML = '<p style="color: #718096; font-style: italic;">No hay secciones disponibles</p>';
            return;
        }
        
        let tocHTML = '<ul>';
        
        headings.forEach((heading, index) => {
            const level = parseInt(heading.tagName.charAt(1));
            const text = heading.textContent.trim();
            const id = `heading-${index}`;
            
            // Agregar ID al heading
            heading.id = id;
            
            // Crear entrada en TOC
            const levelClass = level > 2 ? `toc-level-${level}` : '';
            tocHTML += `<li class="${levelClass}">
                <a href="#${id}" onclick="document.getElementById('${id}').scrollIntoView({behavior: 'smooth'}); return false;">
                    ${text}
                </a>
            </li>`;
        });
        
        tocHTML += '</ul>';
        tocList.innerHTML = tocHTML;
    }

    scrollToTop() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    }
}

// Funciones globales para uso en HTML
function closeModal() {
    document.getElementById('fullscreen-modal').style.display = 'none';
}

function scrollToTop() {
    window.scrollTo({
        top: 0,
        behavior: 'smooth'
    });
}

function loadSection(section) {
    if (window.docsApp) {
        window.docsApp.navigateTo(section);
    }
}

// Inicializar aplicación cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', function() {
    window.docsApp = new DocumentationApp();
});
