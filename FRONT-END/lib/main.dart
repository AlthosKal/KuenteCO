import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

// Pages
import 'package:kuenteco/pages/Login.dart';
import 'package:kuenteco/pages/Register.dart';
import 'package:kuenteco/pages/Suscripciones.dart';
import 'package:kuenteco/pages/Terminos.dart';
import 'package:kuenteco/pages/Privacidad.dart';
import 'package:kuenteco/pages/Contacto.dart';

// Widgets
import 'package:kuenteco/widgets/navbar.dart';
import 'package:kuenteco/widgets/footer.dart';
import 'package:kuenteco/widgets/background.dart';
import 'package:kuenteco/widgets/theme.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
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
      theme: AppTheme.lightTheme, // Usamos el tema definido en theme.dart
      initialRoute: '/',
      routes: _buildAppRoutes(),
    );
  }

  Map<String, WidgetBuilder> _buildAppRoutes() {
    return {
      '/': (context) => const HomePage(title: 'Kuenteco', isLoggedIn: false),
      '/login': (context) => const LoginPage(),
      '/register': (context) => const RegisterPage(),
      '/suscripciones': (context) => const SuscripcionesPage(),
      '/terminos': (context) => const TerminosPage(),
      '/privacidad': (context) => const PrivacidadPage(),
      '/contacto': (context) => const ContactoPage(),
      '/home': (context) => HomePage(title: 'Kuenteco', isLoggedIn: true),
      '/h': (context) => HomePage(title: 'Kuenteco', isLoggedIn: true),
    };
  }
}

class HomePage extends StatelessWidget {
  final String title;
  final bool isLoggedIn;

  const HomePage({super.key, required this.title, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildBody() {
    return Background( // Usamos el Background importado
      child: SafeArea(
        child: Column(
          children: [
            _buildNavbar(),
            Expanded(
              child: Center(
                child: _buildMainContent(), // Eliminamos BlurredCard
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar() {
    return KuentecoNavbar(
      currentRoute: '/',
      isLoggedIn: isLoggedIn,
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: _buildCardContent(),
    );
  }

  Widget _buildCardContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWelcomeTitle(),
        const SizedBox(height: 15),
        _buildWelcomeDescription(),
      ],
    );
  }

  Widget _buildWelcomeTitle() {
    return Text(
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
    );
  }

  Widget _buildWelcomeDescription() {
    return const Text(
      'Ofrecemos las herramientas necesarias para que tomes el control de tus finanzas personales.\n'
          'Desde la creación de presupuestos hasta el seguimiento de tus gastos e inversiones,\n'
          'nuestra plataforma está diseñada para ayudarte a alcanzar tus metas financieras de manera sencilla y efectiva.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}