// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../controllers/user_controller.dart';
// import '../../core/services/app/user_service.dart';
// import '../widgets/components/account/account_widget.dart';
//
// class AccountScreen extends StatelessWidget {
//   const AccountScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => UserController(userService: UserService()),
//       child: const AccountWidget(),
//     );
//   }
// }