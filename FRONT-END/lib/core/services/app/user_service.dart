import 'package:dio/dio.dart';
import '../../../dto/auth/response/user_detail_dto.dart';
import '../../../dto/image/image_dto.dart';
import '../api_client.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  /// Obtener el detalle de usuario
  Future<UserDetailDTO> getUserDetail() async {
    final response = await _apiClient.getApp('/auth/user/details');
    final Map<String, dynamic> json = response.data;
    final actualData = json['data'] ?? json;
    return UserDetailDTO.fromJson(actualData);
  }

    /// Eliminar el usuario
  Future<void> deleteUser() async {
    final response = await _apiClient.deleteApp('/auth/user/delete');
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar usuario: ${response.statusCode}');
    }
  }

  /// Subir imagen
  Future<ImageDTO> uploadUserImage(MultipartFile multipartfile, String fileName) async {
    final formData = FormData.fromMap({
      'image': multipartfile,
    });

    final response = await _apiClient.postApp('/auth/user/image/add', formData);
    if (response.statusCode == 201) {
      return ImageDTO.fromJson(response.data);
    } else {
      throw Exception('Error al subir imagen: ${response.statusCode}');
    }
  }

  /// Actualizar imagen
  Future<ImageDTO> updateUserImage(MultipartFile multipartfile, String fileName) async {
    final formData = FormData.fromMap({
      'image': multipartfile,
    });

    final response = await _apiClient.patchApp('/auth/user/image/update', formData);
    if (response.statusCode == 200) {
      return ImageDTO.fromJson(response.data);
    } else {
      throw Exception('Error al actualizar imagen: ${response.statusCode}');
    }
  }

  /// Eliminar imagen
  Future<void> deleteUserImage() async {
    final response = await _apiClient.deleteApp('/auth/user/image/delete');
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar imagen: ${response.statusCode}');
    }
  }
}
