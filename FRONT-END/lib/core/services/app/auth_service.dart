import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../dto/auth/request/change_password_dto.dart';
import '../../../dto/auth/request/login_user_dto.dart';
import '../../../dto/auth/request/new_user_dto.dart';
import '../../../dto/auth/request/send_verification_code_dto.dart';
import '../../../dto/auth/request/validate_verification_code_dto.dart';
import '../../../dto/auth/response/image_dto.dart';
import '../../../dto/auth/response/token_response_dto.dart';
import '../../../dto/auth/response/user_detail_dto.dart';
import '../../exceptions/api_response.dart';
import '../api_client.dart';

class AuthService {
  final _api = ApiClient();
  final _storage = const FlutterSecureStorage();

  // ✅ Verificar si el servicio puede funcionar correctamente
  bool get isReady => _api.isInitialized;

  /// 🔑 LOGIN
  Future<TokenResponseDTO> login(LoginUserDTO dto) async {
    final response = await _api.postApp('/auth/login', dto.toJson());
    final json = response.data;

    final apiResponse = ApiResponse<TokenResponseDTO>.fromJson(
      json,
          (data) => TokenResponseDTO.fromJson(data),
    );

    // ✅ Guardamos token y rol
    await _storage.write(key: 'Authorization', value: apiResponse.data.token);
    await _storage.write(key: 'role', value: apiResponse.data.role);

    return apiResponse.data;
  }

  /// 🆕 REGISTRO
  Future<void> register(NewUserDTO dto) async {
    await _api.postApp('/auth/register', dto.toJson());
  }

  /// 📩 ENVIAR CÓDIGO DE VERIFICACIÓN
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

  /// 🔓 CAMBIAR CONTRASEÑA CON CÓDIGO
  Future<void> changePasswordWithCode(ChangePasswordDTO dto) async {
    await _api.patchApp('/auth/change-password', dto.toJson());
  }

  /// ✅ ACTIVAR USUARIO (DESPUÉS DE VERIFICAR CÓDIGO)
  Future<void> activateUser(ValidateVerificationCodeDTO dto) async {
    await _api.postApp('/auth/activate-user', dto.toJson());
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await _api.postApp('/auth/logout', {});
    await _storage.delete(key: 'Authorization');
    await _storage.delete(key: 'role'); // ✅ Borramos el rol también
  }

  /// ❌ ELIMINAR USUARIO
  Future<void> deleteUser(String userId) async {
    await _api.deleteApp('/auth/$userId');
  }

  /// 📤 SUBIR IMAGEN DE PERFIL
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

  /// 🔄 ACTUALIZAR IMAGEN DE PERFIL
  Future<ImageDTO> updateProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _api.postApp('/auth/user/image/update', formData);
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
