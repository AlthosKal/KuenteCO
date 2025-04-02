import 'package:flutter/material.dart';
import 'package:kuenteco/pages/Logged_home_view.dart'; // Verifica el nombre real del archivo
import 'package:kuenteco/pages/Category_view.dart';   // Verifica el nombre real del archivo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KuenteCO',
      debugShowCheckedModeBanner: false,
      initialRoute: '/loggedIn',
      routes: {
        '/InicioLog': (context) => const InicioLog(),
        '/Rubros': (context) => const RubrosView(),
      },
    );
  }
}