import 'package:flutter/material.dart';

import '../../../screens/home/logged_home_business_view.dart';
import '../../../screens/home/logged_home_personal_view.dart';
import '../../core/exceptions/global_exception_handler.dart';
import '../../core/services/app/auth_service.dart';
import '../../dto/app/auth/request/login_user_dto.dart';
import '../../provider/toast_helper.dart';

class LoginController {
  final AuthService _authService;

  // Estados de UI reactivos
  final ValueNotifier<bool> rememberPassword = ValueNotifier(false);
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  LoginController({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// 🔥 Método de login
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
        /// ✅ 1️⃣ Loguear usuario y obtener token + role
        final tokenResponse = await _authService.login(dto);

        /// ✅ 2️⃣ Obtener detalles del usuario (nombre, imagen, etc.)
        final user = await _authService.getAuthenticatedUser();

        if (context.mounted) {
          /// ✅ 3️⃣ Mostrar mensaje de éxito
          ToastHelper.showSuccess(
            context,
            title: 'Inicio de Sesión Exitoso',
            description: tokenResponse.type == 'PERSONAL'
                ? 'Has iniciado como usuario Personal'
                : 'Has iniciado como cuenta Business',
          );

          /// ✅ 4️⃣ Redirigir a la vista correcta según el tipo de cuenta
          if (tokenResponse.type == 'PERSONAL') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LoggedHomePersonalView(
                  userName: user.username,
                  profileImageUrl: user.image?.imageUrl ?? '', // ✅ Usa la URL de la imagen
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LoggedHomeBusinessView(
                  userName: user.username,
                  profileImageUrl: user.image?.imageUrl ?? '', // ✅ Usa la URL de la imagen
                ),
              ),
            );
          }
        }
      },
      onError: (error) {
        /// ❌ Mostrar mensaje de error
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

  /// 🔒 Toggle para mostrar/ocultar contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// ✅ Cambiar recordar contraseña
  void toggleRememberPassword(bool? value) {
    rememberPassword.value = value ?? false;
  }

  /// ♻️ Liberar recursos
  void dispose() {
    rememberPassword.dispose();
    obscurePassword.dispose();
    isLoading.dispose();
  }
}
