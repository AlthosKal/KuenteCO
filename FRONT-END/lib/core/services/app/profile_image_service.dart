import 'dart:io';
import 'package:dio/dio.dart';
import '../../../dto/auth/response/image_dto.dart';
import '../../../dto/auth/response/user_detail_dto.dart';
import '../../exceptions/api_response.dart';
import '../api_client.dart';

class ProfileService {
  final _api = ApiClient();

  Future<ImageDTO> uploadProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _api.postApp('/auth/user/image/add', {formData});
    final json = response.data;
    final apiResponse = ApiResponse<ImageDTO>.fromJson(
      json,
          (data) => ImageDTO.fromJson(data),
    );

    return apiResponse.data;
  }

  Future<ImageDTO> updateProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _api.postApp('/auth/user/image/update', {formData});
    final json = response.data;
    final apiResponse = ApiResponse<ImageDTO>.fromJson(
      json,
          (data) => ImageDTO.fromJson(data),
    );

    return apiResponse.data;
  }

  Future<UserDetailDTO> getAuthenticatedUser() async {
    final response = await _api.getApp('/auth/user/details');

    final json = response.data;
    final apiResponse = ApiResponse<UserDetailDTO>.fromJson(
      json,
          (data) => UserDetailDTO.fromJson(data),
    );

    return apiResponse.data;
  }

  Future<void> deleteProfileImage() async {
    await _api.deleteApp('/auth/user/image/delete');
  }
}