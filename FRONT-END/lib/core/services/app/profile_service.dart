import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../dto/profile/new_profile_dto.dart';
import '../../../dto/profile/profile_detail_dto.dart';
import '../../../dto/profile/update_profile_dto.dart';
import '../../../dto/image/image_dto.dart';
import '../api_client.dart';

class ProfileService {
  final _api = ApiClient();

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

  /// Iniciar sesión con un perfil
  Future<void> profileLogin(int profileId, String password) async {
    final payload = {
      'profileId': profileId,
      'password': password,
    };
    await _api.postApp('/profile/login', payload);
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
