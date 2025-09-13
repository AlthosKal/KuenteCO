import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../../../controllers/auth/recaptcha_controller.dart';
import 'dart:async';
import 'recaptcha_web_factory.dart';

class RecaptchaWidget extends StatefulWidget {
  final RecaptchaController controller;
  final VoidCallback? onVerified;
  final VoidCallback? onError;

  const RecaptchaWidget({
    super.key,
    required this.controller,
    this.onVerified,
    this.onError,
  });

  @override
  State<RecaptchaWidget> createState() => _RecaptchaWidgetState();
}

class _RecaptchaWidgetState extends State<RecaptchaWidget> {
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.controller.isVerified,
      builder: (context, isVerified, _) {
        return GestureDetector(
          onTap: isVerified ? null : () => _showRecaptchaBottomSheet(context),
          child: Container(
            width: 304,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Contenido principal del reCAPTCHA
                  Row(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.controller.isLoading,
                        builder: (context, isLoading, _) {
                          return Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: isVerified ? Colors.green : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: isLoading
                                ? Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.purple,
                                    ),
                                  )
                                : isVerified
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 14,
                                      )
                                    : null,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isVerified ? 'Verificado' : "I'm not a robot",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Logo circular de reCAPTCHA
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.refresh,
                          color: isVerified ? Colors.green : Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  // Footer con logo de reCAPTCHA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo de reCAPTCHA
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(1),
                              ),
                              child: const Center(
                                child: Text(
                                  'r',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 6,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'reCAPTCHA',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Enlaces
                      Row(
                        children: [
                          Text(
                            'Privacy',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 8,
                            ),
                          ),
                          Text(
                            ' - ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 8,
                            ),
                          ),
                          Text(
                            'Terms',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRecaptchaBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header del modal
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.purple),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Verificación reCAPTCHA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Contenido del reCAPTCHA
              Expanded(
                child: kIsWeb 
                    ? _buildWebRecaptcha() 
                    : _buildMobileWebView(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWebRecaptcha() {
    return createRecaptchaWebElementWrapper(
      controller: widget.controller,
      onVerified: () {
        Navigator.pop(context);
        widget.onVerified?.call();
      },
      onError: () {
        widget.onError?.call();
      },
    );
  }

  Widget _buildMobileWebView() {
    return RecaptchaWebView(
      controller: widget.controller,
      onVerified: () {
        Navigator.pop(context);
        widget.onVerified?.call();
      },
      onError: () {
        widget.onError?.call();
      },
    );
  }
}

/// Widget para móvil usando WebView tradicional
class RecaptchaWebView extends StatefulWidget {
  final RecaptchaController controller;
  final VoidCallback? onVerified;
  final VoidCallback? onError;

  const RecaptchaWebView({
    super.key,
    required this.controller,
    this.onVerified,
    this.onError,
  });

  @override
  State<RecaptchaWebView> createState() => _RecaptchaWebViewState();
}

class _RecaptchaWebViewState extends State<RecaptchaWebView> {
  WebViewController? _webViewController;
  bool _isPageLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'RecaptchaChannel',
        onMessageReceived: _handleJavaScriptMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isPageLoaded = true;
            });
          },
        ),
      )
      ..loadFlutterAsset('assets/recaptcha.html');
  }

  void _handleJavaScriptMessage(JavaScriptMessage message) async {
    try {
      final data = json.decode(message.message);
      final status = data['status'] as String;

      switch (status) {
        case 'success':
          final token = data['token'] as String;
          await _verifyToken(token);
          break;
        case 'expired':
          _showMessage('⏰ reCAPTCHA expirado. Por favor intenta nuevamente.', Colors.orange);
          widget.onError?.call();
          break;
        case 'error':
          final errorMessage = data['message'] as String? ?? 'Error en reCAPTCHA';
          _showMessage('❌ $errorMessage', Colors.red);
          widget.onError?.call();
          break;
      }
    } catch (e) {
      _showMessage('❌ Error procesando respuesta de reCAPTCHA', Colors.red);
      widget.onError?.call();
    }
  }

  Future<void> _verifyToken(String token) async {
    if (!mounted) return;

    try {
      widget.controller.isLoading.value = true;
      final verified = await widget.controller.verifyToken(token);

      if (verified && mounted) {
        _showMessage('✅ reCAPTCHA verificado correctamente', Colors.green);
        widget.onVerified?.call();
      } else if (mounted) {
        _showMessage('❌ Error verificando reCAPTCHA con el servidor', Colors.red);
        widget.onError?.call();
      }
    } catch (error) {
      if (mounted) {
        _showMessage('❌ Error en reCAPTCHA: $error', Colors.red);
        widget.onError?.call();
      }
    } finally {
      if (mounted) {
        widget.controller.isLoading.value = false;
      }
    }
  }

  void _showMessage(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_webViewController != null)
          WebViewWidget(controller: _webViewController!),
        if (!_isPageLoaded)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.purple),
                SizedBox(height: 16),
                Text(
                  'Cargando reCAPTCHA...',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ValueListenableBuilder<bool>(
          valueListenable: widget.controller.isLoading,
          builder: (context, isLoading, _) {
            return isLoading
                ? Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.purple),
                          SizedBox(height: 16),
                          Text(
                            'Verificando reCAPTCHA...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}