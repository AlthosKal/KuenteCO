// Implementación específica para Flutter Web
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../controllers/auth/recaptcha_controller.dart';

Widget createRecaptchaWebElement({
  required RecaptchaController controller,
  VoidCallback? onVerified,
  VoidCallback? onError,
}) {
  return RecaptchaWebElement(
    controller: controller,
    onVerified: onVerified,
    onError: onError,
  );
}

/// Widget para Flutter Web usando HtmlElementView
class RecaptchaWebElement extends StatefulWidget {
  final RecaptchaController controller;
  final VoidCallback? onVerified;
  final VoidCallback? onError;

  const RecaptchaWebElement({
    super.key,
    required this.controller,
    this.onVerified,
    this.onError,
  });

  @override
  State<RecaptchaWebElement> createState() => _RecaptchaWebElementState();
}

class _RecaptchaWebElementState extends State<RecaptchaWebElement> {
  late String viewType;
  bool _isLoaded = false;
  
  @override
  void initState() {
    super.initState();
    viewType = 'recaptcha-${DateTime.now().millisecondsSinceEpoch}';
    _registerView();
    _loadRecaptchaScript();
    
    // Timeout de seguridad para evitar carga infinita
    Timer(const Duration(seconds: 15), () {
      if (!_isLoaded && mounted) {
        print('⚠️ Timeout: Forzando fin de carga después de 15 segundos');
        setState(() {
          _isLoaded = true;
        });
      }
    });
  }

