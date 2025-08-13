import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../dto/auth/response/token_response_dto.dart';
import '../../../dto/profile/new_profile_dto.dart';
import '../../../dto/profile/profile_detail_dto.dart';
import '../../../dto/profile/update_profile_dto.dart';
import '../../../dto/image/image_dto.dart';
import '../../exceptions/api_response.dart';
import '../api_client.dart';

class ProfileService {
  final _api = ApiClient();
  final _storage = const FlutterSecureStorage();

  bool get isReady => _api.isInitialized;

  /// ✅ Obtener todos los perfiles
  Future<List<ProfileDetailDTO>> getAllProfiles() async {
    final response = await _api.getApp('/profile');
    final data = response.data['data'] as List;
    return data.map((e) => ProfileDetailDTO.fromJson(e)).toList();
  }

  /// ✅ Obtener perfil autenticado
  Future<ProfileDetailDTO> getAuthenticatedProfile() async {
    final response = await _api.getApp('/profile/details');
    final Map<String, dynamic> json = response.data;
    final actualData = json['data'] ?? json;
    return ProfileDetailDTO.fromJson(actualData);
  }

  /// ✅ Obtener perfil por ID
  Future<ProfileDetailDTO> getProfileById(int id) async {
    final response = await _api.getApp('/profile/$id');
    final Map<String, dynamic> json = response.data;
    final actualData = json['data'] ?? json;
    return ProfileDetailDTO.fromJson(actualData);
  }


  /// ✅ Crear perfil
  Future<void> createProfile(NewProfileDTO dto) async {
    await _api.postApp('/profile/add', dto.toJson());
  }

  /// Iniciar sesión con un perfil usando credenciales directas
  Future<TokenResponseDTO> profileLogin(String nameOrEmail, String password) async {
    final payload = {
      'nameOrEmail': nameOrEmail,
      'password': password,
    };
    final response = await _api.postApp('/profile/login', payload);
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

    // ✅ Guardamos token y rol para perfil
    await _storage.write(key: 'Authorization', value: apiResponse.data.token);
    await _storage.write(key: 'role', value: 'ROLE_PROFILE'); // Indicamos que es perfil

    return apiResponse.data;
  }

  /// ✅ Actualizar perfil
  Future<void> updateProfile(UpdateProfileDTO dto, {MultipartFile? imageFile}) async {
    print('🔍 ProfileService - updateProfile called');
    print('🔍 ProfileService - removeImage: ${dto.removeImage}');
    print('🔍 ProfileService - imageFile: ${imageFile != null ? "PROVIDED" : "NULL"}');
    
    // Crear FormData con profile como texto plano
    final formData = FormData();
    
    // Agregar profile como campo de texto (no como archivo)
    formData.fields.add(MapEntry('profile', jsonEncode(dto.toJson())));
    
    // Agregar la imagen si existe
    if (imageFile != null) {
      print('🔍 ProfileService - Adding image to FormData');
      formData.files.add(MapEntry('image', imageFile));
    }
    
    print('🔍 ProfileService - FormData fields: ${formData.fields.length}, files: ${formData.files.length}');
    await _api.patchApp('/profile/update', formData);
  }

  /// Cambiar contraseña
  Future<void> changeProfilePassword(String currentPassword, String newPassword) async {
    final payload = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
    await _api.patchApp('/profile/change-password', payload);
  }

  /// ✅ Eliminar perfil
  Future<void> deleteProfile(int id) async {
    await _api.deleteApp('/profile/delete/$id');
  }

  /// 🚪 LOGOUT PERFIL
  Future<void> logout() async {
    await _api.postApp('/profile/logout', {});
    await _storage.delete(key: 'Authorization');
    await _storage.delete(key: 'role');
  }

  /// Subir imagen de perfil
  Future<ImageDTO> uploadProfileImage(MultipartFile multipartfile, String fileName) async {
    final formData = FormData.fromMap({
      'image': multipartfile,
    });

    final response = await _api.postApp('/profile/image/add', formData);
    if (response.statusCode == 201) {
      return ImageDTO.fromJson(response.data['data']);
    } else {
      throw Exception('Error al subir imagen de perfil: ${response.statusCode}');
    }
  }

  /// Actualizar imagen de perfil
  Future<ImageDTO> updateProfileImage(MultipartFile multipartfile, String fileName) async {
    final formData = FormData.fromMap({
      'image': multipartfile,
    });

    final response = await _api.patchApp('/profile/image/update', formData);
    if (response.statusCode == 200) {
      return ImageDTO.fromJson(response.data['data']);
    } else {
      throw Exception('Error al actualizar imagen de perfil: ${response.statusCode}');
    }
  }

  /// Eliminar imagen de perfil
  Future<void> deleteProfileImage() async {
    final response = await _api.deleteApp('/profile/delete');
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar imagen de perfil: ${response.statusCode}');
    }
  }
}
