abstract class AuthRepository {
  Future<void> login({required String email, required String password});
  Future<void> changePassword({
    required String email,
    required String code,
    required String newPassword,
    String? confirmNewPassword,
  });
}
