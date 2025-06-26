import '../../../dto/subscription_plan_dto.dart';

class SubscriptionConstants {
  static const List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      title: 'Plan Básico',
      description: 'Plan gratuito con funcionalidades básicas',
      features: [
        'Contiene anuncios',
        'Límite de 4 rubros',
      ],
      price: 'Gratis',
      isAcquired: true,
    ),
    SubscriptionPlan(
      title: 'Plan Estándar',
      description: 'Más funcionalidades y menos restricciones',
      features: [
        'Sin anuncios',
        'Hasta 10 rubros',
      ],
      price: '14.900 COP',
    ),
    SubscriptionPlan(
      title: 'Plan Premium',
      description: 'Funcionalidades avanzadas',
      features: [
        'Rubros ilimitados',
        'Soporte prioritario',
      ],
      price: '29.900 COP',
    ),
  ];
}