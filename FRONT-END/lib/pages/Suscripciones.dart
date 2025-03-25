import 'package:flutter/material.dart';
import 'package:kuenteco/widgets/navbar.dart';
import 'package:kuenteco/widgets/footer.dart';

class SuscripcionesPage extends StatefulWidget {
  final Color backgroundColor;
  final double cardHeight; // Propiedad para controlar la altura

  const SuscripcionesPage({
    super.key,
    this.backgroundColor = const Color(0xFF890cac),
    this.cardHeight = 450, // Valor predeterminado para la altura
  });

  @override
  State<SuscripcionesPage> createState() => _SuscripcionesPageState();
}

class _SuscripcionesPageState extends State<SuscripcionesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Mantener solo el degradado como fondo
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF890cac), // Morado arriba
              Colors.white,      // Blanco abajo
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Usando el navbar reutilizable
              const KuentecoNavbar(
                currentRoute: '/suscripciones',
              ),

              // Contenido de la página de suscripciones
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Suscripciones en horizontal
                      Expanded(
                        child: _buildHorizontalSubscriptionPlans(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Usando el Footer reutilizable
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildHorizontalSubscriptionPlans(BuildContext context) {
    // Definir los planes
    final plans = [
      {
        'title': 'Plan Básico',
        'description': 'Este es el plan gratuito con el que todo usuario inicia en nuestra plataforma.',
        'features': [
          'Contiene anuncios',
          'Algunas funciones poseen limitaciones y límites en la cantidad de rubros que se pueden crear(4).',
        ],
        'price': 'Gratis',
        'buttonText': 'Adquirido',
        'isAcquired': true,
      },
      {
        'title': 'Plan Estándar',
        'description': 'Este plan está diseñado para usuarios que desean mayor flexibilidad y menos restricciones en su gestión financiera.',
        'features': [
          'Sin anuncios',
          'Mayor cantidad de rubros disponibles (hasta 10)',
          'Acceso a reportes personalizados',
        ],
        'price': 'Gratis',
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
        'price': 'Gratis',
        'buttonText': 'Suscribirse',
        'isAcquired': false,
      },
    ];

    // Usar un Row envuelto en un SingleChildScrollView para permitir desplazamiento horizontal
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: plans.map((plan) => _buildPlanCard(plan, context)).toList(),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, BuildContext context) {
    // Ancho fijo para cada tarjeta
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.15; // Ancho de la pantalla

    return Container(
      width: cardWidth,
      height: widget.cardHeight, // Usar la altura configurable
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF890cac).withOpacity(0.2),
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
            // Título del plan
            Text(
              plan['title'] as String,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black12,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Descripción
            Text(
              plan['description'] as String,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            const SizedBox(height: 16),

            // Características en un Expanded para que tomen el espacio disponible
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (plan['features'] as List<String>).map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
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

            // Precio centrado arriba del botón
            Center(
              child: Text(
                plan['price'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF890cac),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Botón
            Center(
              child: ElevatedButton(
                onPressed: plan['isAcquired'] as bool ? null : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Suscripción a ${plan['title']} seleccionada'),
                      backgroundColor: const Color(0xFF890cac),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  // Cambiar color solo para el botón adquirido
                  backgroundColor: (plan['isAcquired'] as bool) ? Colors.white : const Color(0xFF890cac),
                  foregroundColor: (plan['isAcquired'] as bool) ? const Color(0xFF890cac) : Colors.white,
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