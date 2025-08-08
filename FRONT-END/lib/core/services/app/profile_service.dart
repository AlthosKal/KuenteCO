import 'dart:io';
import 'package:dio/dio.dart';
import '../../../dto/profile/new_profile_dto.dart';
import '../../../dto/profile/profile_detail_dto.dart';
import '../../../dto/profile/update_profile_dto.dart';
import '../../../dto/auth/response/user_detail_dto.dart';
import '../../../dto/image/image_dto.dart';
import '../../exceptions/api_response.dart';
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
    return ProfileDetailDTO.fromJson(response.data['data']);
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

  /// ✅ Subir imagen de perfil
  Future<ImageDTO> uploadProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _api.postApp('/auth/profile/image/add', formData);
    final apiResponse = ApiResponse<ImageDTO>.fromJson(
      response.data,
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

  /// ✅ Eliminar imagen de perfil
  Future<void> deleteProfileImage() async {
    await _api.deleteApp('/auth/profile/image/delete');
  }
}
