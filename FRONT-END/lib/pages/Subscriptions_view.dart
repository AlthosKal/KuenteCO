import 'package:flutter/material.dart';
import 'package:kuenteco/widgets/Navbar_guest_widget.dart';
import 'package:kuenteco/widgets/Footer_widget.dart';
import 'package:kuenteco/widgets/Background_widget.dart';

// Colores principales
const kPrimaryPurple = Color(0xFF890cac);
const kLightPurple = Color(0xFFEDE7F6);

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
                padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 16.0),
                child: _buildHorizontalSubscriptionPlans(context),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalSubscriptionPlans(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.15; // Ancho original (30% del ancho de pantalla)

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
        children: [
          const SizedBox(width: 20),
          ...plans.map((plan) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _buildPlanCard(plan, cardWidth),
          )).toList(),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, double cardWidth) {
    return Container(
      width: cardWidth, // Usando el ancho original calculado
      height: 480,
      decoration: BoxDecoration(
        color: kLightPurple.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kPrimaryPurple.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: kPrimaryPurple.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan['title'] as String,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan['description'] as String,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white30),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (plan['features'] as List<String>).map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryPurple,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: plan['isAcquired'] as bool ? null : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Suscripción a ${plan['title']} seleccionada'),
                      backgroundColor: kPrimaryPurple,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (plan['isAcquired'] as bool)
                      ? Colors.grey
                      : kPrimaryPurple,
                  foregroundColor: (plan['isAcquired'] as bool)
                      ? Colors.black
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text(
                  plan['buttonText'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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