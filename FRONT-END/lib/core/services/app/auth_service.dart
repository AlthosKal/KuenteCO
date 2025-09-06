import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
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

  // â Verificar si el servicio puede funcionar correctamente
  bool get isReady => _api.isInitialized;

  /// ð LOGIN
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
              throw Exception('Cadena no contenÃ­a un Map<String, dynamic>: $data');
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

    // â Guardamos token y rol
    await _storage.write(key: 'Authorization', value: apiResponse.data.token);
    await _storage.write(key: 'role', value: apiResponse.data.type);

    return apiResponse.data;
  }


  /// ð REGISTRO
  Future<void> register(NewUserDTO dto) async {
    await _api.postApp('/auth/register', dto.toJson());
  }

  /// ð© ENVIAR CÃDIGO DE VERIFICACIÃN
  Future<void> sendVerificationCode({
    required bool isRegistration,
    required SendVerificationCodeDTO dto,
  }) async {
    await _api.postApp(
      '/auth/send-verification-code?isRegistration=$isRegistration',
      dto.toJson(),
    );
  }

  /// â VALIDAR CÃDIGO DE VERIFICACIÃN
  Future<void> validateVerificationCode(ValidateVerificationCodeDTO dto) async {
    await _api.postApp('/auth/validate-verification-code', dto.toJson());
  }

  /// ð CAMBIAR CONTRASEÃA CON CÃDIGO
  Future<void> changePasswordWithCode(ChangePasswordDTO dto) async {
    await _api.patchApp('/auth/change-password', dto.toJson());
  }

  /// â ACTIVAR USUARIO (DESPUÃS DE VERIFICAR CÃDIGO)
  Future<void> activateUser(ValidateVerificationCodeDTO dto) async {
    await _api.postApp('/auth/activate-user', dto.toJson());
  }

  /// ðª LOGOUT
  Future<void> logout() async {
    await _api.postApp('/auth/logout', {});
    await _storage.delete(key: 'Authorization');
    await _storage.delete(key: 'role'); // â Borramos el rol tambiÃ©n
  }

  /// â ELIMINAR USUARIO
  Future<void> deleteUser(String userId) async {
    await _api.deleteApp('/auth/$userId');
  }

  /// ð¤ SUBIR IMAGEN DE PERFIL
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

  /// ð¤ OBTENER USUARIO AUTENTICADO
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
