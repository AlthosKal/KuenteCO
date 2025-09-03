import 'dart:async';

import 'package:flutter/material.dart';

import '../core/exceptions/global_exception_handler.dart';
import '../core/services/app/auth_service.dart';
import '../dto/app/auth/request/validate_verification_code_dto.dart';
import '../provider/toast_helper.dart';
import '../routes/app_routes.dart';
import '../screens/auth/password_recovery_view.dart';

class ValidateVerificationCodeController {
  final AuthService _authService;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  static String? _validatedCode;

  final List<TextEditingController> codeControllers = List.generate(
    6,
        (_) => TextEditingController(),
  );

  int currentStep = 0;
  int timerCount = 120;
  Timer? _timer;

  ValidateVerificationCodeController({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<void> validateVerificationCode({
    required BuildContext context,
    required String email,
    required String code,
  }) async {
    isLoading.value = true;
    final dto = ValidateVerificationCodeDTO(email: email, code: code);

    await GlobalExceptionHandler.run(() async {
      await _authService.activateUser(dto);

      if (context.mounted) {
        ToastHelper.showSuccess(
          context,
          title: 'Cuenta activada correctamente. Ahora puedes iniciar sesión',
        );
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

  Future<void> validatePasswordRecoveryCode({
    required BuildContext context,
    required String email,
    required String code,
  }) async {
    isLoading.value = true;
    final dto = ValidateVerificationCodeDTO(email: email, code: code);

    await GlobalExceptionHandler.run(() async {
      await _authService.validateVerificationCode(dto);

      if (context.mounted) {
        _validatedCode = code;
        ToastHelper.showSuccess(context, title: 'Código validado correctamente');

        /// ✅ Redirige pasando email y código directamente al constructor
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RecoverPasswordScreen(email: email, code: code),
          ),
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

  String formatTime() {
    final minutes = timerCount ~/ 60;
    final seconds = timerCount % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String getCodeInput() {
    return codeControllers.map((c) => c.text).join();
  }

  static String? getValidatedCode() => _validatedCode;

  static void clearValidatedCode() {
    _validatedCode = null;
  }

  void dispose() {
    isLoading.dispose();
    for (var c in codeControllers) {
      c.dispose();
    }
    _timer?.cancel();
  }
}
