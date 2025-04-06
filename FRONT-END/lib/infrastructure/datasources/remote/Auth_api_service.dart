import 'dart:convert';
import 'package:dio/src/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthApiService {
  // ==================== CONSTANTES Y PROPIEDADES ====================
  final String baseUrl = dotenv.get('API_URL');
  final http.Client _client = http.Client();
  String? _authToken;

  // ==================== GETTERS Y SETTERS ====================
  void setToken(String token) => _authToken = token;
  String? getToken() => _authToken;
  bool get isLoggedIn => _authToken != null;

  // ==================== CONFIGURACIÓN DE HEADERS ====================
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

  // ==================== MÉTODOS PRIVADOS AUXILIARES ====================
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
          'message': data is Map
              ? (data['message'] ?? 'Error (${response.statusCode})')
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

  // ==================== REGISTRO DE USUARIO ====================
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    Map<String, dynamic>? additionalData,
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
          ...?additionalData,
        }),
      );

      final token = _extractTokenFromCookies(response);
      if (token != null) _authToken = token;

      return _processResponse(response, 'Registration successful');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error during registration: ${e.toString()}',
      };
    }
  }

  // ==================== ACTIVACIÓN DE CUENTA ====================
  Future<Map<String, dynamic>> activateAccount({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/activate-account'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'code': code,
        }),
      );

      return _processResponse(response, 'Account activated successfully');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error activating account: ${e.toString()}',
      };
    }
  }

  // ==================== AUTENTICACIÓN BÁSICA ====================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/login'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final token = _extractTokenFromCookies(response);
      if (token != null) _authToken = token;

      return _processResponse(response, 'Login successful');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error en login: ${e.toString()}',
      };
    }
  }

  Future<void> logout() async {
    _authToken = null;
  }

  // ==================== RECUPERACIÓN DE CONTRASEÑA ====================
  Future<Map<String, dynamic>> sendVerificationCode({
    required String email,
    bool isRegistration = false,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/send-recovery-code'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'purpose': isRegistration ? 'registration' : 'password_recovery',
        }),
      );

      return _processResponse(
        response,
        isRegistration
            ? 'Registration code sent successfully'
            : 'Password recovery code sent successfully',
      );
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error sending verification code: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> ValidateVerificationCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/verify-recovery-code'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'code': code,
        }),
      );

      return _processResponse(response, 'Code verified successfully');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error verifying code: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String code,
    required String newPassword,
    String? confirmNewPassword,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/v1/auth/change-password'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword ?? newPassword,
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

  // ==================== VERIFICACIÓN DE EMAIL ====================
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/verify-email'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'code': code,
        }),
      );

      return _processResponse(response, 'Email verified successfully');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error verifying email: ${e.toString()}',
      };
    }
  }

  // ==================== ACTUALIZACIÓN DE PERFIL ====================
  Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/v1/user/profile'),
        headers: _authHeaders,
        body: json.encode(userData),
      );

      return _processResponse(response, 'Profile updated successfully');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error updating profile: ${e.toString()}',
      };
    }
  }
}