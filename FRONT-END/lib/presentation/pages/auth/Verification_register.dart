import 'package:flutter/material.dart';
import 'package:kuenteco/infrastructure/datasources/remote/Auth_api_service.dart';
import 'package:kuenteco/presentation/widgets/Particle_animation_widget.dart';
import 'package:kuenteco/presentation/pages/auth/Login_view.dart';
import 'dart:ui' as ui;
import 'dart:async';

class VerificacionR extends StatefulWidget {
  final String email;

  const VerificacionR({
    super.key,
    required this.email,
  });

  @override
  State<VerificacionR> createState() => _VerificacionRState();
}

class _VerificacionRState extends State<VerificacionR> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _remainingTime = 120; // 2 minutos en segundos
  late Timer _timer;

  final AuthApiService _authApiService = AuthApiService();
  final Color _whiteColor = Colors.white;
  final Color _primaryColor = const Color(0xFF890cac);

  @override
  void initState() {
    super.initState();
    _startTimer();
    _showCodeSentSnackbar();
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focus in _focusNodes) {
      focus.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  void _showCodeSentSnackbar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Código enviado a ${widget.email}'),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  String _formatTime() {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _resendCode() async {
    if (_isResending || _remainingTime > 0) return;

    setState(() => _isResending = true);

    try {
      final response = await _authApiService.sendVerificationCode(
        email: widget.email,
        isRegistration: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Código reenviado')),
      );

      setState(() {
        _remainingTime = 120;
        _isResending = false;
      });
      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reenviar código: $e')),
      );
      setState(() => _isResending = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código completo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Verificar el código
      final verificationResponse = await _authApiService.ValidateVerificationCode(
        email: widget.email,
        code: code,
      );

      if (verificationResponse['status'] == 'success') {
        // 2. Activar la cuenta
        final activationResponse = await _authApiService.activateAccount(
          email: widget.email,
          code: code,
        );

        if (activationResponse['status'] == 'success') {
          _navigateToLogin();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cuenta activada exitosamente')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(verificationResponse['message'] ?? 'Código inválido')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de verificación: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false,
    );
  }

  void _onFieldChange(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (index == 5 && value.isNotEmpty) {
      _verifyCode();
    }
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
                      _buildInstructions(),
                      const SizedBox(height: 30),
                      _buildCodeInputFields(),
                      const SizedBox(height: 20),
                      _buildTimerSection(),
                      const SizedBox(height: 30),
                      _buildVerifyButton(),
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
            color: _whiteColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.2),
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
            'Verificar Registro',
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

  Widget _buildInstructions() {
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
          widget.email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              cursorColor: _whiteColor,
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
              onChanged: (value) => _onFieldChange(value, index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    return Column(
      children: [
        Row(
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
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _remainingTime == 0 ? _resendCode : null,
          child: _isResending
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(
            'Reenviar código',
            style: TextStyle(
              color: _remainingTime == 0
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: _whiteColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _isLoading ? null : _verifyCode,
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
            'VERIFICAR REGISTRO',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
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