import 'package:KuenteCO/controllers/business_logic/budget_controller.dart';
import 'package:KuenteCO/controllers/business_logic/category_controller.dart';
import 'package:KuenteCO/controllers/business_logic/debt_controller.dart';
import 'package:KuenteCO/controllers/chat_controller.dart';
import 'package:KuenteCO/controllers/excel/excel_controller.dart';
import 'package:KuenteCO/controllers/profile_controller.dart';
import 'package:KuenteCO/controllers/subscription_controller.dart';
import 'package:KuenteCO/controllers/user_controller.dart';
import 'package:KuenteCO/core/config/is_autenticated.dart';
import 'package:KuenteCO/core/services/api_client.dart';
import 'package:KuenteCO/core/services/app/budget_service.dart';
import 'package:KuenteCO/core/services/app/category_service.dart';
import 'package:KuenteCO/core/services/app/debt_service.dart';
import 'package:KuenteCO/core/services/app/profile_service.dart';
import 'package:KuenteCO/core/services/app/subscription_service.dart';
import 'package:KuenteCO/core/services/app/user_service.dart';
import 'package:KuenteCO/core/services/chat/chat_history_service.dart' as history;
import 'package:KuenteCO/core/services/chat/chat_service.dart';
import 'package:KuenteCO/routes/app_routes.dart';
import 'package:KuenteCO/routes/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/services/chat/excel_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final String? role = await getRoleIfAuthenticated();
  final String initialRoute = _getInitialRoute(role);

  runApp(
    MultiProvider(
      providers: _createProviders(),
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

String _getInitialRoute(String? role) {
  if (role == null) return AppRoutes.homeGuest;
  
  switch (role) {
    case 'ROLE_PROFILE':
      return AppRoutes.homeProfile;
    case 'personal':
      return AppRoutes.homePersonal;
    default:
      return AppRoutes.homeBusiness;
  }
}

List<SingleChildWidget> _createProviders() {
  final ApiClient apiClient = ApiClient();
  
  return [
    ChangeNotifierProvider<UserController>(
      create: (_) => UserController(userService: UserService(apiClient))..loadUser(),
    ),
    ChangeNotifierProvider<SubscriptionController>(
      create: (_) => SubscriptionController(SubscriptionService(apiClient)),
    ),
    ChangeNotifierProvider<CategoryController>(
      create: (_) => CategoryController(CategoryService(apiClient)),
    ),
    ChangeNotifierProvider<BudgetController>(
      create: (_) => BudgetController(BudgetService(apiClient)),
    ),
    Provider<ProfileController>(
      create: (_) => ProfileController(profileService: ProfileService()),
    ),
    ChangeNotifierProvider<ChatController>(
      create: (_) => ChatController(
        ChatService(),
        history.ChatService(),
      ),
    ),
    ChangeNotifierProvider<ExcelController>(
      create: (_) => ExcelController(ExcelService(apiClient)),
    ),
    ChangeNotifierProvider<DebtController>(
      create: (_) => DebtController(DebtService(apiClient)),
    ),
  ];
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.initialRoute,
  });

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      title: 'KuenteCO',
      onGenerateRoute: RouteGenerator.generateRoute,
      builder: (BuildContext context, Widget? child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
