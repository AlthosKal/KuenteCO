import 'package:flutter/material.dart';

import '../../core/services/app/auth_service.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/footer/footer_logged_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';
import '../../widgets/components/budget/budget_card_widget.dart';
import '../../widgets/components/category/category_card_widget.dart';
import '../../widgets/components/report/report_card.dart';
import '../../widgets/components/transaction/transaction_card_widget.dart';

class LoggedHomePersonalView extends StatelessWidget {
  final String userName;
  final String profileImageUrl;

  const LoggedHomePersonalView({
    super.key,
    required this.userName,
    required this.profileImageUrl,
  });

  /// â Factory que carga el usuario autenticado antes de mostrar la vista
  static Future<Widget> create() async {
    final user = await AuthService().getAuthenticatedUser();
    return LoggedHomePersonalView(
      userName: user.username,
      profileImageUrl: user.image?.imageUrl ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              /// â NAVBAR ARRIBA
              KuentecoLoggedNavbar(
                currentRoute: '/homePersonal',
                onLogout: () {
                  print('Cerrando sesión...');
                },
              ),

              /// â CONTENIDO PRINCIPAL
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ð·ï¸ HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Hola, $userName!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bienvenido de nuevo a Kuenteco',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// ð² CARD CONTENEDOR GRANDE
                      Expanded(
                        child: BlurredCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Primera fila: 2 cards
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: const CategoryCardWidget(),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: const BudgetCardWidget(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Segunda fila: 2 cards del mismo ancho
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: const TransactionCardWidget(
                                          isHomeCard: true,
                                          showActions: false,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: const ReportCard(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// â FOOTER
                      const FooterLoggedWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ðï¸ CARD PEQUEÑO
  Widget _buildCardItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}