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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  bool _obscurePassword = true;
  bool _rememberPassword = false;
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF890cac);
  static const Color whiteColor = Colors.white;

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
        password: _passwordController.text,
      );

      if (_rememberPassword) {
        // Guardar credenciales (implementar con shared_preferences)
      }

      if (response['status'] == 'success') {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage(context, response['message'] ?? 'Error en el inicio de sesión');
      }
    } catch (e) {
      _showMessage(context, 'Error de conexión: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enviarCodigoRecuperacion() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showMessage(context, 'Ingresa un email válido para recuperar tu contraseña');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.sendRecoveryCode(email: email);

      if (response['status'] == 'success') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificacionCodigo(email: email),
          ),
        );
      } else {
        _showMessage(context, response['message'] ?? 'Error al enviar el código');
      }
    } catch (e) {
      _showMessage(context, 'Error de conexión: ${e.toString()}');
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
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
                          children: [
                            // Header
                            Row(
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
                            ),
                            const SizedBox(height: 20),

                            // Email Field
                            _buildTextField(
                              controller: _emailController,
                              labelText: 'Correo electrónico',
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Por favor, ingresa tu email'
                                  : !value.contains('@')
                                  ? 'Ingresa un email válido'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            _buildTextField(
                              controller: _passwordController,
                              labelText: 'Contraseña',
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: whiteColor,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Por favor, ingresa tu contraseña'
                                  : null,
                            ),
                            const SizedBox(height: 10),

                            // Remember Password
                            SizedBox(
                              width: 320,
                              child: Row(
                                children: [
                                  Theme(
                                    data: ThemeData(
                                      checkboxTheme: CheckboxThemeData(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        side: BorderSide(color: whiteColor),
                                        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                                          if (states.contains(MaterialState.selected)) {
                                            return primaryColor;
                                          }
                                          return Colors.transparent;
                                        }),
                                        checkColor: MaterialStateProperty.all(whiteColor),
                                      ),
                                    ),
                                    child: Checkbox(
                                      value: _rememberPassword,
                                      onChanged: (bool? value) => setState(() => _rememberPassword = value ?? false),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Recordar contraseña',
                                    style: TextStyle(color: whiteColor, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Login Button
                            Material(
                              borderRadius: BorderRadius.circular(8),
                              color: whiteColor,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: _isLoading ? null : () => _iniciarSesion(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                      : const Text(
                                    'Iniciar sesión',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Register Option
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              ),
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
                            ),
                            const SizedBox(height: 20),

                            // Forgot Password
                            GestureDetector(
                              onTap: _isLoading ? null : _enviarCodigoRecuperacion,
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading Overlay
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