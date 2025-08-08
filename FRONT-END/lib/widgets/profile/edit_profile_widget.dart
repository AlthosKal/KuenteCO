import 'package:flutter/material.dart';
import 'package:KuenteCO/widgets/profile/profile_image_widget.dart';
import '../../controllers/profile_controller.dart';
import '../../dto/profile/update_profile_dto.dart';
import '../../dto/profile/profile_detail_dto.dart';
import '../common/primary_buttom_widget.dart'; // tu botón personalizado

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
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _isLoading = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.profile.username);
    _emailController =
        TextEditingController(text: widget.profile.email);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
        password: null,
        image: widget.profileController.authenticatedProfile.value?.image,
      );

      await widget.profileController.updateProfile(dto);
      widget.onSuccess?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Perfil actualizado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al actualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isChangingPassword = true);
    try {
      await widget.profileController.changeProfilePassword(
        _currentPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Contraseña cambiada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al cambiar contraseña: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
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
              // Header
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
                    ProfileImageWidget(
                        profileController: widget.profileController),
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
              Form(
                key: _passwordFormKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        onPressed:
                        _isChangingPassword ? null : _changePassword,
                        label: _isChangingPassword
                            ? 'Cambiando...'
                            : 'Cambiar Contraseña',
                        isLoading: _isChangingPassword,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
