// import 'package:flutter/material.dart';
// import '../../../routes/app_routes.dart';
//
// class Footer extends StatelessWidget {
//   const Footer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.pushNamed(context, AppRoutes.terms),
//                   child: const Text(
//                     'Términos y Condiciones',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 TextButton(
//                   onPressed: () => Navigator.pushNamed(context, AppRoutes.privacy),
//                   child: const Text(
//                     'Política de Privacidad',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 TextButton(
//                   onPressed: () => Navigator.pushNamed(context, AppRoutes.contact),
//                   child: const Text(
//                     'Contáctanos',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               '© 2025 Kuenteco. Todos los derechos reservados.',
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }