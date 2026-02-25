/**
 * Dashboard Extended - JavaScript para paneles IoT
 * Promotora Palmera de Antioquia S.A.S.
 * Fecha: 20 de febrero de 2026
 */

const API_BASE = '/api';
let currentStationId = 1;
let autoControlEnabled = false;
let refreshInterval = null;
let weatherSimState = {
    temperatura_c: 24.0,
    humedad_porcentaje: 60.0,
    precipitacion_mm: 0.0,
    presion_hpa: 1013.0,
    velocidad_viento_ms: 3.5,
    direccion_viento_grados: 180,
    radiacion_solar_wm2: 700
};

// Gráficas globales
let meteoroCharts = {
    precipitation: null,
    wind: null,
    temperature: null,
    pressure: null
};

// Histórico de datos para gráficas
let meteoroHistory = {
    precipitation: [],
    wind: [],
    temperature: [],
    pressure: [],
    timestamps: []
};

// ==================== INICIALIZACIÓN ====================

document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 Inicializando Dashboard Extendido...');
    
    // Validar que los elementos existan
    const requiredCanvases = ['precipitationChart', 'windChart', 'temperatureChart', 'pressureChart'];
    const missing = requiredCanvases.filter(id => !document.getElementById(id));
    if (missing.length > 0) {
        console.warn('⚠️  Falta canvases:', missing);
    }
    
    // Event listeners
    setupEventListeners();
    
    // Inicializar gráficas
    initWeatherCharts();
    
    // Dar tiempo a que se rendericen los canvas antes de llenarlos
    setTimeout(() => {
        console.log('⏰ Iniciando seed de datos...');
        seedWeatherHistory();
        console.log('⏰ Cargando todos los datos...');
        loadAllData();
        console.log('✓ Dashboard Extendido inicializado completamente');
    }, 500);
    
    // Auto-refresh cada 10 segundos
    startAutoRefresh();
});

function setupEventListeners() {
    // Toggle control automático
    const autoToggle = document.getElementById('autoControlToggle');
    if (autoToggle) {
        autoToggle.addEventListener('change', handleAutoControlToggle);
    }
    
    // Botones de control manual
    const startBtn = document.getElementById('startPumpBtn');
    const stopBtn = document.getElementById('stopPumpBtn');
    
    if (startBtn) {
        startBtn.addEventListener('click', () => handleManualControl('START'));
    }
    
    if (stopBtn) {
        stopBtn.addEventListener('click', () => handleManualControl('STOP'));
    }

    const stopSystemBtn = document.getElementById('stopSystemBtn');
    if (stopSystemBtn) {
        stopSystemBtn.addEventListener('click', handleStopSystem);
    }
    
    // Selector de estación
    const stationSelect = document.getElementById('stationSelect');
    if (stationSelect) {
        stationSelect.addEventListener('change', (e) => {
            currentStationId = parseInt(e.target.value);
            resetWeatherHistory();
            loadAllData();
        });
    }
}

function resetWeatherHistory() {
    meteoroHistory.precipitation = [];
    meteoroHistory.wind = [];
    meteoroHistory.temperature = [];
    meteoroHistory.pressure = [];
    meteoroHistory.timestamps = [];

    Object.values(meteoroCharts).forEach((chart) => {
        if (chart) {
            chart.data.labels = [];
            chart.data.datasets[0].data = [];
            chart.update('none');
        }
    });

    updateWeatherStats();
}

function seedWeatherHistory() {
    if (meteoroHistory.timestamps.length > 0) {
        console.log('✓ Histórico ya tiene datos, saltando seed');
        return;
    }

    console.log('📊 Sembrando histórico de datos meteorológicos...');
    
    // Generar 15 muestras iniciales para llenar los gráficos
    for (let i = 0; i < 15; i += 1) {
        const sample = simulateWeatherData();
        
        // Timestamp escalonado en el pasado
        const timeOffset = (15 - i - 1) * 60 * 1000; // 1 minuto de diferencia
        const timestamp = new Date(Date.now() - timeOffset).toLocaleTimeString('es-CO');
        
        const precip = toNumber(sample.precipitacion_mm ?? sample.precipitation_mm, 0);
        const windKmh = toNumber(sample.velocidad_viento_kmh ?? sample.wind_speed_kmh, 0);
        const temp = toNumber(sample.temperatura_c ?? sample.temperature_c, 0);
        const pressure = toNumber(sample.presion_hpa ?? sample.presion_atmosferica_hpa ?? sample.pressure_hpa, 1013);
        
        meteoroHistory.precipitation.push(precip);
        meteoroHistory.wind.push(windKmh);
        meteoroHistory.temperature.push(temp);
        meteoroHistory.pressure.push(pressure);
        meteoroHistory.timestamps.push(timestamp);
    }
    
    console.log(`✓ Datos agregados: ${meteoroHistory.timestamps.length} timestamps`);
    
    // Actualizar gráficos inmediatamente
    updateAllWeatherCharts();
    updateWeatherStats();
    
    console.log('✓ Histórico de clima inicializado con 15 muestras');
}

