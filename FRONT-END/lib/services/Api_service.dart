import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = dotenv.get('API_URL', fallback: 'https://api.tudominio.com');
  final http.Client _client = http.Client();
  String? _authToken;

  // Métodos para manejar el token
  void setToken(String token) => _authToken = token;
  String? getToken() => _authToken;
  bool get isLoggedIn => _authToken != null;

  // Headers
  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> get _authHeaders {
    final headers = {..._jsonHeaders};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Método para extraer el token de las cookies
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

  // Métodos de autenticación
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/login'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'password': password
        }),
      );

      final token = _extractTokenFromCookies(response);
      if (token != null) {
        _authToken = token;
      }

      return _processResponse(response, 'Login successful');
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/register'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'password': password
        }),
      );
      return _processResponse(response, 'Registration successful. Please verify your email');
    } catch (e) {
      return _handleError(e);
    }
  }

  // Métodos de verificación
  Future<Map<String, dynamic>> sendVerificationCode({
    required String email,
    bool isRegistration = false
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/send-verification-code?isRegistration=$isRegistration'),
        headers: _jsonHeaders,
        body: json.encode({'email': email}),
      );
      return _processResponse(response, 'Verification code sent');
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> validateVerificationCode({
    required String email,
    required String code
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/validate-verification-code'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'code': code
        }),
      );
      return _processResponse(response, 'Code verified successfully');
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> activateAccount({
    required String email,
    required String code
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/activate-account'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'code': code
        }),
      );
      return _processResponse(response, 'Account activated successfully');
    } catch (e) {
      return _handleError(e);
    }
  }

  // Métodos de recuperación de contraseña
  Future<Map<String, dynamic>> sendRecoveryCode({required String email}) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/send-recovery-code'),
        headers: _jsonHeaders,
        body: json.encode({'email': email}),
      );
      return _processResponse(response, 'Recovery code sent successfully');
    } catch (e) {
      return _handleError(e);
    }
  }

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

      final result = _processResponse(response, 'Password changed successfully');

      if (result['status'] == 'error' && result['data'] != null && result['data'] is Map) {
        final data = result['data'] as Map;
        if (data.containsKey('error')) {
          result['message'] = data['error'];
        }
      }

      return result;
    } catch (e) {
      return _handleError(e);
    }
  }

  // Métodos auxiliares
  Map<String, dynamic> _processResponse(http.Response response, String successMessage) {
    if (response.body.isEmpty) {
      return {
        'status': 'error',
        'message': 'Empty response from server',
        'statusCode': response.statusCode,
      };
    }

    try {
      final dynamic data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'status': 'success',
          'message': data is Map ? (data['message'] ?? successMessage) : successMessage,
          'data': data,
        };
      } else {
        return {
          'status': 'error',
          'message': data is Map ? (data['message'] ?? 'Error (${response.statusCode})')
              : 'Error (${response.statusCode})',
          'statusCode': response.statusCode,
          'data': data,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error processing response: $e',
        'rawResponse': response.body,
        'statusCode': response.statusCode,
      };
    }
  }

  Map<String, dynamic> _handleError(dynamic e) {
    return {
      'status': 'error',
      'message': 'Connection error: ${e.toString()}',
    };
  }

  void dispose() {
    _client.close();
  }
}