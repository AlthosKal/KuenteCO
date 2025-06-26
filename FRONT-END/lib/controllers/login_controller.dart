import 'package:flutter/material.dart';
import '../../dto/auth/request/login_user_dto.dart';
import '../core/exceptions/global_exception_handler.dart';
import '../core/services/app/auth_service.dart';
import '../provider/toast_helper.dart';
import '../routes/app_routes.dart';

class LoginController {
  final AuthService _authService;

  // Estados de UI reactivos
  final ValueNotifier<bool> rememberPassword = ValueNotifier(false);
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  LoginController({AuthService? authService})
      : _authService = authService ?? AuthService();

  // Método de login
  Future<void> login({
    required BuildContext context,
    required String nameOrEmail,
    required String password,
  }) async {
    isLoading.value = true;

    final dto = LoginUserDTO(
      nameOrEmail: nameOrEmail.trim(),
      password: password,
    );

    await GlobalExceptionHandler.run(
          () async {
        await _authService.login(dto);
        if (context.mounted) {
          ToastHelper.showSuccess(
            context,
            title: 'Inicio de Sesión Exitoso',
            description: '',
          );
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      },
      onError: (error) {
        ToastHelper.showError(
          context,
          title: 'Error al iniciar Sesión',
          description: error.toString(),
        );
        isLoading.value = false;
      },
    );
    isLoading.value = false;
  }

  // Toggle para mostrar/ocultar contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Cambiar recordar contraseña
  void toggleRememberPassword(bool? value) {
    rememberPassword.value = value ?? false;
  }

  // Liberar recursos
  void dispose() {
    rememberPassword.dispose();
    obscurePassword.dispose();
    isLoading.dispose();
  }
}