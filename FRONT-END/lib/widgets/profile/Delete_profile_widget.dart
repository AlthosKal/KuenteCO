import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../controllers/Auth_repository.dart';

class DeleteProfileWidget extends StatefulWidget {
  final int accountId;
  final String accountName;
  final String authToken;
  final String baseUrl;
  final AuthRepository authRepository;
  final VoidCallback onDeleteConfirmed;

  const DeleteProfileWidget({
    super.key,
    required this.accountId,
    required this.accountName,
    required this.authToken,
    required this.baseUrl,
    required this.authRepository,
    required this.onDeleteConfirmed,
  });

  @override
  State<DeleteProfileWidget> createState() => _DeleteProfileWidgetState();
}

class _DeleteProfileWidgetState extends State<DeleteProfileWidget> {
  bool _isDeleting = false;
  String _errorMessage = '';

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
      _errorMessage = '';
    });

    try {
      await widget.authRepository.deleteAccount(id: widget.accountId);
      _handleSuccess();
    } catch (e) {
      _handleError('Error de conexión: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _handleSuccess() {
    widget.onDeleteConfirmed();
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil eliminado correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() => _errorMessage = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Eliminar Perfil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '¿Estás seguro que deseas eliminar el perfil "${widget.accountName}"?',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _isDeleting ? null : _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'ELIMINAR',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
