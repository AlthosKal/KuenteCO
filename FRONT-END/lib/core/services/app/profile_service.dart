import 'package:dio/dio.dart';
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


  /// ✅ Crear perfil
  Future<void> createProfile(NewProfileDTO dto) async {
    await _api.postApp('/profile/add', dto.toJson());
  }

  /// ✅ Actualizar perfil
  Future<void> updateProfile(UpdateProfileDTO dto) async {
    await _api.putApp('/profile/update', dto.toJson());
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

    final response = await _api.postApp('/auth/profile/image/add', formData);
    if (response.statusCode == 200) {
      return ImageDTO.fromJson(response.data);
    } else {
      throw Exception('Error al subir imagen de perfil: ${response.statusCode}');
    }
  }

  /// Actualizar imagen de perfil
  Future<ImageDTO> updateProfileImage(MultipartFile multipartfile, String fileName) async {
    final formData = FormData.fromMap({
      'image': multipartfile,
    });

    final response = await _api.patchApp('/auth/profile/image/update', formData);
    if (response.statusCode == 200) {
      return ImageDTO.fromJson(response.data);
    } else {
      throw Exception('Error al actualizar imagen de perfil: ${response.statusCode}');
    }
  }

  /// Eliminar imagen de perfil
  Future<void> deleteProfileImage() async {
    final response = await _api.deleteApp('/auth/profile/image/delete');
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar imagen de perfil: ${response.statusCode}');
    }
  }
}
