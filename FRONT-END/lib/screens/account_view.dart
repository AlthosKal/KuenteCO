import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../dto/auth/response/user_detail_dto.dart';
import '../widgets/common/primary_buttom_widget.dart';
import 'auth/verification_code_email_view.dart';
import '../widgets/user/user_image_widget.dart'; // Nuevo widget

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late UserController userController;

  @override
  void initState() {
    super.initState();
    userController = Provider.of<UserController>(context, listen: false);
    userController.loadUser();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cuenta")),
      body: Center(
        child: ValueListenableBuilder<UserDetailDTO?>(
          valueListenable: userController.user,
          builder: (context, user, _) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Widget de imagen de usuario
                  UserImageWidget(userController: userController),

                  const SizedBox(height: 16),
                  Text(
                    user?.username ?? 'Usuario desconocido',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'Correo no disponible',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Botón cambiar contraseña
                  PrimaryButton(
                    label: "Cambiar contraseña",
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              VerificationCodeScreen(email: ''),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Botón eliminar cuenta
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
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Eliminar',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await userController.deleteUser();
                            _showSnackBar('Cuenta eliminada correctamente');
                            // Podrías redirigir al login si quieres
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
