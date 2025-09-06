import 'package:flutter/material.dart';

import '../../core/exceptions/global_exception_handler.dart';
import '../../core/services/app/profile_service.dart';
import '../../dto/app/auth/request/login_user_dto.dart';
import '../../provider/toast_helper.dart';
import '../../routes/app_routes.dart';

class ProfileLoginController {
  final ProfileService _profileService;

  // Estados de UI reactivos
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  ProfileLoginController({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

  /// Login directo con perfil
  Future<void> profileLogin({
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
        /// â 1ï¸â£ Hacer login directo con el perfil usando /profile/login
        await _profileService.profileLogin(dto.nameOrEmail, dto.password);

        if (context.mounted) {
          /// â 2ï¸â£ Mostrar mensaje de Ã©xito
          ToastHelper.showSuccess(
            context,
            title: 'Inicio de SesiÃ³n de Perfil Exitoso',
            description: 'Has iniciado sesiÃ³n como perfil',
          );

          /// â 3ï¸â£ Navegar a la vista de perfil
          Navigator.pushReplacementNamed(context, AppRoutes.homeProfile);
        }
      },
      onError: (error) {
        /// â Mostrar mensaje de error
        ToastHelper.showError(
          context,
          title: 'Error al iniciar SesiÃ³n de Perfil',
          description: error.toString(),
        );
        isLoading.value = false;
      },
    );

    isLoading.value = false;
  }

  /// â»ï¸ Liberar recursos
  void dispose() {
    isLoading.dispose();
  }
}
