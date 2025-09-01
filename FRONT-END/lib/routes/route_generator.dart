import 'package:KuenteCO/screens/transactions/transaction_view.dart';
import 'package:flutter/material.dart';
import '../screens/account_view.dart';
import '../screens/auth/code_recovery_view.dart';
import '../screens/auth/login_view.dart';
import '../screens/auth/password_recovery_view.dart';
import '../screens/auth/register_view.dart';
import '../screens/auth/verification_code_email_view.dart';
import '../screens/auth/verification_register.dart';
import '../screens/budget/budget_view.dart';
import '../screens/category/category_view.dart';
import '../screens/contact/contact_logged_view.dart';
import '../screens/contact/contact_view.dart';
import '../screens/home/home_guest_view.dart';
import '../screens/home/logged_home_business_view.dart';
import '../screens/home/logged_home_personal_view.dart';
import '../screens/home/logged_home_profile_view.dart';
import '../screens/legal/privacy_logged_view.dart';
import '../screens/legal/privacy_view.dart';
import '../screens/legal/terms_logged_view.dart';
import '../screens/legal/terms_view.dart';
import '../screens/profile/profiles_view.dart';
import '../screens/suscription/subscriptions_view.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // ✅ RUTA HOME INVITADO
      case AppRoutes.homeGuest:
        return MaterialPageRoute(
          builder: (_) => const HomeGuestPage(title: 'Inicio'),
        );

    // ✅ AUTENTICACIÓN
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.recoverPassword:
        final args = settings.arguments as Map<String, dynamic>;
        final email = args['email'] as String;
        final code = args['code'] as String;
        return MaterialPageRoute(
          builder: (_) => RecoverPasswordScreen(email: email, code: code),
        );

      case AppRoutes.sendVerificationCode:
        return MaterialPageRoute(
          builder: (_) => const VerificationCodeScreen(email: ''),
        );

      case AppRoutes.validateVerificationCode:
        final email = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ValidateCodeScreen(email: email),
        );

    // ✅ HOME PERSONAL con FutureBuilder
      case AppRoutes.homePersonal:
        return MaterialPageRoute(
          builder: (_) => FutureBuilder<Widget>(
            future: LoggedHomePersonalView.create(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              return snapshot.data!;
            },
          ),
        );

    // ✅ HOME BUSINESS con FutureBuilder
      case AppRoutes.homeBusiness:
        return MaterialPageRoute(
          builder: (_) => FutureBuilder<Widget>(
            future: LoggedHomeBusinessView.create(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              return snapshot.data!;
            },
          ),
        );

      case AppRoutes.homeProfile:
        return MaterialPageRoute(
          builder: (_) => FutureBuilder<Widget>(
            future: LoggedHomeProfileView.create(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              return snapshot.data!;
            },
          ),
        );

    // ✅ SUSCRIPCIONES
      case AppRoutes.suscriptions:
        return MaterialPageRoute(builder: (_) => const SubscriptionPlansView());

    // ✅ RUTAS LOGGED
      case AppRoutes.contactLogged:
        return MaterialPageRoute(builder: (_) => const ContactLoggedView());
      case AppRoutes.termsLogged:
        return MaterialPageRoute(builder: (_) => const TermsLoggedView());
      case AppRoutes.privacyLogged:
        return MaterialPageRoute(builder: (_) => const PrivacyLoggedView());

    // ✅ RUTAS GUEST
      case AppRoutes.contact:
        return MaterialPageRoute(builder: (_) => const ContactView());
      case AppRoutes.terms:
        return MaterialPageRoute(builder: (_) => const TermsView());
      case AppRoutes.privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyView());

    // ✅ VERIFICACIÓN DE REGISTRO
      case AppRoutes.verificationRegister:
        final email = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => VerificationRegisterScreen(email: email),
        );

    // ✅ PANTALLA DE PERFILES
      case AppRoutes.profileScreen:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case AppRoutes.accountScreen:
        return MaterialPageRoute(builder: (_) => AccountScreen());
      case AppRoutes.categoryView:
        return MaterialPageRoute(builder: (_) => const CategoryView());
      case AppRoutes.budgetView:
        return MaterialPageRoute(builder: (_) => const BudgetView());
      case AppRoutes.transactionView:
        return MaterialPageRoute(builder: (_) => const TransactionView());


    // ✅ DEFAULT -> RUTA NO ENCONTRADA
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
