import 'package:flutter/material.dart';
import 'package:kuenteco/services/ApiService.dart';
import 'package:kuenteco/widgets/ParticleAnimation.dart';
import 'dart:ui' as ui;
import 'Login.dart';

class CambioC extends StatefulWidget {
  final String? token;
  final String? email;
  final String? code;

  const CambioC({
    super.key,
    this.token,
    this.email,
    this.code,
  });

  @override
  State<CambioC> createState() => _CambioCState();
}

class _CambioCState extends State<CambioC> {
  static const Color primaryColor = Color(0xFF890cac);
  static const Color whiteColor = Colors.white;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _obscureNewPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final email = widget.email;
    final code = widget.code;

    if (email?.isEmpty ?? true) {
      _showSnackBar(context, 'No se proporcionó un email válido');
      return;
    }

    if (code?.isEmpty ?? true) {
      _showSnackBar(context, 'Se requiere un código de verificación');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.changePassword(
        email: email!,
        code: code!,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
      );

      _showSnackBar(context, response['message'] ?? 'Contraseña actualizada');

      if (response['status'] == 'success') {
        _navigateToLogin(context);
      }
    } catch (e) {

      _showSnackBar(context, 'Error al cambiar contraseña: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    final containerWidth = isSmallScreen ? 360.0 : 400.0;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ParticleAnimation()),
          Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      width: containerWidth,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: whiteColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAppBar(context),
                            const SizedBox(height: 20),
                            _buildPasswordFields(),
                            const SizedBox(height: 30),
                            _buildSubmitButton(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Expanded(
          child: Text(
            'Cambiar Contraseña',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
        ),
        const SizedBox(width: 48), // Balance the row with empty space
      ],
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        _buildPasswordField(
          controller: _newPasswordController,
          label: 'Nueva contraseña',
          obscureText: _obscureNewPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
              color: whiteColor,
            ),
            onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Ingresa tu nueva contraseña';
            if (value!.length < 6) return 'Mínimo 6 caracteres';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: 'Confirmar contraseña',
          obscureText: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Confirma tu contraseña';
            if (value != _newPasswordController.text) return 'No coinciden';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: whiteColor,
        style: const TextStyle(color: whiteColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(color: whiteColor),
          suffixIcon: suffixIcon,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: whiteColor),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: whiteColor))
          : ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: whiteColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => _changePassword(context),
        child: const Text(
          'Cambiar Contraseña',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}