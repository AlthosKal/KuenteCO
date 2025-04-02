import 'package:flutter/material.dart';

class AuthConstants {
  // Colores
  static const Color primaryColor = Color(0xFF890cac);
  static const Color whiteColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);

  // Tiempos
  static const int codeExpirationSeconds = 120;

  // Textos
  static const String recoveryTitle = 'Recuperar Contraseña';
  static const String sendCodeButton = 'Enviar Código';
  static const String verifyCodeButton = 'Verificar Código';
  static const String changePasswordButton = 'Cambiar Contraseña';

  // Validaciones
  static const int minPasswordLength = 6;
  static const String emailRegex = r'^[^@]+@[^@]+\.[^@]+';
}