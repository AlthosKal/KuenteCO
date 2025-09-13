import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../dto/app/auth/request/recaptcha_request_dto.dart';
import '../../../dto/app/auth/response/recaptcha_response_dto.dart';
import '../api_client.dart';

class RecaptchaService {
  final _api = ApiClient();

  bool get isReady => _api.isInitialized;

  /// Obtener la site key desde .env
  String get siteKey => dotenv.env['RECAPTCHA_SITE_KEY'] ?? '';

  /// Verificar token de reCAPTCHA con el backend usando endpoint público
  Future<bool> verifyRecaptcha(String token) async {
    try {
      print('🔍 Iniciando verificación de reCAPTCHA...');
      print('🎯 Token a verificar: ${token.substring(0, 20)}...');
      
      final dto = RecaptchaRequestDTO(token: token);
      print('📦 DTO creado: ${dto.toJson()}');
      
      print('🌐 Enviando request a: /recaptcha/verify');
      print('🔧 Usando endpoint público (sin autenticación)');
      final response = await _api.postPublic('/recaptcha/verify', dto.toJson());
      
      print('📡 Response recibido:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');
      print('   Response Headers: ${response.headers}');
      
      // Si la respuesta es exitosa (200), el reCAPTCHA es válido
      final isValid = response.statusCode == 200;
      print('✅ reCAPTCHA ${isValid ? 'válido' : 'inválido'}');
      return isValid;
    } catch (e) {
      // Si hay algún error, considerar el reCAPTCHA como inválido
      print('❌ Error verificando reCAPTCHA: $e');
      print('🔍 Tipo de error: ${e.runtimeType}');
      return false;
    }
  }

  /// Verificar token y obtener respuesta completa del backend
  Future<RecaptchaResponseDTO?> verifyRecaptchaDetailed(String token) async {
    try {
      final dto = RecaptchaRequestDTO(token: token);
      final response = await _api.postPublic('/recaptcha/verify', dto.toJson());
      
      if (response.statusCode == 200) {
        // Parsear respuesta exitosa
        return RecaptchaResponseDTO(success: true);
      } else {
        // Parsear respuesta de error si está disponible
        final errorData = response.data;
        if (errorData is Map<String, dynamic>) {
          return RecaptchaResponseDTO.fromJson(errorData);
        }
        return RecaptchaResponseDTO(success: false);
      }
    } catch (e) {
      print('❌ Error detallado verificando reCAPTCHA: $e');
      return RecaptchaResponseDTO(
        success: false, 
        errorCodes: ['network-error']
      );
    }
  }

  /// Validar que la site key esté configurada
  bool get isSiteKeyConfigured => siteKey.isNotEmpty;
}