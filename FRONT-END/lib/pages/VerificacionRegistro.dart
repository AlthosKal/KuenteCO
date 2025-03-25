import 'package:flutter/material.dart';
import 'package:kuenteco/services/ApiService.dart';
import 'package:kuenteco/widgets/ParticleAnimation.dart';
import 'package:kuenteco/pages/Login.dart';
import 'dart:ui' as ui;
import 'dart:async';

class VerificacionRegistro extends StatefulWidget {
  final String email;

  const VerificacionRegistro({
    super.key,
    required this.email,
  });

  @override
  State<VerificacionRegistro> createState() => _VerificacionRegistroState();
}

class _VerificacionRegistroState extends State<VerificacionRegistro> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isResending = false;
  int _tiempoRestante = 120;
  late Timer _timer;

  static const Color primaryColor = Color(0xFF890cac);
  static const Color whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tiempoRestante > 0) {
        setState(() => _tiempoRestante--);
      } else {
        _timer.cancel();
      }
    });
  }

  String _formatTime() {
    final minutes = (_tiempoRestante ~/ 60).toString().padLeft(2, '0');
    final seconds = (_tiempoRestante % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _resendCode() async {
    if (_isResending) return;
    setState(() => _isResending = true);

    try {
      final response = await _apiService.solicitarCodigoVerificacion(
        email: widget.email,
        isRegistration: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Código reenviado')),
      );

      setState(() {
        _tiempoRestante = 120;
        _isResending = false;
      });
      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
      final response = await _apiService.validarCodigoRegistro(
        email: widget.email,
        code: code,
      );

      if (response['status'] == 'success') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro completado exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Código inválido')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
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
        style: const TextStyle(color: whiteColor, fontSize: 20),
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: whiteColor.withOpacity(0.7)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: whiteColor, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (index == 5 && value.isNotEmpty) {
            _verifyCode();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
        const Positioned.fill(child: ParticleAnimation()),
    Center(
    child: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: BackdropFilter(
    filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    child: Container(
    width: MediaQuery.of(context).size.width > 600 ? 400 : 360,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
    color: whiteColor.withOpacity(0.2),
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: whiteColor.withOpacity(0.3)),
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    Align(
    alignment: Alignment.topLeft,
    child: IconButton(
    icon: const Icon(Icons.arrow_back, color: whiteColor),
    onPressed: () => Navigator.pop(context),
    ),
    ),
    const Text(
    'Verificar Registro',
    style: TextStyle(
    color: whiteColor,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 20),
    Text(
    'Ingresa el código enviado a:',
    style: TextStyle(
    color: whiteColor.withOpacity(0.9),
    fontSize: 16,
    ),
    ),
    const SizedBox(height: 5),
    Text(
    widget.email,
    style: const TextStyle(
    color: whiteColor,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 30),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(6, (index) =>
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: _buildCodeField(index),
    ),
    ),
    ),
    const SizedBox(height: 30),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    'Tiempo restante: ',
    style: TextStyle(color: whiteColor.withOpacity(0.8)),
    ),
    Text(
    _formatTime(),
    style: const TextStyle(
    color: whiteColor,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    const SizedBox(height: 20),
    TextButton(
    onPressed: _tiempoRestante == 0 ? _resendCode : null,
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
    color: _tiempoRestante == 0
    ? whiteColor
        : whiteColor.withOpacity(0.5),
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    const SizedBox(height: 20),
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: _isLoading ? null : _verifyCode,
    style: ElevatedButton.styleFrom(
    backgroundColor: whiteColor,
    padding: const EdgeInsets.symmetric(vertical: 15),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8)),
    ),
    ),
    child: _isLoading
    ? const CircularProgressIndicator(color: primaryColor)
        : const Text(
    'VERIFICAR REGISTRO',
    style: TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.bold,
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
    ],
    ),
    );
  }
}