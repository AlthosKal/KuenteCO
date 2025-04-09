import 'package:kuenteco/infrastructure/datasources/remote/Auth_api_service.dart';
import 'package:kuenteco/infrastructure/repositories/Auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  // =================== TOKEN MANAGEMENT ===================

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token != null) _apiService.setToken(token); // ⬅️ CARGA EN MEMORIA
  }



  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    _apiService.setToken('');
  }

  // =================== AUTH ===================

  @override
  Future<void> login({required String nameOrEmail, required String password}) async {
    final response = await _apiService.login(
      nameOrEmail: nameOrEmail,
      password: password,
    );

    if (response == null) {
      throw Exception('Error: Respuesta nula del servidor');
    }

    if (response['status'] == 'success') {
      final token = response['token'];
      if (token != null) {
        await _saveToken(token);           // ✅ persistente
        _apiService.setToken(token);       // ✅ ¡esto es lo que falta!
        print('[DEBUG] Token seteado en memoria: $token'); // opcional para confirmar
      }

  } else {
      throw Exception(response['message'] ?? 'Login failed');
    }
  }


  @override
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } finally {
      await _clearToken();
    }
  }

  @override
  Future<bool> checkAuth() async {
    await _loadToken();
    return await _apiService.checkAuth();
  }

  @override
  Future<bool> isLoggedIn() async {
    await _loadToken();
    return _apiService.getToken() != null;
  }

  @override
  Future<Map<String, dynamic>> getAllAccounts() async {
    await _loadToken();
    final response = await _apiService.getAllAccounts();

    if (response['status'] == 'success') {
      return {
        'accounts': response['data'], // <- Aquí lo adaptamos al frontend
        'status': 'success',
      };
    } else {
      throw Exception(response['message'] ?? 'Error al obtener detalles del usuario');
    }
  }


  // =================== REGISTER ===================

  @override
  Future<void> register(String name, String email, String password) async {
    final response = await _apiService.register(
      name: name,
      email: email,
      password: password,
      confirmPassword: password, // Assuming confirmPassword is required by API
    );

    if (response['status'] == 'success') {
      final token = _apiService.getToken();
      if (token != null) await _saveToken(token);
    } else {
      throw Exception(response['message'] ?? 'Error al registrarse');
    }
  }

  @override
  Future<void> activateAccount({
    required String email,
    required String code,
  }) async {
    final response = await _apiService.activateAccount(email: email, code: code);
    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Error al activar la cuenta');
    }
  }

  // =================== VERIFICATION ===================

  @override
  Future<void> sendVerificationCode({
    required String email,
    bool isRegistration = false,
  }) async {
    final response = await _apiService.sendVerificationCode(
      email: email,
      isRegistration: isRegistration,
    );
    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Error enviando código de verificación');
    }
  }

  @override
  Future<void> validateVerificationCode({
    required String email,
    required String code,
  }) async {
    final response = await _apiService.validateVerificationCode(email: email, code: code);
    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Código inválido');
    }
  }

  // =================== PASSWORD ===================

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
      confirmNewPassword: confirmNewPassword ?? newPassword,
    );

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Error al cambiar la contraseña');
    }
  }

  // =================== PROFILE ===================

  @override
  Future<void> updateProfile(Map<String, dynamic> userData) async {
    await _loadToken();
    final response = await _apiService.updateProfile(userData: userData);

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Error al actualizar el perfil');
    }
  }

  @override
  Future<void> updateAccountImage({
    required int accountId,
    required dynamic imageFile,
  }) async {
    await _loadToken();
    final response = await _apiService.updateAccountImage(
      accountId: accountId,
      imageFile: imageFile,
    );

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Error al actualizar imagen de cuenta');
    }
  }

  @override
  Future<void> deleteAccountImage({required int accountId}) async {
    await _loadToken();
    final response = await _apiService.deleteAccountImage(accountId: accountId);

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Error al eliminar imagen de cuenta');
    }
  }
}