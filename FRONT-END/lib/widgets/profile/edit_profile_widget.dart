import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/app/profile_service.dart';
import '../../dto/image/image_dto.dart';
import '../../dto/profile/update_profile_dto.dart';
import '../../dto/profile/profile_detail_dto.dart';

class EditProfile extends StatefulWidget {
  final ProfileDetailDTO profile;
  final VoidCallback? onSuccess;

  const EditProfile({
    super.key,
    required this.profile,
    this.onSuccess,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  File? _selectedImageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _emailController = TextEditingController(text: widget.profile.email);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  Future<ImageDTO> _uploadImage(File imageFile) async {
    // Implementa tu lógica de subida de imagen aquí
    throw UnimplementedError("Falta implementar la subida de imagen.");
  }

  Future<void> _editProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      ImageDTO finalImageDTO = widget.profile.image!;
      if (_selectedImageFile != null) {
        finalImageDTO = await _uploadImage(_selectedImageFile!);
      }

      final dto = UpdateProfileDTO(
        id: widget.profile.id,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        image: finalImageDTO,
      );

      await ProfileService().updateProfile(dto);
      widget.onSuccess?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado con éxito')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = widget.profile.image?.imageUrl;
    final bool hasRemoteImage = imageUrl != null && imageUrl.isNotEmpty;

    return AlertDialog(
      title: const Text('Editar perfil'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // GestureDetector(
              //   onTap: _isLoading ? null : _pickImage,
              //   child: CircleAvatar(
              //     radius: 40,
              //     backgroundColor: Colors.grey.shade300,
              //     backgroundImage: _selectedImageFile != null
              //         ? FileImage(_selectedImageFile!)
              //         : hasRemoteImage
              //         ? NetworkImage(imageUrl!)
              //         : null,
              //     child: _selectedImageFile == null && !hasRemoteImage
              //         ? const Icon(Icons.person, size: 40, color: Colors.white)
              //         : null,
              //   ),
              // ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                enabled: !_isLoading,
                validator: (value) =>
                value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                enabled: !_isLoading,
                validator: (value) =>
                value == null || !value.contains('@') ? 'Correo inválido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                enabled: !_isLoading,
                validator: (value) =>
                value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _editProfile,
          child: const Text('Guardar cambios'),
        ),
      ],
    );
  }
}
