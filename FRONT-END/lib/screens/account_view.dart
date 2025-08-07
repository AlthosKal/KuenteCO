import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../../controllers/user_controller.dart';
import '../../dto/auth/response/user_detail_dto.dart';
import '../../dto/image/image_dto.dart';

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
    userController.loadUser().then((_) {
      if (mounted) {
        setState(() {
          _selectedImageBytes = null;
          _selectedImageName = null;
        });
      }
    });
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

  void _clearSelectedImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta'),
      ),
      body: Center(
        child: ValueListenableBuilder<UserDetailDTO?>(
          valueListenable: userController.user,
          builder: (context, user, _) {
            final ImageDTO? currentImage = user?.image;
            final String? imageUrl = currentImage?.imageUrl;

            Widget avatar = ClipOval(
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
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 100);
                  },
                )
                    : const Icon(Icons.person, size: 100),
              ),
            );

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  ValueListenableBuilder<bool>(
                    valueListenable: userController.isLoading,
                    builder: (context, isLoading, _) {
                      if (isLoading) return const CircularProgressIndicator();
                      return Column(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.upload),
                            label: const Text('Subir nueva imagen'),
                            onPressed: () async {
                              await _pickImage();
                              if (_selectedImageBytes != null && _selectedImageName != null) {
                                try {
                                  final multipartFile = MultipartFile.fromBytes(
                                    _selectedImageBytes!,
                                    filename: _selectedImageName!,
                                  );
                                  await userController.uploadUserImage(
                                      multipartFile, _selectedImageName!);
                                  await userController.loadUser(); // recargar datos
                                  _showSnackBar('Imagen subida correctamente');
                                  _clearSelectedImage();
                                } catch (e) {
                                  _showSnackBar('Error al subir la imagen');
                                }
                              }
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.update),
                            label: const Text('Actualizar imagen'),
                            onPressed: () async {
                              await _pickImage();
                              if (_selectedImageBytes != null && _selectedImageName != null) {
                                try {
                                  final multipartFile = MultipartFile.fromBytes(
                                    _selectedImageBytes!,
                                    filename: _selectedImageName!,
                                  );
                                  await userController.updateUserImage(
                                      multipartFile, _selectedImageName!);
                                  await userController.loadUser(); // recargar datos
                                  _showSnackBar('Imagen actualizada correctamente');
                                  _clearSelectedImage();
                                } catch (e) {
                                  _showSnackBar('Error al actualizar la imagen');
                                }
                              }
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete),
                            label: const Text('Eliminar imagen'),
                            onPressed: () async {
                              try {
                                await userController.deleteUserImage();
                                await userController.loadUser(); // recargar datos
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
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Eliminar cuenta'),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text(
                                '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await userController.deleteUser();
                            _showSnackBar('Cuenta eliminada correctamente');
                            // Podrías navegar al login aquí si quieres
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