function updateAllWeatherCharts() {
    console.log('📊 updateAllWeatherCharts() llamado');
    if (!meteoroCharts) {
        console.warn('⚠️  meteoroCharts no está inicializado');
        return;
    }
    
    if (meteoroCharts.precipitation && meteoroHistory.timestamps.length > 0) {
        meteoroCharts.precipitation.data.labels = meteoroHistory.timestamps;
        meteoroCharts.precipitation.data.datasets[0].data = meteoroHistory.precipitation;
        meteoroCharts.precipitation.update('none');
        console.log('✓ Gráfico Precipitación actualizado con', meteoroHistory.precipitation.length, 'datos');
    }
    
    if (meteoroCharts.wind && meteoroHistory.timestamps.length > 0) {
        meteoroCharts.wind.data.labels = meteoroHistory.timestamps;
        meteoroCharts.wind.data.datasets[0].data = meteoroHistory.wind;
        meteoroCharts.wind.update('none');
        console.log('✓ Gráfico Viento actualizado con', meteoroHistory.wind.length, 'datos');
    }
    
    if (meteoroCharts.temperature && meteoroHistory.timestamps.length > 0) {
        meteoroCharts.temperature.data.labels = meteoroHistory.timestamps;
        meteoroCharts.temperature.data.datasets[0].data = meteoroHistory.temperature;
        meteoroCharts.temperature.update('none');
        console.log('✓ Gráfico Temperatura actualizado con', meteoroHistory.temperature.length, 'datos');
    }
    
    if (meteoroCharts.pressure && meteoroHistory.timestamps.length > 0) {
        meteoroCharts.pressure.data.labels = meteoroHistory.timestamps;
        meteoroCharts.pressure.data.datasets[0].data = meteoroHistory.pressure;
        meteoroCharts.pressure.update('none');
        console.log('✓ Gráfico Presión actualizado con', meteoroHistory.pressure.length, 'datos');
    }
}
        meteoroCharts.wind.data.datasets[0].data = meteoroHistory.wind;
        meteoroCharts.wind.update('none');
        console.log('✓ Gráfico Viento actualizado');
    }
    
    if (meteoroCharts.temperature && meteoroHistory.timestamps.length > 0) {
        meteoroCharts.temperature.data.labels = meteoroHistory.timestamps;
        meteoroCharts.temperature.data.datasets[0].data = meteoroHistory.temperature;
        meteoroCharts.temperature.update('none');
        console.log('✓ Gráfico Temperatura actualizado');
    }
    
    if (meteoroCharts.pressure && meteoroHistory.timestamps.length > 0) {
        meteoroCharts.pressure.data.labels = meteoroHistory.timestamps;
        meteoroCharts.pressure.data.datasets[0].data = meteoroHistory.pressure;
        meteoroCharts.pressure.update('none');
        console.log('✓ Gráfico Presión actualizado');
    }
}

// ==================== INICIALIZACIÓN DE GRÁFICAS ====================

function initWeatherCharts() {
    const chartConfig = {
        type: 'line',
        options: {
            responsive: true,
            maintainAspectRatio: true,
            animation: { duration: 0 },
            plugins: {
                legend: { display: true, position: 'top' }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { font: { size: 10 } }
                },
                x: {
                    ticks: { font: { size: 9 } }
                }
            }
        }
    };
    
    // Gráfica Precipitación
    const precipCanvas = document.getElementById('precipitationChart');
    if (precipCanvas) {
        meteoroCharts.precipitation = new Chart(precipCanvas, {
            ...chartConfig,
            data: {
                labels: [],
                datasets: [{
                    label: 'Precipitación (mm)',
                    data: [],
                    borderColor: '#3498db',
                    backgroundColor: 'rgba(52, 152, 219, 0.1)',
                    tension: 0.3
                }]
            }
        });
    }
    
    // Gráfica Viento
    const windCanvas = document.getElementById('windChart');
    if (windCanvas) {
        meteoroCharts.wind = new Chart(windCanvas, {
            ...chartConfig,
            data: {
                labels: [],
                datasets: [{
                    label: 'Velocidad Viento (km/h)',
                    data: [],
                    borderColor: '#e74c3c',
                    backgroundColor: 'rgba(231, 76, 60, 0.1)',
                    tension: 0.3
                }]
            }
        });
    }
    
    // Gráfica Temperatura
    const tempCanvas = document.getElementById('temperatureChart');
    if (tempCanvas) {
        meteoroCharts.temperature = new Chart(tempCanvas, {
            ...chartConfig,
            data: {
                labels: [],
                datasets: [{
                    label: 'Temperatura (°C)',
                    data: [],
                    borderColor: '#f39c12',
                    backgroundColor: 'rgba(243, 156, 18, 0.1)',
                    tension: 0.3
                }]
            }
        });
    }
    
    // Gráfica Presión
    const pressureCanvas = document.getElementById('pressureChart');
    if (pressureCanvas) {
        meteoroCharts.pressure = new Chart(pressureCanvas, {
            ...chartConfig,
            data: {
                labels: [],
                datasets: [{
                    label: 'Presión Atmosférica (hPa)',
                    data: [],
                    borderColor: '#9b59b6',
                    backgroundColor: 'rgba(155, 89, 182, 0.1)',
                    tension: 0.3
                }]
            }
        });
    }
}

