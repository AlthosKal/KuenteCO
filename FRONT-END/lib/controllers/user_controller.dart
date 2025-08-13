import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/services/app/user_service.dart';
import '../dto/app/auth/response/user_detail_dto.dart';
import '../dto/app/image/image_dto.dart';

class UserController extends ChangeNotifier {
  final UserService _userService;

  final ValueNotifier<UserDetailDTO?> user = ValueNotifier(null);
  ImageDTO? userImage;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  UserController({required UserService userService}) : _userService = userService;

  /// Cargar usuario
  Future<void> loadUser() async {
    try {
      isLoading.value = true;
      user.value = await _userService.getUserDetail();
      userImage = user.value?.image;
      print("✅ Usuario cargado correctamente");
    } catch (e) {
      print("🛑 Error cargando usuario: $e");
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }



  /// Subir imagen de usuario
  Future<void> uploadUserImage(MultipartFile multipartfile, String fileName) async {
    try {
      isLoading.value = true;
      final result = await _userService.uploadUserImage(multipartfile, fileName);
      userImage = result;
      // CRÍTICO: Actualizar user.value para que la vista se refresque
      if (user.value != null) {
        final updatedUser = UserDetailDTO(
          version: user.value!.version,
          image: result,
          username: user.value!.username,
          email: user.value!.email,
          userType: user.value!.userType,
          subscriptionType: user.value!.subscriptionType,
          state: user.value!.state,
        );
        user.value = updatedUser; // Esto dispara el ValueListenableBuilder
      }
      print("✅ Imagen de usuario subida correctamente");
    } catch (e) {
      print("🛑 Error subiendo imagen: $e");
      rethrow; // Re-lanza el error para que la vista lo maneje
    } finally {
      isLoading.value = false;
    }
  }

  /// Actualizar imagen de usuario
  Future<void> updateUserImage(MultipartFile multipartfile, String fileName) async {
    try {
      isLoading.value = true;
      final result = await _userService.updateUserImage(multipartfile, fileName);
      userImage = result;
      // CRÍTICO: Actualizar user.value para que la vista se refresque
      if (user.value != null) {
        final updatedUser = UserDetailDTO(
          version: user.value!.version,
          image: result,
          username: user.value!.username,
          email: user.value!.email,
          userType: user.value!.userType,
          subscriptionType: user.value!.subscriptionType,
          state: user.value!.state,
        );
        user.value = updatedUser; // Esto dispara el ValueListenableBuilder
      }
      print("✅ Imagen de usuario actualizada correctamente");
    } catch (e) {
      print("🛑 Error actualizando imagen: $e");
      rethrow; // Re-lanza el error para que la vista lo maneje
    } finally {
      isLoading.value = false;
    }
  }

  /// Eliminar imagen de usuario
  Future<void> deleteUserImage() async {
    try {
      if (userImage == null || userImage?.imageId == null) {
        print("ℹ️ No hay imagen para eliminar.");
        return;
      }
      isLoading.value = true;
      await _userService.deleteUserImage();
      userImage = null;
      // Actualizar también la información completa del usuario
      if (user.value != null) {
        user.value = UserDetailDTO(
          version: user.value!.version,
          image: null,
          username: user.value!.username,
          email: user.value!.email,
          userType: user.value!.userType,
          subscriptionType: user.value!.subscriptionType,
          state: user.value!.state,
        );
      }
      print("✅ Imagen de usuario eliminada correctamente");
    } catch (e) {
      print("🛑 Error eliminando imagen: $e");
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  /// Eliminar cuenta de usuario
  Future<void> deleteUser() async {
    try {
      isLoading.value = true;
      await _userService.deleteUser();
      user.value = null;
      userImage = null;
      print("✅ Usuario eliminado exitosamente");
    } catch (e) {
      print("🛑 Error eliminando usuario: $e");
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }
}