import 'package:KuenteCO/widgets/components/profile/profile_image_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../controllers/profile_controller.dart';
import '../../../dto/app/profile/profile_detail_dto.dart';
import '../../../dto/app/profile/update_profile_dto.dart';
import '../../../screens/auth/verification_code_email_view.dart';
import '../../common/buttoms/primary_buttom_widget.dart';

class EditProfile extends StatefulWidget {
  final ProfileDetailDTO profile;
  final ProfileController profileController;
  final VoidCallback? onSuccess;

  const EditProfile({
    super.key,
    required this.profile,
    required this.profileController,
    this.onSuccess,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  
  // Notifiers para manejar la imagen integrada con update_profile
  final ValueNotifier<MultipartFile?> _selectedImageNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _removeImageNotifier = ValueNotifier(false);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _emailController = TextEditingController(text: widget.profile.email);
    
    // Debug: verificar si el profile ya tiene imagen
    debugPrint('ð EditProfile - profile.image: ${widget.profile.image?.imageUrl ?? "NO_IMAGE"}');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _selectedImageNotifier.dispose();
    _removeImageNotifier.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final dto = UpdateProfileDTO(
        id: widget.profile.id,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        removeImage: _removeImageNotifier.value, // ð¯ Sincronizado con widget
      );

      debugPrint('ð Profile update - removeImage: ${_removeImageNotifier.value}');
      debugPrint('ð Profile update - selectedImage: ${_selectedImageNotifier.value != null ? "YES" : "NO"}');

      // ð¯ Pasar imagen al update_profile del backend
      await widget.profileController.updateProfile(
        dto, 
        imageFile: _selectedImageNotifier.value,
      );
      
      widget.onSuccess?.call();

      if (mounted) {
        Navigator.of(context).pop(); // Cerrar el diálogo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('â Perfil actualizado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('â Error al actualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- Encabezado ---
              Row(
                children: [
                  const Icon(Icons.edit, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Text(
                    'Editar Perfil',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.purple),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),

              /// --- Formulario de edición de perfil ---
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: ProfileImageWidget(
                        profileController: widget.profileController,
                        selectedImageNotifier: _selectedImageNotifier,
                        removeImageNotifier: _removeImageNotifier,
                        profile: widget.profile, // ð¯ Pasar el profile con la imagen
                        size: 120,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        prefixIcon: Icon(Icons.person),
                      ),
                      enabled: !_isLoading,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo requerido'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email),
                      ),
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                      value == null || !value.contains('@')
                          ? 'Correo inválido'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        label:
                        _isLoading ? 'Guardando...' : 'Actualizar Perfil',
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// --- Botón cambiar contraseña ---
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Cambiar contraseña',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const VerificationCodeScreen(email: ''),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
