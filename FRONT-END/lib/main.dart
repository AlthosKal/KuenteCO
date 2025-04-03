import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

// Pages
import 'package:kuenteco/pages/Login_view.dart';
import 'package:kuenteco/pages/Register_view.dart';
import 'package:kuenteco/pages/Subscriptions_view.dart';
import 'package:kuenteco/pages/Terms_view.dart';
import 'package:kuenteco/pages/Privacy_view.dart';
import 'package:kuenteco/pages/Contact_view.dart';
import 'package:kuenteco/pages/Category_view.dart';

// Widgets
import 'package:kuenteco/widgets/Navbar_guest_widget.dart';
import 'package:kuenteco/widgets/Footer_widget.dart';
import 'package:kuenteco/widgets/Background_widget.dart';
import 'package:kuenteco/widgets/Theme_widget.dart';

void main() async {
  await _initializeApp();
  runApp(const KuentecoApp());
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
}

class KuentecoApp extends StatelessWidget {
  const KuentecoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuenteco',
      initialRoute: '/',
      routes: _appRoutes,
    );
  }

  Map<String, WidgetBuilder> get _appRoutes => {
    '/': (context) => const HomePage(title: 'Kuenteco', isLoggedIn: false),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/suscripciones': (context) => const SuscripcionesPage(),
    '/terminos': (context) => const TerminosPage(),
    '/privacidad': (context) => const PrivacidadPage(),
    '/contacto': (context) => const ContactoPage(),
    '/home': (context) => const HomePage(title: 'Kuenteco', isLoggedIn: true),
    '/h': (context) => const HomePage(title: 'Kuenteco', isLoggedIn: true),
    '/rubros': (context) => const RubrosView(),
  };
}

class HomePage extends StatelessWidget {
  final String title;
  final bool isLoggedIn;

  const HomePage({super.key, required this.title, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Column(
          children: [
            KuentecoNavbar(
              currentRoute: '/',
              isLoggedIn: isLoggedIn,
            ),
            Expanded(
              child: Center(
                child: _buildMainContent(context),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFFEDE7F6).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bienvenido a Kuenteco',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
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
          Text(
            'Ofrecemos las herramientas necesarias para que tomes el control de tus finanzas personales.\n'
                'Desde la creación de presupuestos hasta el seguimiento de tus gastos e inversiones,\n'
                'nuestra plataforma está diseñada para ayudarte a alcanzar tus metas financieras de manera sencilla y efectiva.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}