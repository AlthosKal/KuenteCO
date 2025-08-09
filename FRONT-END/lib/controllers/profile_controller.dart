import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/services/app/profile_service.dart';
import '../dto/image/image_dto.dart';
import '../dto/profile/new_profile_dto.dart';
import '../dto/profile/profile_detail_dto.dart';
import '../dto/profile/update_profile_dto.dart';

class ProfileController {
  final ProfileService _profileService;
  final _storage = const FlutterSecureStorage();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<List<ProfileDetailDTO>> profiles = ValueNotifier([]);
  final ValueNotifier<ProfileDetailDTO?> authenticatedProfile = ValueNotifier(null);

  ProfileController({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

  bool get isReady => _profileService.isReady;

  Future<void> loadAllProfiles() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final result = await _profileService.getAllProfiles();
      profiles.value = result;
    } catch (e) {
      debugPrint('🔴 Error loading profiles: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAuthenticatedProfile() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final result = await _profileService.getAuthenticatedProfile();
      authenticatedProfile.value = result;
    } catch (e) {
      debugPrint('🔴 Error loading authenticated profile: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Obtener perfil por ID
  Future<ProfileDetailDTO> getProfileById(int id) async {
    try {
      final result = await _profileService.getProfileById(id);
      return result;
    } catch (e) {
      debugPrint('🔴 Error loading profile by ID: $e');
      rethrow;
    }
  }

  Future<void> createProfile(NewProfileDTO dto) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _profileService.createProfile(dto);
      await loadAllProfiles();
    } catch (e) {
      debugPrint('🔴 Error creating profile: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(UpdateProfileDTO dto, {MultipartFile? imageFile}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _profileService.updateProfile(dto, imageFile: imageFile);
      await loadAuthenticatedProfile();
    } catch (e) {
      debugPrint('🔴 Error updating profile: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProfile(int id) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _profileService.deleteProfile(id);
      await loadAllProfiles();
    } catch (e) {
      debugPrint('🔴 Error deleting profile: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Iniciar sesión con un perfil
  Future<void> profileLogin(int profileId, String password) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _profileService.profileLogin(profileId, password);
      // Actualizar el perfil autenticado después del login
      await loadAuthenticatedProfile();
    } catch (e) {
      debugPrint('🔴 Error logging in with profile: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Cambiar contraseña del perfil
  Future<void> changeProfilePassword(String currentPassword, String newPassword) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _profileService.changeProfilePassword(currentPassword, newPassword);
    } catch (e) {
      debugPrint('🔴 Error changing profile password: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Subir imagen de perfil (cuando aún no tiene)
  Future<ImageDTO?> uploadProfileImage(Uint8List bytes, String fileName) async {
    if (isLoading.value) return null;
    isLoading.value = true;
    try {
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      );

      final result = await _profileService.uploadProfileImage(multipartFile, fileName);
      await loadAuthenticatedProfile();
      return result;
    } catch (e) {
      debugPrint('🔴 Error uploading profile image: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Actualizar imagen de perfil (cuando ya tiene una)
  Future<ImageDTO?> updateProfileImage(Uint8List bytes, String fileName) async {
    if (isLoading.value) return null;
    isLoading.value = true;
    try {
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      );

      final result = await _profileService.updateProfileImage(multipartFile, fileName);
      await loadAuthenticatedProfile();
      return result;
    } catch (e) {
      debugPrint('🔴 Error updating profile image: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Eliminar imagen de perfil
  Future<void> deleteProfileImage() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _profileService.deleteProfileImage();
      await loadAuthenticatedProfile();
    } catch (e) {
      debugPrint('🔴 Error deleting profile image: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }


  void dispose() {
    isLoading.dispose();
    profiles.dispose();
    authenticatedProfile.dispose();
  }
}
