import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../dto/subscription/request/create_subscription_request_dto.dart';
import '../controllers/suscription_controller.dart';
import '../widgets/common/primary_buttom_widget.dart';
import '../utils/enum/subscription_type_enum.dart';

class SubscriptionPlansView extends StatefulWidget {
  const SubscriptionPlansView({super.key});

  @override
  State<SubscriptionPlansView> createState() => _SubscriptionPlansViewState();
}

class _SubscriptionPlansViewState extends State<SubscriptionPlansView> {
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
    final controller = Provider.of<SubscriptionController>(context, listen: false);
    
    final response = await controller.createSubscription(
      CreateSubscriptionRequestDTO(subscriptionType: type),
    );

    if (controller.errorMessage == null && response != null && response.initPoint.isNotEmpty) {
      // Usar initPoint que es la URL de pago de MercadoPago
      final uri = Uri.parse(response.initPoint);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el enlace de pago')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage ?? 'Error al crear la suscripción'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Suscripción'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SubscriptionController>(builder: (context, controller, child) {
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
                  duration: const Duration(seconds: 4),
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
                
                const SizedBox(height: 24),
                
                // Título de planes disponibles
                Text(
                  'Planes Disponibles',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Banner informativo si estamos usando fallback
                if (controller.subscriptionPrices.isEmpty && !controller.isLoading)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      border: Border.all(color: Colors.amber.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mostrando planes predeterminados. Toca "Reintentar" para cargar desde el servidor.',
                            style: TextStyle(color: Colors.amber.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                
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
    );
  }

  List<Widget> _buildCurrentSubscriptionSection(SubscriptionController controller) {
    // Mostrar cualquier suscripción (ACTIVE, PENDING, etc.)
    final activeSub = controller.mySubscriptions.firstOrNull;
    
    if (activeSub == null) return [];

    return [
      Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Suscripción Actual',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Plan: ${_getPlanTitle(activeSub.subscriptionType)}'),
              Text('Estado: ${activeSub.subscriptionState.name}'),
              Text('Próximo pago: ${_formatDate(activeSub.nextPaymentDate)}'),
              Text('Renovación automática: ${activeSub.isAutoRenewable ? "Sí" : "No"}'),
              if (activeSub.cardLastFourDigits != null)
                Text('Tarjeta: **** ${activeSub.cardLastFourDigits}'),
              if (activeSub.cardBrand != null)
                Text('Tipo: ${activeSub.cardBrand}'),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildFallbackPlans(SubscriptionController controller) {
    // Planes hardcodeados como fallback si no se pueden cargar desde el backend
    final fallbackPlans = [
      {
        'type': SubscriptionType.BASIC,
        'title': 'Plan Básico',
        'description': 'Funcionalidades básicas',
        'price': 'Gratis'
      },
      {
        'type': SubscriptionType.STANDARD,
        'title': 'Plan Estándar',
        'description': 'Acceso completo por 1 mes',
        'price': '\$20.000 COP'
      },
      {
        'type': SubscriptionType.PREMIUM,
        'title': 'Plan Premium',
        'description': 'Acceso completo por 3 meses',
        'price': '\$50.000 COP'
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
    return controller.mySubscriptions.any(
      (sub) => sub.subscriptionType == type && sub.subscriptionState.name == 'ACTIVE',
    );
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

  const _PlanCard({
    required this.title,
    required this.description,
    required this.price,
    required this.subscriptionType,
    required this.onSubscribe,
    required this.loading,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isActive ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive 
          ? BorderSide(color: Colors.green.shade400, width: 2)
          : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ACTIVO',
                      style: TextStyle(
                        color: Colors.green.shade700,
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
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              price,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: isActive ? 'Plan Activo' : 'Suscribirse',
                isLoading: loading,
                onPressed: (loading || isActive) ? null : onSubscribe,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
