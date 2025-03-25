import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'pages/Login.dart';
import 'package:kuenteco/pages/Register.dart';
import 'package:kuenteco/pages/Suscripciones.dart';
import 'package:kuenteco/pages/Terminos.dart';
import 'package:kuenteco/pages/Privacidad.dart';
import 'package:kuenteco/pages/Contacto.dart';
import 'package:kuenteco/widgets/navbar.dart';
import 'package:kuenteco/widgets/footer.dart';

Future <void> main() async {
  await dotenv.load(fileName: ".env"); // Cargar las variables de entorno
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MyApp());
  }, (error, stackTrace) {
    print('Error no controlado: $error\nStack trace: $stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuenteco',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Color(0xFF890cac),
          secondary: Color(0xFFba68c8),
          surface: Colors.white,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
      ),
      routes: {
        '/': (context) => const HomePage(title: 'Kuenteco'),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/suscripciones': (context) => const SuscripcionesPage(),
        '/terminos': (context) => const TerminosPage(),
        '/privacidad': (context) => const PrivacidadPage(),
        '/contacto': (context) => const ContactoPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF890cac), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const KuentecoNavbar(currentRoute: '/'), // Usa el Navbar importado
              Expanded(
                child: Center(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF890cac).withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Bienvenido a Kuenteco',
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Ofrecemos las herramientas necesarias para que tomes el control de tus finanzas personales.\n Desde la creación de presupuestos hasta el seguimiento de tus gastos e inversiones,\n nuestra plataforma está diseñada para ayudarte a alcanzar tus metas financieras de manera sencilla y efectiva.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Footer(), // Usa el nuevo widget Footer
    );
  }
}