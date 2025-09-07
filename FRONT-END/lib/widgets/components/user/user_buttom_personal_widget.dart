import 'package:flutter/material.dart';

import '../../../core/services/app/auth_service.dart';
import '../../../routes/app_routes.dart';

class UserButtomPersonalWidget extends StatelessWidget {
  final String? profileImageUrl;

  const UserButtomPersonalWidget({
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

  Future<void> _logout(BuildContext context) async {
    try {
      final authService = AuthService();
      await authService.logout();
      Navigator.pushReplacementNamed(context, AppRoutes.homeGuest);
    } catch (e) {
      print("â Error al cerrar sesión: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }
}
