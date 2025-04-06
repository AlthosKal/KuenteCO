import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kuenteco/infrastructure/datasources/remote/Auth_api_service.dart';
import 'package:kuenteco/presentation/widgets/Particle_animation_widget.dart';
import 'package:kuenteco/presentation/pages/auth/Login_view.dart';
import 'dart:ui' as ui;
import 'dart:async';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final AuthApiService _authApiService = AuthApiService();
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _codeControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;
  int _timerCount = 120; // 2 minutos en segundos
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
    _timerCount = 120;
    _startTimer();
  }

  String _formatTime() {
    final minutes = _timerCount ~/ 60;
    final seconds = _timerCount % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _sendVerificationCode() async {
    if (_emailController.text.isEmpty ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
      _showErrorSnackBar('Por favor ingresa un correo electrónico válido');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authApiService.sendVerificationCode(
        email: _emailController.text,
        isRegistration: false,
      );

      _showSuccessSnackBar(response['message'] ?? 'Código enviado con éxito');

      if (response['status'] == 'success') {
        setState(() {
          _email = _emailController.text;
          _currentStep = 1;
          _resetTimer();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al enviar el código: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length != 6) {
      _showErrorSnackBar('Por favor ingresa el código completo');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authApiService.ValidateVerificationCode(
        email: _email!,
        code: code,
      );

      if (response['status'] == 'success') {
        setState(() => _currentStep = 2);
      } else {
        _showErrorSnackBar(response['message'] ?? 'Código inválido');
      }
    } catch (e) {
      _showErrorSnackBar('Error de verificación: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Las contraseñas no coinciden');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showErrorSnackBar('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final code = _codeControllers.map((c) => c.text).join();
      final response = await _authApiService.changePassword(
        email: _email!,
        code: code,
        newPassword: _newPasswordController.text,
      );

      _showSuccessSnackBar(response['message'] ?? 'Contraseña cambiada con éxito');

      if (response['status'] == 'success') {
        _navigateToLogin();
      }
    } catch (e) {
      _showErrorSnackBar('Error al cambiar contraseña: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    if (_timerCount > 0) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authApiService.sendVerificationCode(
        email: _email!,
        isRegistration: false,
      );

      _showSuccessSnackBar(response['message'] ?? 'Código reenviado');
      _resetTimer();
    } catch (e) {
      _showErrorSnackBar('Error al reenviar código: $e');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
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
                child: _buildBlurredContainer(
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
            'Recuperar Contraseña',
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

  Widget _buildEmailStep() {
    return Column(
      children: [
        const Text(
          'Ingresa tu correo electrónico para recibir un código de verificación',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
        _buildTextField(
          controller: _emailController,
          label: 'Correo electrónico',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 30),
        _buildActionButton(
          onPressed: _sendVerificationCode,
          text: 'Enviar Código',
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      children: [
        const Text(
          'Ingresa el código de 6 dígitos enviado a:',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _email!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
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

  Widget _buildPasswordStep() {
    return Column(
      children: [
        const Text(
          'Ingresa tu nueva contraseña',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
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
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white, fontSize: 22),
              decoration: const InputDecoration(
                counterText: '',
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2),
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
        const Text(
          'Código válido por: ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        Text(
          _formatTime(),
          style: const TextStyle(
            color: Colors.white,
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
          color: _timerCount == 0 ? Colors.white : Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
        ),
      ),
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
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          suffixIcon: toggleVisibility != null
              ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: toggleVisibility,
          )
              : null,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
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
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(
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