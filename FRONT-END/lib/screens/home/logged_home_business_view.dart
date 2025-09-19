import 'package:KuenteCO/widgets/components/transaction/transaction_card_widget.dart';
import 'package:flutter/material.dart';

import '../../core/services/app/auth_service.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/blurred_card_widget.dart';
import '../../widgets/common/footer/footer_logged_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';
import '../../widgets/components/budget/budget_card_widget.dart';
import '../../widgets/components/category/category_card_widget.dart';
import '../../widgets/components/report/report_card.dart';

class LoggedHomeBusinessView extends StatefulWidget {
  final String userName;
  final String profileImageUrl;

  const LoggedHomeBusinessView({
    super.key,
    required this.userName,
    required this.profileImageUrl,
  });

  /// â Factory que carga el usuario autenticado antes de mostrar la vista
  static Future<Widget> create() async {
    final user = await AuthService().getAuthenticatedUser();
    return LoggedHomeBusinessView(
      userName: user.username,
      profileImageUrl: user.image?.imageUrl ?? '',
    );
  }

  @override
  State<LoggedHomeBusinessView> createState() => _LoggedHomeBusinessViewState();
}

class _LoggedHomeBusinessViewState extends State<LoggedHomeBusinessView> {
  @override
  Widget build(BuildContext context) {
    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              /// â NAVBAR ARRIBA
              KuentecoLoggedNavbar(
                currentRoute: '/homeBusiness',
                onLogout: () {
                  print('Cerrando sesión...');
                },
              ),

              /// â CONTENIDO SCROLLABLE  
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ð·ï¸ HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Hola, ${widget.userName}!',
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

                      /// ð² CARD CONTENEDOR GRANDE
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

                      const SizedBox(height: 15),

                      /// â FOOTER
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

  /// ðï¸ Helper para crear cada card
  Widget _buildCardItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
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
