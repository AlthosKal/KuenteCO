import 'package:kuenteco/infrastructure/datasources/remote/Auth_api_service.dart';
import 'package:kuenteco/infrastructure/repositories/Auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;

  AuthRepositoryImpl(this._apiService){
    _loadToken();
  }

  // =================== TOKEN MANAGEMENT ===================

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    print('[DEBUG] Token guardado en SharedPreferences: $token');
  }

  Future<String?> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      print('[DEBUG] Token cargado desde SharedPreferences: $token');
      if (token != null && token.isNotEmpty) {
        _apiService.setToken(token);
        return token;
      }
      return null;
    } catch (e) {
      print('[ERROR] Error al cargar token: $e');
      return null;
    }
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    _apiService.setToken(null);
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
      // La respuesta podría tener el token directamente en 'token'
      // o dentro de la estructura 'data'
      String? token = response['token'];

      // Si no está en 'token', intentar buscarlo en 'data'
      if (token == null && response['data'] is Map) {
        token = response['data']['token'];
      }

      // Si se encontró un token válido, guardarlo
      if (token != null && token.isNotEmpty) {
        await _saveToken(token);
        _apiService.setToken(token);
        print('[DEBUG] Login exitoso - Token guardado: $token');
      } else {
        // Verificar si el servicio ya tiene un token válido (en caso de extraerse de cookies)
        token = _apiService.getToken();
        if (token != null && token.isNotEmpty) {
          await _saveToken(token);
          print('[DEBUG] Login exitoso - Token extraído de cookies: $token');
        } else {
          print('[WARNING] Login exitoso pero no se recibió token');
          throw Exception('No se recibió token de autenticación');
        }
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
  Future<bool> isLoggedIn() async {
    final token = await _loadToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> checkAuth() async {
    // Ya que mencionaste que este endpoint fue retirado,
    // simplemente verificamos si hay un token válido
    final token = await _loadToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>> getAllAccounts() async {
    // Asegurar que el token esté cargado antes de hacer la petición
    final token = await _loadToken();

    if (token == null || token.isEmpty) {
      print('[ERROR] getAllAccounts: No hay token válido disponible');
      return {
        'accounts': [],
        'status': 'error',
        'message': 'No hay sesión activa'
      };
    }

    final response = await _apiService.getAllAccounts();

    if (response['status'] == 'success') {
      return {
        'accounts': response['data'],
        'status': 'success',
      };
    } else {
      // Si recibimos un 401, podríamos intentar re-autenticar aquí
      if (response['statusCode'] == 401) {
        print('[WARNING] Token inválido o expirado');
      }

      return {
        'accounts': [],
        'status': 'error',
        'message': response['message'] ?? 'Error al obtener cuentas'
      };
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