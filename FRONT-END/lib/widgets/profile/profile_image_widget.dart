import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../controllers/profile_controller.dart';
import '../../dto/image/image_dto.dart';
import '../../dto/profile/profile_detail_dto.dart';

class ProfileImageWidget extends StatefulWidget {
  final ProfileController profileController;
  final ValueNotifier<MultipartFile?>? selectedImageNotifier;
  final ValueNotifier<bool>? removeImageNotifier;
  final ProfileDetailDTO? profile; // Para usar la información del perfil directamente
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

  // 🎯 CLICK SIMPLE: Seleccionar imagen
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final multipartFile = MultipartFile.fromBytes(
      bytes,
      filename: pickedFile.name,
    );

    setState(() {
      _selectedImageBytes = bytes;
      _selectedImageName = pickedFile.name;
    });

    // Notificar al widget padre sobre la imagen seleccionada
    widget.selectedImageNotifier?.value = multipartFile;
    widget.removeImageNotifier?.value = false;

    debugPrint('🖼️ Image selected: ${pickedFile.name}');
  }

  // 🎯 CLICK PRESIONADO: Confirmar eliminación
  Future<void> _confirmDeleteImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar imagen de perfil?'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu imagen de perfil? Este cambio se aplicará al guardar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, eliminar',
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

    // Notificar al widget padre que se debe remover la imagen
    widget.selectedImageNotifier?.value = null;
    widget.removeImageNotifier?.value = true;

    debugPrint('🗑️ Image marked for removal');
  }

  bool _hasCurrentImage() {
    final profile = widget.profile; // 🎯 Usar profile pasado directamente
    return _selectedImageBytes != null || 
           (profile?.image?.imageUrl != null && 
            profile!.image!.imageUrl!.isNotEmpty &&
            widget.removeImageNotifier?.value != true);
  }

  bool _hasCurrentImageFromProfile(ProfileDetailDTO? profile) {
    return _selectedImageBytes != null || 
           (profile?.image?.imageUrl != null && 
            profile!.image!.imageUrl!.isNotEmpty &&
            widget.removeImageNotifier?.value != true);
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 Usar getProfileById para obtener datos actualizados automáticamente
    return FutureBuilder<ProfileDetailDTO>(
      future: widget.profile != null 
          ? widget.profileController.getProfileById(widget.profile!.id)
          : null,
      builder: (context, snapshot) {
        ProfileDetailDTO? currentProfile;
        
        if (snapshot.hasData) {
          currentProfile = snapshot.data;
        } else if (widget.profile != null) {
          // Usar profile pasado como fallback mientras carga
          currentProfile = widget.profile;
        }
        
        final currentImage = currentProfile?.image;
        final shouldRemoveImage = widget.removeImageNotifier?.value ?? false;
        
        // Debug logs para verificar la imagen
        debugPrint('🔍 ProfileImageWidget - profile: ${currentProfile != null ? "LOADED" : "NULL"}');
        debugPrint('🔍 ProfileImageWidget - image: ${currentImage != null ? "FOUND" : "NULL"}');
        debugPrint('🔍 ProfileImageWidget - imageUrl: ${currentImage?.imageUrl ?? "NO_URL"}');
        debugPrint('🔍 ProfileImageWidget - shouldRemove: $shouldRemoveImage');
        debugPrint('🔍 ProfileImageWidget - snapshot state: ${snapshot.connectionState}');

        return GestureDetector(
          onTap: _pickImage, // 🎯 Click simple: seleccionar imagen
          onLongPress: _hasCurrentImageFromProfile(currentProfile) ? _confirmDeleteImage : null,
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
    // Si hay una imagen seleccionada localmente, mostrarla
    if (_selectedImageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            _selectedImageBytes!,
            fit: BoxFit.cover,
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

    // Si se marcó para eliminar, mostrar placeholder
    if (shouldRemoveImage) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 40, color: Colors.grey),
            SizedBox(height: 4),
            Text(
              'Se eliminará',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Si hay imagen actual, mostrarla
    final imageUrl = currentImage?.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.person, size: 60, color: Colors.grey),
        ),
      );
    }

    // Sin imagen - mostrar placeholder
    return const Center(
      child: Icon(Icons.person, size: 60, color: Colors.grey),
    );
  }
}
