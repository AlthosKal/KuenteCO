import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/services/app/profile_service.dart';
import '../dto/auth/response/image_dto.dart';
import '../dto/profile/new_profile_dto.dart';
import '../dto/profile/profile_detail_dto.dart';
import '../dto/profile/update_profile_dto.dart';
import 'dart:io';

class ProfileController {
  final ProfileService _profileService;
  final _storage = const FlutterSecureStorage();

  // Estados de UI reactivos
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<List<ProfileDetailDTO>> profiles = ValueNotifier([]);
  final ValueNotifier<ProfileDetailDTO?> authenticatedProfile = ValueNotifier(null);

  ProfileController({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

  // Verificar si el servicio puede funcionar correctamente
  bool get isReady => _profileService.isReady;

  Future<void> loadAllProfiles() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final result = await _profileService.getAllProfiles();
      profiles.value = result;
    } catch (e) {
      debugPrint('Error loading profiles: $e');
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
      debugPrint('Error loading authenticated profile: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProfile(NewProfileDTO dto) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _profileService.createProfile(dto);
      // Recargar perfiles después de crear
      await loadAllProfiles();
    } catch (e) {
      debugPrint('Error creating profile: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(UpdateProfileDTO dto) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _profileService.updateProfile(dto);
      // Recargar perfil autenticado después de actualizar
      await loadAuthenticatedProfile();
    } catch (e) {
      debugPrint('Error updating profile: $e');
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
      // Recargar perfiles después de eliminar
      await loadAllProfiles();
    } catch (e) {
      debugPrint('Error deleting profile: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<ImageDTO?> updateProfileImage(File imageFile) async {
    if (isLoading.value) return null;

    isLoading.value = true;
    try {
      final result = await _profileService.updateImage(imageFile);
      // Recargar perfil autenticado después de actualizar imagen
      await loadAuthenticatedProfile();
      return result;
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProfileImage() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _profileService.deleteImage();
      // Recargar perfil autenticado después de eliminar imagen
      await loadAuthenticatedProfile();
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
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