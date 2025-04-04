import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateProfileWidget extends StatefulWidget {
  final VoidCallback onAccountCreated;

  const CreateProfileWidget({
    Key? key,
    required this.onAccountCreated,
  }) : super(key: key);

  @override
  State<CreateProfileWidget> createState() => _CreateProfileWidgetState();
}

class _CreateProfileWidgetState extends State<CreateProfileWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/account/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your-token-here',
        },
        body: json.encode({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        _handleSuccess();
      } else {
        _handleError(response);
      }
    } catch (e) {
      _handleException(e);
    }
  }

  void _handleSuccess() {
    widget.onAccountCreated();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil creado correctamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleError(http.Response response) {
    final errorData = json.decode(response.body);
    setState(() {
      _errorMessage = errorData['message'] ?? 'Error al crear el perfil';
      _isSubmitting = false;
    });
  }

  void _handleException(dynamic e) {
    setState(() {
      _errorMessage = 'Error de conexión: ${e.toString()}';
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme, colors),
              if (_errorMessage.isNotEmpty) _buildErrorText(),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 24),
              _buildSubmitButton(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colors) {
    return Text(
      'Crear Nuevo Perfil',
      style: theme.textTheme.headlineSmall?.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        _errorMessage,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nombre del Perfil',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Ingresa un nombre' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descripción',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      validator: (value) => value?.isEmpty ?? true ? 'Ingresa una descripción' : null,
    );
  }

  Widget _buildSubmitButton(ColorScheme colors) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isSubmitting
          ? const CircularProgressIndicator()
          : const Text('CREAR PERFIL'),
    );
  }
}