// ==================== CARGA DE DATOS ====================

async function loadAllData() {
    try {
        await Promise.all([
            loadWeatherData(),
            loadPumpStatus(),
            loadActiveAlerts(),
            loadControlStatus(),
            loadLastDecision()
        ]);
    } catch (error) {
        console.error('Error cargando datos:', error);
    }
}

// ==================== DATOS METEOROLÓGICOS ====================

async function loadWeatherData() {
    try {
        const response = await fetch(`${API_BASE}/meteorology/latest?station_id=${currentStationId}`);
        
        if (!response.ok) {
            console.warn('No hay datos meteorológicos disponibles, usando simulacion local');
            const fallback = simulateWeatherData();
            updateWeatherUI(fallback);
            updateWeatherCharts(fallback);
            return;
        }
        
        const result = await response.json();

        let payload = null;

        if (result && result.data) {
            payload = result.data;
        } else if (result && result.success && result.data) {
            payload = result.data;
        } else if (result) {
            payload = result;
        }

        const hasData = payload && (payload.temperatura_c !== undefined || payload.humedad_porcentaje !== undefined);
        if (!hasData) {
            const fallback = simulateWeatherData();
            updateWeatherUI(fallback);
            updateWeatherCharts(fallback);
            return;
        }

        updateWeatherUI(payload);
        updateWeatherCharts(payload);
    } catch (error) {
        console.error('Error cargando datos meteorológicos:', error);
        const fallback = simulateWeatherData();
        updateWeatherUI(fallback);
        updateWeatherCharts(fallback);
    }
}

function simulateWeatherData() {
    const drift = (value, min, max, delta) => {
        const next = value + (Math.random() * delta * 2 - delta);
        return Math.max(min, Math.min(max, next));
    };

    weatherSimState.temperatura_c = drift(weatherSimState.temperatura_c, 18, 36, 0.4);
    weatherSimState.humedad_porcentaje = drift(weatherSimState.humedad_porcentaje, 40, 95, 1.5);
    weatherSimState.velocidad_viento_ms = drift(weatherSimState.velocidad_viento_ms, 0, 12, 0.6);
    weatherSimState.direccion_viento_grados = drift(weatherSimState.direccion_viento_grados, 0, 360, 8);
    weatherSimState.presion_hpa = drift(weatherSimState.presion_hpa, 1004, 1022, 0.6);
    weatherSimState.radiacion_solar_wm2 = drift(weatherSimState.radiacion_solar_wm2, 0, 1100, 40);

    if (Math.random() < 0.12) {
        weatherSimState.precipitacion_mm = drift(weatherSimState.precipitacion_mm, 0, 8, 1.2);
    } else {
        weatherSimState.precipitacion_mm = drift(weatherSimState.precipitacion_mm, 0, 2, 0.4);
    }

    return {
        ...weatherSimState,
        velocidad_viento_kmh: weatherSimState.velocidad_viento_ms * 3.6,
        presion_atmosferica_hpa: weatherSimState.presion_hpa,
        fecha_hora: new Date().toISOString()
    };
}

function updateWeatherCharts(data) {
    const precip = toNumber(data.precipitacion_mm ?? data.precipitation_mm, 0);
    const windKmh = toNumber(data.velocidad_viento_kmh ?? data.wind_speed_kmh, 0);
    const temp = toNumber(data.temperatura_c ?? data.temperature_c, 0);
    const pressure = toNumber(data.presion_hpa ?? data.presion_atmosferica_hpa ?? data.pressure_hpa, 1013);
    const timestamp = new Date(data.fecha_hora ?? data.timestamp).toLocaleTimeString('es-CO');
    
    // Mantener últimas 20 mediciones
    if (meteoroHistory.timestamps.length >= 20) {
        meteoroHistory.precipitation.shift();
        meteoroHistory.wind.shift();
        meteoroHistory.temperature.shift();
        meteoroHistory.pressure.shift();
        meteoroHistory.timestamps.shift();
    }
    
    meteoroHistory.precipitation.push(precip);
    meteoroHistory.wind.push(windKmh);
    meteoroHistory.temperature.push(temp);
    meteoroHistory.pressure.push(pressure);
    meteoroHistory.timestamps.push(timestamp);
    
    // Actualizar gráficas
    if (meteoroCharts.precipitation) {
        meteoroCharts.precipitation.data.labels = meteoroHistory.timestamps;
        meteoroCharts.precipitation.data.datasets[0].data = meteoroHistory.precipitation;
        meteoroCharts.precipitation.update('none');
    }
    
    if (meteoroCharts.wind) {
        meteoroCharts.wind.data.labels = meteoroHistory.timestamps;
        meteoroCharts.wind.data.datasets[0].data = meteoroHistory.wind;
        meteoroCharts.wind.update('none');
    }
    
    if (meteoroCharts.temperature) {
        meteoroCharts.temperature.data.labels = meteoroHistory.timestamps;
        meteoroCharts.temperature.data.datasets[0].data = meteoroHistory.temperature;
        meteoroCharts.temperature.update('none');
    }
    
    if (meteoroCharts.pressure) {
        meteoroCharts.pressure.data.labels = meteoroHistory.timestamps;
        meteoroCharts.pressure.data.datasets[0].data = meteoroHistory.pressure;
        meteoroCharts.pressure.update('none');
    }

    updateWeatherStats();
}

