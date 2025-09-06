import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/profile_controller.dart';
import '../../../dto/app/image/image_dto.dart';
import '../../../dto/app/profile/profile_detail_dto.dart';

class ProfileImageWidget extends StatefulWidget {
  final ProfileController profileController;
  final ValueNotifier<MultipartFile?>? selectedImageNotifier;
  final ValueNotifier<bool>? removeImageNotifier;
  final ProfileDetailDTO? profile;
  final double size;

  const ProfileImageWidget({
    super.key,
    required this.profileController,
    this.selectedImageNotifier,
    this.removeImageNotifier,
    this.profile,
    this.size = 150,
  });

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isPickingImage = false;

  // â MÃTODO COMPATIBLE WEB + MÃVIL
  Future<void> _pickImage() async {
    if (_isPickingImage) return; // Prevenir mÃºltiples clicks

    setState(() => _isPickingImage = true);

    try {
      final picker = ImagePicker();

      // â ConfiguraciÃ³n que funciona en ambas plataformas
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: kIsWeb ? null : 800, // Web no soporta bien maxWidth
        maxHeight: kIsWeb ? null : 800,
        imageQuality: kIsWeb ? null : 85, // Web usa calidad original
      );

      if (pickedFile == null) {
        debugPrint('ð· Image selection cancelled by user');
        return;
      }

      debugPrint('ð· Image picked: ${pickedFile.name} (${pickedFile.path})');

      // â Leer bytes - funciona tanto en web como mÃ³vil
      final bytes = await pickedFile.readAsBytes();

      if (bytes.isEmpty) {
        debugPrint('â Image bytes are empty');
        _showError('Error: imagen vacÃ­a');
        return;
      }

      // â Crear MultipartFile con nombre apropiado
      final fileName = pickedFile.name.isNotEmpty
          ? pickedFile.name
          : 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      );

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = fileName;
      });

      // Notificar al widget padre
      widget.selectedImageNotifier?.value = multipartFile;
      widget.removeImageNotifier?.value = false;

      debugPrint('â Image selected successfully: $fileName (${bytes.length} bytes)');

    } catch (e, stackTrace) {
      debugPrint('â Error picking image: $e');
      debugPrint('Stack trace: $stackTrace');

      // â Manejo especÃ­fico de errores por plataforma
      if (kIsWeb) {
        if (e.toString().contains('User cancelled') ||
            e.toString().contains('AbortError')) {
          debugPrint('ð« User cancelled image selection on web');
          return; // No mostrar error si usuario cancelÃ³
        }
      }

      _showError('Error al seleccionar imagen: ${e.toString()}');
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  Future<void> _confirmDeleteImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Â¿Eliminar imagen de perfil?'),
        content: const Text(
          'Â¿EstÃ¡s seguro de que deseas eliminar tu imagen de perfil? Este cambio se aplicarÃ¡ al guardar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'SÃ­, eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
    });

    widget.selectedImageNotifier?.value = null;
    widget.removeImageNotifier?.value = true;

    debugPrint('ðï¸ Image marked for removal');
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  bool _hasCurrentImageFromProfile(ProfileDetailDTO? profile) {
    return _selectedImageBytes != null ||
        (profile?.image?.imageUrl != null &&
            profile!.image!.imageUrl!.isNotEmpty &&
            widget.removeImageNotifier?.value != true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileDetailDTO>(
      future: widget.profile != null
          ? widget.profileController.getProfileById(widget.profile!.id)
          : null,
      builder: (context, snapshot) {
        ProfileDetailDTO? currentProfile;

        if (snapshot.hasData) {
          currentProfile = snapshot.data;
        } else if (widget.profile != null) {
          currentProfile = widget.profile;
        }

        final currentImage = currentProfile?.image;
        final shouldRemoveImage = widget.removeImageNotifier?.value ?? false;

        debugPrint('ð ProfileImageWidget - Building with state:');
        debugPrint('  - Has profile: ${currentProfile != null}');
        debugPrint('  - Has image: ${currentImage?.imageUrl?.isNotEmpty == true}');
        debugPrint('  - Should remove: $shouldRemoveImage');
        debugPrint('  - Is picking: $_isPickingImage');
        debugPrint('  - Selected bytes: ${_selectedImageBytes?.length ?? 0}');

        return GestureDetector(
          onTap: _isPickingImage ? null : _pickImage,
          onLongPress: _hasCurrentImageFromProfile(currentProfile) && !_isPickingImage
              ? _confirmDeleteImage
              : null,
          child: ClipOval(
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: _buildImageContent(currentImage, shouldRemoveImage),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageContent(ImageDTO? currentImage, bool shouldRemoveImage) {
    // â Mostrar loading si estÃ¡ seleccionando imagen
    if (_isPickingImage) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(
                'Seleccionando...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Si hay una imagen seleccionada localmente
    if (_selectedImageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            _selectedImageBytes!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('â Error displaying selected image: $error');
              return const Center(
                child: Icon(Icons.error, size: 40, color: Colors.red),
              );
            },
          ),
          Container(
            color: Colors.black26,
            child: const Center(
              child: Text(
                'Nueva\nImagen',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    // Si se marcÃ³ para eliminar
    if (shouldRemoveImage) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 40, color: Colors.grey),
            SizedBox(height: 4),
            Text(
              'Se eliminarÃ¡',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Si hay imagen actual
    final imageUrl = currentImage?.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('â Error loading profile image: $error');
          return const Center(
            child: Icon(Icons.person, size: 60, color: Colors.grey),
          );
        },
      );
    }

    // Sin imagen - placeholder
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
            SizedBox(height: 4),
            Text(
              'Tocar para\nagregar foto',
              style: TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}