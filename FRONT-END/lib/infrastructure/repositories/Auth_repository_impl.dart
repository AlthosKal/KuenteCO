import 'package:kuenteco/infrastructure/datasources/remote/Auth_api_service.dart';
import 'package:kuenteco/infrastructure/repositories/Auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.login(email: email, password: password);

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Login failed');
    }
  }

  @override
  Future<void> changePassword({
    required String email,
    required String code,
    required String newPassword,
    String? confirmNewPassword,
  }) async {
    final response = await _apiService.changePassword(
      email: email,
      code: code,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword ?? newPassword, // ✅ Manejo de null
    );

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Failed to change password');
    }
  }
}
