import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/terminos'),
                  child: const Text(
                    'Términos y Condiciones',
                    style: TextStyle(color: Color(0xFF890cac)),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/privacidad'),
                  child: const Text(
                    'Política de Privacidad',
                    style: TextStyle(color: Color(0xFF890cac)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '© 2025 Kuenteco. Todos los derechos reservados.',
              style: TextStyle(color: Color(0xFF890cac)),
            ),
          ],
        ),
      ),
    );
  }
}