function updateWeatherStats() {
    const precipSum = meteoroHistory.precipitation.reduce((acc, val) => acc + val, 0);
    const windMax = meteoroHistory.wind.length ? meteoroHistory.wind.reduce((max, val) => Math.max(max, val), 0) : 0;
    const tempAvg = meteoroHistory.temperature.length
        ? meteoroHistory.temperature.reduce((acc, val) => acc + val, 0) / meteoroHistory.temperature.length
        : 0;
    const pressureCurrent = meteoroHistory.pressure.length
        ? meteoroHistory.pressure[meteoroHistory.pressure.length - 1]
        : 0;

    const precipEl = document.getElementById('precipStats');
    if (precipEl) {
        precipEl.textContent = `Acumulado: ${precipSum.toFixed(1)} mm`;
    }

    const windEl = document.getElementById('windStats');
    if (windEl) {
        windEl.textContent = `Maxima: ${windMax.toFixed(1)} km/h`;
    }

    const tempEl = document.getElementById('tempStats');
    if (tempEl) {
        tempEl.textContent = `Promedio: ${tempAvg.toFixed(1)} °C`;
    }

    const pressureEl = document.getElementById('pressureStats');
    if (pressureEl) {
        pressureEl.textContent = `Actual: ${pressureCurrent.toFixed(1)} hPa`;
    }
}

function updateWeatherUI(data) {
    const precip = toNumber(data.precipitacion_mm ?? data.precipitation_mm, 0);
    const windMs = toNumber(data.velocidad_viento_ms, 0);
    const windKmh = toNumber(data.velocidad_viento_kmh ?? data.wind_speed_kmh, windMs * 3.6);
    const windDir = toNumber(data.direccion_viento_grados ?? data.wind_direction_deg, 0);
    const temp = toNumber(data.temperatura_c ?? data.temperature_c, 0);
    const hum = toNumber(data.humedad_porcentaje ?? data.humidity_percent, 0);
    const pressure = toNumber(data.presion_hpa ?? data.presion_atmosferica_hpa ?? data.pressure_hpa, 1013);
    const solar = toNumber(data.radiacion_solar_wm2 ?? data.solar_radiation_wm2, 0);

    // Precipitación
    const precipEl = document.getElementById('weatherPrecip');
    if (precipEl) {
        precipEl.textContent = `${precip.toFixed(1)} mm`;
        precipEl.parentElement.querySelector('.weather-sub').textContent = 'Última hora';
    }
    
    // Viento
    const windEl = document.getElementById('weatherWind');
    if (windEl) {
        windEl.textContent = `${windKmh.toFixed(1)} km/h`;
        
        const dirEl = document.getElementById('weatherWindDir');
        if (dirEl) {
            const direction = getWindDirection(windDir);
            dirEl.textContent = `${direction} (${Math.round(windDir)}°)`;
        }
    }
    
    // Temperatura y humedad
    const tempEl = document.getElementById('weatherTemp');
    if (tempEl) {
        tempEl.textContent = `${temp.toFixed(1)} °C`;
        
        const humEl = document.getElementById('weatherHumidity');
        if (humEl) {
            humEl.textContent = `Hum: ${hum.toFixed(0)}%`;
        }
    }
    
    // Presión y radiación solar
    const pressureEl = document.getElementById('weatherPressure');
    if (pressureEl) {
        pressureEl.textContent = `${pressure.toFixed(1)} hPa`;
        
        const solarEl = document.getElementById('weatherSolar');
        if (solarEl) {
            solarEl.textContent = `Solar: ${solar.toFixed(0)} W/m²`;
        }
    }
    
    // Última actualización
    const updateEl = document.getElementById('weatherLastUpdate');
    if (updateEl) {
        const rawTimestamp = data.fecha_hora ?? data.timestamp;
        updateEl.textContent = `Última actualización: ${formatTimestamp(rawTimestamp)}`;
    }
}

function toNumber(value, fallback = 0) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
}

function getWindDirection(degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
    const index = Math.round(degrees / 45) % 8;
    return directions[index];
}

// ==================== ESTADO DE BOMBA ====================

