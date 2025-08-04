import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:joder/routes/app_routes.dart';
import 'package:joder/routes/route_generator.dart';
import 'core/config/is_autenticated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final role = await getRoleIfAuthenticated();

  runApp(MyApp(
    initialRoute: role == null
        ? AppRoutes.homeGuest
        : role == 'personal'
        ? AppRoutes.homePersonal
        : AppRoutes.homeBusiness,
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: RouteGenerator.generateRoute,
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
