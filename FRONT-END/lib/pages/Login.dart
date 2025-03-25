import 'package:flutter/material.dart';
import 'package:kuenteco/services/ApiService.dart';
import 'package:kuenteco/widgets/ParticleAnimation.dart';
import 'package:kuenteco/pages/Register.dart';
import 'VerificacionC.dart';
import 'dart:ui' as ui;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberPassword = false;
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF890cac);
  static const Color whiteColor = Colors.white;

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.login(
        email: _emailController.text,
        password: _passwordController.text, // Changed from 'contrasena' to 'password'
      );

      if (_rememberPassword) {
        // Guardar credenciales seguras
      }

      if (response['status'] == 'success') {
        // Navegar a la pantalla principal
      }

      _showMessage(context, response['message']);
    } catch (e) {
      _showMessage(context, 'Error de conexión: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Expanded(
          child: Text(
            'Inicio de sesión',
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

  Widget _buildRememberPasswordOption() {
    return SizedBox(
      width: 320,
      child: Row(
        children: [
          Theme(
            data: ThemeData(
              checkboxTheme: CheckboxThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                fillColor: WidgetStateProperty.resolveWith<Color>((states) {  // Changed from WidgetStateProperty to MaterialStateProperty
                  if (states.contains(WidgetState.selected)) {  // Changed from WidgetState to MaterialState
                    return Colors.blue;
                  }
                  return whiteColor;
                }),
                checkColor: WidgetStateProperty.all(whiteColor),  // Changed from WidgetStateProperty to MaterialStateProperty
              ),
            ),
            child: Checkbox(
              value: _rememberPassword,
              onChanged: (bool? value) {
                setState(() {
                  _rememberPassword = value ?? false;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Recordar contraseña',
            style: TextStyle(
              color: whiteColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: whiteColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _iniciarSesion(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          child: const Text(
            'Iniciar sesión',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterOption() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      },
      child: const Text.rich(
        TextSpan(
          text: '¿No tienes una cuenta? ',
          style: TextStyle(color: whiteColor),
          children: [
            TextSpan(
              text: 'Regístrate',
              style: TextStyle(
                color: whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordOption() {
    return GestureDetector(
      onTap: () {
        final email = _emailController.text.trim();
        if (email.isEmpty || !email.contains('@')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, ingresa un email válido para recuperar tu contraseña')),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificacionCodigo(
                email: email,
              ),
            ),
          );
        }
      },
      child: const Text.rich(
        TextSpan(
          text: '¿Olvidaste tu contraseña? ',
          style: TextStyle(color: whiteColor),
          children: [
            TextSpan(
              text: 'Recupérala',
              style: TextStyle(
                color: whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            _buildHeader(),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _emailController,
                              labelText: 'Correo electrónico',
                              validator: (value) =>
                              value == null || value.isEmpty
                                  ? 'Por favor, ingresa tu email'
                                  : !value.contains('@')
                                  ? 'Ingresa un email válido'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _passwordController,
                              labelText: 'Contraseña',
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: whiteColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) =>
                              value == null || value.isEmpty
                                  ? 'Por favor, ingresa tu contraseña'
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            _buildRememberPasswordOption(),
                            const SizedBox(height: 20),
                            _buildLoginButton(context),
                            const SizedBox(height: 20),
                            _buildRegisterOption(),
                            const SizedBox(height: 20),
                            _buildForgotPasswordOption(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}