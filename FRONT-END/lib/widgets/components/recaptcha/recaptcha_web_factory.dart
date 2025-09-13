// Importación condicional para reCAPTCHA web
import 'package:flutter/material.dart';
import '../../../controllers/auth/recaptcha_controller.dart';

// Importación condicional basada en la plataforma
import 'recaptcha_web_stub.dart' 
    if (dart.library.html) 'recaptcha_web_implementation.dart';

Widget createRecaptchaWebElementWrapper({
  required RecaptchaController controller,
  VoidCallback? onVerified,
  VoidCallback? onError,
}) {
  return createRecaptchaWebElement(
    controller: controller,
    onVerified: onVerified,
    onError: onError,
  );
}