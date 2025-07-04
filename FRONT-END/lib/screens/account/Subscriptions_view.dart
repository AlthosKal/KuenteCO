import 'package:flutter/material.dart';
import 'package:kuenteco/core/constants/app_colors_constant.dart';
import '../../core/constants/subscription_constant.dart';
import '../../widgets/common/background_widget.dart';
import '../../widgets/common/footer_widget.dart';
import '../../widgets/common/navbar_guest_widget.dart';

class SubscriptionsView extends StatefulWidget {
  const SubscriptionsView({super.key});

  @override
  State<SubscriptionsView> createState() => _SubscriptionsViewState();
}

class _SubscriptionsViewState extends State<SubscriptionsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Column(
          children: [
            const KuentecoNavbar(
              currentRoute: '/suscripciones',
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSubscriptionPlans(context),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlans(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.15;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 20),
          ...SubscriptionConstants.plans.map((plan) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _buildPlanCard(plan, cardWidth),
          )),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, double cardWidth) {
    return Container(
      width: cardWidth,
      height: 480,
      decoration: BoxDecoration(
        color: AppColors.lightPurple.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.2),
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
              plan.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF890cac),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan.description,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF890cac),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF890cac)),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: plan.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: Color(0xFF890cac),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              color: Color(0xFF890cac),
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
                plan.price,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: plan.isAcquired
                    ? null
                    : () => _handleSubscriptionSelection(plan.title),
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan.isAcquired
                      ? Colors.grey
                      : AppColors.primaryPurple,
                  foregroundColor: plan.isAcquired
                      ? Colors.black
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  plan.isAcquired ? 'Adquirido' : 'Suscribirse',
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

  void _handleSubscriptionSelection(String planTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suscripción a $planTitle seleccionada'),
        backgroundColor: AppColors.primaryPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}