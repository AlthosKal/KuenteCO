import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../dto/auth/response/user_detail_dto.dart';
import '../../../dto/image/image_dto.dart';
import '../api_client.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  /// Obtener el detalle de usuario
  Future<UserDetailDTO> getUserDetail() async {
    final response = await _apiClient.getApp('/auth/user');
    if (response.statusCode == 200) {
      return UserDetailDTO.fromJson(response.data);
    } else {
      throw Exception('Error al obtener usuario: ${response.statusCode}');
    }
  }

  /// Eliminar el usuario
  Future<void> deleteUser() async {
    final response = await _apiClient.deleteApp('/auth/user/delete');
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar usuario: ${response.statusCode}');
    }
  }

  /// Subir imagen
  Future<ImageDTO> uploadUserImage(Uint8List imageBytes, String fileName) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(imageBytes, filename: fileName),
    });

    final response = await _apiClient.postApp('/auth/user/image/add', formData);
    if (response.statusCode == 200) {
      return ImageDTO.fromJson(response.data);
    } else {
      throw Exception('Error al subir imagen: ${response.statusCode}');
    }
  }

  /// Actualizar imagen
  Future<ImageDTO> updateUserImage(Uint8List imageBytes, String fileName) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(imageBytes, filename: fileName),
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

  /// Actualizar datos del usuario
  Future<UserDetailDTO> updateUser(UserDetailDTO updatedUser) async {
    final response = await _apiClient.patchApp('/auth/user/update', updatedUser.toJson());
    if (response.statusCode == 200) {
      return UserDetailDTO.fromJson(response.data);
    } else {
      throw Exception('Error al actualizar usuario: ${response.statusCode}');
    }
  }
}