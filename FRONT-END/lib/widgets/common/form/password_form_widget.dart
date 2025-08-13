import 'package:flutter/material.dart';
import 'custom_form_widget.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const PasswordFormField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.labelText = 'Contraseña',
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscure = true;

  void _toggleVisibility() {
    setState(() {
      _obscure = !_obscure;
    });
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    if (value.length < 6) return 'Debe tener al menos 6 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      labelText: widget.labelText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      validator: widget.validator ?? _defaultValidator,
      onFieldSubmitted: widget.onFieldSubmitted,
      obscureText: _obscure,
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off : Icons.visibility,
          color: Colors.white,
        ),
        onPressed: _toggleVisibility,
      ),
    );
  }
}