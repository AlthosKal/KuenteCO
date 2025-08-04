import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../exceptions/global_exception_handler.dart';
import '../services/app/auth_service.dart';

Future<String?> getRoleIfAuthenticated() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'Authorization');

  if (token == null || token.isEmpty) return null;

  final userService = AuthService();
  bool valid = false;

  await GlobalExceptionHandler.run(
        () async {
      await userService.getAuthenticatedUser();
      valid = true;
    },
    onError: (_) async {
      await storage.delete(key: 'Authorization');
      await storage.delete(key: 'role'); // ✅ Borramos también el rol si falla
      valid = false;
    },
  );

  if (!valid) return null;

  // ✅ devolvemos el rol guardado
  return await storage.read(key: 'role');
}
