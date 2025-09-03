import 'package:flutter/material.dart';

import '../../../core/services/app/profile_service.dart';

class DeleteProfileButton extends StatefulWidget {
  final int profileId;
  final VoidCallback? onSuccess;

  const DeleteProfileButton({
    super.key,
    required this.profileId,
    this.onSuccess,
  });

  @override
  State<DeleteProfileButton> createState() => _DeleteProfileButtonState();
}

class _DeleteProfileButtonState extends State<DeleteProfileButton> {
  bool _isLoading = false;

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este perfil? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await ProfileService().deleteProfile(widget.profileId);
      if (widget.onSuccess != null) widget.onSuccess!();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el perfil: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const CircularProgressIndicator()
        : IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: _confirmAndDelete,
    );
  }
}
