import 'package:flutter/material.dart';
import 'package:kuenteco/screens/home/Logged_home_view.dart';

import '../screens/auth/Login_view.dart';
import '../screens/auth/code_recovery_view.dart';
import '../screens/auth/email_recovery_view.dart';
import '../screens/auth/password_recovery_view.dart';
import '../screens/auth/register_view.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.recoverPassword:
        final email = settings.arguments as String;
        final code = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => RecoverPasswordScreen(email: email, code: code));
      case AppRoutes.sendVerificationCode:
        return MaterialPageRoute(builder: (_) => const VerificationCodeScreen());
      case AppRoutes.validateVerificationCode:
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ValidateCodeScreen(email: email));
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const LoggedInHomePage(title: title, onLogout: onLogout));
      case AppRoutes.chat:
        return MaterialPageRoute(builder: (_) => const ChatAiScreen());
      case AppRoutes.chatHistory:
        return MaterialPageRoute(builder: (_) => const ChatHistoryScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.userDetail:
        return MaterialPageRoute(builder: (_) => const UserDetailScreen());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
