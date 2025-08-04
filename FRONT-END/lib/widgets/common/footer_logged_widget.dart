import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class FooterLoggedWidget extends StatelessWidget {
  const FooterLoggedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.termsLogged,
                  ),
                  child: const Text(
                    'Términos y Condiciones',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.privacyLogged,
                  ),
                  child: const Text(
                    'Política de Privacidad',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.contactLogged,
                  ),
                  child: const Text(
                    'Contáctanos',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '© 2025 Kuenteco. Todos los derechos reservados.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}