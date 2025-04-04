import 'package:flutter/material.dart';
import 'package:kuenteco/models/account_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeleteProfileWidget extends StatelessWidget {
  final Account account;
  final VoidCallback onDeleteConfirmed;

  const DeleteProfileWidget({
    Key? key,
    required this.account,
    required this.onDeleteConfirmed,
  }) : super(key: key);

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/api/v1/account/${account.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your-token-here',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil eliminado correctamente')),
        );
        Navigator.of(context).pop();
        onDeleteConfirmed();
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorData['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Eliminar Perfil'),
      content: Text('¿Estás seguro que deseas eliminar el perfil "${account.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => _deleteAccount(context),
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}