-- Tabla para estado de compuertas
CREATE TABLE gate_status (
    id SERIAL PRIMARY KEY,
    gate_id INT NOT NULL,
    position_percent DECIMAL(5,2),
    event_type VARCHAR(20) CHECK (event_type IN ('OPEN', 'CLOSE', 'MOVING')),
    timestamp TIMESTAMP NOT NULL,
    source_device VARCHAR(50)
);

-- Tabla para lecturas de nivel de agua
CREATE TABLE water_level (
    id SERIAL PRIMARY KEY,
    location_id INT NOT NULL,
    level_m DECIMAL(6,3) NOT NULL,
    flow_m3s DECIMAL(12,4),
    timestamp TIMESTAMP NOT NULL,
    source_device VARCHAR(50)
);

-- Tabla para resúmenes diarios
CREATE TABLE flow_summary (
    id SERIAL PRIMARY KEY,
    location_id INT,
    date DATE,
    total_m3 DECIMAL(14,3) NOT NULL,
    peak_flow_m3s DECIMAL(12,4),
    gate_open_hours DECIMAL(8,2)
);

-- Tabla para las estaciones de bombeo
CREATE TABLE pumping_stations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    gate_diameter DECIMAL(4,2) DEFAULT 2.0,
    gate_length DECIMAL(4,1) DEFAULT 5.0,
    weir_type VARCHAR(50),
    weir_width DECIMAL(6,3),
    cd_coefficient DECIMAL(5,3) DEFAULT 0.62
);