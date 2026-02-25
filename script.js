// Sistema de Monitoreo Mejorado - script.js
class AdvancedMonitoringDashboard {
    constructor() {
        this.stationId = 1;
        this.timeRange = 24; // horas
        this.autoRefresh = true;
        this.refreshInterval = null;
        this.connectionStatus = 'disconnected';
        this.lastData = null;
        this.virtualSensors = new Map();
        this.alerts = [];
        
        // Configuración del simulador
        this.simulatorEnabled = false;
        this.simulatorUrl = 'http://localhost:5001';
        this.useSimulator = false; // Desactivar simulador por defecto
        
        // URL del API - Detectar automáticamente
        this.apiBase = this.detectApiBase();
        
        // Referencias a gráficos
        this.flowChart = null;
        this.levelChart = null;
        this.gateChart = null;

        // Estado base para simulacion meteorologica local
        this.weatherState = {
            temperatura_c: 24.0,
            humedad_porcentaje: 60.0,
            precipitacion_mm: 0.0,
            presion_hpa: 1013.0,
            velocidad_viento_ms: 3.5,
            direccion_viento_grados: 180,
            radiacion_solar_wm2: 700
        };
        
        this.init();
    }

    detectApiBase() {
        // Si estamos siendo servidos desde el mismo servidor que el API, usar la raíz
        const host = window.location.hostname;
        const port = window.location.port;
        const protocol = window.location.protocol;
        
        // Si estamos en puerto 9000, ya estamos en el servidor Flask
        if (port === '9000' || port === '') {
            return `${protocol}//${host}${port ? ':' + port : ''}`;
        }
        
        // Si no, asumir que el API está en 9000
        return `${protocol}//${host}:9000`;
    }

    init() {
        this.initCharts();
        this.bindEvents();
        
        // Dar tiempo a que se rendericen los canvas
        setTimeout(() => {
            // Primera actualización con datos simulados
            const simulatedData = this.generateSimulatedHistoricalData(20);
            this.updateCharts(simulatedData);
            
            // Luego cargar datos reales
            this.startAutoRefresh();
            this.loadInitialData();
            this.updateConnectionStatus('connecting');
        }, 300);
    }

    initCharts() {
        // Configuración común para todos los gráficos
        const commonOptions = {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                mode: 'index',
                intersect: false,
            },
            plugins: {
                legend: {
                    position: 'top',
                },
            },
            scales: {
                x: {
                    display: true,
                    grid: {
                        color: 'rgba(255, 255, 255, 0.1)'
                    }
                },
                y: {
                    display: true,
                    grid: {
                        color: 'rgba(255, 255, 255, 0.1)'
                    }
                }
            }
        };

