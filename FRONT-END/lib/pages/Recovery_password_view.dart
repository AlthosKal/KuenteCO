import 'package:flutter/material.dart';
import 'package:kuenteco/services/Api_service.dart';
import 'package:kuenteco/widgets/Particle_animation_widget.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'Login_view.dart';

// Shared constants and utilities
class AuthConstants {
  static const Color primaryColor = Color(0xFF890cac);
  static const Color whiteColor = Colors.white;
  static const int codeExpirationSeconds = 120;
  static const int minPasswordLength = 6;
  static const String emailRegex = r'^[^@]+@[^@]+\.[^@]+';
  static const String recoveryTitle = 'Recuperar Contraseña';
  static const String sendCodeButton = 'Enviar Código';
}

class AuthUtils {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  static Widget buildBlurredContainer({
    required Widget child,
    required double width,
    bool withPadding = true,
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: width,
          padding: withPadding ? const EdgeInsets.all(20.0) : null,
          decoration: BoxDecoration(
            color: AuthConstants.whiteColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: AuthConstants.primaryColor.withOpacity(0.2),
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
}

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;
  int _timerCount = AuthConstants.codeExpirationSeconds;
  late Timer _timer;
  bool _obscureNewPassword = true;
  String? _email;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focus in _focusNodes) {
      focus.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer(Timer timer) {
    if (_timerCount > 0) {
      setState(() => _timerCount--);
    } else {
      _timer.cancel();
    }
  }

  void _resetTimer() {
    _timerCount = AuthConstants.codeExpirationSeconds;
    _startTimer();
  }

  String _formatTime() {
    final minutes = _timerCount ~/ 60;
    final seconds = _timerCount % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _sendVerificationCode() async {
    if (_emailController.text.isEmpty || !RegExp(AuthConstants.emailRegex).hasMatch(_emailController.text)) {
      AuthUtils.showSnackBar(context, 'Por favor ingresa un correo electrónico válido', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.sendVerificationCode(
        email: _emailController.text,
        isRegistration: false,
      );

      AuthUtils.showSnackBar(context, response['message'] ?? 'Código enviado con éxito');

      if (response['status'] == 'success') {
        setState(() {
          _email = _emailController.text;
          _currentStep = 1;
          _resetTimer();
        });
      }
    } catch (e) {
      AuthUtils.showSnackBar(context, 'Error al enviar el código: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length != 6) {
      AuthUtils.showSnackBar(context, 'Por favor ingresa el código completo', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.validateVerificationCode(
        email: _email!,
        code: code,
      );

      if (response['status'] == 'success') {
        setState(() => _currentStep = 2);
      } else {
        AuthUtils.showSnackBar(context, response['message'] ?? 'Código inválido', isError: true);
      }
    } catch (e) {
      AuthUtils.showSnackBar(context, 'Error de verificación: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      AuthUtils.showSnackBar(context, 'Las contraseñas no coinciden', isError: true);
      return;
    }

    if (_newPasswordController.text.length < AuthConstants.minPasswordLength) {
      AuthUtils.showSnackBar(
        context,
        'La contraseña debe tener al menos ${AuthConstants.minPasswordLength} caracteres',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final code = _codeControllers.map((c) => c.text).join();
      final response = await _apiService.changePassword(
        email: _email!,
        code: code,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
      );

      AuthUtils.showSnackBar(context, response['message'] ?? 'Contraseña cambiada con éxito');

      if (response['status'] == 'success') {
        AuthUtils.navigateToLogin(context);
      }
    } catch (e) {
      AuthUtils.showSnackBar(context, 'Error al cambiar contraseña: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    if (_timerCount > 0) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.sendVerificationCode(
        email: _email!,
        isRegistration: false,
      );

      AuthUtils.showSnackBar(context, response['message'] ?? 'Código reenviado');
      _resetTimer();
    } catch (e) {
      AuthUtils.showSnackBar(context, 'Error al reenviar código: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onCodeFieldChange(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
        const Text(
          'Ingresa tu correo electrónico para recibir un código de verificación',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AuthConstants.whiteColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 320,
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: AuthConstants.whiteColor,
            style: const TextStyle(color: AuthConstants.whiteColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Correo electrónico',
              labelStyle: const TextStyle(color: AuthConstants.whiteColor),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AuthConstants.whiteColor),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buildActionButton(
          onPressed: _sendVerificationCode,
          text: AuthConstants.sendCodeButton,
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      children: [
        Text(
          'Ingresa el código de 6 dígitos enviado a:',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AuthConstants.whiteColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _email!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AuthConstants.whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        _buildCodeInputFields(),
        const SizedBox(height: 20),
        _buildTimerText(),
        const SizedBox(height: 10),
        _buildResendCodeButton(),
        const SizedBox(height: 30),
        _buildActionButton(
          onPressed: _verifyCode,
          text: 'Verificar Código',
        ),
      ],
    );
  }

  Widget _buildCodeInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
            (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: SizedBox(
            width: 40,
            child: TextFormField(
              controller: _codeControllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              cursorColor: AuthConstants.whiteColor,
              style: const TextStyle(color: AuthConstants.whiteColor, fontSize: 22),
              decoration: const InputDecoration(
                counterText: '',
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AuthConstants.whiteColor, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AuthConstants.whiteColor, width: 2),
                ),
              ),
              onChanged: (value) => _onCodeFieldChange(value, index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Código válido por: ',
          style: TextStyle(
            color: AuthConstants.whiteColor,
            fontSize: 14,
          ),
        ),
        Text(
          _formatTime(),
          style: TextStyle(
            color: AuthConstants.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildResendCodeButton() {
    return TextButton(
      onPressed: _timerCount == 0 ? _resendCode : null,
      child: Text(
        'Reenviar código',
        style: TextStyle(
          color: _timerCount == 0
              ? AuthConstants.whiteColor
              : AuthConstants.whiteColor.withOpacity(0.5),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      children: [
        const Text(
          'Ingresa tu nueva contraseña',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AuthConstants.whiteColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
        _buildPasswordField(
          controller: _newPasswordController,
          label: 'Nueva contraseña',
          obscureText: _obscureNewPassword,
          toggleVisibility: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
        ),
        const SizedBox(height: 20),
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: 'Confirmar contraseña',
          obscureText: true,
        ),
        const SizedBox(height: 30),
        _buildActionButton(
          onPressed: _changePassword,
          text: 'Cambiar Contraseña',
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    VoidCallback? toggleVisibility,
  }) {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: AuthConstants.whiteColor,
        style: const TextStyle(color: AuthConstants.whiteColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(color: AuthConstants.whiteColor),
          suffixIcon: toggleVisibility != null
              ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: AuthConstants.whiteColor,
            ),
            onPressed: toggleVisibility,
          )
              : null,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AuthConstants.whiteColor),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
  }) {
    return SizedBox(
      width: double.infinity,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AuthConstants.whiteColor))
          : ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthConstants.whiteColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
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
                child: AuthUtils.buildBlurredContainer(
                  width: containerWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildCurrentStep(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AuthConstants.whiteColor),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        const Expanded(
          child: Text(
            AuthConstants.recoveryTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AuthConstants.whiteColor,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildCodeStep();
      case 2:
        return _buildPasswordStep();
      default:
        return const SizedBox();
    }
  }
}