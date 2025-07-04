import 'package:dio/dio.dart';
import 'dart:io';
import '../../../dto/auth/response/image_dto.dart';
import '../../../dto/profile/new_profile_dto.dart';
import '../../../dto/profile/profile_detail_dto.dart';
import '../../../dto/profile/update_profile_dto.dart';
import '../api_client.dart';

class ProfileService {
  final _api = ApiClient();

  bool get isReady => _api.isInitialized;

  Future<List<ProfileDetailDTO>> getAllProfiles() async {
    final response = await _api.getApp('/v1/profile');
    final data = response.data['data'] as List;
    return data.map((e) => ProfileDetailDTO.fromJson(e)).toList();
  }

  Future<ProfileDetailDTO> getAuthenticatedProfile() async {
    final response = await _api.getApp('/v1/profile/details');
    return ProfileDetailDTO.fromJson(response.data['data']);
  }

  Future<void> createProfile(NewProfileDTO dto) async {
    await _api.postApp('/v1/profile/add', dto.toJson());
  }

  Future<void> updateProfile(UpdateProfileDTO dto) async {
    await _api.putApp('/v1/profile/update', dto.toJson());
  }

  Future<void> deleteProfile(int id) async {
    await _api.deleteApp('/v1/profile/$id');
  }

  Future<ImageDTO> updateImage(File imageFile) async {
    final fileName = imageFile.path.split('/').last;

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    final response = await _api.putApp('/v1/profile/image/update', formData);
    return ImageDTO.fromJson(response.data['data']);
  }

  Future<void> deleteImage() async {
    await _api.deleteApp('/v1/profile/image/delete');
  }
}