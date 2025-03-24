import 'package:flutter/material.dart';
import 'package:kuenteco/services/ApiService.dart';
import 'package:kuenteco/widgets/ParticleAnimation.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'CambioC.dart';

class VerificacionCodigo extends StatefulWidget {
  final String email;

  const VerificacionCodigo({
    super.key,
    required this.email,
  });

  @override
  State<VerificacionCodigo> createState() => _VerificacionCodigoState();
}

class _VerificacionCodigoState extends State<VerificacionCodigo> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _tiempoRestante = 120; // 2 minutos en segundos
  late Timer _timer;

  final ApiService _apiService = ApiService();

  static const Color primaryColor = Color(0xFF890cac);
  static const Color whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _iniciarTemporizador();
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
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.solicitarCodigoVerificacion(email: widget.email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Código enviado con éxito')),
      );

      setState(() => _tiempoRestante = 120);
      _iniciarTemporizador();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el código: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enviarCodigoAlBackend() async {
    setState(() => _isLoading = true);

    final code = _controllers.map((controller) => controller.text).join();

    try {
      final response = await _apiService.validarCodigoVerificacion(
        email: widget.email,
        code: code,
      );

      if (response['status'] == 'success') {
        final String? tokenRecuperacion = response['data']?['token'];

        // Navegar a la pantalla de cambio de contraseña
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CambioC(
              token: tokenRecuperacion,
              email: widget.email,
            ),
          ),
        );
      } else {
        // Mostrar mensaje de error si el código no es válido
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Código inválido')),
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
                                  'Verificación de Código',
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
                            child: Text(
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
                              onTap: _enviarCodigoAlBackend,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                child: const Text(
                                  'Verificar Código',
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