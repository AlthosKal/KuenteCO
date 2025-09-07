import 'package:flutter/material.dart';

import '../../core/exceptions/global_exception_handler.dart';
import '../../core/services/app/auth_service.dart';
import '../../dto/app/auth/request/new_user_dto.dart';
import '../../provider/toast_helper.dart';
import '../../routes/app_routes.dart';
import '../../utils/enum/user_type_enum.dart';

class RegisterController {
  final AuthService _authService;

  /// Estados reactivos de UI
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  RegisterController({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// Método para registrar al usuario
  Future<void> register({
    required BuildContext context,
    required String username,
    required String email,
    required String password,
    required UserType type,
  }) async {
    isLoading.value = true;

    final dto = NewUserDTO(
      username: username,
      email: email,
      password: password,
      type: type,
    );

    await GlobalExceptionHandler.run(
          () async {
        await _authService.register(dto);

        if (context.mounted) {
          /// â Mostramos mensaje de éxito
          ToastHelper.showSuccess(
            context,
            title: 'Registro exitoso',
            description: 'Verifica tu correo para activar tu cuenta',
          );

          /// â Redirigimos a la vista de verificación de registro
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.verificationRegister,
            arguments: email, // ð¥ enviamos el email a la pantalla de verificación
          );
        }
      },
      onError: (error) {
        ToastHelper.showError(
          context,
          title: 'Error al registrarse',
          description: error.toString(),
        );
        isLoading.value = false;
      },
    );

    isLoading.value = false;
  }

  /// Cambiar visibilidad de contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Liberar recursos
  void dispose() {
    obscurePassword.dispose();
    isLoading.dispose();
  }
}
