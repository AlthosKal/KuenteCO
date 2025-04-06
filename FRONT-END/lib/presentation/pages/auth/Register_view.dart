import 'package:flutter/material.dart';
import 'package:kuenteco/infrastructure/datasources/remote/Auth_api_service.dart';
import 'package:kuenteco/presentation/widgets/Particle_animation_widget.dart';
import 'package:kuenteco/presentation/pages/auth/Verification_register.dart';
import 'dart:ui' as ui;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final AuthApiService _authApiService = AuthApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _registerUser(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authApiService.register(
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        name: _fullNameController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Registro exitoso')),
      );

      if (response['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificacionR(email: _emailController.text),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final bool isSmallScreen = screenWidth < 600;
    final containerWidth = isSmallScreen ? 360.0 : 400.0;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: ParticleAnimation(),
          ),
          Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildBlurredContainer(
                  width: containerWidth,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildFullNameField(),
                        const SizedBox(height: 20),
                        _buildEmailField(),
                        const SizedBox(height: 20),
                        _buildPasswordField(),
                        const SizedBox(height: 20),
                        _buildConfirmPasswordField(),
                        const SizedBox(height: 20),
                        _buildRegisterButton(),
                        const SizedBox(height: 20),
                        _buildLoginOption(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBlurredContainer({
    required double width,
    required Widget child,
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Expanded(
          child: Text(
            'Registro',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildFullNameField() {
    return _buildTextField(
      controller: _fullNameController,
      labelText: 'Nombre completo',
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Por favor, ingresa tu nombre';
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      controller: _emailController,
      labelText: 'Correo electrónico',
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Por favor, ingresa tu correo';
        if (!value!.contains('@')) return 'Ingresa un correo válido';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: _passwordController,
      labelText: 'Contraseña',
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility : Icons.visibility_off,
          color: Colors.white,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Por favor, ingresa tu contraseña';
        if (value!.length < 6) return 'Mínimo 6 caracteres';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildTextField(
      controller: _confirmPasswordController,
      labelText: 'Confirmar contraseña',
      obscureText: true,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Confirma tu contraseña';
        if (value != _passwordController.text) return 'Las contraseñas no coinciden';
        return null;
      },
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
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white),
          suffixIcon: suffixIcon,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _isLoading ? null : () => _registerUser(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          )
              : const Text(
            'Registrarse',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginOption() {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => Navigator.pushReplacementNamed(context, '/login'),
      child: const Text.rich(
        TextSpan(
          text: '¿Ya tienes una cuenta? ',
          style: TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: 'Inicia sesión',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}