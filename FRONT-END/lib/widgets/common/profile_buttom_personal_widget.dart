import 'package:flutter/material.dart';

class ProfileButtonPersonal extends StatelessWidget {
  final String? profileImageUrl;
  final Function(BuildContext, String) onMenuSelection;

  const ProfileButtonPersonal({
    super.key,
    this.profileImageUrl,
    required this.onMenuSelection,
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
        PopupMenuItem<String>(value: 'account', child: Text('Mis datos')),
        PopupMenuItem<String>(value: 'subscription', child: Text('Suscripción')),
        PopupMenuItem<String>(value: 'logout', child: Text('Cerrar sesión')),
      ],
      onSelected: (value) => onMenuSelection(context, value),
    );
  }
}
