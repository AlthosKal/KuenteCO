import 'package:flutter/material.dart';
import 'package:kuenteco/core/constants/App_colors.dart';

class SubscriptionConstants {
  // Textos estáticos
  static const String basicPlanTitle = 'Plan Básico';
  static const String standardPlanTitle = 'Plan Estándar';
  static const String premiumPlanTitle = 'Plan Premium';

  static const String basicPlanPrice = 'Gratis';
  static const String standardPlanPrice = '14.900 COP/mes';
  static const String premiumPlanPrice = '29.900 COP/mes';

  // Características como listas separadas
  static const List<String> basicPlanFeatures = [
    'Límite de 4 rubros',
    'Contiene anuncios',
  ];

  static const List<String> standardPlanFeatures = [
    'Hasta 10 rubros',
    'Sin anuncios',
  ];

  static const List<String> premiumPlanFeatures = [
    'Rubros ilimitados',
    'Soporte prioritario',
  ];

  // Método para obtener los planes (no puede ser const por los colores)
  static List<Map<String, dynamic>> getSubscriptionPlans() {
    return [
      {
        'title': basicPlanTitle,
        'price': basicPlanPrice,
        'features': basicPlanFeatures,
        'color': AppColors.primaryPurple.withOpacity(0.2),
      },
      {
        'title': standardPlanTitle,
        'price': standardPlanPrice,
        'features': standardPlanFeatures,
        'color': AppColors.primaryPurple.withOpacity(0.4),
      },
      {
        'title': premiumPlanTitle,
        'price': premiumPlanPrice,
        'features': premiumPlanFeatures,
        'color': AppColors.primaryPurple.withOpacity(0.6),
      },
    ];
  }

  // Estilos
  static const TextStyle planTitleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white, // Cambiado a Colors.white directamente
  );

  static ButtonStyle subscribeButtonStyle(bool isActive) {
    return ElevatedButton.styleFrom(
      backgroundColor: isActive ? AppColors.primaryPurple : Colors.grey,
      foregroundColor: Colors.white, // Cambiado a Colors.white
    );
  }
}