async function loadPumpStatus() {
    console.log('📊 loadPumpStatus() llamado...');
    try {
        const url = `${API_BASE}/pump/status?pump_id=${currentStationId}`;
        console.log('🔄 Fetching:', url);
        const response = await fetch(url);
        console.log('📡 Response status:', response.status);
        
        if (response.ok) {
            const result = await response.json();
            console.log('✓ API data:', result);
            if (result.success && result.data) {
                console.log('✓ updatePumpUI con datos reales');
                updatePumpUI(result.data);
                return;
            }
        }
    } catch (error) {
        console.error('❌ Error en loadPumpStatus:', error);
    }
    
    // Si no hay datos reales, usar simulación
    console.log('⚠️  Usando datos simulados de bomba');
    const pumpData = generateSimulatedPumpData();
    console.log('✓ Generated pump data:', pumpData);
    updatePumpUI(pumpData);
}

function generateSimulatedPumpData() {
    const running = Math.random() > 0.3;
    return {
        estado: running ? 'ENCENDIDA' : 'APAGADA',
        is_running: running,
        caudal_m3h: running ? 2.5 + Math.random() * 1.5 : 0,
        presion_entrada_bar: running ? 0.5 + Math.random() * 0.8 : 0,
        presion_salida_bar: running ? 1.5 + Math.random() * 1.5 : 0,
        temperatura_motor_c: running ? 65 + Math.random() * 20 : 25,
        consumo_energia_kw: running ? 15 + Math.random() * 10 : 0,
        horas_operacion: 1200 + Math.random() * 800
    };
}

function updatePumpUI(data) {
    console.log('🎯 updatePumpUI() - Datos recibidos:', data);
    
    const estado = data.estado || (data.is_running ? 'ENCENDIDA' : 'APAGADA');
    const running = data.is_running !== undefined ? data.is_running : estado !== 'APAGADA';
    const flow = toNumber(data.caudal_m3h ?? data.flow_rate_m3h, 0);
    const pressureIn = toNumber(data.presion_entrada_bar ?? data.inlet_pressure_bar, 0);
    const pressureOut = toNumber(data.presion_salida_bar ?? data.outlet_pressure_bar, 0);
    const power = toNumber(data.consumo_energia_kw ?? data.power_consumption_kwh, 0);
    const motorTemp = toNumber(data.temperatura_motor_c ?? data.motor_temperature_c, 0);
    const hours = toNumber(data.horas_operacion ?? data.running_hours, 0);

    console.log('📋 Valores procesados - Estado:', estado, ', Running:', running);

    // Badge de estado
    const badge = document.getElementById('pumpStatusBadge');
    console.log('🔍 Badge element:', badge ? 'FOUND' : 'NOT FOUND');
    if (badge) {
        badge.textContent = running ? 'EN OPERACIÓN' : 'DETENIDA';
        badge.className = 'pump-status-badge ' + (running ? 'running' : 'stopped');
        console.log('✓ Badge actualizado:', badge.textContent);
    }
    
    // Métricas
    updateElement('pumpFlow', `${flow.toFixed(2)} m³/h`);
    updateElement('pumpPressureIn', `${pressureIn.toFixed(2)} bar`);
    updateElement('pumpPressureOut', `${pressureOut.toFixed(2)} bar`);
    updateElement('pumpMotorTemp', `${motorTemp.toFixed(1)} °C`);
    updateElement('pumpPower', `${power.toFixed(2)} kWh`);
    updateElement('pumpHours', `${hours.toFixed(1)} h`);
    
    // Colorear temperatura según riesgo
    const motorTempEl = document.getElementById('pumpMotorTemp');
    if (motorTempEl && motorTemp > 75) {
        motorTempEl.style.color = '#e74c3c'; // Rojo si > 75°C
    } else if (motorTempEl) {
        motorTempEl.style.color = '#2c3e50';
    }
    console.log('✓ updatePumpUI completado');
}

// ==================== ESTADO DE CONTROL ====================

async function loadControlStatus() {
    try {
        const response = await fetch(`${API_BASE}/control/status?station_id=${currentStationId}`);
        
        if (!response.ok) {
            autoControlEnabled = false;
            updateControlUI();
            return;
        }
        
        const result = await response.json();
        
        if (result && result.success) {
            const enabled = result.control_automatico_habilitado;
            autoControlEnabled = enabled === undefined ? false : enabled;
            updateControlUI();
        }
    } catch (error) {
        console.error('Error cargando estado de control:', error);
        autoControlEnabled = false;
        updateControlUI();
    }
}

function updateControlUI() {
    const toggle = document.getElementById('autoControlToggle');
    const modeText = document.getElementById('controlModeText');
    const manualControls = document.getElementById('manualControls');
    
    if (toggle) {
        toggle.checked = autoControlEnabled;
    }
    
    if (modeText) {
        modeText.textContent = autoControlEnabled ? 'Modo Automático' : 'Modo Manual';
        modeText.style.color = autoControlEnabled ? '#27ae60' : '#e74c3c';
    }
    
    if (manualControls) {
        manualControls.style.display = autoControlEnabled ? 'none' : 'flex';
    }
}

