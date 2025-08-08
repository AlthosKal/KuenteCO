import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../controllers/user_controller.dart';
import '../../dto/image/image_dto.dart';

class UserImageWidget extends StatefulWidget {
  final UserController userController;

  const UserImageWidget({super.key, required this.userController});

  @override
  State<UserImageWidget> createState() => _UserImageWidgetState();
}

class _UserImageWidgetState extends State<UserImageWidget> {
  Uint8List? _selectedImageBytes;

  Future<void> _pickImageAndUploadOrUpdate() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();

    setState(() {
      _selectedImageBytes = bytes;
    });

    try {
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: pickedFile.name,
      );

      final currentImage = widget.userController.user.value?.image;

      if (currentImage == null) {
        await widget.userController.uploadUserImage(multipartFile, pickedFile.name);
        _showSnackBar('Imagen subida correctamente');
      } else {
        await widget.userController.updateUserImage(multipartFile, pickedFile.name);
        _showSnackBar('Imagen actualizada correctamente');
      }

      await widget.userController.loadUser();
      setState(() => _selectedImageBytes = null);

    } catch (e) {
      _showSnackBar('Error al procesar la imagen');
    }
  }

  Future<void> _confirmDeleteImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar imagen?'),
        content: const Text('¿Estás seguro de que deseas eliminar tu imagen de perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await widget.userController.deleteUserImage();
      await widget.userController.loadUser();
      _showSnackBar('Imagen eliminada correctamente');
    } catch (e) {
      _showSnackBar('Error al eliminar la imagen');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.userController.user,
      builder: (context, user, _) {
        final ImageDTO? currentImage = user?.image;
        final String? imageUrl = currentImage?.imageUrl;

        return GestureDetector(
          onTap: _pickImageAndUploadOrUpdate,
          onLongPress: currentImage != null ? _confirmDeleteImage : null,
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
                  return const Center(child: CircularProgressIndicator());
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
