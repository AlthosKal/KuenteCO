import 'package:flutter/material.dart';
import 'package:kuenteco/widgets/Navbar_guest_widget.dart';
import 'package:kuenteco/widgets/Footer_widget.dart';
import 'package:kuenteco/widgets/Background_widget.dart';

class SuscripcionesPage extends StatefulWidget {
  final bool isLoggedIn;

  const SuscripcionesPage({
    super.key,
    this.isLoggedIn = false,
  });

  @override
  State<SuscripcionesPage> createState() => _SuscripcionesPageState();
}

class _SuscripcionesPageState extends State<SuscripcionesPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Background(
        child: Column(
          children: [
            KuentecoNavbar(
              currentRoute: '/suscripciones',
              isLoggedIn: widget.isLoggedIn,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildHorizontalSubscriptionPlans(context),
                    ),
                  ],
                ),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalSubscriptionPlans(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final plans = [
      {
        'title': 'Plan Básico',
        'description': 'Este es el plan gratuito con el que todo usuario inicia en nuestra plataforma.',
        'features': [
          'Contiene anuncios',
          'Algunas funciones poseen limitaciones y límites en la cantidad de rubros que se pueden crear(4).',
        ],
        'price': 'Gratis',
        'buttonText': 'Suscribirse',
        'isAcquired': false,
      },
      {
        'title': 'Plan Estándar',
        'description': 'Este plan está diseñado para usuarios que desean mayor flexibilidad y menos restricciones en su gestión financiera.',
        'features': [
          'Sin anuncios',
          'Mayor cantidad de rubros disponibles (hasta 10)',
          'Acceso a reportes personalizados',
        ],
        'price': '14.900 COP',
        'buttonText': 'Suscribirse',
        'isAcquired': false,
      },
      {
        'title': 'Plan Premium',
        'description': 'Ideal para empresas y emprendedores que requieren herramientas avanzadas para la administración financiera.',
        'features': [
          'Sin anuncios',
          'Rubros ilimitados',
          'Acceso a múltiples usuarios con permisos personalizados',
          'Soporte prioritario',
        ],
        'price': '29.900 COP',
        'buttonText': 'Suscribirse',
        'isAcquired': false,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: plans.map((plan) => _buildPlanCard(plan, context)).toList(),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.15;

    return Container(
      width: cardWidth,
      height: 450,
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.surface.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan['title'] as String,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan['description'] as String,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (plan['features'] as List<String>).map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                plan['price'] as String,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: plan['isAcquired'] as bool ? null : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Suscripción a ${plan['title']} seleccionada'),
                      backgroundColor: colorScheme.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (plan['isAcquired'] as bool)
                      ? colorScheme.surface
                      : colorScheme.primary,
                  foregroundColor: (plan['isAcquired'] as bool)
                      ? colorScheme.primary
                      : colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  plan['buttonText'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}