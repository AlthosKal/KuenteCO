import 'dart:convert';
import 'dart:io';
import 'dart:html' as html show window;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../dto/app/auth/request/change_password_dto.dart';
import '../../../dto/app/auth/request/login_user_dto.dart';
import '../../../dto/app/auth/request/new_user_dto.dart';
import '../../../dto/app/auth/request/send_verification_code_dto.dart';
import '../../../dto/app/auth/request/validate_verification_code_dto.dart';
import '../../../dto/app/auth/response/token_response_dto.dart';
import '../../../dto/app/auth/response/user_detail_dto.dart';
import '../../../dto/app/image/image_dto.dart';
import '../../exceptions/api_response.dart';
import '../api_client.dart';

class AuthService {
  final _api = ApiClient();
  final _storage = const FlutterSecureStorage();

  // ✅ Verificar si el servicio puede funcionar correctamente
  bool get isReady => _api.isInitialized;

  /// 🔐 LOGIN
  Future<TokenResponseDTO> login(LoginUserDTO dto) async {
    final response = await _api.postApp('/auth/login', dto.toJson());
    final json = response.data;

    final apiResponse = ApiResponse<TokenResponseDTO>.fromJson(
      json,
          (data) {
        if (data is String) {
          try {
            final decoded = jsonDecode(data);
            if (decoded is Map<String, dynamic>) {
              return TokenResponseDTO.fromJson(decoded);
            } else {
              throw Exception('Cadena no contenía un Map<String, dynamic>: $data');
            }
          } catch (_) {
            throw Exception('No se pudo decodificar JSON del string: $data');
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Tipo inesperado de data: ${data.runtimeType}');
        }

        return TokenResponseDTO.fromJson(data);
      },
    );

    // ✅ Guardamos token y rol
    await _storage.write(key: 'Authorization', value: apiResponse.data.token);
    await _storage.write(key: 'role', value: apiResponse.data.type);

    print('✅ AuthService: Login exitoso para usuario tipo: ${apiResponse.data.type}');
    
    return apiResponse.data;
  }


  /// 📝 REGISTRO
  Future<void> register(NewUserDTO dto) async {
    await _api.postApp('/auth/register', dto.toJson());
  }

  /// 📧 ENVIAR CÓDIGO DE VERIFICACIÓN
  Future<void> sendVerificationCode({
    required bool isRegistration,
    required SendVerificationCodeDTO dto,
  }) async {
    await _api.postApp(
      '/auth/send-verification-code?isRegistration=$isRegistration',
      dto.toJson(),
    );
  }

  /// ✅ VALIDAR CÓDIGO DE VERIFICACIÓN
  Future<void> validateVerificationCode(ValidateVerificationCodeDTO dto) async {
    await _api.postApp('/auth/validate-verification-code', dto.toJson());
  }

  /// 🔑 CAMBIAR CONTRASEÑA CON CÓDIGO
  Future<void> changePasswordWithCode(ChangePasswordDTO dto) async {
    await _api.patchApp('/auth/change-password', dto.toJson());
  }

  /// ✅ ACTIVAR USUARIO (DESPUÉS DE VERIFICAR CÓDIGO)
  Future<void> activateUser(ValidateVerificationCodeDTO dto) async {
    await _api.postApp('/auth/activate-user', dto.toJson());
  }

  /// 🚪 LOGOUT - Limpieza completa de sesión
  Future<void> logout() async {
    try {
      // Notificar al backend sobre el logout
      await _api.postApp('/auth/logout', {});
    } catch (e) {
      print('⚠️ AuthService: Error notificando logout al backend: $e');
      // Continuar con la limpieza local incluso si el backend falla
    }
    
    // Limpiar almacenamiento seguro
    await _storage.delete(key: 'Authorization');
    await _storage.delete(key: 'role');
    
    // Limpiar todas las claves del secure storage (por si hay más)
    await _storage.deleteAll();
    
    // Limpiar cookies y localStorage del navegador (solo en web)
    if (kIsWeb) {
      try {
        // Limpiar localStorage
        html.window.localStorage.clear();
        
        // Limpiar sessionStorage
        html.window.sessionStorage.clear();
        
        // Limpiar todas las cookies del dominio actual
        _clearAllCookies();
        
        print('✅ AuthService: Limpieza web completada');
      } catch (e) {
        print('⚠️ AuthService: Error limpiando datos web: $e');
      }
    }
    
    print('✅ AuthService: Logout completo realizado');
  }

  /// Limpiar todas las cookies del navegador
  void _clearAllCookies() {
    if (!kIsWeb) return;
    
    try {
      // Obtener todas las cookies
      final cookies = html.window.document.cookie;
      if (cookies?.isNotEmpty == true) {
        final cookieList = cookies!.split(';');
        
        for (final cookie in cookieList) {
          final eqPos = cookie.indexOf('=');
          if (eqPos > 0) {
            final name = cookie.substring(0, eqPos).trim();
            // Limpiar la cookie estableciendo su fecha de expiración en el pasado
            html.window.document.cookie = '$name=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
            // También para subdominios
            html.window.document.cookie = '$name=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/; domain=.${html.window.location.hostname};';
          }
        }
      }
      print('✅ AuthService: Cookies del navegador limpiadas');
    } catch (e) {
      print('⚠️ AuthService: Error limpiando cookies: $e');
    }
  }

  /// ❌ ELIMINAR USUARIO
  Future<void> deleteUser(String userId) async {
    await _api.deleteApp('/auth/$userId');
  }

  /// 📷 SUBIR IMAGEN DE PERFIL
  Future<ImageDTO> uploadProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _api.postApp('/auth/user/image/add', formData);
    final json = response.data;

    final apiResponse = ApiResponse<ImageDTO>.fromJson(
      json,
          (data) => ImageDTO.fromJson(data),
    );

    return apiResponse.data;
  }

  /// 👤 OBTENER USUARIO AUTENTICADO
  Future<UserDetailDTO> getAuthenticatedUser() async {
    final response = await _api.getApp('/auth/user/details');
    final json = response.data;

    final apiResponse = ApiResponse<UserDetailDTO>.fromJson(
      json,
          (data) => UserDetailDTO.fromJson(data),
    );

    return apiResponse.data;
  }
}