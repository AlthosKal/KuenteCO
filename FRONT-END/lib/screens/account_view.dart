import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../dto/auth/response/user_detail_dto.dart';
import '../../dto/image/image_dto.dart';
import '../widgets/common/primary_buttom_widget.dart';
import 'auth/verification_code_email_view.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  late UserController userController;

  @override
  void initState() {
    super.initState();
    userController = Provider.of<UserController>(context, listen: false);
    userController.loadUser();
  }

  Future<void> _pickImageAndUploadOrUpdate() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedFile.name;
      });

      try {
        final multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: pickedFile.name,
        );

        final currentImage = userController.user.value?.image;

        if (currentImage == null) {
          await userController.uploadUserImage(multipartFile, pickedFile.name);
          _showSnackBar('Imagen subida correctamente');
        } else {
          await userController.updateUserImage(multipartFile, pickedFile.name);
          _showSnackBar('Imagen actualizada correctamente');
        }

        await userController.loadUser();
        setState(() {
          _selectedImageBytes = null;
          _selectedImageName = null;
        });
      } catch (e) {
        _showSnackBar('Error al procesar la imagen');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

    if (confirm == true) {
      try {
        await userController.deleteUserImage();
        await userController.loadUser();
        _showSnackBar('Imagen eliminada correctamente');
      } catch (e) {
        _showSnackBar('Error al eliminar la imagen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cuenta")),
      body: Center(
        child: ValueListenableBuilder<UserDetailDTO?>(
          valueListenable: userController.user,
          builder: (context, user, _) {
            final ImageDTO? currentImage = user?.image;
            final String? imageUrl = currentImage?.imageUrl;

            Widget avatar = GestureDetector(
              onTap: _pickImageAndUploadOrUpdate,
              onLongPress: currentImage != null ? _confirmDeleteImage : null,
              child: ClipOval(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: _selectedImageBytes != null
                      ? Image.memory(
                    _selectedImageBytes!,
                    fit: BoxFit.cover,
                  )
                      : (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 100);
                    },
                  )
                      : const Icon(Icons.person, size: 100),
                ),
              ),
            );

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  avatar,
                  const SizedBox(height: 16),
                  Text(
                    user?.username ?? 'Usuario desconocido',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'Correo no disponible',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // cambiar contraseña
                  PrimaryButton(
                    label: "Cambiar contraseña",
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => VerificationCodeScreen(email: '',),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // eliminar cuenta
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Eliminar cuenta'),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text('¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await userController.deleteUser();
                            _showSnackBar('Cuenta eliminada correctamente');
                            // Podrías redirigir al login:
                            // Navigator.pushReplacementNamed(context, '/login');
                          } catch (e) {
                            _showSnackBar('Error al eliminar la cuenta');
                          }
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
