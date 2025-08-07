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
    final response = await _apiClient.getApp('/auth/user/details');

    print('🔍 DEBUG: StatusCode: ${response.statusCode}');
    print('🔍 DEBUG: Response completa: ${response.data}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = response.data;
      
      // Si la respuesta está envuelta en un objeto con 'data'
      final actualData = json['data'] ?? json;
      print('🔍 DEBUG: Data actual: $actualData');
      
      // Verificar específicamente la imagen
      if (actualData['image'] != null) {
        print('🖼️ DEBUG: Imagen encontrada: ${actualData['image']}');
      } else {
        print('❌ DEBUG: No hay imagen en la respuesta');
      }

      actualData['username'] ??= '';
      actualData['email'] ??= '';
      actualData['userType'] ??= '';
      actualData['subscriptionType'] ??= '';
      actualData['state'] ??= '';

      final userDetailDTO = UserDetailDTO.fromJson(actualData);
      print('🔍 DEBUG: UserDetailDTO creado: ${userDetailDTO.toJson()}');
      
      return userDetailDTO;
    }

    // Si no es 200, lanza excepción explícita
    throw Exception('Error al obtener usuario: ${response.statusCode}');
  }



    /// Eliminar el usuario
  Future<void> deleteUser() async {
    final response = await _apiClient.deleteApp('/auth/delete');
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
    if (response.statusCode == 200) {
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

  /// Actualizar contraseña
  Future<UserDetailDTO> updateUserPassword(UserDetailDTO updatedUser) async {
    final response = await _apiClient.patchApp('/auth/change-password', updatedUser.toJson());
    if (response.statusCode == 200) {
      return UserDetailDTO.fromJson(response.data);
    } else {
      throw Exception('Error al actualizar contraseña: ${response.statusCode}');
    }
  }
}