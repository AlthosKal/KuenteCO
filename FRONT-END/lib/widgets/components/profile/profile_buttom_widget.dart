import 'package:flutter/material.dart';

import '../../../controllers/profile_controller.dart';
import '../../../core/services/app/profile_service.dart';
import '../../../dto/app/profile/profile_detail_dto.dart';
import '../../../routes/app_routes.dart';
import '../notification/notification_widget.dart';
import '../exchange_rate/currency_converter_widget.dart';

class ProfileButtonWidget extends StatelessWidget {
  final String? profileImageUrl;
  final ProfileController? profileController;
  final ProfileDetailDTO? profile;
  final double radius;

  const ProfileButtonWidget({
    super.key,
    this.profileImageUrl,
    this.profileController,
    this.profile,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opciones de perfil',
      onSelected: (value) => _handleMenuSelection(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'notifications',
          child: Row(
            children: [
              Icon(Icons.notifications, size: 20),
              SizedBox(width: 8),
              Text('Notificaciones'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'currency_converter',
          child: Row(
            children: [
              Icon(Icons.currency_exchange, size: 20),
              SizedBox(width: 8),
              Text('Divisa'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.purpleAccent),
              SizedBox(width: 8),
              Text('Cerrar sesión', style: TextStyle(color: Colors.purpleAccent)),
            ],
          ),
        ),
      ],
      child: _buildAvatar(),
    );
  }

  /// Avatar que maneja carga desde URL directa o desde controller
  Widget _buildAvatar() {
    // 1) Si nos pasan URL directa, se usa esa.
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(profileImageUrl!),
      );
    }

    // 2) Si nos pasan controller + profile
    if (profileController != null && profile != null) {
      return FutureBuilder<ProfileDetailDTO>(
        future: profileController!.getProfileById(profile!.id),
        builder: (context, snapshot) {
          final currentProfile = snapshot.data ?? profile;
          final imageUrl = currentProfile?.image?.imageUrl;

          if (snapshot.connectionState == ConnectionState.waiting &&
              (imageUrl == null || imageUrl.isEmpty)) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: Colors.white,
              child: SizedBox(
                width: radius,
                height: radius,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          if (imageUrl != null && imageUrl.isNotEmpty) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(imageUrl),
            );
          }

          return _placeholderAvatar();
        },
      );
    }

    // 3) Fallback general
    return _placeholderAvatar();
  }

  Widget _placeholderAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }

  /// â Lógica de navegación y logout (extraída del navbar original)
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

  Future<void> _handleMenuSelection(BuildContext context, String value) async {
    switch (value) {
      case 'notifications':
        _showNotifications(context);
        break;
      case 'currency_converter':
        _showCurrencyConverter(context);
        break;
      case 'profile':
        Navigator.pushNamed(context, AppRoutes.homeProfile);
        break;
      case 'settings':
        Navigator.pushNamed(context, '/profile/settings');
        break;
      case 'contact':
        Navigator.pushNamed(context, AppRoutes.contactLogged);
        break;
      case 'logout':
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          final profileService = ProfileService();
          await profileService.logout();

          if (context.mounted) Navigator.of(context).pop();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        } catch (e) {
          if (context.mounted) Navigator.of(context).pop();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cerrar sesión: $e'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
        break;
    }
  }
}
