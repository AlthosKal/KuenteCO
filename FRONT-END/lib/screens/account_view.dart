import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/user_controller.dart';
import '../../core/services/api_client.dart';
import '../../core/services/app/user_service.dart';
import '../../dto/auth/response/user_detail_dto.dart';
import '../../dto/image/image_dto.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final UserController userController;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    userController = UserController(userService: UserService(ApiClient()));
    userController.loadUser();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedFile.name;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Eliminar cuenta',
            onPressed: () async {
              try {
                await userController.deleteUser();
                _showSnackBar('Usuario eliminado correctamente');
                // TODO: Redirigir si es necesario
              } catch (e) {
                _showSnackBar('Error al eliminar usuario');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ValueListenableBuilder<UserDetailDTO?>(
          valueListenable: userController.user,
          builder: (context, user, _) {
            final ImageDTO? currentImage = user?.image;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedImageBytes != null)
                  ClipOval(
                    child: Image.memory(
                      _selectedImageBytes!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (currentImage != null)
                  Column(
                    children: [
                      ClipOval(
                        child: Image.network(
                          currentImage.imageUrl,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Nombre: ${currentImage.name}'),
                    ],
                  )
                else
                  const Icon(Icons.person, size: 100),

                const SizedBox(height: 16),

                ValueListenableBuilder<bool>(
                  valueListenable: userController.isLoading,
                  builder: (context, isLoading, _) {
                    if (isLoading) return const CircularProgressIndicator();

                    return Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload),
                          label: const Text('Subir nueva'),
                          onPressed: () async {
                            await _pickImage();
                            if (_selectedImageBytes != null && _selectedImageName != null) {
                              try {
                                await userController.uploadUserImage(
                                  _selectedImageBytes!,
                                  _selectedImageName!,
                                );
                                _showSnackBar('Imagen subida correctamente');
                              } catch (e) {
                                _showSnackBar('Error al subir la imagen');
                              }
                            }
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.update),
                          label: const Text('Actualizar'),
                          onPressed: () async {
                            await _pickImage();
                            if (_selectedImageBytes != null && _selectedImageName != null) {
                              try {
                                await userController.updateUserImage(
                                  _selectedImageBytes!,
                                  _selectedImageName!,
                                );
                                _showSnackBar('Imagen actualizada correctamente');
                              } catch (e) {
                                _showSnackBar('Error al actualizar la imagen');
                              }
                            }
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete),
                          label: const Text('Eliminar'),
                          onPressed: () async {
                            try {
                              await userController.deleteUserImage();
                              _showSnackBar('Imagen eliminada');
                            } catch (e) {
                              _showSnackBar('Error al eliminar la imagen');
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}