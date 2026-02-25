#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generador de Alertas Automáticas Simuladas
Promotora Palmera de Antioquia S.A.S.
"""

import requests
import json
from datetime import datetime, timedelta
import random
import time

API_BASE = "http://localhost:9000/api"
STATION_ID = 1
ALERT_INTERVAL_SECONDS = 60
RESOLVE_AFTER_MINUTES = 3
PROBABILITY_SCALE = 0.7

# Configuración de alertas
ALERT_CONFIGS = [
    {
        "severity": "HIGH",
        "alert_type": "TEMPERATURA_MOTOR",
        "message": "Temperatura del motor muy elevada (>75°C). Requiere supervisión.",
        "probability": 0.15  # 15% cada ciclo
    },
    {
        "severity": "MEDIUM",
        "alert_type": "PRECIPITACION_INTENSA",
        "message": "Se detecta lluvia intensa. Posible desbordamiento en 2 horas.",
        "probability": 0.05
    },
    {
        "severity": "CRITICAL",
        "alert_type": "NIVEL_CRITICO",
        "message": "Nivel de agua crítico. Si no baja en 15 min, activar drenaje de emergencia.",
        "probability": 0.02  # Muy raro
    },
    {
        "severity": "HIGH",
        "alert_type": "PRESION_ANOMALA",
        "message": "Presión de salida anómala. Verificar bomba.",
        "probability": 0.08
    },
    {
        "severity": "MEDIUM",
        "alert_type": "VIENTO_FUERTE",
        "message": "Velocidad de viento > 15 km/h. Revisar estructuras.",
        "probability": 0.10
    },
    {
        "severity": "LOW",
        "alert_type": "MANTENIMIENTO_PREVENTIVO",
        "message": "Próximo mantenimiento programado en 5 días.",
        "probability": 0.03
    },
    {
        "severity": "HIGH",
        "alert_type": "EFICIENCIA_BOMBA_BAJA",
        "message": "Eficiencia de bomba degradada. Considerar limpieza.",
        "probability": 0.07
    },
    {
        "severity": "MEDIUM",
        "alert_type": "VARIACION_FLUJO",
        "message": "Variación anómala en flujo de salida.",
        "probability": 0.06
    }
]

def generar_alertas():
    """Genera alertas aleatorias basadas en probabilidades"""
    
    print("\n" + "="*60)
    print("GENERADOR DE ALERTAS AUTOMÁTICAS")
    print("="*60)
    print(f"API Base: {API_BASE}")
    print(f"Estación: {STATION_ID}")
    print("Presione Ctrl+C para detener\n")
    
    alertas_activas = {}
    iteracion = 1
    
    try:
        while True:
            print(f"\n--- Iteración {iteracion} ({datetime.now().strftime('%H:%M:%S')}) ---")
            
            # Procesar cada tipo de alerta
            for config in ALERT_CONFIGS:
                alert_type = config["alert_type"]
                
                # Decidir si crear alerta
                if random.random() < (config["probability"] * PROBABILITY_SCALE):
                    # Esta alerta debería existir
                    if alert_type not in alertas_activas:
                        # Crear nueva alerta
                        crear_alerta(config)
                        alertas_activas[alert_type] = datetime.now()
                        print(f"  ✓ [{config['severity']}] {alert_type}: CREADA")
                else:
                    # Esta alerta no debería existir
                    if alert_type in alertas_activas:
                        # Resolver alerta existente si lleva activa > 5 minutos
                        tiempo_activa = datetime.now() - alertas_activas[alert_type]
                        if tiempo_activa > timedelta(minutes=RESOLVE_AFTER_MINUTES):
                            resolver_alerta(alert_type)
                            del alertas_activas[alert_type]
                            print(f"  ✓ [{config['severity']}] {alert_type}: RESUELTA")

            if not alertas_activas:
                baseline = {
                    "severity": "LOW",
                    "alert_type": "SISTEMA_MONITOREO",
                    "message": "Monitoreo activo. Sin incidentes criticos recientes.",
                    "probability": 1.0
                }
                if crear_alerta(baseline):
                    alertas_activas[baseline["alert_type"]] = datetime.now()
                    print("  ✓ [LOW] SISTEMA_MONITOREO: CREADA")
            
            print(f"  Alertas activas: {len(alertas_activas)}")
            print(f"  Esperando {ALERT_INTERVAL_SECONDS} segundos...")
            
            iteracion += 1
            time.sleep(ALERT_INTERVAL_SECONDS)
            
    except KeyboardInterrupt:
        print("\n\n✓ Generador detenido.")

def crear_alerta(config):
    """Crea una nueva alerta en la API"""
    try:
        payload = {
            "station_id": STATION_ID,
            "severity": config["severity"],
            "alert_type": config["alert_type"],
            "message": config["message"],
            "auto_notify": True
        }

        response = requests.post(
            f"{API_BASE}/alerts",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=5
        )

        if response.status_code == 200:
            result = response.json()
            if result.get("success"):
                return True
    except Exception:
        pass

    return False

def resolver_alerta(alert_type):
    """Resuelve alertas activas por tipo"""
    try:
        response = requests.get(
            f"{API_BASE}/alerts/active?station_id={STATION_ID}",
            timeout=5
        )

        if response.status_code != 200:
            return False

        result = response.json()
        alerts = result.get("alerts", [])
        targets = [a for a in alerts if a.get("alert_type") == alert_type]

        success_any = False
        for alert in targets:
            alert_id = alert.get("id")
            if not alert_id:
                continue
            resolve_resp = requests.put(
                f"{API_BASE}/alerts/{alert_id}/resolve",
                json={"resolved_by": "AlertGenerator_Auto"},
                headers={"Content-Type": "application/json"},
                timeout=5
            )
            if resolve_resp.status_code == 200:
                success_any = True

        return success_any
    except Exception:
        return False

if __name__ == "__main__":
    # Esperar a que Flask esté listo
    print("\nEsperando que API esté disponible...")
    for i in range(30):
        try:
            r = requests.get(f"{API_BASE}/meteorology/latest?station_id={STATION_ID}")
            if r.status_code == 200:
                print("✓ API disponible\n")
                generar_alertas()
                break
        except:
            pass
        
        if i == 29:
            print("✗ API no disponible después de 30 segundos")
        else:
            time.sleep(1)
