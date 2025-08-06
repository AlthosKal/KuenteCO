import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/footer/footer_logged_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';

class SubscriptionPlansView extends StatelessWidget {
  const SubscriptionPlansView({super.key});

  @override
  Widget build(BuildContext context) {
    return Background(
      opacity: 0.3, // 👈 oscurece un poco la imagen para mejorar contraste
      child: Column(
        children: [
          /// 🔝 Navbar fijo
          KuentecoLoggedNavbar(
            currentRoute: '/subscription',
            onLogout: () => print("Cerrar sesión"),
          ),

          /// 📜 Contenido scrollable de los planes
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(
                children: [
                  const Text(
                    'Planes de Suscripción',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// 📦 Contenedores de planes con límite de ancho
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // 📱 En pantallas chicas (mobile) apila en columna
                          if (constraints.maxWidth < 800) {
                            return Column(
                              children: [
                                _PlanCard.basic(),
                                const SizedBox(height: 20),
                                _PlanCard.standard(),
                                const SizedBox(height: 20),
                                _PlanCard.premium(),
                              ],
                            );
                          }

                          // 💻 En pantallas grandes muestra en fila
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _PlanCard.basic()),
                              const SizedBox(width: 20),
                              Expanded(child: _PlanCard.standard()),
                              const SizedBox(width: 20),
                              Expanded(child: _PlanCard.premium()),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 👣 Footer fijo al final
          const FooterLoggedWidget(),
        ],
      ),
    );
  }
}

/// 🎨 Widget para los 3 planes con Blur y Transparencia
class _PlanCard extends StatelessWidget {
  final String title;
  final List<String> features;
  final String price;
  final bool isAcquired;

  const _PlanCard._({
    required this.title,
    required this.features,
    required this.price,
    this.isAcquired = false,
  });

  /// 🔵 Plan Básico
  factory _PlanCard.basic() => const _PlanCard._(
    title: 'Básico ✓',
    features: [
      'Contiene anuncios',
      'Algunas funciones están limitadas',
      'Solo puedes crear hasta 4 rubros',
      'Acceso a 3 perfiles',
    ],
    price: 'Gratis',
    isAcquired: true,
  );

  /// 🟣 Plan Estándar
  factory _PlanCard.standard() => const _PlanCard._(
    title: 'Estándar ☆',
    features: [
      'Sin anuncios',
      'Mayor cantidad de rubros disponibles hasta 10',
      'Acceso a reportes personalizados',
      'Acceso a 5 perfiles',
    ],
    price: '\$ 12.900',
  );

  /// 🏆 Plan Premium
  factory _PlanCard.premium() => const _PlanCard._(
    title: 'Premium 👜',
    features: [
      'Sin anuncios',
      'Rubros ilimitados',
      'Acceso a múltiples perfiles sin límites',
      'Soporte prioritario',
    ],
    price: '\$ 24.900',
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              for (var feature in features)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              /// Botón dinámico según plan
              ElevatedButton(
                onPressed: isAcquired ? null : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isAcquired ? Colors.grey : Colors.deepPurple,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isAcquired ? 'Adquirido' : 'Suscribirse',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
