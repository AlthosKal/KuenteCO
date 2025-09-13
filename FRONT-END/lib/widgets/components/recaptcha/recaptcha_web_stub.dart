// Stub para plataformas no-web
import 'package:flutter/material.dart';
import '../../../controllers/auth/recaptcha_controller.dart';

Widget createRecaptchaWebElement({
  required RecaptchaController controller,
  VoidCallback? onVerified,
  VoidCallback? onError,
}) {
  // Para plataformas no-web, mostrar mensaje informativo
  return Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.web, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'reCAPTCHA Web no disponible',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Esta funcionalidad solo está disponible en Flutter Web',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // Simular verificación exitosa para testing
            controller.isLoading.value = true;
            Future.delayed(const Duration(seconds: 1), () {
              controller.isLoading.value = false;
              controller.isVerified.value = true;
              controller.currentToken.value = 'test_token_${DateTime.now().millisecondsSinceEpoch}';
              onVerified?.call();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Simular Verificación'),
        ),
      ],
    ),
  );
}