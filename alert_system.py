"""
Sistema de Alertas Multi-Canal
Promotora Palmera de Antioquia S.A.S.
Integración: WhatsApp, Email, SMS

Fecha: 20 de febrero de 2026
"""

import os
import sys
import requests
import json
from datetime import datetime
from twilio.rest import Client
from database import db, SystemAlert, AlertThreshold, NotificationContact

# Agregar path para importar BrevoEmailHelper del sistema PPA
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

try:
    from BrevoEmailHelperV2 import enviar_email_brevo
    BREVO_AVAILABLE = True
except ImportError:
    BREVO_AVAILABLE = False
    print("⚠️ BrevoEmailHelper no disponible, alertas por email desactivadas")


class AlertManager:
    """Gestor centralizado de alertas del sistema"""
    
    def __init__(self):
        # Configuración WhatsApp Business API
        self.whatsapp_api_url = os.getenv('WHATSAPP_API_URL', '')
        self.whatsapp_token = os.getenv('WHATSAPP_TOKEN', '')
        self.whatsapp_phone_id = os.getenv('WHATSAPP_PHONE_ID', '')
        
        # Configuración Twilio SMS
        self.twilio_account_sid = os.getenv('TWILIO_ACCOUNT_SID', '')
        self.twilio_auth_token = os.getenv('TWILIO_AUTH_TOKEN', '')
        self.twilio_phone_number = os.getenv('TWILIO_PHONE_NUMBER', '')
        
        # Inicializar cliente Twilio
        if self.twilio_account_sid and self.twilio_auth_token:
            self.twilio_client = Client(self.twilio_account_sid, self.twilio_auth_token)
            self.sms_available = True
        else:
            self.twilio_client = None
            self.sms_available = False
            print("⚠️ Twilio no configurado, alertas por SMS desactivadas")
        
        # Verificar WhatsApp
        self.whatsapp_available = bool(self.whatsapp_api_url and self.whatsapp_token)
        if not self.whatsapp_available:
            print("⚠️ WhatsApp API no configurada, alertas por WhatsApp desactivadas")
    
    def create_alert(self, alert_type, severity, station_id, message, auto_notify=True):
        """
        Crear nueva alerta en el sistema
        
        Args:
            alert_type (str): Tipo de alerta (WATER_LEVEL, TEMPERATURE, PRESSURE, etc.)
            severity (str): Nivel de severidad (LOW, MEDIUM, HIGH, CRITICAL)
            station_id (int): ID de la estación
            message (str): Mensaje descriptivo
            auto_notify (bool): Enviar notificaciones automáticamente
        
        Returns:
            SystemAlert: Objeto de alerta creado
        """
        alert = SystemAlert(
            alert_type=alert_type,
            severity=severity,
            station_id=station_id,
            message=message,
            created_at=datetime.now()
        )
        
        db.session.add(alert)
        db.session.commit()
        
        if auto_notify:
            self.notify_alert(alert)
        
        return alert
    
    def notify_alert(self, alert):
        """
        Enviar notificaciones según severidad de la alerta
        
        Args:
            alert (SystemAlert): Objeto de alerta a notificar
        """
        # Obtener contactos que deben ser notificados
        contacts = self.get_notification_recipients(alert.station_id, alert.severity)
        
        if not contacts:
            print(f"⚠️ No hay contactos configurados para estación {alert.station_id}")
            return
        
        # Determinar canales según severidad
        channels = self.get_channels_for_severity(alert.severity)
        
        notified_via = []
        
        for contact in contacts:
            for channel in channels:
                if channel == 'EMAIL' and contact.correo:
                    if self.send_email_alert(contact.correo, alert):
                        if 'EMAIL' not in notified_via:
                            notified_via.append('EMAIL')
                
                elif channel == 'WHATSAPP' and contact.numero_whatsapp:
                    if self.send_whatsapp_alert(contact.numero_whatsapp, alert):
                        if 'WHATSAPP' not in notified_via:
                            notified_via.append('WHATSAPP')
                
                elif channel == 'SMS' and contact.telefono:
                    if self.send_sms_alert(contact.telefono, alert):
                        if 'SMS' not in notified_via:
                            notified_via.append('SMS')
        
        # Actualizar registro de alerta
        alert.notified_via = ','.join(notified_via)
        db.session.commit()
        
        print(f"✅ Alerta {alert.id} notificada vía: {', '.join(notified_via)}")
    
    def get_notification_recipients(self, station_id, severity):
        """Obtener contactos que deben recibir notificaciones"""
        query = NotificationContact.query.filter_by(
            activo=True
        )
        
        # Filtrar según preferencias de severidad
        if severity == 'CRITICAL':
            query = query.filter_by(recibir_critico=True)
        elif severity == 'HIGH':
            query = query.filter_by(recibir_alto=True)
        elif severity == 'MEDIUM':
            query = query.filter_by(recibir_medio=True)
        elif severity == 'LOW':
            query = query.filter_by(recibir_bajo=True)
        
        return query.all()
    
    def get_channels_for_severity(self, severity):
        """Determinar canales de notificación según severidad"""
        if severity == 'CRITICAL':
            return ['WHATSAPP', 'EMAIL', 'SMS']
        elif severity == 'HIGH':
            return ['WHATSAPP', 'EMAIL']
        elif severity == 'MEDIUM':
            return ['EMAIL']
        else:  # LOW
            return ['EMAIL']
    
    def send_email_alert(self, email, alert):
        """
        Enviar alerta por email usando BrevoEmailHelper
        
        Args:
            email (str): Dirección de email
            alert (SystemAlert): Objeto de alerta
        
        Returns:
            bool: True si se envió correctamente
        """
        if not BREVO_AVAILABLE:
            return False
        
        try:
            # Formatear HTML según severidad
            severity_colors = {
                'CRITICAL': '#dc2626',
                'HIGH': '#f59e0b',
                'MEDIUM': '#3b82f6',
                'LOW': '#10b981'
            }
            
            severity_icons = {
                'CRITICAL': '🚨',
                'HIGH': '⚠️',
                'MEDIUM': 'ℹ️',
                'LOW': '✓'
            }
            
            color = severity_colors.get(alert.severity, '#6b7280')
            icon = severity_icons.get(alert.severity, '•')
            
            html_content = f"""
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background: {color}; color: white; padding: 20px; border-radius: 8px 8px 0 0;">
                    <h2 style="margin: 0;">{icon} ALERTA {alert.severity}</h2>
                </div>
                <div style="background: #f8f9fa; padding: 20px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 8px 8px;">
                    <p><strong>Tipo:</strong> {alert.alert_type}</p>
                    <p><strong>Estación:</strong> {alert.station_id}</p>
                    <p><strong>Fecha:</strong> {alert.created_at.strftime('%d/%m/%Y %H:%M:%S')}</p>
                    <hr style="border: none; border-top: 1px solid #e5e7eb;">
                    <p><strong>Mensaje:</strong></p>
                    <p style="background: white; padding: 15px; border-radius: 6px; border-left: 4px solid {color};">
                        {alert.message}
                    </p>
                    <hr style="border: none; border-top: 1px solid #e5e7eb;">
                    <p style="font-size: 12px; color: #6b7280;">
                        Sistema de Monitoreo Automatizado - Promotora Palmera de Antioquia S.A.S.<br>
                        Este es un mensaje automático, no responder.
                    </p>
                </div>
            </div>
            """
            
            result = enviar_email_brevo(
                destinatario=email,
                asunto=f"[{alert.severity}] {alert.alert_type} - Estación {alert.station_id}",
                contenido_html=html_content
            )
            
            return result.get('success', False)
        
        except Exception as e:
            print(f"❌ Error enviando email: {str(e)}")
            return False
    
    def send_whatsapp_alert(self, phone_number, alert):
        """
        Enviar alerta por WhatsApp Business API
        
        Args:
            phone_number (str): Número de WhatsApp (+57XXXXXXXXXX)
            alert (SystemAlert): Objeto de alerta
        
        Returns:
            bool: True si se envió correctamente
        """
        if not self.whatsapp_available:
            return False
        
        try:
            # Formatear mensaje
            severity_emoji = {
                'CRITICAL': '🚨',
                'HIGH': '⚠️',
                'MEDIUM': 'ℹ️',
                'LOW': '✅'
            }
            
            emoji = severity_emoji.get(alert.severity, '📢')
            
            message = f"""{emoji} *ALERTA {alert.severity}*

*Tipo:* {alert.alert_type}
*Estación:* {alert.station_id}
*Fecha:* {alert.created_at.strftime('%d/%m/%Y %H:%M:%S')}

*Mensaje:*
{alert.message}

_Sistema de Monitoreo PPA_"""
            
            # Enviar vía WhatsApp Business API
            headers = {
                'Authorization': f'Bearer {self.whatsapp_token}',
                'Content-Type': 'application/json'
            }
            
            payload = {
                'messaging_product': 'whatsapp',
                'to': phone_number.replace('+', ''),
                'type': 'text',
                'text': {'body': message}
            }
            
            response = requests.post(
                f"{self.whatsapp_api_url}/{self.whatsapp_phone_id}/messages",
                headers=headers,
                json=payload,
                timeout=10
            )
            
            return response.status_code == 200
        
        except Exception as e:
            print(f"❌ Error enviando WhatsApp: {str(e)}")
            return False
    
    def send_sms_alert(self, phone_number, alert):
        """
        Enviar alerta por SMS usando Twilio
        
        Args:
            phone_number (str): Número de teléfono (+57XXXXXXXXXX)
            alert (SystemAlert): Objeto de alerta
        
        Returns:
            bool: True si se envió correctamente
        """
        if not self.sms_available:
            return False
        
        try:
            message = f"[{alert.severity}] {alert.alert_type} - Estación {alert.station_id}: {alert.message[:100]}"
            
            self.twilio_client.messages.create(
                body=message,
                from_=self.twilio_phone_number,
                to=phone_number
            )
            
            return True
        
        except Exception as e:
            print(f"❌ Error enviando SMS: {str(e)}")
            return False
    
    def check_thresholds(self, station_id, parameter_name, current_value):
        """
        Verificar si un valor excede umbrales configurados
        
        Args:
            station_id (int): ID de la estación
            parameter_name (str): Nombre del parámetro a verificar
            current_value (float): Valor actual
        
        Returns:
            dict: Información de violación de umbral o None
        """
        thresholds = AlertThreshold.query.filter_by(
            nombre_parametro=parameter_name,
            activo=True
        ).all()
        
        for threshold in thresholds:
            # Verificar límite inferior
            if threshold.valor_minimo and current_value < float(threshold.valor_minimo):
                return {
                    'violated': True,
                    'threshold_id': threshold.id,
                    'alert_level': threshold.nivel_alerta,
                    'message': f"{parameter_name} ({current_value}) por debajo del minimo ({threshold.valor_minimo})"
                }
            
            # Verificar límite superior
            if threshold.valor_maximo and current_value > float(threshold.valor_maximo):
                return {
                    'violated': True,
                    'threshold_id': threshold.id,
                    'alert_level': threshold.nivel_alerta,
                    'message': f"{parameter_name} ({current_value}) excede el maximo ({threshold.valor_maximo})"
                }
        
        return None
    
    def resolve_alert(self, alert_id, resolved_by):
        """
        Marcar alerta como resuelta
        
        Args:
            alert_id (int): ID de la alerta
            resolved_by (str): Nombre del usuario que resolvió
        
        Returns:
            bool: True si se resolvió correctamente
        """
        alert = SystemAlert.query.get(alert_id)
        
        if alert and not alert.resolved:
            alert.resolved = True
            alert.resolved_at = datetime.now()
            alert.resolved_by = resolved_by
            db.session.commit()
            return True
        
        return False


# Instancia global del gestor de alertas
alert_manager = AlertManager()


def test_alert_system():
    """Prueba del sistema de alertas"""
    print("\n🧪 PRUEBA DEL SISTEMA DE ALERTAS\n")
    
    test_alert = alert_manager.create_alert(
        alert_type='TEST_SYSTEM',
        severity='MEDIUM',
        station_id=1,
        message='Prueba del sistema de alertas multi-canal. Si recibes esto, el sistema funciona correctamente.',
        auto_notify=True
    )
    
    print(f"\n✅ Alerta de prueba creada: ID {test_alert.id}")
    print(f"   Notificada vía: {test_alert.notified_via}")


if __name__ == '__main__':
    test_alert_system()
