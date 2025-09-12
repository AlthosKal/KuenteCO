import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../screens/home/logged_home_business_view.dart';
import '../../../screens/home/logged_home_personal_view.dart';
import '../../core/exceptions/global_exception_handler.dart';
import '../../core/services/app/auth_service.dart';
import '../../dto/app/auth/request/login_user_dto.dart';
import '../../provider/toast_helper.dart';
import '../chat_controller.dart';

class LoginController {
  final AuthService _authService;

  // Estados de UI reactivos
  final ValueNotifier<bool> rememberPassword = ValueNotifier(false);
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  LoginController({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// ð¥ Método de login
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
        /// â 1ï¸â£ Loguear usuario y obtener token + role
        final tokenResponse = await _authService.login(dto);

        /// â 2ï¸â£ Obtener detalles del usuario (nombre, imagen, etc.)
        final user = await _authService.getAuthenticatedUser();

        /// 🔄 Notificar al ChatController sobre el cambio de usuario
        if (context.mounted) {
          try {
            final chatController = Provider.of<ChatController>(context, listen: false);
            await chatController.onUserChanged();
            print('✅ LoginController: ChatController notificado del cambio de usuario');
          } catch (e) {
            print('⚠️ LoginController: Error notificando cambio de usuario al ChatController: $e');
            // Continuar con el login incluso si falla la notificación
          }
        }

        if (context.mounted) {
          /// â 3ï¸â£ Mostrar mensaje de éxito
          ToastHelper.showSuccess(
            context,
            title: 'Inicio de Sesión Exitoso',
            description: tokenResponse.type == 'PERSONAL'
                ? 'Has iniciado como usuario Personal'
                : 'Has iniciado como cuenta Business',
          );

          /// â 4ï¸â£ Redirigir a la vista correcta según el tipo de cuenta
          if (tokenResponse.type == 'PERSONAL') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LoggedHomePersonalView(
                  userName: user.username,
                  profileImageUrl: user.image?.imageUrl ?? '', // â Usa la URL de la imagen
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LoggedHomeBusinessView(
                  userName: user.username,
                  profileImageUrl: user.image?.imageUrl ?? '', // â Usa la URL de la imagen
                ),
              ),
            );
          }
        }
      },
      onError: (error) {
        /// â Mostrar mensaje de error
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

  /// ð Toggle para mostrar/ocultar contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// â Cambiar recordar contraseña
  void toggleRememberPassword(bool? value) {
    rememberPassword.value = value ?? false;
  }

  /// â»ï¸ Liberar recursos
  void dispose() {
    rememberPassword.dispose();
    obscurePassword.dispose();
    isLoading.dispose();
  }
}
