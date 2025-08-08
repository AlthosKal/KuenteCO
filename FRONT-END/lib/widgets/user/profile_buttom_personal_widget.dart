import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class ProfileButtonPersonal extends StatelessWidget {
  final String? profileImageUrl;

  const ProfileButtonPersonal({
    super.key,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opciones de cuenta personal',
      child: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
          ? CircleAvatar(
        backgroundImage: NetworkImage(profileImageUrl!),
      )
          : const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person),
      ),
      itemBuilder: (BuildContext context) => const [
        PopupMenuItem<String>(
          value: 'account',
          child: Text('Mis datos'),
        ),
        PopupMenuItem<String>(
          value: 'subscription',
          child: Text('Suscripción'),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Text('Cerrar sesión'),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'account':
            Navigator.pushNamed(context, AppRoutes.accountScreen);
            break;
          case 'subscription':
            Navigator.pushNamed(context, AppRoutes.suscriptions);
            break;
          case 'logout':
            _logout(context);
            break;
        }
      },
    );
  }

  void _logout(BuildContext context) {
    // Aquí puedes borrar token si lo deseas
    print("Cerrando sesión...");
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }
}
