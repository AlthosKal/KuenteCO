import 'package:flutter/material.dart';
import '../../../core/services/app/auth_service.dart';
import '../../../routes/app_routes.dart';

class ProfileButtonBusiness extends StatelessWidget {
  final String? profileImageUrl;

  const ProfileButtonBusiness({
    super.key,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opciones de cuenta de Negocio',
      child: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
          ? CircleAvatar(
        backgroundImage: NetworkImage(profileImageUrl!),
      )
          : const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.business),
      ),
      itemBuilder: (BuildContext context) => const [
        PopupMenuItem<String>(
          value: 'account',
          child: Text('Mis datos'),
        ),
        PopupMenuItem<String>(
          value: 'add_profile',
          child: Text('Perfiles'),
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
          case 'add_profile':
            Navigator.pushNamed(context, AppRoutes.profileScreen);
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
      print("❌ Error al cerrar sesión: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }
}
