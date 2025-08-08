import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/profile_controller.dart';
import '../../../dto/image/image_dto.dart';

class ProfileImageWidget extends StatefulWidget {
  final ProfileController profileController;

  const ProfileImageWidget({super.key, required this.profileController});

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  Uint8List? _selectedImageBytes;

  Future<void> _pickImageAndUploadOrUpdate() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final file = File(pickedFile.path);

    setState(() => _selectedImageBytes = bytes);

    try {
      final currentImage =
          widget.profileController.authenticatedProfile.value?.image;

      if (currentImage == null) {
        await widget.profileController.uploadProfileImage(file);
        _showSnackBar('Imagen de perfil subida correctamente');
      } else {
        await widget.profileController.updateProfileImage(file);
        _showSnackBar('Imagen de perfil actualizada correctamente');
      }

      await widget.profileController.loadAuthenticatedProfile();
      setState(() => _selectedImageBytes = null);
    } catch (e) {
      _showSnackBar('Error al procesar la imagen');
    }
  }

  Future<void> _confirmDeleteImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar imagen de perfil?'),
        content:
        const Text('¿En verdad deseas eliminar esta imagen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, eliminar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await widget.profileController.deleteProfileImage();
      await widget.profileController.loadAuthenticatedProfile();
      _showSnackBar('Imagen de perfil eliminada correctamente');
    } catch (e) {
      _showSnackBar('Error al eliminar la imagen de perfil');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.profileController.authenticatedProfile,
      builder: (context, profile, _) {
        final ImageDTO? currentImage = profile?.image;
        final String? imageUrl = currentImage?.imageUrl;

        return GestureDetector(
          onTap: _pickImageAndUploadOrUpdate,
          onLongPress:
          currentImage != null ? _confirmDeleteImage : null,
          child: ClipOval(
            child: SizedBox(
              width: 150,
              height: 150,
              child: _selectedImageBytes != null
                  ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                  : (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                      child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.person, size: 100),
              )
                  : const Icon(Icons.person, size: 100),
            ),
          ),
        );
      },
    );
  }
}
