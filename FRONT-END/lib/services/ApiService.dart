import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // URL base para la API configurada en variables de entorno
  final String baseUrl = dotenv.get('API_URL', fallback: 'https://api.tudominio.com');

  // Cliente HTTP reutilizable
  final http.Client _client = http.Client();

  // Variable para almacenar el token en memoria
  String? _authToken;

  // Setter para el token
  void setToken(String token) {
    _authToken = token;
  }

  // Getter para el token
  String? getToken() {
    return _authToken;
  }

  // Headers comunes para peticiones JSON
  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers con autorización
  Map<String, String> get _authHeaders => {
    ..._jsonHeaders,
    'Authorization': 'Bearer ${_authToken ?? ''}',
  };

  // Método para procesar respuestas HTTP
  Map<String, dynamic> _processResponse(http.Response response, String successMessage) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Si la respuesta contiene un token, lo guardamos en memoria
        if (data is Map && data['token'] != null) {
          _authToken = data['token'];
        }

        return {
          'status': 'success',
          'message': successMessage,
          'data': data,
        };
      } else {
        final errorMessage = data is Map ? data['message'] : null;
        return {
          'status': 'error',
          'message': errorMessage ?? 'Error en la solicitud: ${response.statusCode}',
          'details': data is Map ? data : response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error al procesar respuesta: $e',
      };
    }
  }

  // Método para registrar usuario
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/register'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      return _processResponse(response, 'Registro exitoso');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Método para iniciar sesión
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

      return _processResponse(response, 'Inicio de sesión exitoso');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Método para cambiar contraseña
  Future<Map<String, dynamic>> cambiarContrasena({
    required String nuevaContrasena,
    required String confirmarContrasena,
    required String codigoVerificacion,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/v1/auth/change-password'),
        headers: _authHeaders,
        body: json.encode({
          'newPassword': nuevaContrasena,
          'confirmNewPassword': confirmarContrasena,
          'verificationCode': codigoVerificacion,
        }),
      );

      return _processResponse(response, 'Contraseña actualizada con éxito');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Método para solicitar código de verificación
  Future<Map<String, dynamic>> solicitarCodigoVerificacion({
    required String email,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/send-verification-code'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
        }),
      );

      return _processResponse(response, 'Código de verificación enviado con éxito');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Método para validar código de verificación
  Future<Map<String, dynamic>> validarCodigoVerificacion({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/validate-verification-code'),
        headers: _jsonHeaders,
        body: json.encode({
          'email': email,
          'code': code,
        }),
      );

      return _processResponse(response, 'Código verificado con éxito');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Método para cerrar sesión
  Future<Map<String, dynamic>> logout() async {
    try {
      if (_authToken == null) {
        return {
          'status': 'error',
          'message': 'No hay sesión activa',
        };
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/v1/auth/logout'),
        headers: _authHeaders,
      );

      // Independientemente de la respuesta, limpiamos el token
      _authToken = null;

      return _processResponse(response, 'Sesión cerrada con éxito');
    } catch (e) {
      // Aún en caso de error, limpiamos el token local
      _authToken = null;
      return {
        'status': 'error',
        'message': 'Error al cerrar sesión: $e',
      };
    }
  }

  // Método para obtener datos del usuario actual
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      if (_authToken == null) {
        return {
          'status': 'error',
          'message': 'No se encontró sesión activa',
        };
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/v1/auth/user/details'),
        headers: _authHeaders,
      );

      return _processResponse(response, 'Perfil obtenido con éxito');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Método para crear una nueva cuenta
  Future<Map<String, dynamic>> createAccount({
    required String name,
    required String type,
    required double initialBalance,
  }) async {
    try {
      if (_authToken == null) {
        return {
          'status': 'error',
          'message': 'No se encontró sesión activa',
        };
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/v1/accounts'),
        headers: _authHeaders,
        body: json.encode({
          'name': name,
          'type': type,
          'initialBalance': initialBalance,
        }),
      );

      return _processResponse(response, 'Cuenta creada con éxito');
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error de conexión: $e',
      };
    }
  }

  // No olvides cerrar el cliente HTTP cuando ya no sea necesario
  void dispose() {
    _client.close();
  }
}