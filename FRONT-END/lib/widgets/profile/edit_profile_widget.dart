import 'package:flutter/material.dart';
import 'package:KuenteCO/widgets/profile/profile_image_widget.dart';
import '../../controllers/profile_controller.dart';
import '../../dto/profile/update_profile_dto.dart';
import '../../dto/profile/profile_detail_dto.dart';
import '../../core/services/app/profile_service.dart';

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
  late TextEditingController _passwordController;

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

  Future<void> _editProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final dto = UpdateProfileDTO(
        id: widget.profile.id,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim().isEmpty
            ? null
            : _passwordController.text.trim(),
        image: widget.profileController.authenticatedProfile.value?.image,
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
    return AlertDialog(
      title: const Text('Editar perfil'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Aquí usamos tu ProfileImageWidget actual
              ProfileImageWidget(profileController: widget.profileController),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration:
                const InputDecoration(labelText: 'Nombre de usuario'),
                enabled: !_isLoading,
                validator: (value) =>
                value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration:
                const InputDecoration(labelText: 'Correo electrónico'),
                enabled: !_isLoading,
                validator: (value) => value == null || !value.contains('@')
                    ? 'Correo inválido'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                enabled: !_isLoading,
                validator: (value) => value != null && value.isNotEmpty && value.length < 6
                    ? 'Mínimo 6 caracteres'
                    : null,
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
