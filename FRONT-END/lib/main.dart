import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:KuenteCO/routes/app_routes.dart';
import 'package:KuenteCO/routes/route_generator.dart';
import 'package:KuenteCO/core/config/is_autenticated.dart';
import 'package:KuenteCO/controllers/user_controller.dart';
import 'package:KuenteCO/core/services/app/user_service.dart';
import 'package:KuenteCO/core/services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final role = await getRoleIfAuthenticated();

  // ✅ Crear instancia de ApiClient y UserService
  final apiClient = ApiClient();
  final userService = UserService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserController(userService: userService)..loadUser(),
        ),
      ],
      child: MyApp(
        initialRoute: role == null
            ? AppRoutes.homeGuest
            : role == 'personal'
            ? AppRoutes.homePersonal
            : AppRoutes.homeBusiness,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      title: "KuenteCO",
      onGenerateRoute: RouteGenerator.generateRoute,
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