async function handleAutoControlToggle(event) {
    const enabled = event.target.checked;
    
    try {
        const response = await fetch(`${API_BASE}/control/auto`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                estacion_id: currentStationId,
                enabled: enabled
            })
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }
        
        const result = await response.json();
        
        if (result.success) {
            autoControlEnabled = enabled;
            updateControlUI();
            showNotification(
                `Control automático ${enabled ? 'activado' : 'desactivado'}`,
                'success'
            );
        } else {
            event.target.checked = !enabled; // Revertir
            showNotification('Error al cambiar modo de control', 'error');
        }
    } catch (error) {
        event.target.checked = !enabled; // Revertir
        console.error('Error:', error);
        showNotification('Control automático no disponible. Usando modo manual.', 'warning');
        autoControlEnabled = false;
        updateControlUI();
    }
}

async function handleManualControl(action) {
    if (autoControlEnabled) {
        try {
            const disableResponse = await fetch(`${API_BASE}/control/auto`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    estacion_id: currentStationId,
                    enabled: false
                })
            });

            if (disableResponse.ok) {
                autoControlEnabled = false;
                updateControlUI();
                showNotification('Control automático desactivado para modo manual', 'info');
            } else {
                showNotification('Desactive el control automático primero', 'warning');
                return;
            }
        } catch (error) {
            console.error('Error:', error);
            showNotification('No se pudo desactivar el control automático', 'error');
            return;
        }
    }

    const mappedAction = action === 'START' ? 'INICIAR' : 'DETENER';
    
    try {
        const response = await fetch(`${API_BASE}/control/manual`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                bomba_id: currentStationId,
                action: mappedAction,
                user: 'Dashboard_Manual'
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            showNotification(result.message, 'success');
            setTimeout(() => loadPumpStatus(), 1000); // Recargar después de 1s
        } else {
            showNotification(result.error || 'Error en comando', 'error');
        }
    } catch (error) {
        console.error('Error:', error);
        showNotification('Error de conexión', 'error');
    }
}

async function handleStopSystem() {
    showNotification('Deteniendo sistema...', 'warning');

    const autoRefresh = document.getElementById('autoRefresh');
    if (autoRefresh && autoRefresh.checked) {
        autoRefresh.checked = false;
        autoRefresh.dispatchEvent(new Event('change'));
    }

    if (autoControlEnabled) {
        try {
            const response = await fetch(`${API_BASE}/control/auto`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    estacion_id: currentStationId,
                    enabled: false
                })
            });

            if (response.ok) {
                autoControlEnabled = false;
                updateControlUI();
            }
        } catch (error) {
            console.error('Error:', error);
        }
    }

    await handleManualControl('STOP');
}

// ==================== ÚLTIMA DECISIÓN AUTOMÁTICA ====================

async function loadLastDecision() {
    try {
        // Intentar obtener último log de control automático
        const response = await fetch(`${API_BASE}/control/last-decision?station_id=${currentStationId}`);
        
        if (response.ok) {
            const result = await response.json();
            if (result.success && result.data) {
                updateDecisionUI(result.data);
                return;
            }
        }
    } catch (error) {
        // Continuar con simulación
    }
    
    // Si no hay datos reales, cargar o generar simulados
    console.log('⚠️  Usando decisión automática simulada');
    loadSimulatedDecision();
}

function loadSimulatedDecision() {
    // Obtener últimos datos meteorológicos de las gráficas
    const lastTemp = meteoroHistory.temperature[meteoroHistory.temperature.length - 1] || 24;
    const lastRain = meteoroHistory.precipitation[meteoroHistory.precipitation.length - 1] || 0;
    const lastWind = meteoroHistory.wind[meteoroHistory.wind.length - 1] || 5;
    
    // Lógica de decisión simulada
    let accion = 'NO CAMBIOS';
    let razon = 'Sistema en estado normal';
    
    if (lastRain > 5) {
        accion = 'APAGAR';
        razon = 'Lluvia intensa detectada. Bomba apagada por seguridad.';
    } else if (lastRain > 2) {
        accion = 'REDUCIR';
        razon = 'Lluvia moderada. Reductor de caudal activado.';
    } else if (meteoroHistory.temperature[meteoroHistory.temperature.length - 1] > 28) {
        accion = 'INICIAR';
        razon = 'Temperatura elevada. Aumentar bombeo para enfriamiento.';
    }
    
    const mockData = {
        accion: accion,
        razon: razon,
        nivel_agua_m: 2.5 + (Math.random() * 0.5 - 0.25),
        precipitacion_mm: lastRain,
        periodo_tarifa: 'VALLE',
        fecha_hora: new Date().toISOString()
    };
    
    updateDecisionUI(mockData);
}

