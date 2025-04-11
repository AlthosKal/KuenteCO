import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Infrastructure
import 'package:kuenteco/infrastructure/datasources/remote/Auth_api_service.dart';
import 'package:kuenteco/infrastructure/repositories/Auth_repository.dart';
import 'package:kuenteco/infrastructure/repositories/Auth_repository_impl.dart';
import 'package:kuenteco/presentation/pages/account/Subscriptions_view.dart';
// Presentation
import 'package:kuenteco/presentation/pages/auth/Login_view.dart';
import 'package:kuenteco/presentation/pages/auth/Register_view.dart';
import 'package:kuenteco/presentation/pages/category/Category_view.dart';
import 'package:kuenteco/presentation/pages/contact/Contact_view.dart';
import 'package:kuenteco/presentation/pages/home/Home_guest_view.dart';
import 'package:kuenteco/presentation/pages/home/Logged_home_view.dart';
import 'package:kuenteco/presentation/pages/legal/Privacy_view.dart';
import 'package:kuenteco/presentation/pages/legal/Terms_view.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // 1. Crea las instancias necesarias
  final AuthApiService apiService = AuthApiService();
  final AuthRepository repository = AuthRepositoryImpl(apiService);
  // 2. Configura el MultiProvider
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => repository),
      ],
      child: KuentecoApp(authRepository: repository), // Pasa la instancia correctamente
    ),
  );
}

class KuentecoApp extends StatelessWidget {
  final AuthRepository authRepository;
  const KuentecoApp({
    super.key,
    required this.authRepository, // Correctamente declarado como requerido
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuenteco',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeGuestPage(title: 'Inicio'),
        // Añadimos el authRepository requerido al LoggedInHomePage
        '/home': (context) => LoggedInHomePage(
          title: 'Iniciado',
          authRepository: authRepository,
        ),
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