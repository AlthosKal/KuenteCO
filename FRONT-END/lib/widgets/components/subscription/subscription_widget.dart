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
    
    // Si es Plan Básico, mostrar confirmación de cambio
    if (type == SubscriptionType.BASIC) {
      final activePaidPlan = controller.mySubscriptions.where(
        (sub) => sub.subscriptionType != SubscriptionType.BASIC && 
                (sub.subscriptionState.name == 'ACTIVE' || sub.subscriptionState.name == 'PENDING')
      ).firstOrNull;
      
      if (activePaidPlan != null) {
        // Mostrar confirmación para downgrade
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cambiar a Plan Básico'),
            content: const Text(
              '¿Estás seguro de que quieres cambiar al Plan Básico? '
              'Perderás las funcionalidades premium de tu plan actual.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        );
        
        if (confirmed != true) return;
        
        // Aquí se implementaría la lógica para cancelar suscripción actual
        // Por ahora solo mostramos mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cambiado al Plan Básico exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Recargar suscripciones
        await controller.loadMySubscriptions();
        return;
      } else {
        // Usuario ya tiene Plan Básico
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya tienes el Plan Básico activo'),
            backgroundColor: Colors.blue,
          ),
        );
        return;
      }
    }

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
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.card_membership, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Planes de Suscripción',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                        // Mostrar suscripción actual si existe
                        if (controller.mySubscriptions.isNotEmpty) ...
                        _buildCurrentSubscriptionSection(controller),

                        const SizedBox(height: 8),

                        // Título de planes disponibles
                        Text(
                          'Planes Disponibles',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  List<Widget> _buildCurrentSubscriptionSection(SubscriptionController controller) {
    // Mostrar cualquier suscripción (ACTIVE, PENDING, etc.)
    final activeSub = controller.mySubscriptions.firstOrNull;

    if (activeSub == null) return [];

    return [
      DottedBorderCard(
        isActive: true,
        isCurrentSubscription: true,
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(
              'Próximo pago: ${_formatDate(activeSub.nextPaymentDate)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Renovación automática: ${activeSub.isAutoRenewable ? "Sí" : "No"}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (activeSub.cardLastFourDigits != null)
              Text(
                'Tarjeta: **** ${activeSub.cardLastFourDigits}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (activeSub.cardBrand != null)
              Text(
                'Tipo: ${activeSub.cardBrand}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
    ];
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  const _PlanCard({
    required this.title,
    required this.description,
    required this.price,
    required this.subscriptionType,
    required this.onSubscribe,
    required this.loading,
    this.isActive = false,
    this.isDefault = false,
  });

  String _getButtonLabel() {
    if (isActive) {
      return 'Plan Activo';
    } else {
      return 'Suscribirse';
    }
  }
  
  bool _shouldDisableButton() {
    // Solo deshabilitar si es el plan activo
    return isActive;
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
                      color: Colors.white,
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
  
  const DottedBorderCard({
    required this.child, 
    this.isActive = false,
    this.isCurrentSubscription = false,
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