import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../exceptions/global_exception_handler.dart';
import '../services/app/auth_service.dart';
import '../services/app/profile_service.dart';

Future<String?> getRoleIfAuthenticated() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'Authorization');

  if (token == null || token.isEmpty) return null;

  // â Obtener el rol para determinar quÃ© servicio usar
  final role = await storage.read(key: 'role');
  bool valid = false;

  await GlobalExceptionHandler.run(
        () async {
      // â Usar el servicio apropiado segÃºn el rol
      if (role == 'ROLE_PROFILE') {
        final profileService = ProfileService();
        await profileService.getAuthenticatedProfile();
      } else {
        final userService = AuthService();
        await userService.getAuthenticatedUser();
      }
      valid = true;
    },
    onError: (_) async {
      await storage.delete(key: 'Authorization');
      await storage.delete(key: 'role'); // â Borramos tambiÃ©n el rol si falla
      valid = false;
    },
  );

  if (!valid) return null;

  // â devolvemos el rol guardado
  return role;
}
