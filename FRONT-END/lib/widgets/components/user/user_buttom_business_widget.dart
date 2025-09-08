import 'package:flutter/material.dart';

import '../../../core/services/app/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../notification/notification_widget.dart';

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
          value: 'notifications',
          child: ListTile(
            leading: Icon(Icons.notifications, size: 20),
            title: Text('Notificaciones'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'account',
          child: ListTile(
            leading: Icon(Icons.person, size: 20),
            title: Text('Mis datos'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'add_profile',
          child: ListTile(
            leading: Icon(Icons.group, size: 20),
            title: Text('Perfiles'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'subscription',
          child: ListTile(
            leading: Icon(Icons.card_membership, size: 20),
            title: Text('Suscripción'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout, size: 20),
            title: Text('Cerrar sesión'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'notifications':
            _showNotifications(context);
            break;
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

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NotificationWidget(),
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
