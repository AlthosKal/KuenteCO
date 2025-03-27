import 'package:flutter/material.dart';
import 'package:kuenteco/services/ApiService.dart';
import 'package:kuenteco/widgets/ParticleAnimation.dart';
import 'package:kuenteco/pages/Login.dart';
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
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _tiempoRestante = 120;
  late Timer _timer;

  final ApiService _apiService = ApiService();

  static const Color primaryColor = Color(0xFF890cac);
  static const Color whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _iniciarTemporizador();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Código enviado a ${widget.email}'),
          duration: const Duration(seconds: 3),
        ),
      );
    });
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

  void _iniciarTemporizador() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_tiempoRestante > 0) {
          _tiempoRestante--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  String _formatoTiempo() {
    int minutos = _tiempoRestante ~/ 60;
    int segundos = _tiempoRestante % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  Future<void> _reenviarCodigo() async {
    if (_isResending) return;
    setState(() => _isResending = true);

    try {
      final response = await _apiService.sendVerificationCode( // Changed from solicitarCodigoVerificacion
        email: widget.email,
        isRegistration: true, // Set to true for registration flow
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Código reenviado')),
      );

      setState(() {
        _tiempoRestante = 120;
        _isResending = false;
      });
      _iniciarTemporizador();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el código: $e')),
      );
      setState(() => _isResending = false);
    }
  }

  Future<void> _verificarCodigo() async {
    final code = _controllers.map((controller) => controller.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código completo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Validar el código primero
      final validationResponse = await _apiService.validateVerificationCode(
        email: widget.email,
        code: code,
      );

      if (validationResponse['status'] == 'success') {
        // 2. Activar la cuenta
        final activationResponse = await _apiService.activateAccount(
          email: widget.email,
          code: code,
        );

        if (activationResponse['status'] == 'success') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cuenta activada exitosamente')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationResponse['message'] ?? 'Código inválido')),
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

  void _onFieldChange(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (index == 5 && value.isNotEmpty) {
      _verificarCodigo();
    }
  }

  Widget _buildCodeField(int index) {
    return SizedBox(
      width: 40,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        cursorColor: whiteColor,
        style: const TextStyle(color: whiteColor, fontSize: 22),
        decoration: const InputDecoration(
          counterText: '',
          border: UnderlineInputBorder(),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: whiteColor, width: 2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: whiteColor, width: 2),
          ),
        ),
        onChanged: (value) => _onFieldChange(value, index),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: whiteColor),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const Expanded(
                                child: Text(
                                  'Verificar Registro',
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
                          Text(
                            'Ingresa el código de 6 dígitos enviado a:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.email,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              6,
                                  (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: _buildCodeField(index),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Código válido por: ',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _formatoTiempo(),
                                style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _tiempoRestante == 0 ? _reenviarCodigo : null,
                            child: _isResending
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: whiteColor,
                              ),
                            )
                                : Text(
                              'Reenviar código',
                              style: TextStyle(
                                color: _tiempoRestante == 0 ? whiteColor : whiteColor.withOpacity(0.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _isLoading
                              ? const CircularProgressIndicator(color: whiteColor)
                              : Material(
                            borderRadius: BorderRadius.circular(8),
                            color: whiteColor,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: _verificarCodigo,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                child: const Text(
                                  'VERIFICAR REGISTRO',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
        ],
      ),
    );
  }
}