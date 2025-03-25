import 'package:flutter/material.dart';
import 'package:kuenteco/services/ApiService.dart';
import 'package:kuenteco/widgets/ParticleAnimation.dart';
import 'dart:ui' as ui;
import 'Login.dart';

class CambioC extends StatefulWidget {
  final String? token;
  final String? email;

  const CambioC({
    super.key,
    this.token,
    this.email,
  });

  @override
  State<CambioC> createState() => _CambioCState();
}

class _CambioCState extends State<CambioC> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _isLoading = false;

  final ApiService _apiService = ApiService();

  static const Color primaryColor = Color(0xFF890cac);
  static const Color whiteColor = Colors.white;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _cambiarContrasena(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.email?.isEmpty ?? true) {
      _showSnackBar(context, 'No se proporcionó un email válido');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.changePassword(
        email: widget.email!,
        code: _verificationCodeController.text,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
      );

      _showSnackBar(context, response['message'] ?? 'Contraseña actualizada');

      if (response['status'] == 'success') {
        _navigateToLogin(context);
      }
    } catch (e) {
      _showSnackBar(context, 'Error de conexión: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
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
          labelText: labelText,
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bool isSmallScreen = mediaQuery.size.width < 600;
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
                            const SizedBox(height: 20),
                            _buildVerificationCodeField(),
                            const SizedBox(height: 20),
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
      mainAxisAlignment: MainAxisAlignment.start,
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
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _newPasswordController,
          labelText: 'Nueva contraseña',
          obscureText: _obscureNewPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
              color: whiteColor,
            ),
            onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Por favor, ingresa tu nueva contraseña';
            if (value!.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _confirmPasswordController,
          labelText: 'Confirmar contraseña',
          obscureText: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Por favor, confirma tu contraseña';
            if (value != _newPasswordController.text) return 'Las contraseñas no coinciden';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildVerificationCodeField() {
    return _buildTextField(
      controller: _verificationCodeController,
      labelText: 'Código de verificación',
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Por favor, ingresa el código de verificación';
        return null;
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return _isLoading
        ? const CircularProgressIndicator(color: whiteColor)
        : Material(
      borderRadius: BorderRadius.circular(8),
      color: whiteColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _cambiarContrasena(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          child: const Text(
            'Cambiar Contraseña',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}