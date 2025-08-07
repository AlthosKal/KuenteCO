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
    // Usar el UserController global del Provider
    userController = Provider.of<UserController>(context, listen: false);
    // Recargar la información del usuario
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
            final String? imageUrl = currentImage?.imageUrl;

            print("🖼️ Usuario completo: ${user?.username} - Email: ${user?.email}");
            print("🖼️ Imagen cargada del backend: $imageUrl");
            print("🖼️ ImageId: ${currentImage?.imageId}");
            print("🖼️ ImageName: ${currentImage?.name}");

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
                    print("❌ Error cargando imagen: $error");
                    return const Icon(Icons.person, size: 100);
                  },
                )
                    : const Icon(Icons.person, size: 100),
              ),
            );

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                avatar,
                const SizedBox(height: 16),
                
                // DEBUG INFO - Mostrar toda la información del usuario
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DEBUG INFO:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Usuario: ${user?.username ?? "null"}'),
                      Text('Email: ${user?.email ?? "null"}'),
                      Text('Estado: ${user?.state ?? "null"}'),
                      Text('Imagen completa: ${user?.image?.toJson() ?? "null"}'),
                      Text('ImageUrl: ${imageUrl ?? "null"}'),
                      Text('ImageId: ${currentImage?.imageId ?? "null"}'),
                      Text('ImageName: ${currentImage?.name ?? "null"}'),
                    ],
                  ),
                ),
                
                if (currentImage != null && currentImage.name != null) ...[
                  Text('Nombre: ${currentImage.name}'),
                  const SizedBox(height: 8),
                ],
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
                                final multipartFile = MultipartFile.fromBytes(
                                  _selectedImageBytes!,
                                  filename: _selectedImageName!,
                                );
                                await userController.uploadUserImage(
                                  multipartFile,
                                  _selectedImageName!,
                                );
                                _showSnackBar('Imagen subida correctamente');
                                _clearSelectedImage();
                                // NO necesario: await userController.loadUser(); // Ya se actualiza automáticamente
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
                                final multipartFile = MultipartFile.fromBytes(
                                  _selectedImageBytes!,
                                  filename: _selectedImageName!,
                                );
                                await userController.updateUserImage(
                                  multipartFile,
                                  _selectedImageName!,
                                );
                                _showSnackBar('Imagen actualizada correctamente');
                                _clearSelectedImage();
                                // NO necesario: await userController.loadUser(); // Ya se actualiza automáticamente
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
                              // NO necesario: await userController.loadUser(); // Ya se actualiza automáticamente
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