function updateDecisionUI(data) {
    // Actualizar acción
    const lastDecisionDiv = document.getElementById('lastDecision');
    if (lastDecisionDiv) {
        const actionEl = lastDecisionDiv.querySelector('.decision-action');
        if (actionEl) {
            const isStart = data.accion === 'INICIAR' || data.accion === 'START';
            const isStop = data.accion === 'APAGAR' || data.accion === 'STOP';
            let icon = 'fa-minus-circle';
            let color = '#95a5a6';
            
            if (isStart) {
                icon = 'fa-play-circle';
                color = '#27ae60';
            } else if (isStop) {
                icon = 'fa-stop-circle';
                color = '#e74c3c';
            }
            
            actionEl.innerHTML = `<i class="fas ${icon}" style="color:${color}"></i> ${data.accion || '-'}`;
        }

        // Actualizar razón
        const reasonEl = lastDecisionDiv.querySelector('.decision-reason');
        if (reasonEl) {
            reasonEl.textContent = data.razon || '-';
        }
    }
    
    // Actualizar datos contextuales
    updateElement('decisionLevel', data.nivel_agua_m ? `${data.nivel_agua_m.toFixed(2)}m` : '-');
    updateElement('decisionRain', data.precipitacion_mm ? `${data.precipitacion_mm.toFixed(1)}mm` : '-');
    updateElement('decisionTariff', data.periodo_tarifa || '-');
    updateElement('decisionTime', formatTimestamp(data.fecha_hora));
}

// ==================== ALERTAS ACTIVAS ====================

async function loadActiveAlerts() {
    try {
        const response = await fetch(`${API_BASE}/alerts/active?station_id=${currentStationId}`);
        
        if (response.ok) {
            const result = await response.json();
            
            if (result.success) {
                const alerts = result.alerts || [];
                if (alerts.length > 0) {
                    updateAlertsUI(alerts);
                    return;
                }
            }
        }
    } catch (error) {
        console.error('Error cargando alertas:', error);
    }
    
    // Si no hay alertas del API, mostrar alertas simuladas
    loadSimulatedAlerts();
}

function loadSimulatedAlerts() {
    // Generar alertas simuladas basadas en condiciones actuales
    const alerts = [];
    
    const lastTemp = meteoroHistory.temperature[meteoroHistory.temperature.length - 1] || 24;
    const lastRain = meteoroHistory.precipitation[meteoroHistory.precipitation.length - 1] || 0;
    const lastWind = meteoroHistory.wind[meteoroHistory.wind.length - 1] || 5;
    
    // Alerta 1: Temperatura
    if (lastTemp > 28) {
        alerts.push({
            id: 1,
            severity: 'HIGH',
            alert_type: 'TEMPERATURA_ELEVADA',
            message: `Temperatura ambiente muy elevada (${lastTemp.toFixed(1)}°C). Monitor activo.`,
            created_at: new Date().toISOString(),
            notified_via: 'EMAIL,DASHBOARD'
        });
    }
    
    // Alerta 2: Lluvia intensa
    if (lastRain > 5) {
        alerts.push({
            id: 2,
            severity: 'CRITICAL',
            alert_type: 'LLUVIA_INTENSA',
            message: `Precipitación muy intensa (${lastRain.toFixed(1)}mm/h). Riesgo de desbordamiento.`,
            created_at: new Date().toISOString(),
            notified_via: 'WHATSAPP,EMAIL,SMS'
        });
    } else if (lastRain > 2) {
        alerts.push({
            id: 3,
            severity: 'MEDIUM',
            alert_type: 'LLUVIA_MODERADA',
            message: `Lluvia moderada en progreso (${lastRain.toFixed(1)}mm/h).`,
            created_at: new Date().toISOString(),
            notified_via: 'EMAIL'
        });
    }
    
    // Alerta 3: Viento fuerte
    if (lastWind > 20) {
        alerts.push({
            id: 4,
            severity: 'HIGH',
            alert_type: 'VIENTO_FUERTE',
            message: `Velocidad de viento muy elevada (${lastWind.toFixed(1)} km/h). Revisar estructuras.`,
            created_at: new Date().toISOString(),
            notified_via: 'DASHBOARD'
        });
    }
    
    // Alerta 4: Mantenimiento simulado
    if (Math.random() < 0.3) {
        alerts.push({
            id: 5,
            severity: 'MEDIUM',
            alert_type: 'MANTENIMIENTO',
            message: 'Próximo mantenimiento preventivo en 7 días. Agendar revisión.',
            created_at: new Date(Date.now() - 60*60*1000).toISOString(),
            notified_via: 'EMAIL'
        });
    }

    if (alerts.length === 0) {
        alerts.push({
            id: 6,
            severity: 'LOW',
            alert_type: 'SISTEMA_MONITOREO',
            message: 'Monitoreo activo. Sin incidentes críticos recientes.',
            created_at: new Date().toISOString(),
            notified_via: 'DASHBOARD'
        });
    }
    
    updateAlertsUI(alerts);
}

