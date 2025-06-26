import 'package:flutter/material.dart';
import 'package:kuenteco/core/constants/app_colors_constant.dart';

class AuthConstants {
  // Tiempos
  static const int codeExpirationTime = 120; // segundos

  // Textos
  static const String loginTitle = 'Iniciar Sesión';
  static const String registerTitle = 'Registrarse';

  // Validaciones
  static const int minPasswordLength = 6;
  static const String emailRegex = r'^[^@]+@[^@]+\.[^@]+';

  // Estilos
  static const TextStyle authTitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryPurple,
  );

  static InputDecoration authInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryPurple),
      ),
    );
  }
}