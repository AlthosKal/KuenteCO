import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

class EmailService {
  
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
        return false;
      }

      final dio = Dio();
      
      final templateParams = {
        'nombreCompleto': fromName,
        'correoElectronico': fromEmail,
        'asunto': subject,
        'mensaje': message,
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
      return false;
    }
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
           _emailJsPublicKey.isNotEmpty;
  }

  /// Obtener información de configuración (para debug)
  static Map<String, String> get configInfo {
    return {
      'emailJsServiceId': _emailJsServiceId.isNotEmpty ? _emailJsServiceId : 'NO CONFIGURADO',
      'emailJsTemplateId': _emailJsTemplateId.isNotEmpty ? _emailJsTemplateId : 'NO CONFIGURADO',
      'emailJsPublicKey': _emailJsPublicKey.isNotEmpty ? 'CONFIGURADO' : 'NO CONFIGURADO',
      'provider': _detectProvider(),
    };
  }

  static String _detectProvider() {
    if (kIsWeb) return 'EmailJS (Web)';
    return 'EmailJS (Mobile)';
  }
}