import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../controllers/user_controller.dart';
import '../../dto/app/image/image_dto.dart';

class UserImageWidget extends StatefulWidget {
  final UserController userController;

  const UserImageWidget({super.key, required this.userController});

  @override
  State<UserImageWidget> createState() => _UserImageWidgetState();
}

class _UserImageWidgetState extends State<UserImageWidget> {
  Uint8List? _selectedImageBytes;
  bool _isProcessing = false;

  // ✅ MÉTODO COMPATIBLE WEB + MÓVIL
  Future<void> _pickImageAndUploadOrUpdate() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final picker = ImagePicker();

      // ✅ Configuración optimizada para web y móvil
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: kIsWeb ? null : 1200,
        maxHeight: kIsWeb ? null : 1200,
        imageQuality: kIsWeb ? null : 90,
      );

      if (pickedFile == null) {
        debugPrint('📷 User cancelled image selection');
        return;
      }

      debugPrint('📷 User image picked: ${pickedFile.name}');

      final bytes = await pickedFile.readAsBytes();

      if (bytes.isEmpty) {
        _showSnackBar('Error: imagen vacía', isError: true);
        return;
      }

      setState(() {
        _selectedImageBytes = bytes;
      });

      // ✅ Crear MultipartFile con nombre adecuado
      final fileName = pickedFile.name.isNotEmpty
          ? pickedFile.name
          : 'user_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      );

      final currentImage = widget.userController.user.value?.image;

      // ✅ Upload o update según corresponda
      if (currentImage == null) {
        debugPrint('📤 Uploading new user image...');
        await widget.userController.uploadUserImage(multipartFile, fileName);
        _showSnackBar('Imagen subida correctamente');
      } else {
        debugPrint('🔄 Updating existing user image...');
        await widget.userController.updateUserImage(multipartFile, fileName);
        _showSnackBar('Imagen actualizada correctamente');
      }

      await widget.userController.loadUser();

      if (mounted) {
        setState(() => _selectedImageBytes = null);
      }

      debugPrint('✅ User image processed successfully');

    } catch (e, stackTrace) {
      debugPrint('❌ Error processing user image: $e');
      debugPrint('Stack trace: $stackTrace');

      // ✅ No mostrar error si el usuario canceló en web
      if (kIsWeb && (e.toString().contains('User cancelled') ||
          e.toString().contains('AbortError'))) {
        return;
      }

      _showSnackBar('Error al procesar la imagen: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _confirmDeleteImage() async {
    if (_isProcessing) return;

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

    setState(() => _isProcessing = true);

    try {
      debugPrint('🗑️ Deleting user image...');
      await widget.userController.deleteUserImage();
      await widget.userController.loadUser();
      _showSnackBar('Imagen eliminada correctamente');
      debugPrint('✅ User image deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting user image: $e');
      _showSnackBar('Error al eliminar la imagen: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: isError ? 4 : 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.userController.user,
      builder: (context, user, _) {
        final ImageDTO? currentImage = user?.image;
        final String? imageUrl = currentImage?.imageUrl;

        return GestureDetector(
          onTap: _isProcessing ? null : _pickImageAndUploadOrUpdate,
          onLongPress: (currentImage != null && !_isProcessing)
              ? _confirmDeleteImage
              : null,
          child: ClipOval(
            child: SizedBox(
              width: 150,
              height: 150,
              child: _buildImageContent(imageUrl),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageContent(String? imageUrl) {
    // ✅ Mostrar loading si está procesando
    if (_isProcessing) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(
                'Procesando...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Si hay imagen seleccionada temporalmente
    if (_selectedImageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            _selectedImageBytes!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('❌ Error displaying temp user image: $error');
              return const Center(
                child: Icon(Icons.error, size: 50, color: Colors.red),
              );
            },
          ),
          Container(
            color: Colors.black26,
            child: const Center(
              child: Text(
                'Subiendo...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Si hay imagen actual
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error loading user image: $error');
          return const Center(
            child: Icon(Icons.person, size: 100, color: Colors.grey),
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
            Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Tocar para\nagregar foto',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}