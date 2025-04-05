abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> sendVerificationCode(String email);

  Future<bool> verifyRecoveryCode(String email, String code);

  Future<void> changePassword(String email, String newPassword);

  Future<void> logout();
}
