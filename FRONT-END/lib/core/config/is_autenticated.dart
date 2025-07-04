import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kuenteco/core/services/app/auth_service.dart';
import '../exceptions/global_exception_handler.dart';

Future<bool> isAuthenticated() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'Authorization');

  if (token == null || token.isEmpty) return false;

  final userService = AuthService();
  bool valid = false;

  await GlobalExceptionHandler.run(
        () async {
      await userService.getAuthenticatedUser();
      valid = true;
    },
    onError: (_) async {
      await storage.delete(key: 'Authorization');
      valid = false;
    },
  );

  return valid;
}