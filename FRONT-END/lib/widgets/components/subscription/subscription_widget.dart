import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/subscription_controller.dart';
import '../../../dto/app/subscription/request/create_subscription_request_dto.dart';
import '../../../utils/enum/subscription_type_enum.dart';
import '../../common/buttoms/primary_buttom_widget.dart';

class SubscriptionWidget extends StatefulWidget {
  const SubscriptionWidget({super.key});

  @override
  State<SubscriptionWidget> createState() => _SubscriptionWidgetState();
}

class _SubscriptionWidgetState extends State<SubscriptionWidget> {
  @override
  void initState() {
    super.initState();
    // Cargar precios al inicializar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<SubscriptionController>(context, listen: false);
      controller.loadSubscriptionPrices();
      controller.loadMySubscriptions(); // También cargar suscripciones existentes
    });
  }

  Future<void> _subscribe(SubscriptionType type) async {
    print('🎯 Intentando suscribirse al plan: ${type.name}');
    
    final controller = Provider.of<SubscriptionController>(context, listen: false);
    
    // Si es Plan Básico, no permitir el cambio si hay suscripción paga activa
    if (type == SubscriptionType.BASIC) {
      final activePaidPlan = controller.mySubscriptions.where(
        (sub) => sub.subscriptionType != SubscriptionType.BASIC && 
                (sub.subscriptionState.name == 'ACTIVE' || sub.subscriptionState.name == 'PENDING')
      ).firstOrNull;
      
      if (activePaidPlan != null) {
        // No permitir cambio a Plan Básico si hay suscripción paga
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No puedes cambiar al Plan Básico mientras tengas una suscripción activa'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Si no hay suscripción paga, ya está en Plan Básico
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya tienes el Plan Básico activo'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    // Para planes pagos, continuar con el flujo normal
    final response = await controller.createSubscription(
      CreateSubscriptionRequestDTO(subscriptionType: type, backUrl: ''),
    );

    if (controller.errorMessage == null && response != null && response.initPoint.isNotEmpty) {
      print('🚀 Abriendo URL de MercadoPago: ${response.initPoint}');

      try {
        // Usar url_launcher para todas las plataformas
        final uri = Uri.parse(response.initPoint);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw Exception('No se pudo abrir la URL de pago');
        }
        
        // Mostrar mensaje de confirmación
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Redirigiendo a MercadoPago para completar el pago...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        print('❌ Error en redirección: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al abrir el enlace de pago: $e'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Copiar URL',
                onPressed: () async {
                  // Como fallback, abrir URL de nuevo
                  try {
                    final uri = Uri.parse(response.initPoint);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    print('Error al abrir URL: $e');
                  }
                },
              ),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage ?? 'Error al crear la suscripción'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        borderRadius: 16,
        blur: 20,
        alignment: Alignment.bottomCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.2),
          ],
        ),
        child: Column(
          children: [
            // Header - Solo botón de cerrar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Consumer<SubscriptionController>(builder: (context, controller, child) {
                if (controller.isLoading && controller.subscriptionPrices.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Mostrar mensaje de error si existe, pero no bloquear la UI
                if (controller.errorMessage != null) {
                  // Solo mostrar un SnackBar o un banner, no bloquear toda la pantalla
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(controller.errorMessage ?? 'Error desconocido'),
                          action: SnackBarAction(
                            label: 'Reintentar',
                            onPressed: () {
                              controller.loadSubscriptionPrices();
                              controller.loadMySubscriptions();
                            },
                          ),
                        ),
                      );
                    }
                  });
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.loadSubscriptionPrices();
                    await controller.loadMySubscriptions();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título de planes disponibles
                        Text(
                          'Planes Disponibles',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Lista de planes
                        if (controller.subscriptionPrices.isEmpty)
                          _buildFallbackPlans(controller)
                        else
                          ...controller.subscriptionPrices.map((price) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _PlanCard(
                              title: _getPlanTitle(price.type),
                              description: price.description,
                              price: '${price.monthlyPrice} ${price.currencyId}',
                              subscriptionType: price.type,
                              loading: controller.isLoading,
                              onSubscribe: () => _subscribe(price.type),
                              isActive: _isCurrentlySubscribed(controller, price.type),
                              subscriptionInfo: _isCurrentlySubscribed(controller, price.type) ? _getSubscriptionInfo(controller) : null,
                            ),
                          )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFallbackPlans(SubscriptionController controller) {
    final fallbackPlans = [
      {
        'type': SubscriptionType.BASIC,
        'title': 'Plan Básico',
        'description': '• Contiene anuncios\n• Algunas funciones están limitadas\n• Solo puedes crear hasta 4 rubros\n• Acceso a 3 perfiles',
        'price': 'Gratis',
        'isDefault': true, // Plan por defecto
      },
      {
        'type': SubscriptionType.STANDARD,
        'title': 'Plan Estándar',
        'description': '• Sin anuncios\n• Mayor cantidad de rubros disponibles hasta 10\n• Acceso a reportes personalizados\n• Acceso a 5 perfiles',
        'price': '\$12.900 COP /mes',
        'isDefault': false,
      },
      {
        'type': SubscriptionType.PREMIUM,
        'title': 'Plan Premium',
        'description': '• Sin anuncios\n• Rubros ilimitados\n• Acceso a múltiples perfiles sin límites\n• Soporte prioritario',
        'price': '\$24.900 COP /mes',
        'isDefault': false,
      },
    ];

    return Column(
      children: fallbackPlans.map((plan) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _PlanCard(
          title: plan['title'] as String,
          description: plan['description'] as String,
          price: plan['price'] as String,
          subscriptionType: plan['type'] as SubscriptionType,
          loading: controller.isLoading,
          onSubscribe: () => _subscribe(plan['type'] as SubscriptionType),
          isActive: _isCurrentlySubscribed(controller, plan['type'] as SubscriptionType),
          isDefault: plan['isDefault'] == true,
          isDisabled: _isPlanDisabled(controller, plan['type'] as SubscriptionType),
          subscriptionInfo: _isCurrentlySubscribed(controller, plan['type'] as SubscriptionType) ? _getSubscriptionInfo(controller) : null,
        ),
      )).toList(),
    );
  }

  String _getPlanTitle(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.BASIC:
        return 'Plan Básico';
      case SubscriptionType.STANDARD:
        return 'Plan Estándar';
      case SubscriptionType.PREMIUM:
        return 'Plan Premium';
    }
  }

  bool _isCurrentlySubscribed(SubscriptionController controller, SubscriptionType type) {
    // Primero verificar si hay una suscripción paga activa o pendiente
    final activePaidSubscription = controller.mySubscriptions.where(
      (sub) => sub.subscriptionType != SubscriptionType.BASIC && 
              (sub.subscriptionState.name == 'ACTIVE' || sub.subscriptionState.name == 'PENDING')
    ).firstOrNull;
    
    // Si hay una suscripción paga activa, solo ese plan está activo
    if (activePaidSubscription != null) {
      return activePaidSubscription.subscriptionType == type;
    }
    
    // Si no hay suscripción paga activa, solo el Plan Básico está activo
    return type == SubscriptionType.BASIC;
  }

  bool _isPlanDisabled(SubscriptionController controller, SubscriptionType type) {
    // Deshabilitar Plan Básico si hay suscripción paga activa
    if (type == SubscriptionType.BASIC) {
      final activePaidPlan = controller.mySubscriptions.where(
        (sub) => sub.subscriptionType != SubscriptionType.BASIC && 
                (sub.subscriptionState.name == 'ACTIVE' || sub.subscriptionState.name == 'PENDING')
      ).firstOrNull;
      
      return activePaidPlan != null;
    }
    
    // Los planes pagos nunca se deshabilitan
    return false;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String? _getSubscriptionInfo(SubscriptionController controller) {
    final activeSub = controller.mySubscriptions.firstOrNull;
    if (activeSub == null) return null;
    
    List<String> info = [];
    info.add('Próximo pago: ${_formatDate(activeSub.nextPaymentDate)}');
    info.add('Renovación automática: ${activeSub.isAutoRenewable ? "Sí" : "No"}');
    
    if (activeSub.cardLastFourDigits != null) {
      info.add('Tarjeta: **** ${activeSub.cardLastFourDigits}');
    }
    
    if (activeSub.cardBrand != null) {
      info.add('Tipo: ${activeSub.cardBrand}');
    }
    
    return info.join('\n');
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final SubscriptionType subscriptionType;
  final VoidCallback onSubscribe;
  final bool loading;
  final bool isActive;
  final bool isDefault;
  final bool isDisabled;
  final String? subscriptionInfo;

  const _PlanCard({
    required this.title,
    required this.description,
    required this.price,
    required this.subscriptionType,
    required this.onSubscribe,
    required this.loading,
    this.isActive = false,
    this.isDefault = false,
    this.isDisabled = false,
    this.subscriptionInfo,
  });

  String _getButtonLabel() {
    if (isActive) {
      return 'Plan Activo';
    } else if (isDisabled) {
      return 'No disponible';
    } else {
      return 'Suscribirse';
    }
  }
  
  bool _shouldDisableButton() {
    // Deshabilitar si es el plan activo o está explícitamente deshabilitado
    return isActive || isDisabled;
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorderCard(
      isActive: isActive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ACTIVO',
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            if (subscriptionInfo != null) ...[
              const SizedBox(height: 16),
              Text(
                subscriptionInfo!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.purple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              price,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: _getButtonLabel(),
                isLoading: loading,
                onPressed: loading ? null : (_shouldDisableButton() ? null : onSubscribe),
              ),
            ),
          ],
        ),
    );
  }
}

class DottedBorderCard extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final bool isCurrentSubscription;
  final bool isDisabled;
  
  const DottedBorderCard({
    required this.child, 
    this.isActive = false,
    this.isCurrentSubscription = false,
    this.isDisabled = false,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    if (isCurrentSubscription) {
      borderColor = Colors.white;
    } else if (isActive) {
      borderColor = Colors.purple.shade400;
    } else {
      borderColor = Colors.grey;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: (isActive || isCurrentSubscription) ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(16),
        color: (isActive || isCurrentSubscription) ? Colors.purple.shade50.withOpacity(0.3) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}