        // Gráfico de caudal
        const flowCtx = document.getElementById('flowChart').getContext('2d');
        this.flowChart = new Chart(flowCtx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Caudal (m³/s)',
                    data: [],
                    borderColor: 'rgb(34, 197, 94)',
                    backgroundColor: 'rgba(34, 197, 94, 0.1)',
                    tension: 0.2,
                    fill: true
                }]
            },
            options: {
                ...commonOptions,
                scales: {
                    ...commonOptions.scales,
                    y: {
                        ...commonOptions.scales.y,
                        beginAtZero: true
                    }
                }
            }
        });

        // Gráfico de nivel de agua
        const levelCtx = document.getElementById('levelChart').getContext('2d');
        this.levelChart = new Chart(levelCtx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Nivel de Agua (m)',
                    data: [],
                    borderColor: 'rgb(59, 130, 246)',
                    backgroundColor: 'rgba(59, 130, 246, 0.1)',
                    tension: 0.2,
                    fill: true
                }]
            },
            options: {
                ...commonOptions,
                scales: {
                    ...commonOptions.scales,
                    y: {
                        ...commonOptions.scales.y,
                        beginAtZero: true
                    }
                }
            }
        });

        // Gráfico de estado de compuertas
        const gateCtx = document.getElementById('gateChart').getContext('2d');
        this.gateChart = new Chart(gateCtx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Posición Compuerta (%)',
                    data: [],
                    borderColor: 'rgb(234, 88, 12)',
                    backgroundColor: 'rgba(234, 88, 12, 0.1)',
                    tension: 0.1,
                    fill: true,
                    stepped: true
                }]
            },
            options: {
                ...commonOptions,
                scales: {
                    ...commonOptions.scales,
                    y: {
                        ...commonOptions.scales.y,
                        min: 0,
                        max: 100
                    }
                }
            }
        });
    }

    bindEvents() {
        // Selector de estación
        document.getElementById('stationSelect').addEventListener('change', (e) => {
            this.stationId = parseInt(e.target.value);
            this.loadData();
        });

        // Control de rango de tiempo
        document.getElementById('timeRange').addEventListener('change', (e) => {
            this.timeRange = parseInt(e.target.value);
            this.loadData();
        });

        // Botón de actualización manual
        document.getElementById('refreshBtn').addEventListener('click', () => {
            this.loadData(true);
        });

        // Control de auto-actualización
        document.getElementById('autoRefresh').addEventListener('change', (e) => {
            this.autoRefresh = e.target.checked;
            if (this.autoRefresh) {
                this.startAutoRefresh();
            } else {
                this.stopAutoRefresh();
            }
        });

        // Control de sensores virtuales
        document.getElementById('toggleSensors').addEventListener('click', () => {
            this.toggleVirtualSensors();
        });
        
        // Control del simulador
        const simulatorToggle = document.getElementById('simulatorToggle');
        if (simulatorToggle) {
            simulatorToggle.addEventListener('change', (e) => {
                this.useSimulator = e.target.checked;
                this.loadData(true);
            });
        }

        // Limpiar alertas
        document.getElementById('clearAlerts').addEventListener('click', () => {
            this.clearAlerts();
        });
    }

    startAutoRefresh() {
        this.stopAutoRefresh();
        if (this.autoRefresh) {
            this.refreshInterval = setInterval(() => {
                this.loadData();
            }, 30000); // Actualizar cada 30 segundos
        }
    }

    stopAutoRefresh() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
            this.refreshInterval = null;
        }
    }

    async loadInitialData() {
        await this.loadData();
        await this.loadVirtualSensorsStatus();
    }

    async loadData(manual = false) {
        try {
            this.updateConnectionStatus('connecting');
            
            // Animar botón de refresh si es manual
            if (manual) {
                const refreshBtn = document.getElementById('refreshBtn');
                refreshBtn.classList.add('spinning');
                setTimeout(() => refreshBtn.classList.remove('spinning'), 1000);
            }

            let data;
            
            if (this.useSimulator) {
                // Intentar usar simulador primero
                try {
                    const response = await fetch(`${this.simulatorUrl}/api/simulator/dashboard?station_id=${this.stationId}&hours=${this.timeRange}`);
                    if (response.ok) {
                        data = await response.json();
                        this.simulatorEnabled = true;
                    } else {
                        throw new Error('Simulador no disponible');
                    }
                } catch (simError) {
                    console.warn('Simulador no disponible, usando API principal:', simError.message);
                    // Fallback a API principal
                    const response = await fetch(`${this.apiBase}/api/dashboard?station_id=${this.stationId}&hours=${this.timeRange}`);
                    if (!response.ok) {
                        throw new Error(`HTTP ${response.status}`);
                    }
                    data = await response.json();
                    this.simulatorEnabled = false;
                }
            } else {
                // Usar solo API principal
                const response = await fetch(`${this.apiBase}/api/dashboard?station_id=${this.stationId}&hours=${this.timeRange}`);
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}`);
                }
                data = await response.json();
            }
            
            this.lastData = data;
            
            this.updateDashboard(data);
            this.updateCharts(data.historical_data || []);
            this.updateVirtualSensorsFromData(data.virtual_sensors || {});
            await this.loadWeatherData();
            this.updateConnectionStatus('connected');
            
        } catch (error) {
            console.error('Error loading data:', error);
            this.updateConnectionStatus('error');
            this.addAlert('error', `Error al cargar datos: ${error.message}`);
        }
    }

    async loadWeatherData() {
        const lastUpdateEl = document.getElementById('weatherLastUpdate');
        if (!lastUpdateEl) return;

        try {
            const response = await fetch(`${this.apiBase}/api/meteorology/latest?station_id=${this.stationId}`);
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const payload = await response.json();
            let meteo = payload.data || payload || {};

            const hasRealData = meteo.temperatura_c !== undefined || meteo.humedad_porcentaje !== undefined;
            if (!hasRealData) {
                meteo = this.simulateWeatherData();
            }

            const windMs = (meteo.velocidad_viento_ms !== undefined && meteo.velocidad_viento_ms !== null)
                ? meteo.velocidad_viento_ms
                : (meteo.velocidad_viento_kmh ? (meteo.velocidad_viento_kmh / 3.6) : 0);

            const windKmh = (meteo.velocidad_viento_kmh !== undefined && meteo.velocidad_viento_kmh !== null)
                ? meteo.velocidad_viento_kmh
                : windMs * 3.6;

            const pressure = (meteo.presion_hpa !== undefined && meteo.presion_hpa !== null)
                ? meteo.presion_hpa
                : (meteo.presion_atmosferica_hpa !== undefined && meteo.presion_atmosferica_hpa !== null)
                    ? meteo.presion_atmosferica_hpa
                    : 1013;

            const summary = this.lastData && this.lastData.daily_summary ? this.lastData.daily_summary : {};
            const precip24h = summary.precipitacion_total_mm ?? summary.precipitation_total_mm;
            const precip = meteo.precipitacion_mm || 0;
            const temp = meteo.temperatura_c || 0;
            const hum = meteo.humedad_porcentaje || 0;
            const solar = meteo.radiacion_solar_wm2 || 0;
            const windDir = meteo.direccion_viento_grados || 0;

            document.getElementById('weatherPrecip').textContent = `${precip.toFixed(1)} mm`;
            const precip24hValue = precip24h !== undefined && precip24h !== null ? precip24h : precip;
            document.getElementById('weatherPrecip24h').textContent = `24h: ${Number(precip24hValue).toFixed(1)}mm`;
            document.getElementById('weatherWind').textContent = `${windKmh.toFixed(1)} km/h`;
            document.getElementById('weatherWindDir').textContent = `${Math.round(windDir)}°`;
            document.getElementById('weatherTemp').textContent = `${temp.toFixed(1)} °C`;
            document.getElementById('weatherHumidity').textContent = `Hum: ${hum.toFixed(0)}%`;
            document.getElementById('weatherPressure').textContent = `${pressure.toFixed(0)} hPa`;
            document.getElementById('weatherSolar').textContent = `Solar: ${solar.toFixed(0)} W/m²`;

            const ts = meteo.fecha_hora ? new Date(meteo.fecha_hora) : new Date();
            lastUpdateEl.textContent = `Última actualización: ${ts.toLocaleString()}`;
        } catch (error) {
            console.error('Error loading weather data:', error);
            const meteo = this.simulateWeatherData();

            document.getElementById('weatherPrecip').textContent = `${meteo.precipitacion_mm.toFixed(1)} mm`;
            document.getElementById('weatherPrecip24h').textContent = `24h: ${meteo.precipitacion_mm.toFixed(1)}mm`;
            document.getElementById('weatherWind').textContent = `${(meteo.velocidad_viento_ms * 3.6).toFixed(1)} km/h`;
            document.getElementById('weatherWindDir').textContent = `${Math.round(meteo.direccion_viento_grados)}°`;
            document.getElementById('weatherTemp').textContent = `${meteo.temperatura_c.toFixed(1)} °C`;
            document.getElementById('weatherHumidity').textContent = `Hum: ${meteo.humedad_porcentaje.toFixed(0)}%`;
            document.getElementById('weatherPressure').textContent = `${meteo.presion_hpa.toFixed(0)} hPa`;
            document.getElementById('weatherSolar').textContent = `Solar: ${meteo.radiacion_solar_wm2.toFixed(0)} W/m²`;

            const ts = new Date();
            lastUpdateEl.textContent = `Última actualización: ${ts.toLocaleString()} (simulado)`;
        }
    }

    simulateWeatherData() {
        const drift = (value, min, max, delta) => {
            const next = value + (Math.random() * delta * 2 - delta);
            return Math.max(min, Math.min(max, next));
        };

        this.weatherState.temperatura_c = drift(this.weatherState.temperatura_c, 18, 36, 0.4);
        this.weatherState.humedad_porcentaje = drift(this.weatherState.humedad_porcentaje, 40, 95, 1.5);
        this.weatherState.velocidad_viento_ms = drift(this.weatherState.velocidad_viento_ms, 0, 12, 0.6);
        this.weatherState.direccion_viento_grados = drift(this.weatherState.direccion_viento_grados, 0, 360, 8);
        this.weatherState.presion_hpa = drift(this.weatherState.presion_hpa, 1004, 1022, 0.6);
        this.weatherState.radiacion_solar_wm2 = drift(this.weatherState.radiacion_solar_wm2, 0, 1100, 40);

        if (Math.random() < 0.12) {
            this.weatherState.precipitacion_mm = drift(this.weatherState.precipitacion_mm, 0, 8, 1.2);
        } else {
            this.weatherState.precipitacion_mm = drift(this.weatherState.precipitacion_mm, 0, 2, 0.4);
        }

        return {
            ...this.weatherState,
            fecha_hora: new Date().toISOString()
        };
    }

    updateConnectionStatus(status) {
        this.connectionStatus = status;
        const statusIcon = document.getElementById('statusIcon');
        const statusText = document.getElementById('statusText');
        
        statusIcon.classList.remove('connected', 'connecting', 'error');
        
        switch (status) {
            case 'connected':
                statusIcon.classList.add('connected');
                const dataSource = this.simulatorEnabled ? ' (Simulador)' : ' (API Principal)';
                statusText.textContent = 'Conectado' + dataSource;
                break;
            case 'connecting':
                statusIcon.classList.add('connecting');
                statusText.textContent = 'Conectando...';
                break;
            case 'error':
                statusIcon.classList.add('error');
                statusText.textContent = 'Error de conexión';
                break;
        }
        
        // Actualizar indicador visual del simulador
        this.updateSimulatorIndicator();
    }
    
    updateSimulatorIndicator() {
        const indicator = document.getElementById('simulatorIndicator');
        if (indicator) {
            if (this.simulatorEnabled) {
                indicator.style.display = 'inline-block';
                indicator.title = 'Usando datos simulados';
            } else {
                indicator.style.display = 'none';
            }
        }
    }

    updateDashboard(data) {
        if (!data.current_status) return;

        const status = data.current_status;
        const summary = data.daily_summary || {};

        // Actualizar estado de compuerta
        const gateStatus = this.getGateStatusText(status.status || 'UNKNOWN');
        document.getElementById('gateStatus').textContent = `${status.position_percent || 0}%`;
        document.getElementById('gateStatusBadge').textContent = gateStatus;
        document.getElementById('gatePercentage').textContent = `${status.position_percent || 0}%`;
        
        // Actualizar medidor de compuerta
        const gateGauge = document.getElementById('gateGauge');
        const gatePercentage = status.position_percent || 0;
        gateGauge.style.width = `${gatePercentage}%`;
        gateGauge.className = `gauge-fill ${this.getGaugeColorClass(gatePercentage)}`;

        // Actualizar nivel de agua
        const waterLevel = status.level_m || 0;
        document.getElementById('waterLevel').textContent = waterLevel.toFixed(3);
        
        // Actualizar indicador de nivel
        const levelFill = document.getElementById('levelFill');
        const levelPercentage = Math.min(100, (waterLevel / 5.0) * 100); // Asumiendo máximo 5m
        levelFill.style.height = `${levelPercentage}%`;
        levelFill.className = `level-fill ${this.getLevelColorClass(levelPercentage)}`;

        // Actualizar caudal
        const currentFlow = status.flow_m3s || 0;
        document.getElementById('currentFlow').textContent = currentFlow.toFixed(4);
        
        // Actualizar tendencia de flujo
        this.updateFlowTrend(currentFlow);

        // Actualizar volumen diario
        const dailyVolume = summary.total_m3 || 0;
        document.getElementById('dailyVolume').textContent = dailyVolume.toFixed(1);
        
        // Actualizar progreso diario (asumiendo meta de 10000 m³)
        const dailyTarget = 10000;
        const dailyProgress = Math.min(100, (dailyVolume / dailyTarget) * 100);
        document.getElementById('dailyProgress').style.width = `${dailyProgress}%`;
        document.getElementById('dailyTarget').textContent = `Meta diaria: ${dailyTarget.toLocaleString()} m³`;

        // Actualizar timestamp de última actualización
        if (status.last_update) {
            const lastUpdate = new Date(status.last_update);
            document.getElementById('gateLastUpdate').textContent = 
                `Última actualización: ${lastUpdate.toLocaleString()}`;
        }

        // Verificar alertas
        this.checkAlerts(status, summary);
    }

    updateCharts(historicalData) {
        // Si no hay datos históricos, generar datos simulados
        if (!historicalData || historicalData.length === 0) {
            console.log('⚠️  Sin datos históricos, generando simulación...');
            historicalData = this.generateSimulatedHistoricalData(20);
        }

        // Formatear etiquetas de tiempo
        const labels = historicalData.map(item => {
            const date = new Date(item.timestamp);
            return this.timeRange <= 6 ? 
                date.toLocaleTimeString('es', { hour: '2-digit', minute: '2-digit' }) :
                date.toLocaleString('es', { 
                    day: '2-digit', 
                    month: '2-digit',
                    hour: '2-digit', 
                    minute: '2-digit' 
                });
        });

        // Datos para gráficos
        const flowData = historicalData.map(item => item.flow_m3s || 0);
        const levelData = historicalData.map(item => item.level_m || 0);
        
        // Obtener datos de compuerta (simulado o real)
        const gateData = historicalData.map(item => item.gate_opening_percent || (Math.random() * 100));

        // Actualizar gráfico de caudal
        if (this.flowChart) {
            this.flowChart.data.labels = labels;
            this.flowChart.data.datasets[0].data = flowData;
            this.flowChart.update('none');
            this.updateFlowStats(flowData);
        }

        // Actualizar gráfico de nivel
        if (this.levelChart) {
            this.levelChart.data.labels = labels;
            this.levelChart.data.datasets[0].data = levelData;
            this.levelChart.update('none');
            this.updateLevelStats(levelData);
        }

        // Actualizar gráfico de compuerta
        if (this.gateChart) {
            this.gateChart.data.labels = labels;
            this.gateChart.data.datasets[0].data = gateData;
            this.gateChart.update('none');
        }
    }
    
    generateSimulatedHistoricalData(count) {
        const data = [];
        const now = Date.now();
        
        for (let i = count; i > 0; i--) {
            const baseLevel = 2.5 + Math.sin(i * 0.2) * 1.5;
            const baseFlow = Math.max(0, baseLevel - 1.0) * 0.5;
            
            data.push({
                timestamp: new Date(now - i * 5 * 60 * 1000), // 5 minutos de diferencia
                level_m: baseLevel + (Math.random() - 0.5) * 0.3,
                flow_m3s: baseFlow + (Math.random() - 0.5) * 0.1,
                gate_opening_percent: Math.max(0, Math.min(100, baseLevel * 20 + (Math.random() - 0.5) * 10))
            });
        }
        
        return data;
    }

    updateFlowStats(flowData) {
        if (flowData.length === 0) return;

        const avg = flowData.reduce((a, b) => a + b, 0) / flowData.length;
        const max = Math.max(...flowData);
        
        document.getElementById('flowStats').innerHTML = `
            <span>Promedio: ${avg.toFixed(3)} m³/s</span>
            <span>Pico: ${max.toFixed(3)} m³/s</span>
        `;
    }

    updateLevelStats(levelData) {
        if (levelData.length === 0) return;

        const avg = levelData.reduce((a, b) => a + b, 0) / levelData.length;
        const min = Math.min(...levelData);
        const max = Math.max(...levelData);
        
        document.getElementById('levelStats').innerHTML = `
            <span>Promedio: ${avg.toFixed(3)} m</span>
            <span>Rango: ${min.toFixed(2)}-${max.toFixed(2)} m</span>
        `;
    }

    updateFlowTrend(currentFlow) {
        // Lógica simple de tendencia - en producción usaría datos históricos
        const trend = Math.random() > 0.5 ? 'up' : Math.random() > 0.5 ? 'down' : 'stable';
        const trendElement = document.getElementById('flowTrend');
        
        let icon, text;
        switch (trend) {
            case 'up':
                icon = 'fas fa-arrow-up';
                text = 'Incrementando';
                trendElement.className = 'flow-trend trend-up';
                break;
            case 'down':
                icon = 'fas fa-arrow-down';
                text = 'Disminuyendo';
                trendElement.className = 'flow-trend trend-down';
                break;
            default:
                icon = 'fas fa-arrow-right';
                text = 'Estable';
                trendElement.className = 'flow-trend trend-stable';
        }
        
        trendElement.innerHTML = `<i class="${icon}"></i><span>${text}</span>`;
    }

    async loadVirtualSensorsStatus() {
        try {
            let sensors;
            
            if (this.simulatorEnabled) {
                try {
                    const response = await fetch(`${this.simulatorUrl}/api/simulator/sensors?station_id=${this.stationId}`);
                    if (response.ok) {
                        const sensorsData = await response.json();
                        sensors = this.formatVirtualSensorsFromAPI(sensorsData);
                    } else {
                        throw new Error('No se pudieron cargar sensores del simulador');
                    }
                } catch (simError) {
                    console.warn('Usando sensores virtuales simulados:', simError.message);
                    sensors = this.getDefaultVirtualSensors();
                }
            } else {
                sensors = this.getDefaultVirtualSensors();
            }

            this.renderVirtualSensors(sensors);
            document.getElementById('sensorCount').textContent = `${sensors.length} sensores`;

        } catch (error) {
            console.error('Error loading sensors:', error);
        }
    }
    
    getDefaultVirtualSensors() {
        return [
            { id: 1, name: 'Compuerta Principal A', type: 'gate', status: 'active', value: '45%' },
            { id: 2, name: 'Compuerta Principal B', type: 'gate', status: 'active', value: '78%' },
            { id: 3, name: 'Compuerta Auxiliar 1', type: 'gate', status: 'active', value: '12%' },
            { id: 11, name: 'Nivel Embalse Principal', type: 'level', status: 'active', value: '2.45m' },
            { id: 12, name: 'Nivel Canal Entrada', type: 'level', status: 'active', value: '1.82m' },
            { id: 13, name: 'Nivel Canal Salida', type: 'level', status: 'active', value: '1.65m' }
        ];
    }
    
    formatVirtualSensorsFromAPI(sensorsData) {
        const sensors = [];
        let id = 1;
        
        for (const [key, sensor] of Object.entries(sensorsData)) {
            sensors.push({
                id: id++,
                name: sensor.name || key.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase()),
                type: this.getSensorType(key),
                status: sensor.status === 'alert' ? 'warning' : 'active',
                value: `${sensor.value} ${sensor.unit}`,
                percentage: sensor.percentage || 0
            });
        }
        
        return sensors;
    }
    
    getSensorType(sensorKey) {
        if (sensorKey.includes('level') || sensorKey.includes('water')) return 'level';
        if (sensorKey.includes('gate') || sensorKey.includes('position')) return 'gate';
        if (sensorKey.includes('flow') || sensorKey.includes('velocity')) return 'flow';
        if (sensorKey.includes('temp')) return 'temperature';
        return 'sensor';
    }
    
    updateVirtualSensorsFromData(sensorsData) {
        if (!sensorsData || Object.keys(sensorsData).length === 0) return;
        
        const sensors = this.formatVirtualSensorsFromAPI(sensorsData);
        this.renderVirtualSensors(sensors);
        document.getElementById('sensorCount').textContent = `${sensors.length} sensores`;
    }

    renderVirtualSensors(sensors) {
        const grid = document.getElementById('sensorsGrid');
        grid.innerHTML = sensors.map(sensor => `
            <div class="sensor-card ${sensor.status}" title="${sensor.name}">
                <div class="sensor-header">
                    <i class="fas fa-${this.getSensorIcon(sensor.type)}"></i>
                    <span class="sensor-name">${sensor.name}</span>
                    <span class="sensor-status ${sensor.status}"></span>
                </div>
                <div class="sensor-value">${sensor.value}</div>
                <div class="sensor-details">
                    <span class="sensor-id">ID: ${sensor.id}</span>
                    ${sensor.percentage ? `<span class="sensor-percentage">${sensor.percentage}%</span>` : ''}
                </div>
            </div>
        `).join('');
    }
    
    getSensorIcon(sensorType) {
        const icons = {
            'gate': 'door-open',
            'level': 'tint',
            'flow': 'water',
            'temperature': 'thermometer-half',
            'pressure': 'gauge-high',
            'sensor': 'microchip'
        };
        return icons[sensorType] || 'microchip';
    }

    toggleVirtualSensors() {
        // Implementar lógica para activar/desactivar sensores virtuales
        const button = document.getElementById('toggleSensors');
        const isActive = button.classList.contains('active');
        
        if (isActive) {
            button.innerHTML = '<i class="fas fa-play"></i> Activar';
            button.classList.remove('active');
            this.addAlert('info', 'Sensores virtuales desactivados');
        } else {
            button.innerHTML = '<i class="fas fa-pause"></i> Desactivar';
            button.classList.add('active');
            this.addAlert('success', 'Sensores virtuales activados');
        }
    }

    // Funciones auxiliares
    getGateStatusText(status) {
        const statusMap = {
            'OPEN': 'ABIERTA',
            'CLOSE': 'CERRADA', 
            'MOVING': 'EN MOVIMIENTO',
            'PARTIAL': 'PARCIAL',
            'ERROR': 'ERROR',
            'UNKNOWN': 'DESCONOCIDO'
        };
        return statusMap[status] || status;
    }

    getGaugeColorClass(percentage) {
        if (percentage < 20) return 'low';
        if (percentage < 60) return 'medium';
        return 'high';
    }

    getLevelColorClass(percentage) {
        if (percentage < 30) return 'low';
        if (percentage < 70) return 'normal';
        return 'high';
    }

    checkAlerts(status, summary) {
        // Verificar condiciones de alerta
        if (status.level_m > 4.0) {
            this.addAlert('warning', 'Nivel de agua alto: ' + status.level_m.toFixed(2) + 'm');
        }
        
        if (status.flow_m3s > 10.0) {
            this.addAlert('warning', 'Caudal elevado: ' + status.flow_m3s.toFixed(2) + ' m³/s');
        }
        
        if (!status.last_update || (Date.now() - new Date(status.last_update).getTime()) > 300000) {
            this.addAlert('error', 'Sin datos recientes de la estación');
        }
    }

    addAlert(type, message) {
        const alert = {
            id: Date.now(),
            type: type,
            message: message,
            timestamp: new Date()
        };
        
        this.alerts.unshift(alert);
        this.alerts = this.alerts.slice(0, 10); // Mantener solo las últimas 10
        
        this.renderAlerts();
    }

    renderAlerts() {
        const container = document.getElementById('alertsContainer');
        const section = document.getElementById('alertsSection');
        
        if (this.alerts.length === 0) {
            section.style.display = 'none';
            return;
        }
        
        section.style.display = 'block';
        container.innerHTML = this.alerts.map(alert => `
            <div class="alert alert-${alert.type}">
                <div class="alert-content">
                    <i class="fas fa-${this.getAlertIcon(alert.type)}"></i>
                    <span class="alert-message">${alert.message}</span>
                </div>
                <div class="alert-time">${alert.timestamp.toLocaleTimeString()}</div>
            </div>
        `).join('');
    }

    getAlertIcon(type) {
        const icons = {
            'error': 'exclamation-circle',
            'warning': 'exclamation-triangle',
            'info': 'info-circle',
            'success': 'check-circle'
        };
        return icons[type] || 'info-circle';
    }

    clearAlerts() {
        this.alerts = [];
        this.renderAlerts();
    }
}

// Inicializar dashboard cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    window.dashboard = new AdvancedMonitoringDashboard();

    // Agregar estilos CSS adicionales dinámicamente
    const additionalStyles = `
        .spinning { animation: spin 1s linear infinite; }
        @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
        .gauge-fill.low { background: linear-gradient(90deg, #ef4444, #f87171); }
        .gauge-fill.medium { background: linear-gradient(90deg, #f59e0b, #fbbf24); }
        .gauge-fill.high { background: linear-gradient(90deg, #22c55e, #4ade80); }
        .level-fill.low { background: linear-gradient(0deg, #ef4444, #f87171); }
        .level-fill.normal { background: linear-gradient(0deg, #22c55e, #4ade80); }
        .level-fill.high { background: linear-gradient(0deg, #f59e0b, #fbbf24); }
        .trend-up { color: #22c55e; }
        .trend-down { color: #ef4444; }
        .trend-stable { color: #6b7280; }
        .connected { color: #22c55e; }
        .connecting { color: #f59e0b; animation: pulse 2s infinite; }
        .error { color: #ef4444; }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
    `;
    
    const style = document.createElement('style');
    style.textContent = additionalStyles;
    document.head.appendChild(style);
});
