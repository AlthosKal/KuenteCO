import 'dart:async';
import 'package:flutter/material.dart';
import '../core/exceptions/global_exception_handler.dart';
import '../core/services/app/auth_service.dart';
import '../dto/auth/request/validate_verification_code_dto.dart';
import '../provider/toast_helper.dart';
import '../routes/app_routes.dart';

class ValidateVerificationCodeController {
  final AuthService _authService;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  /// 📌 Variable estática para almacenar temporalmente el código validado (para recuperación de contraseña)
  static String? _validatedCode;

  /// 📌 Controladores de los 6 campos de código
  final List<TextEditingController> codeControllers = List.generate(
    6,
        (_) => TextEditingController(),
  );

  int currentStep = 0;
  int timerCount = 120;
  Timer? _timer;

  ValidateVerificationCodeController({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// ✅ Valida y activa la cuenta del usuario
  Future<void> validateVerificationCode({
    required BuildContext context,
    required String email,
    required String code,
  }) async {
    isLoading.value = true;
    final dto = ValidateVerificationCodeDTO(email: email, code: code);

    await GlobalExceptionHandler.run(() async {
      // 🔥 Llama a activateUser (que valida y activa la cuenta)
      await _authService.activateUser(dto);

      if (context.mounted) {
        ToastHelper.showSuccess(
          context,
          title: 'Cuenta activada correctamente. Ahora puedes iniciar sesión',
        );

        // Redirige al login
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }, onError: (error) {
      ToastHelper.showError(
        context,
        title: 'Error al validar el código de verificación',
        description: error.toString(),
      );
      isLoading.value = false;
    });

    isLoading.value = false;
  }

  /// ✅ Valida el código para recuperación de contraseña
  Future<void> validatePasswordRecoveryCode({
    required BuildContext context,
    required String email,
    required String code,
  }) async {
    isLoading.value = true;
    final dto = ValidateVerificationCodeDTO(email: email, code: code);

    await GlobalExceptionHandler.run(() async {
      // 📩 Solo valida el código, no activa usuario
      await _authService.validateVerificationCode(dto);

      if (context.mounted) {
        _validatedCode = code; // ✅ Guardamos código temporalmente
        ToastHelper.showSuccess(context, title: 'Código validado correctamente');

        // Redirige a la vista de cambio de contraseña
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.recoverPassword,
          arguments: email,
        );
      }
    }, onError: (error) {
      ToastHelper.showError(
        context,
        title: 'Error al validar el código de verificación',
        description: error.toString(),
      );
      isLoading.value = false;
    });

    isLoading.value = false;
  }

  /// ⏱️ Inicia el temporizador del código
  void startTimer(VoidCallback onTick, VoidCallback onFinished) {
    timerCount = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timerCount--;
      onTick();
      if (timerCount <= 0) {
        timer.cancel();
        onFinished();
      }
    });
  }

  /// 🔢 Formatea el tiempo (MM:SS)
  String formatTime() {
    final minutes = timerCount ~/ 60;
    final seconds = timerCount % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 🔐 Obtiene el código ingresado en los 6 campos
  String getCodeInput() {
    return codeControllers.map((c) => c.text).join();
  }

  /// 📌 Devuelve el código validado (para recuperación de contraseña)
  static String? getValidatedCode() {
    return _validatedCode;
  }

  /// 📌 Limpia el código validado (por ejemplo, después de cambiar la contraseña)
  static void clearValidatedCode() {
    _validatedCode = null;
  }

  /// 🧹 Limpia recursos
  void dispose() {
    isLoading.dispose();
    for (var c in codeControllers) {
      c.dispose();
    }
    _timer?.cancel();
  }
}
