import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/app/auth_service.dart';
import '../../../controllers/chat_controller.dart';
import '../../../routes/app_routes.dart';
import '../notification/notification_widget.dart';
import '../exchange_rate/currency_converter_widget.dart';

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
          value: 'currency_converter',
          child: ListTile(
            leading: Icon(Icons.currency_exchange, size: 20),
            title: Text(''),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'account',
          child: const ListTile(
            leading: Icon(Icons.person, size: 20),
            title: Text('Mis datos'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'add_profile',
          child: const ListTile(
            leading: Icon(Icons.group, size: 20),
            title: Text('Perfiles'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'subscription',
          child: const ListTile(
            leading: Icon(Icons.card_membership, size: 20),
            title: Text('Suscripción'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: const ListTile(
            leading: Icon(Icons.logout, size: 20, color: Colors.purpleAccent),
            title: Text('Cerrar sesión', style: TextStyle(color: Colors.purpleAccent)),
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
          case 'currency_converter':
            _showCurrencyConverter(context);
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

  void _showCurrencyConverter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CurrencyConverterWidget(),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final authService = AuthService();
      
      // Limpiar estado del chat antes del logout
      try {
        final chatController = Provider.of<ChatController>(context, listen: false);
        chatController.clearAllChatData();
      } catch (e) {
        print("⚠️ Error limpiando chat: $e");
        // Continuar con el logout incluso si falla la limpieza del chat
      }
      
      // Realizar logout completo (incluye limpieza de cookies)
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
