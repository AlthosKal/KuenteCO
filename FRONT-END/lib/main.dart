import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kuenteco/presentation/pages/home/Home_guest_view.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

// Infrastructure
import 'package:kuenteco/infrastructure/datasources/remote/Auth_api_service.dart';
import 'package:kuenteco/infrastructure/repositories/Auth_repository.dart';
import 'package:kuenteco/infrastructure/repositories/Auth_repository_impl.dart';

// Presentation
import 'package:kuenteco/presentation/pages/auth/Login_view.dart';
import 'package:kuenteco/presentation/pages/auth/Register_view.dart';
import 'package:kuenteco/presentation/pages/account/Subscriptions_view.dart';
import 'package:kuenteco/presentation/pages/legal/Terms_view.dart';
import 'package:kuenteco/presentation/pages/legal/Privacy_view.dart';
import 'package:kuenteco/presentation/pages/contact/Contact_view.dart';
import 'package:kuenteco/presentation/pages/category/Category_view.dart';
import 'package:kuenteco/presentation/pages/home/Logged_home_view.dart';

void main() async {
  Future<void> _initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
  }
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final authApiService = AuthApiService();
  final authRepository = AuthRepositoryImpl(authApiService);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => authRepository),
      ],
      child: const KuentecoApp(),
    ),
  );
}

class KuentecoApp extends StatelessWidget {
  const KuentecoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuenteco',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeGuestPage(title: 'Inicio'),
        'home': (context) => const LoggedInHomePage(title: 'Iniciado'),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterPage(),
        '/suscripciones': (context) => const SubscriptionsView(),
        '/terminos': (context) => const TerminosPage(),
        '/privacidad': (context) => const PrivacyPage(),
        '/contacto': (context) => const ContactPage(),
        '/rubros': (context) => const CategoryPage(),
      },
    );
  }
}