  void _registerView() {
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final div = html.DivElement()
          ..id = viewType
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.flexDirection = 'column'
          ..style.justifyContent = 'center'
          ..style.alignItems = 'center'
          ..style.backgroundColor = '#f5f5f5';

        // Configurar callbacks globales con nombres únicos
        final successCallback = 'onRecaptchaSuccess_$viewType';
        final expiredCallback = 'onRecaptchaExpired_$viewType';
        final errorCallback = 'onRecaptchaError_$viewType';
        
        print('🔧 Configurando callbacks: $successCallback, $expiredCallback, $errorCallback');
        
        js.context[successCallback] = js.allowInterop((String token) {
          print('✅ Callback de éxito llamado con token: ${token.substring(0, 20)}...');
          _handleRecaptchaSuccess(token);
        });

        js.context[expiredCallback] = js.allowInterop(() {
          print('⏰ Callback de expiración llamado');
          _handleRecaptchaExpired();
        });

        js.context[errorCallback] = js.allowInterop(() {
          print('❌ Callback de error llamado');
          _handleRecaptchaError();
        });

        // Crear el contenido del reCAPTCHA cuando el script esté listo
        var attempts = 0;
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
          attempts++;
          print('🔍 Intento $attempts - Verificando grecaptcha...');
          
          // Diagnosticar qué está disponible en js.context
          if (attempts == 1) {
            print('🔍 Diagnóstico: Verificando entorno JavaScript');
            print('📋 grecaptcha disponible: ${js.context.hasProperty('grecaptcha')}');
          }
          
          if (js.context.hasProperty('grecaptcha')) {
            print('✅ grecaptcha encontrado!');
            timer.cancel();
            
            // Verificar que grecaptcha.render esté disponible
            final hasRender = js.context['grecaptcha'] != null && 
                             js.context.callMethod('eval', ['typeof grecaptcha.render === "function"']);
            print('🔧 grecaptcha.render disponible: $hasRender');
            
            _renderRecaptcha(div);
          } else if (attempts > 30) {
            print('❌ Timeout: grecaptcha no se cargó después de 15 segundos');
            print('🔍 Estado final del script:');
            final scripts = html.document.querySelectorAll('script[src*="recaptcha"]');
            print('📄 Scripts de reCAPTCHA en DOM: ${scripts.length}');
            timer.cancel();
            if (mounted) {
              _handleRecaptchaError();
            }
          } else {
            print('⏳ grecaptcha aún no está disponible...');
          }
        });

        return div;
      },
    );
  }

  void _loadRecaptchaScript() {
    print('🔄 Cargando script de reCAPTCHA...');
    
    // Verificar si grecaptcha ya está disponible
    if (js.context.hasProperty('grecaptcha')) {
      print('✅ grecaptcha ya está disponible');
      return;
    }
    
    // Remover script existente que pueda estar corrupto
    final existingScript = html.document.querySelector('script[src*="recaptcha"]');
    if (existingScript != null) {
      print('🗑️ Removiendo script existente de reCAPTCHA');
      existingScript.remove();
    }
    
    // Cargar script fresco
    final script = html.ScriptElement()
      ..src = 'https://www.google.com/recaptcha/api.js?render=explicit'
      ..async = true
      ..defer = true;
    
    script.onLoad.listen((_) {
      print('✅ Script de reCAPTCHA cargado exitosamente');
      // Verificar que grecaptcha esté disponible
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (js.context.hasProperty('grecaptcha')) {
          print('🎯 grecaptcha disponible después de cargar script');
          timer.cancel();
        }
      });
    });
    
    script.onError.listen((_) {
      print('❌ Error cargando script de reCAPTCHA');
    });
    
    html.document.head?.append(script);
    print('📄 Script fresco agregado al head');
  }

  void _renderRecaptcha(html.DivElement container) {
    final siteKey = dotenv.env['RECAPTCHA_SITE_KEY'] ?? '';
    print('🎯 Renderizando reCAPTCHA con siteKey: $siteKey');
    
    if (siteKey.isEmpty) {
      print('❌ SITE KEY VACÍA! Verificar .env');
      _handleRecaptchaError();
      return;
    }
    
    final recaptchaDiv = html.DivElement()..id = 'recaptcha-$viewType';
    container.append(recaptchaDiv);
    print('📦 Div de reCAPTCHA creado: recaptcha-$viewType');

    // Renderizar el reCAPTCHA
    try {
      final successCallback = 'onRecaptchaSuccess_$viewType';
      final expiredCallback = 'onRecaptchaExpired_$viewType';
      final errorCallback = 'onRecaptchaError_$viewType';
      
      print('🎯 Usando callbacks: $successCallback, $expiredCallback, $errorCallback');
      
      js.context.callMethod('eval', ['''
        console.log('🔧 Intentando renderizar reCAPTCHA...');
        if (typeof grecaptcha !== 'undefined' && grecaptcha.render) {
          console.log('✅ grecaptcha disponible, renderizando...');
          console.log('🔧 Verificando callbacks...');
          console.log('Success callback exists:', typeof window['$successCallback'] === 'function');
          console.log('Expired callback exists:', typeof window['$expiredCallback'] === 'function');
          console.log('Error callback exists:', typeof window['$errorCallback'] === 'function');
          
          var widgetId = grecaptcha.render('recaptcha-$viewType', {
            'sitekey': '$siteKey',
            'callback': '$successCallback',
            'expired-callback': '$expiredCallback',
            'error-callback': '$errorCallback',
            'theme': 'light',
            'size': 'normal',
            'badge': 'bottomright',
            'isolated': false,
            'hl': 'es'
          });
          console.log('🎯 reCAPTCHA renderizado con ID:', widgetId);
        } else {
          console.error('❌ grecaptcha no disponible');
        }
      ''']);
      print('✅ Comando de renderizado ejecutado');
    } catch (e) {
      print('❌ Error ejecutando renderizado: $e');
    }

    setState(() {
      _isLoaded = true;
    });
  }

  void _handleRecaptchaSuccess(String token) async {
    if (!mounted) return;
    
    try {
      widget.controller.isLoading.value = true;
      final verified = await widget.controller.verifyToken(token);
      
      if (verified && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ reCAPTCHA verificado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onVerified?.call();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error verificando reCAPTCHA con el servidor'),
            backgroundColor: Colors.red,
          ),
        );
        widget.onError?.call();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error en reCAPTCHA: $error'),
            backgroundColor: Colors.red,
          ),
        );
        widget.onError?.call();
      }
    } finally {
      widget.controller.isLoading.value = false;
    }
  }

  void _handleRecaptchaExpired() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏰ reCAPTCHA expirado. Por favor intenta nuevamente.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _handleRecaptchaError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error al cargar reCAPTCHA. Verifica tu conexión.'),
          backgroundColor: Colors.red,
        ),
      );
      widget.onError?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HtmlElementView(viewType: viewType),
        if (!_isLoaded)
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