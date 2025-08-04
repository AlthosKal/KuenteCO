import 'package:flutter/material.dart';

class ProfileButtonBusiness extends StatelessWidget {
  final String? profileImageUrl;
  final Function(BuildContext, String) onMenuSelection;

  const ProfileButtonBusiness({
    super.key,
    this.profileImageUrl,
    required this.onMenuSelection,
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
        PopupMenuItem<String>(value: 'account', child: Text('Mis datos')),
        PopupMenuItem<String>(value: 'add_profile', child: Text('Agregar perfil')),
        PopupMenuItem<String>(value: 'subscription', child: Text('Suscripcion')),
        PopupMenuItem<String>(value: 'logout', child: Text('Cerrar sesión')),
      ],
      onSelected: (value) => onMenuSelection(context, value),
    );
  }
}