function updateAlertsUI(alerts) {
    const grid = document.getElementById('alertsActiveGrid');
    
    if (!grid) return;
    
    // Contar por severidad
    const countByKey = { CRITICAL: 0, HIGH: 0, MEDIUM: 0, LOW: 0 };
    alerts.forEach(a => {
        if (countByKey.hasOwnProperty(a.severity)) {
            countByKey[a.severity]++;
        }
    });
    
    updateElement('criticalCount', countByKey.CRITICAL || 0);
    updateElement('highCount', countByKey.HIGH || 0);
    updateElement('mediumCount', countByKey.MEDIUM || 0);
    
    if (alerts.length === 0) {
        grid.innerHTML = `
            <div class="no-alerts" style="grid-column: 1/-1; padding: 40px; text-align: center; color: #7f8c8d;">
                <i class="fas fa-check-circle" style="font-size: 3em; color: #27ae60; margin-bottom: 10px;"></i>
                <p style="font-size: 1.1em;">No hay alertas activas</p>
            </div>
        `;
        return;
    }
    
    grid.innerHTML = alerts.map(alert => `
        <div class="alert-item ${alert.severity.toLowerCase()}" style="
            border-left: 4px solid ${getSeverityColor(alert.severity)};
            padding: 15px;
            margin-bottom: 10px;
            background: #f8f9fa;
            border-radius: 4px;
        ">
            <div class="alert-content">
                <div class="alert-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                    <span class="alert-severity ${alert.severity.toLowerCase()}" style="
                        background: ${getSeverityColor(alert.severity)};
                        color: white;
                        padding: 4px 12px;
                        border-radius: 20px;
                        font-size: 0.85em;
                        font-weight: bold;
                    ">${alert.severity}</span>
                    <span class="alert-type" style="font-weight: bold; color: #2c3e50;">${alert.alert_type}</span>
                </div>
                <div class="alert-message" style="margin-bottom: 8px; color: #34495e;">${alert.message}</div>
                <div class="alert-meta" style="display: flex; gap: 15px; font-size: 0.9em; color: #7f8c8d;">
                    <span><i class="fas fa-clock"></i> ${formatTimestamp(alert.created_at)}</span>
                    <span><i class="fas fa-bell"></i> ${alert.notified_via || 'N/A'}</span>
                </div>
            </div>
        </div>
    `).join('');
}

function getSeverityColor(severity) {
    const colors = {
        'CRITICAL': '#e74c3c',
        'HIGH': '#f39c12',
        'MEDIUM': '#3498db',
        'LOW': '#95a5a6'
    };
    return colors[severity] || '#95a5a6';
}

async function resolveAlert(alertId) {
    try {
        const response = await fetch(`${API_BASE}/alerts/${alertId}/resolve`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                resolved_by: 'Dashboard_User'
            })
        });

        if (response.ok) {
            showNotification('Alerta resuelta', 'success');
        } else {
            showNotification('No se pudo resolver la alerta', 'warning');
        }
    } catch (error) {
        console.error('Error:', error);
        showNotification('Error de conexión', 'error');
    }

    loadActiveAlerts();
}
        if (result.success) {
            showNotification('Alerta resuelta', 'success');
            loadActiveAlerts(); // Recargar lista
        } else {
            showNotification('Error al resolver alerta', 'error');
        }
    } catch (error) {
        console.error('Error:', error);
        showNotification('Error de conexión', 'error');
    }
}

// ==================== AUTO-REFRESH ====================

function startAutoRefresh() {
    // Actualizar cada 10 segundos
    refreshInterval = setInterval(() => {
        const autoRefreshCheckbox = document.getElementById('autoRefresh');
        if (autoRefreshCheckbox && autoRefreshCheckbox.checked) {
            loadAllData();
        }
    }, 10000);
}

// ==================== UTILIDADES ====================

function updateElement(id, value) {
    const el = document.getElementById(id);
    if (el) {
        el.textContent = value;
    }
}

function formatTimestamp(timestamp) {
    if (!timestamp) return '-';
    
    const date = new Date(timestamp);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    
    if (diffMins < 1) return 'Ahora';
    if (diffMins < 60) return `Hace ${diffMins} min`;
    
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `Hace ${diffHours}h`;
    
    return date.toLocaleDateString('es-CO') + ' ' + date.toLocaleTimeString('es-CO');
}

function showNotification(message, type = 'info') {
    // Crear notificación toast
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerHTML = `
        <i class="fas fa-${type === 'success' ? 'check-circle' : 
                          type === 'error' ? 'exclamation-circle' : 
                          type === 'warning' ? 'exclamation-triangle' : 'info-circle'}"></i>
        <span>${message}</span>
    `;
    
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        background: ${type === 'success' ? '#27ae60' : 
                     type === 'error' ? '#e74c3c' : 
                     type === 'warning' ? '#f39c12' : '#3498db'};
        color: white;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        z-index: 10000;
        display: flex;
        align-items: center;
        gap: 10px;
        animation: slideIn 0.3s ease;
    `;
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Exponer función global para resolver alertas desde HTML
window.resolveAlert = resolveAlert;
