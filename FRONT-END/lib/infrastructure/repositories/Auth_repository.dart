abstract class AuthRepository {
  Future<void> register(
      String email,
      String password,
      String name);

  Future<void> login({
    required String nameOrEmail,
    required String password,
  });

  Future<bool> isLoggedIn();

  Future<void> changePassword({
    required String email,
    required String code,
    required String newPassword,
    String? confirmNewPassword,
  });

  Future<void> logout();


  Future<void> updateAccountImage({
    required int accountId,
    required dynamic imageFile,
  });

  Future<void> deleteAccountImage({
    required int accountId,
  });

  Future<bool> checkAuth();

  Future<Map<String, dynamic>> getAllAccounts();
}
