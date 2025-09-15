import 'package:flutter/material.dart';

import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/footer/footer_guest_widget.dart';
import '../../widgets/common/navbar/navbar_guest_widget.dart';


class HomeGuestPage extends StatelessWidget {
  final String title;

  const HomeGuestPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Column(
          children: [
            const KuentecoNavbar(
              
            ),
            Expanded(
              child: Center(
                child: _buildMainContent(context),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bienvenido a Kuenteco',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF890cac),
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Ofrecemos las herramientas necesarias para que tomes el control de tus finanzas personales.\n'
                'Desde la creación de presupuestos hasta el seguimiento de tus gastos e inversiones,\n'
                'nuestra plataforma está diseñada para ayudarte a alcanzar tus metas financieras de manera sencilla y efectiva.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF890cac),
            ),
          ),
        ],
      ),
    );
  }
}