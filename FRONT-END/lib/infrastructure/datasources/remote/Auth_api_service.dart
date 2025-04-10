import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiService {
  // ==================== PROPIEDADES ====================
  final String baseUrl = dotenv.get('API_URL');
  final http.Client _client = http.Client();
  String? _authToken;

  // ==================== HEADERS ====================
  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null && _authToken!.isNotEmpty) 'Authorization': 'Bearer $_authToken',
  };

  // ==================== TOKEN ====================
  void setToken(String? token) {
    _authToken = token;
    print('[DEBUG] Token establecido en AuthApiService: $_authToken');
  }

  String? getToken() => _authToken;
  bool get isLoggedIn => _authToken != null && _authToken!.isNotEmpty;

  String? _extractTokenFromCookies(http.Response response) {
    final cookieHeader = response.headers['set-cookie'];
    if (cookieHeader != null) {
      final cookies = cookieHeader.split(';');
      for (var cookie in cookies) {
        if (cookie.trim().startsWith('jwt=')) {
          return cookie.trim().substring(4);
        }
      }
    }
    return null;
  }

  // ==================== RESPUESTA ====================
  Map<String, dynamic> _processResponse(http.Response response, String successMessage) {
    if (response.body.isEmpty) {
      return {
        'status': 'error',
        'message': 'Empty response from server',
        'statusCode': response.statusCode,
      };
    }

    try {
      final data = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'status': 'success',
          'message': data is Map ? (data['message'] ?? successMessage) : successMessage,
          'data': data,
        };
      } else {
        return {
          'status': 'error',
          'message': data is Map ? (data['message'] ?? 'Error (${response.statusCode})') : 'Error',
          'statusCode': response.statusCode,
          'data': data,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error parsing response: $e',
        'rawResponse': response.body,
        'statusCode': response.statusCode,
      };
    }
  }

  // ==================== AUTENTICACIÓN ====================
  Future<Map<String, dynamic>> login({
    required String nameOrEmail,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/login'),
        headers: _jsonHeaders,
        body: json.encode({
          'nameOrEmail': nameOrEmail,
          'password': password,
        }),
      );
      final data = jsonDecode(response.body);
      print('[DEBUG] Estructura completa de la respuesta: $data');
      print('[DEBUG] Respuesta completa del backend: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          _authToken = data['token'];
          print('[DEBUG] Token extraído del cuerpo: $_authToken');
          return {
            'status': 'success',
            'token': data['token'],
          };
        }
      }

      // Como respaldo, intentar extraer token de cookies
      final token = _extractTokenFromCookies(response);
      if (token != null) {
        _authToken = token;
        print('[DEBUG] Token extraído de cookies: $_authToken');
      }

      return _processResponse(response, 'Login successful');
    } catch (e) {
      print('[ERROR] Error en login: $e');
      return {'status': 'error', 'message': 'Login error: $e'};
    }
  }

  Future<void> logout() async {
    if (_authToken == null) return;

    try {
      await _client.post(
        Uri.parse('$baseUrl/v1/auth/logout'),
        headers: _authHeaders,
      );
    } catch (_) {
      // Ignorar errores de logout
    } finally {
      _authToken = null;
    }
  }

  Future<bool> checkAuth() async {
    if (_authToken == null) return false;

    final response = await _client.get(
      Uri.parse('$baseUrl/v1/auth/check-auth'),
      headers: _authHeaders,
    );

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    if (_authToken == null) {
      return {'status': 'error', 'message': 'Token no disponible'};
    }

    final response = await _client.get(
      Uri.parse('$baseUrl/v1/auth/user/details'),
      headers: _authHeaders,
    );

    final data = json.decode(response.body);
    return response.statusCode == 200
        ? {'status': 'success', 'data': data}
        : {'status': 'error', 'message': data['message']};
  }

  // ==================== CONTRASEÑA ====================
  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/v1/auth/change-password'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        }),
      );

      return _processResponse(response, 'Password changed successfully');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error changing password: ${e.toString()}',
      };
    }
  }

  // ==================== VERIFICACIÓN ====================
  Future<Map<String, dynamic>> sendVerificationCode({
    required String email,
    bool isRegistration = false,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/send-verification-code?isRegistration=$isRegistration'),
        headers: _jsonHeaders,
        body: json.encode({'email': email}),
      );

      return _processResponse(response, 'Verification code sent successfully');
    } catch (e) {
      return {'status': 'error', 'message': 'Error sending code: $e'};
    }
  }

  Future<Map<String, dynamic>> validateVerificationCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/validate-verification-code'),
        headers: _jsonHeaders,
        body: json.encode({'email': email, 'code': code}),
      );

      return _processResponse(response, 'Code verified');
    } catch (e) {
      return {'status': 'error', 'message': 'Error verifying code: $e'};
    }
  }

  // ==================== REGISTRO ====================
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/register'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'name': name,
        }),
      );

      final token = _extractTokenFromCookies(response);
      if (token != null) _authToken = token;

      return _processResponse(response, 'Registration successful');
    } catch (e) {
      return {'status': 'error', 'message': 'Registration error: $e'};
    }
  }

  Future<Map<String, dynamic>> activateAccount({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/activate-account'),
        headers: _jsonHeaders,
        body: json.encode({'email': email, 'code': code}),
      );

      return _processResponse(response, 'Account activated');
    } catch (e) {
      return {'status': 'error', 'message': 'Activation error: $e'};
    }
  }

  // ==================== PERFIL ====================
  Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/v1/account'),
        headers: _authHeaders,
        body: json.encode(userData),
      );

      return _processResponse(response, 'Profile updated');
    } catch (e) {
      return {'status': 'error', 'message': 'Profile update error: $e'};
    }
  }

  // ==================== IMAGEN DE PERFIL ====================
  Future<Map<String, dynamic>> uploadProfileImage({
    required dynamic imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/v1/auth/user/image/add'),
      );

      request.headers['Authorization'] = 'Bearer $_authToken';
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response, 'Profile image uploaded successfully');
    } catch (e) {
      return {'status': 'error', 'message': 'Error uploading profile image: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfileImage({
    required dynamic imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/v1/auth/user/image/update'),
      );

      request.headers['Authorization'] = 'Bearer $_authToken';
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response, 'Profile image updated successfully');
    } catch (e) {
      return {'status': 'error', 'message': 'Error updating profile image: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteProfileImage() async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/v1/auth/delete'),
        headers: _authHeaders,
      );

      return _processResponse(response, 'Profile image deleted successfully');
    } catch (e) {
      return {'status': 'error', 'message': 'Error deleting profile image: $e'};
    }
  }

  // ==================== CUENTAS ====================
  Future<Map<String, dynamic>> getAllAccounts() async {
    if (_authToken == null || _authToken!.isEmpty) {
      print('[ERROR] getAllAccounts: Token no disponible');
      return {'status': 'error', 'message': 'Token no disponible'};
    }

    print('[DEBUG] Token en getAllAccounts: $_authToken');
    print('[DEBUG] Headers en getAllAccounts: $_authHeaders');

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/v1/account'),
        headers: _authHeaders,
      );

      print('[DEBUG] getAllAccounts response: ${response.statusCode} - ${response.body}');
      return _processResponse(response, 'Accounts retrieved successfully');
    } catch (e) {
      print('[ERROR] Error en getAllAccounts: $e');
      return {'status': 'error', 'message': 'Error retrieving accounts: $e'};
    }
  }

  Future<Map<String, dynamic>> registerAccount({
    required String name,
    required String type,
    required double initialBalance,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/account/register'),
        headers: _authHeaders,
        body: json.encode({
          'name': name,
          'type': type,
        }),
      );

      return _processResponse(response, 'Account registered successfully');
    } catch (e) {
      return {'status': 'error', 'message': 'Error registering account: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAccount({
    required int accountId,
  }) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/v1/account/$accountId'),
        headers: _authHeaders,
      );

      return _processResponse(response, 'Account deleted successfully');
    } catch (e) {
      return {'status': 'error', 'message': 'Error deleting account: $e'};
    }
  }

  // ==================== IMAGENES DE CUENTAS ====================
  Future<Map<String, dynamic>> uploadAccountImage({
    required int accountId,
    required dynamic imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/v1/account/$accountId/image/add'),
      );

      request.headers['Authorization'] = 'Bearer $_authToken';
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response, 'Account image uploaded successfully');
    } catch (e) {
      return {'status': 'error', 'message': 'Error uploading account image: $e'};
    }
  }

  Future<Map<String, dynamic>> updateAccountImage({
    required int accountId,
    required dynamic imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/v1/account/$accountId/image/update'),
      );

      request.headers['Authorization'] = 'Bearer $_authToken';
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response, 'Account image updated successfully');
    } catch (e) {
      return {'status': 'error', 'message': 'Error updating account image: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAccountImage({
    required int accountId,
  }) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/v1/account/$accountId/delete'),
        headers: _authHeaders,
      );

      return _processResponse(response, 'Account image deleted successfully');
    } catch (e) {
      return {'status': 'error', 'message': 'Error deleting account image: $e'};
    }
  }
}
