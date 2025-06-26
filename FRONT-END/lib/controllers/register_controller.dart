import 'package:flutter/material.dart';
import '../core/exceptions/global_exception_handler.dart';
import '../core/services/app/auth_service.dart';
import '../dto/auth/request/new_user_dto.dart';
import '../provider/toast_helper.dart';
import '../routes/app_routes.dart';

class RegisterController {
  final AuthService _authService;

  // Estados de UI reactivos
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  RegisterController({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<void> register({
    required BuildContext context,
    required String username,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;

    final dto = NewUserDTO(
      username: username.trim(),
      email: email,
      password: password,
    );

    await GlobalExceptionHandler.run(() async {
      await _authService.register(dto);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        ToastHelper.showSuccess(context, title: 'Registro de cuenta exitoso');
      }
    }, onError: (error) {
      ToastHelper.showError(context, title: 'Error al registrar la cuenta', description: error.toString());
      isLoading.value = false;
    });
    isLoading.value = false;
  }

  // Toggle para mostrar/ocultar contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  //Liberar Recursos
  void dispose() {
    obscurePassword.dispose();
    isLoading.dispose();
  }
}