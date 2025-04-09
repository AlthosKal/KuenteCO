import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kuenteco/infrastructure/repositories/Auth_repository.dart';
import 'package:kuenteco/presentation/widgets/Auth_form_field.dart';
import 'package:kuenteco/presentation/widgets/Particle_animation_widget.dart';
import 'package:kuenteco/presentation/pages/auth/Register_view.dart';
import 'package:kuenteco/presentation/pages/auth/Recovery_password_view.dart';
import 'package:kuenteco/presentation/pages/home/Logged_home_view.dart';
import 'dart:ui' as ui;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _nameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = Provider.of<AuthRepository>(context, listen: false);

      /// Ejecuta login y guarda token internamente
      await authRepo.login(
        nameOrEmail: _nameOrEmailController.text,
        password: _passwordController.text,
      );

      /// Forzar carga del token a memoria para uso inmediato
      await authRepo.checkAuth(); // 🔐 clave para que _authToken esté seteado

      if (!mounted) return;

      /// Redirige a la pantalla principal
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoggedInHomePage(
            title: 'Inicio',
            userEmail: _nameOrEmailController.text.contains('@')
                ? _nameOrEmailController.text
                : null,
            authRepository: authRepo,
          ),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de inicio de sesión: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ParticleAnimation()),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildLoginForm(theme, isSmallScreen),
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme, bool isSmallScreen) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: isSmallScreen ? 360.0 : 400.0,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.2),
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
                _buildHeader(),
                const SizedBox(height: 20),
                _buildNameOrEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                _buildRememberMeCheckbox(),
                const SizedBox(height: 20),
                _buildLoginButton(theme),
                const SizedBox(height: 20),
                _buildRegisterOption(),
                const SizedBox(height: 20),
                _buildForgotPasswordOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Expanded(
          child: Text(
            'Inicio de sesión',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 48), // Balancear el espacio del back button
      ],
    );
  }

  Widget _buildNameOrEmailField() {
    return AuthFormField(
      controller: _nameOrEmailController,
      label: 'Correo electrónico o nombre de usuario',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa tu email o nombre de usuario';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return AuthFormField(
      controller: _passwordController,
      label: 'Contraseña',
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility : Icons.visibility_off,
          color: Colors.white,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
        if (value.length < 6) return 'Mínimo 6 caracteres';
        return null;
      },
    );
  }

  Widget _buildRememberMeCheckbox() {
    return SizedBox(
      width: 320,
      child: Row(
        children: [
          Checkbox(
            value: _rememberPassword,
            onChanged: (value) => setState(() => _rememberPassword = value ?? false),
            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).primaryColor;
              }
              return Colors.transparent;
            }),
          ),
          const SizedBox(width: 8),
          const Text(
            'Recordar contraseña',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _handleLogin(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
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
        'Iniciar sesión',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRegisterOption() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterPage()),
      ),
      child: const Text.rich(
        TextSpan(
          text: '¿No tienes una cuenta? ',
          style: TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: 'Regístrate',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordOption() {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PasswordRecoveryScreen()),
      ),
      child: const Text.rich(
        TextSpan(
          text: '¿Olvidaste tu contraseña? ',
          style: TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: 'Recupérala',
              style: TextStyle(fontWeight: FontWeight.bold),
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