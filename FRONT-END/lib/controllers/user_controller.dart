import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/services/app/user_service.dart';
import '../dto/auth/response/user_detail_dto.dart';
import '../dto/image/image_dto.dart';

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

  /// Actualizar datos de usuario
  Future<void> updateUser(UserDetailDTO updatedUser) async {
    try {
      isLoading.value = true;
      final result = await _userService.updateUser(updatedUser);
      user.value = result;
      userImage = result.image;
      print("✅ Usuario actualizado correctamente");
    } catch (e) {
      print("🛑 Error actualizando usuario: $e");
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  /// Subir imagen de usuario
  Future<void> uploadUserImage(Uint8List imageBytes, String fileName) async {
    try {
      isLoading.value = true;
      final result = await _userService.uploadUserImage(imageBytes, fileName);
      userImage = result;
      print("✅ Imagen de usuario subida correctamente");
    } catch (e) {
      print("🛑 Error subiendo imagen: $e");
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  /// Actualizar imagen de usuario
  Future<void> updateUserImage(Uint8List imageBytes, String fileName) async {
    try {
      isLoading.value = true;
      final result = await _userService.updateUserImage(imageBytes, fileName);
      userImage = result;
      print("✅ Imagen de usuario actualizada correctamente");
    } catch (e) {
      print("🛑 Error actualizando imagen: $e");
    } finally {
      isLoading.value = false;
      notifyListeners();
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
