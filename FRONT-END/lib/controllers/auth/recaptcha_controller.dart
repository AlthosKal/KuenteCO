import 'package:flutter/material.dart';
import '../../core/services/app/recaptcha_service.dart';

class RecaptchaController {
  final RecaptchaService _recaptchaService;

  // Estados de UI reactivos
  final ValueNotifier<bool> isVerified = ValueNotifier(false);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> currentToken = ValueNotifier(null);

  RecaptchaController({RecaptchaService? recaptchaService})
      : _recaptchaService = recaptchaService ?? RecaptchaService();

  /// 🤖 Verificar token de reCAPTCHA
  Future<bool> verifyToken(String token) async {
    isLoading.value = true;
    
    try {
      final isValid = await _recaptchaService.verifyRecaptcha(token);
      
      if (isValid) {
        currentToken.value = token;
        isVerified.value = true;
      } else {
        currentToken.value = null;
        isVerified.value = false;
      }
      
      return isValid;
    } catch (e) {
      currentToken.value = null;
      isVerified.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔄 Resetear estado del reCAPTCHA
  void reset() {
    isVerified.value = false;
    currentToken.value = null;
    isLoading.value = false;
  }

  /// ✅ Verificar si el reCAPTCHA está validado
  bool get isValid => isVerified.value && currentToken.value != null;

  /// 🎫 Obtener el token actual
  String? get token => currentToken.value;

  /// 🧹 Liberar recursos
  void dispose() {
    isVerified.dispose();
    isLoading.dispose();
    currentToken.dispose();
  }
}