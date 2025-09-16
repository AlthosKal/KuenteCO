import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

class EmailService {
  // Obtener configuración desde .env
  static String get _senderEmail => dotenv.env['SENDER_EMAIL'] ?? '';
  static String get _senderPassword => dotenv.env['SENDER_PASSWORD'] ?? '';
  static String get _senderName => dotenv.env['SENDER_NAME'] ?? 'KuenteCO Contact Form';
  static String get _destinationEmail => dotenv.env['DESTINATION_EMAIL'] ?? 'KuenteCO@yopmail.com';
  
  // Configuración EmailJS
  static String get _emailJsServiceId => dotenv.env['EMAILJS_SERVICE_ID'] ?? '';
  static String get _emailJsTemplateId => dotenv.env['EMAILJS_TEMPLATE_ID'] ?? '';
  static String get _emailJsPublicKey => dotenv.env['EMAILJS_PUBLIC_KEY'] ?? '';

  /// Envía email usando EmailJS
  static Future<bool> _sendEmailViaEmailJS({
    required String fromName,
    required String fromEmail,
    required String subject,
    required String message,
  }) async {
    try {
      // Verificar que las credenciales de EmailJS estén configuradas
      if (_emailJsServiceId.isEmpty || _emailJsTemplateId.isEmpty || _emailJsPublicKey.isEmpty) {
        print('❌ Error: Credenciales de EmailJS no configuradas en .env');
        return false;
      }

      final dio = Dio();
      
      final templateParams = {
        'nombreCompleto': fromName,
        'correoElectronico': fromEmail,
        'asunto': subject,
        'mensaje': message,
        'to_email': _destinationEmail,
        'reply_to': fromEmail,
      };
      
      final response = await dio.post(
        'https://api.emailjs.com/api/v1.0/email/send',
        data: {
          'service_id': _emailJsServiceId,
          'template_id': _emailJsTemplateId,
          'user_id': _emailJsPublicKey,
          'template_params': templateParams,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error enviando email via EmailJS: $e');
      if (e.toString().contains('400')) {
        print('💡 Tip: Verifica que el service_id y template_id sean correctos');
      } else if (e.toString().contains('401')) {
        print('💡 Tip: Verifica tu public_key de EmailJS');
      }
      return false;
    }
  }


  /// Construye el HTML del email
  static String _buildHtmlEmail({
    required String fromName,
    required String fromEmail,
    required String subject,
    required String message,
  }) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Nuevo mensaje de contacto - KuenteCO</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; }
        .header { background: linear-gradient(135deg, #890cac, #a855f7); padding: 20px; border-radius: 10px 10px 0 0; text-align: center; }
        .header h1 { color: white; margin: 0; }
        .content { background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px; border: 1px solid #dee2e6; }
        .info-box { background: white; padding: 20px; border-radius: 8px; margin: 15px 0; }
        .message-box { background: white; padding: 20px; border-radius: 8px; border-left: 4px solid #890cac; }
        .footer { margin-top: 20px; padding: 15px; background: #e3f2fd; border-radius: 8px; border-left: 4px solid #2196f3; }
        .small-text { font-size: 12px; color: #666; text-align: center; margin-top: 20px; }
        h2, h3 { color: #890cac; }
        .pre-wrap { white-space: pre-wrap; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌟 Nuevo Mensaje de Contacto</h1>
        </div>
        
        <div class="content">
            <h2>📬 Detalles del Contacto</h2>
            
            <div class="info-box">
                <p><strong>👤 Nombre:</strong> $fromName</p>
                <p><strong>📧 Email:</strong> $fromEmail</p>
                <p><strong>📋 Asunto:</strong> $subject</p>
            </div>
            
            <h3>💬 Mensaje:</h3>
            <div class="message-box">
                <p class="pre-wrap">$message</p>
            </div>
            
            <div class="footer">
                <p style="margin: 0;">
                    <strong>📅 Fecha:</strong> ${DateTime.now().toString().split('.')[0]}<br>
                    <strong>🔗 Origen:</strong> Formulario de contacto KuenteCO
                </p>
            </div>
        </div>
        
        <div class="small-text">
            <p>Este mensaje fue generado automáticamente por el sistema de contacto de KuenteCO</p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  /// Método principal que se llama desde los formularios
  static Future<bool> sendEmailSimple({
    required String fromName,
    required String fromEmail,
    required String subject,
    required String message,
  }) async {
    return await _sendEmailViaEmailJS(
      fromName: fromName,
      fromEmail: fromEmail,
      subject: subject,
      message: message,
    );
  }

  /// Validar configuración
  static bool get isConfigured {
    return _emailJsServiceId.isNotEmpty && 
           _emailJsTemplateId.isNotEmpty && 
           _emailJsPublicKey.isNotEmpty &&
           _destinationEmail.isNotEmpty;
  }

  /// Obtener información de configuración (para debug)
  static Map<String, String> get configInfo {
    return {
      'emailJsServiceId': _emailJsServiceId.isNotEmpty ? _emailJsServiceId : 'NO CONFIGURADO',
      'emailJsTemplateId': _emailJsTemplateId.isNotEmpty ? _emailJsTemplateId : 'NO CONFIGURADO',
      'emailJsPublicKey': _emailJsPublicKey.isNotEmpty ? 'CONFIGURADO' : 'NO CONFIGURADO',
      'destinationEmail': _destinationEmail,
      'provider': _detectProvider(),
    };
  }

  static String _detectProvider() {
    if (kIsWeb) return 'EmailJS (Web)';
    return 'EmailJS (Mobile)';
  }
}